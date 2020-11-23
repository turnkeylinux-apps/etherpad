Etherpad Lite - Real-time document collaboration
================================================

`Etherpad Lite`_ is a real-time collaborative editor, sort of like a
web-based multiplayer Notepad that allows groups of users to
simultaneously edit a text document, with the ability to display each
author's text in their own color. There is also a chat box in the
sidebar to allow meta communication.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- EtherPad Lite configurations:
   
   - Latest upstream version installed via git repository to
     /opt/etherpad-lite
   - Pre-configured to use MySQL/MariaDB (recommended for production).

- Node.js configurations:
   
   - Includes NodeJS 14 and various other Node tools (n, npm, etc).
   - The nginx web server is pre-configured to proxy to nodejs daemon,
     with SSL support out of the box.
   - Includes custom nodejs initscript for running node app as daemon.

- SSL support out of the box
- Includes postfix MTA (bound to localhost) for sending of email.  Also
  includes webmin postfix module for convenience.


Note: This appliance does not include Abiword or Libre Office. One of these
tools is required to export pads, but they add significant size to the
image. They are easy to install, please see below.

Install Abiword aand enable it in Etherpad::

   apt update
   apt install abiword
   sed -i "s|\"abiword\" :.*|\"abiword\" : \"/usr/bin/abiword\",|" \
      /opt/etherpad-lite/settings.json
   systemctl restart etherpad

Or;

Install Libre Office and enable it in Etherpad::

   apt update
   apt install soffice-common
   sed -i "s|\"soffice\" :.*|\"soffice\" : \"/usr/bin/soffice\",|" \
      /opt/etherpad-lite/settings.json
   systemctl restart etherpad



Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, MySQL: username **root**

.. _Etherpad Lite: http://etherpad.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
