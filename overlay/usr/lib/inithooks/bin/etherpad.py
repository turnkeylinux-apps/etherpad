#!/usr/bin/python3
"""Set Etherpad admin password

Option:
    --pass=     unless provided, will ask interactively

"""

import subprocess
import sys
import getopt
import string
import bcrypt

from dialog_wrapper import Dialog

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
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

    hash_pass = bcrypt.hashpw(password.encode('utf-8'),
                              bcrypt.gensalt(rounds=10, prefix=b"2a")
                             ).decode('utf-8')

    subprocess.run(["sed", "-i",
                    f'/\"admin\":/,+1 s|\\(\"hash\":\\).*|\\1 \"{hash_pass}\",|',
                    "/opt/etherpad-lite/settings.json"])

if __name__ == "__main__":
    main()
