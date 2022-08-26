Etherpad Lite - Real-time document collaboration
================================================

`Tkl Etherpad`_ is a real-time collaborative editor, sort of like a
web-based multiplayer Notepad that allows groups of users to
simultaneously edit a text document, with the ability to display each
author's text in their own color. There is also a chat box in the
sidebar to allow meta communication.

Etherpad is based on `Etherpad Lite`_ and includes all the standard features in `TurnKey Core`_,
and on top of that.

Testing
================================================
No default passwords used for security reasons, all passwords will be set on first boot.
After installing Etherpad, you can test the appliance by logging into the webmin.
More information about installation and usage can be found at `etherpad-light github`_

This appliance does not include Abiword or Libre Office. One of these
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
.. _Tkl Etherpad: https://www.turnkeylinux.org/etherpad
.. _etherpad-light github: https://github.com/ether/etherpad-lite