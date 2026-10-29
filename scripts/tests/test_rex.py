import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parents[1]


class RexStartupTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.log = self.root / 'calls.jsonl'
        mock = self.root / 'rex'
        mock.write_text(f'#!{sys.executable}\n' + '''import json
import os
import sys

args = sys.argv[1:]
with open(os.environ['REX_TEST_LOG'], 'a') as log:
    log.write(json.dumps(args) + '\\n')
if args == ['--autostart=false', 'server', 'tailscale', 'pair', '--json']:
    sys.exit(0 if os.environ.get('REX_TEST_READY') == '1' else 1)
if args == ['--autostart=false', 'server', 'tailscale', 'login']:
    print('https://login.example.invalid/synthetic')
    sys.exit(int(os.environ.get('REX_TEST_LOGIN_EXIT', '0')))
if args == ['--autostart=false', 'server', 'tailscale', 'pair']:
    sys.exit(0 if os.environ.get('REX_TEST_READY') == '1' else 1)
''')
        mock.chmod(0o755)
        self.env = dict(os.environ, PATH=str(self.root) + os.pathsep + os.environ['PATH'],
                        REX_TEST_LOG=str(self.log), REX_SERVER='https://wrong.invalid',
                        REX_PACKAGE_TOKEN='synthetic-secret')

    def run_script(self, name, *args):
        return subprocess.run(['bash', str(SCRIPTS / name), *args], env=self.env,
                              capture_output=True, text=True)

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()]

    def test_forwards_exported_variables_without_a_name_whitelist(self):
        self.env.update(CODER_WORKSPACE_NAME='synthetic-box',
                        CUSTOM_WORKSPACE_SETTING='synthetic value\nwith spaces',
                        GIT_CONFIG_COUNT='0')
        result = self.run_script('start-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        start = self.calls()[0]
        forwarded = [start[i + 1] for i, arg in enumerate(start) if arg == '--env']
        for name in ['CODER_WORKSPACE_NAME', 'CUSTOM_WORKSPACE_SETTING', 'GIT_CONFIG_COUNT']:
            self.assertIn(name, forwarded)
            self.assertNotIn(self.env[name], start)
        self.assertFalse(any(name.startswith('REX_') for name in forwarded))
        self.assertNotIn('synthetic-secret', self.log.read_text() + result.stdout + result.stderr)

    def test_requests_login_when_pairing_is_not_ready(self):
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(['--autostart=false', 'server', 'tailscale', 'login'], self.calls())
        self.assertIn('https://login.example.invalid/synthetic', result.stdout)
        self.assertIn('rerun this script', result.stdout)

    def test_ready_node_does_not_request_another_login(self):
        self.env['REX_TEST_READY'] = '1'
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(['--autostart=false', 'server', 'tailscale', 'login'], self.calls())
        self.assertIn('Add Remote Host', result.stdout)

    def test_login_failure_is_reported(self):
        self.env['REX_TEST_LOGIN_EXIT'] = '7'
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 7)
        self.assertNotIn('Add Remote Host', result.stdout)

    def test_host_name_comes_from_coder_workspace(self):
        self.env['CODER_WORKSPACE_NAME'] = 'payments-dev'
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        start = self.calls()[0]
        self.assertEqual(start[start.index('--tailscale-hostname') + 1], 'payments-dev-rex')
        self.assertIn(['--autostart=false', 'server', 'tailscale', 'on',
                       '--hostname', 'payments-dev-rex'], self.calls())
        self.assertIn(['--autostart=false', 'server', 'tailscale', 'rename',
                       'payments-dev-rex'], self.calls())

    def test_explicit_host_name_overrides_workspace(self):
        self.env['CODER_WORKSPACE_NAME'] = 'payments-dev'
        result = self.run_script('connect-rex.sh', 'custom-rex')
        self.assertEqual(result.returncode, 0, result.stderr)
        start = self.calls()[0]
        self.assertEqual(start[start.index('--tailscale-hostname') + 1], 'custom-rex')

    def test_host_name_falls_back_to_machine_name(self):
        self.env.pop('CODER_WORKSPACE_NAME', None)
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        machine = subprocess.check_output(['hostname', '-s'], text=True).strip()
        start = self.calls()[0]
        self.assertEqual(start[start.index('--tailscale-hostname') + 1], machine + '-rex')


if __name__ == '__main__':
    unittest.main()
