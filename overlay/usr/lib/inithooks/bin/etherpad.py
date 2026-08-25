#!/usr/bin/python3
"""Set Etherpad admin password

Option:
    --pass=     unless provided, will ask interactively

"""

import subprocess
import sys
import getopt
import json
import re
from pathlib import Path

from libinithooks.dialog_wrapper import Dialog


def usage(s=None):
    if s:
        print(f"Error: {s}", file=sys.stderr)
    print(f"Syntax: {sys.argv[0]} [options]", file=sys.stderr)
    print(__doc__, file=sys.stderr)
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass='])
    except getopt.GetoptError as e:
        usage(e)

    password = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val

    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "Etherpad Password",
            "Enter new password for the Etherpad 'admin' account.")

    path = Path("/etc/etherpad/settings.json")
    settings = path.read_text()
    encoded = json.dumps(password)
    pattern = (r'("users"\s*:\s*\{.*?"admin"\s*:\s*\{.*?'
               r'"password"\s*:\s*)"(?:[^"\\]|\\.)*"')
    settings, count = re.subn(pattern,
                              lambda match: match.group(1) + encoded,
                              settings, count=1, flags=re.DOTALL)
    if count != 1:
        raise SystemExit("Etherpad administrator password setting is missing")
    path.write_text(settings)
    subprocess.run(["systemctl", "restart", "etherpad.service"], check=True)

if __name__ == "__main__":
    main()
