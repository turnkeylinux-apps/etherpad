#!/usr/bin/python
"""Set Etherpad admin password

Option:
    --pass=     unless provided, will ask interactively

"""

import sys
import getopt
import string

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
    except getopt.GetoptError, e:
        usage(e)

    password = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val
        elif opt == '--email':
            email = val

    if not password:
        d = Dialog('TurnKey Linux - First boot configuration')
        password = d.get_password(
            "Etherpad Password",
            "Enter new password for the Etherpad 'admin' account.")

    system("sed -i '/admin/,+1 s|\\(\"password":\\).*|\\1 \"%s\"|' /opt/etherpad-lite/settings.json" % password)

if __name__ == "__main__":
    main()

