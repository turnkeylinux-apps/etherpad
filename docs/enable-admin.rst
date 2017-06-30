=======
Warning
=======

Etherpad admin interface is disable by default in the turnkeylinux etherpad appliance
as per security concerns regarding passwords being stored as plaintext. And access to
the plaintext via the online admin-interface.

This is a concerning security issue and it should be known that plaintext passwords
provide no protection in the occurance of a malicious individual gaining access to
your server. By enabling the administrative user you also enable the ability for any
one with valid administrator credentials to read settings.json file and along with it
your passwords.


**Proceed with Caution**

--------------
etherpad-admin
--------------

Since the etherpad admin interface has been disabled by default, the inithook relating
to it no longer exists, however it's functionality has been moved to a commandline
tool ``etherpad-admin``.

running ``etherpad-admin enable`` will enable the administrative user login with
"admin" and allow you to set it's password.

running ``etherpad-admin disable`` will disable the administrative user login with
"admin" and remove it's password from the ``settings.json`` file.

**Note: ``etherpad-admin disable`` does not deauthenticate authenticated users, only
disables their ability to login**
