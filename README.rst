Etherpad Lite - Real-time document collaboration
================================================

`Etherpad Lite`_ is a real-time collaborative editor, sort of like a
web-based multiplayer Notepad that allows groups of users to
simultaneously edit a text document, with the ability to display each
author's text in their own color. There is also a chat box in the
sidebar to allow meta communication.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- Etherpad configurations:
   
   - The maintained upstream stable package is installed from Etherpad's
     signed APT repository in ``/opt/etherpad``.
   - Pre-configured to use MySQL/MariaDB (recommended for production).

- Node.js configurations:
   
   - Includes the supported Node.js 24 LTS runtime from NodeSource's signed
     repository.
   - The nginx web server is pre-configured to proxy to the Etherpad service,
     with SSL support out of the box.
   - Etherpad runs under its upstream systemd service and dedicated account.

- SSL support out of the box
- Includes postfix MTA (bound to localhost) for sending of email.  Also
  includes webmin postfix module for convenience.


Note: This appliance does not include Abiword or Libre Office. One of these
tools is required to export pads, but they add significant size to the
image. They are easy to install, please see below.

Install Abiword and enable it in Etherpad::

   apt update
   apt install abiword
   sed -i "s|\"abiword\" :.*|\"abiword\" : \"/usr/bin/abiword\",|" \
      /etc/etherpad/settings.json
   systemctl restart etherpad

Or;

Install Libre Office and enable it in Etherpad::

   apt update
   apt install libreoffice
   sed -i "s|\"soffice\" :.*|\"soffice\" : \"/usr/bin/soffice\",|" \
      /etc/etherpad/settings.json
   systemctl restart etherpad



Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, MySQL: username **root**

-  Etherpad administration: username **admin**

.. _Etherpad Lite: http://etherpad.org/
.. _TurnKey Core: https://www.turnkeylinux.org/core
