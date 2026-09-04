#!/usr/bin/env python3
"""Fail if any handoff item in the evidence file is missing from the report."""
import re
import sys


def links(text):
    return {u.split("?")[0].rstrip("/") for u in re.findall(r"\((http[^)\s]+)", text)}


def main(evidence_path, report_path):
    evidence = open(evidence_path).read()
    report = open(report_path).read()
    if "## To hand off" not in evidence:
        print(f"no '## To hand off' section in {evidence_path}")
        return 1

    covered = links(report)
    missing = []
    for line in evidence.split("## To hand off", 1)[1].splitlines():
        if not line.startswith("- **"):
            continue
        item = links(line)
        if item and not (item & covered):
            missing.append(line.strip())

    if missing:
        print(f"{len(missing)} handoff items missing from {report_path}:")
        for line in missing:
            print(f"  {line[:140]}")
        return 1
    print("all handoff items covered")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("usage: check_coverage.py <evidence.md> <report.md>")
    sys.exit(main(sys.argv[1], sys.argv[2]))
