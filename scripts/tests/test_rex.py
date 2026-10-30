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
if args == ['--autostart=false', 'server', 'status', '--json']:
    states = os.environ.get('REX_TEST_STATES', 'ready' if os.environ.get('REX_TEST_READY') == '1' else 'needs_login').split(',')
    from pathlib import Path
    counter = Path(os.environ['REX_TEST_LOG'] + '.status-count')
    index = int(counter.read_text()) if counter.exists() else 0
    counter.write_text(str(index + 1))
    state = states[min(index, len(states) - 1)]
    print(json.dumps({'tailscale': {'state': 'running' if state == 'ready' else state,
                                   'https': {'state': 'available' if state == 'ready' else 'pending'}}}))
if args == ['--autostart=false', 'server', 'tailscale', 'pair', '--json']:
    sys.exit(0 if os.environ.get('REX_TEST_READY') == '1' else 1)
if args == ['--autostart=false', 'server', 'tailscale', 'login']:
    print('https://login.example.invalid/synthetic')
    sys.exit(int(os.environ.get('REX_TEST_LOGIN_EXIT', '0')))
if args == ['--autostart=false', 'server', 'tailscale', 'pair']:
    sys.exit(0 if os.environ.get('REX_TEST_READY') == '1' else 1)
''')
        mock.chmod(0o755)
        sudo = self.root / 'sudo'
        sudo.write_text(f'#!{sys.executable}\n' + '''import json, os, sys
with open(os.environ['REX_TEST_LOG'] + '.sudo', 'a') as log:
    log.write(json.dumps(sys.argv[1:]) + '\\n')
sys.exit(int(os.environ.get('REX_TEST_SUDO_EXIT', '0')))
''')
        sudo.chmod(0o755)
        sleep = self.root / 'sleep'
        sleep.write_text('#!/bin/sh\nexit 0\n')
        sleep.chmod(0o755)
        self.env = dict(os.environ, PATH=str(self.root) + os.pathsep + os.environ['PATH'],
                        REX_TEST_LOG=str(self.log), REX_SERVER='https://wrong.invalid',
                        REX_PACKAGE_TOKEN='synthetic-secret', REX_TEST_READY='1',
                        REX_CONNECT_TIMEOUT_SECONDS='0')

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

    def test_grants_raw_socket_capability_to_rex(self):
        result = self.run_script('start-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        sudo_calls = [json.loads(line) for line in
                      Path(str(self.log) + '.sudo').read_text().splitlines()]
        self.assertEqual(sudo_calls, [['-n', 'setcap', 'cap_net_raw=ep',
                                       str((self.root / 'rex').resolve())]])

    def test_capability_failure_still_starts_rex(self):
        self.env['REX_TEST_SUDO_EXIT'] = '1'
        result = self.run_script('start-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('cap_net_raw', result.stderr)
        self.assertEqual(self.calls()[0][:2], ['server', 'start'])

    def test_requests_login_when_pairing_is_not_ready(self):
        self.env['REX_TEST_READY'] = '0'
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn(['--autostart=false', 'server', 'tailscale', 'login'], self.calls())
        self.assertIn('https://login.example.invalid/synthetic', result.stdout)
        self.assertIn('rerun this script', result.stderr)

    def test_ready_node_does_not_request_another_login(self):
        self.env['REX_TEST_READY'] = '1'
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(['--autostart=false', 'server', 'tailscale', 'login'], self.calls())
        self.assertIn('Add Remote Host', result.stdout)

    def test_login_failure_is_reported(self):
        self.env['REX_TEST_READY'] = '0'
        self.env['REX_TEST_LOGIN_EXIT'] = '7'
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 7)
        self.assertNotIn('Add Remote Host', result.stdout)

    def test_waits_for_https_without_requesting_another_login(self):
        self.env.update(REX_TEST_STATES='running,running,ready', REX_CONNECT_TIMEOUT_SECONDS='60')
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Add Remote Host', result.stdout)
        self.assertNotIn(['--autostart=false', 'server', 'tailscale', 'login'], self.calls())

    def test_https_timeout_does_not_suggest_signing_in(self):
        self.env['REX_TEST_STATES'] = 'running'
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 1)
        self.assertIn('MagicDNS and HTTPS', result.stderr)
        self.assertNotIn('Sign-in is still pending', result.stderr)
        self.assertNotIn(['--autostart=false', 'server', 'tailscale', 'login'], self.calls())

    def test_reports_each_state_change_once(self):
        self.env.update(REX_TEST_STATES='needs_login,needs_login,running,ready',
                        REX_CONNECT_TIMEOUT_SECONDS='60')
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count('Tailscale state: needs_login'), 1)
        self.assertIn('Tailscale state: https_pending', result.stdout)
        self.assertIn('Tailscale state: ready', result.stdout)

    def test_waits_for_login_and_requests_it_only_once(self):
        self.env.update(REX_TEST_STATES='needs_login,needs_login,ready', REX_CONNECT_TIMEOUT_SECONDS='60')
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls().count(['--autostart=false', 'server', 'tailscale', 'login']), 1)

    def test_starting_node_does_not_request_login(self):
        self.env.update(REX_TEST_STATES='starting,starting,ready', REX_CONNECT_TIMEOUT_SECONDS='60')
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(['--autostart=false', 'server', 'tailscale', 'login'], self.calls())

    def test_new_node_requests_login_once_it_needs_login(self):
        self.env.update(REX_TEST_STATES='starting,needs_login,needs_login,ready',
                        REX_CONNECT_TIMEOUT_SECONDS='60')
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls().count(['--autostart=false', 'server', 'tailscale', 'login']), 1)

    def test_starting_timeout_points_at_connectivity(self):
        self.env['REX_TEST_STATES'] = 'starting'
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 1)
        self.assertIn('coordination server', result.stderr)

    def test_machine_approval_has_a_specific_error(self):
        self.env['REX_TEST_STATES'] = 'needs_machine_approval'
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 1)
        self.assertIn('administrator must approve', result.stderr)

    def test_boot_hook_enables_tailscale_with_owner_scoped_name(self):
        self.env.update(CODER_WORKSPACE_NAME='payments-dev', CODER_WORKSPACE_OWNER_NAME='alex')
        result = self.run_script('start-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        start = self.calls()[0]
        self.assertIn('--tailscale', start)
        self.assertEqual(start[start.index('--tailscale-hostname') + 1], 'payments-dev-alex-rex')

    def test_host_name_comes_from_coder_workspace(self):
        self.env.update(CODER_WORKSPACE_NAME='payments-dev', CODER_WORKSPACE_OWNER_NAME='alex')
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        start = self.calls()[0]
        self.assertEqual(start[start.index('--tailscale-hostname') + 1], 'payments-dev-alex-rex')
        self.assertIn(['--autostart=false', 'server', 'tailscale', 'on',
                       '--hostname', 'payments-dev-alex-rex'], self.calls())
        self.assertIn(['--autostart=false', 'server', 'tailscale', 'rename',
                       'payments-dev-alex-rex'], self.calls())

    def test_explicit_host_name_overrides_workspace(self):
        self.env['CODER_WORKSPACE_NAME'] = 'payments-dev'
        result = self.run_script('connect-rex.sh', 'custom-rex')
        self.assertEqual(result.returncode, 0, result.stderr)
        start = self.calls()[0]
        self.assertEqual(start[start.index('--tailscale-hostname') + 1], 'custom-rex')

    def test_host_name_falls_back_to_machine_name(self):
        self.env.pop('CODER_WORKSPACE_NAME', None)
        self.env.pop('CODER_WORKSPACE_OWNER_NAME', None)
        result = self.run_script('connect-rex.sh')
        self.assertEqual(result.returncode, 0, result.stderr)
        machine = subprocess.check_output(['hostname', '-s'], text=True).strip()
        start = self.calls()[0]
        self.assertEqual(start[start.index('--tailscale-hostname') + 1], machine + '-rex')

if __name__ == '__main__':
    unittest.main()
