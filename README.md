<div align="center">
    <a href="https://insentrica.net/" target="_blank">
        <img alt="lamp" src="https://github.com/Valikahn/lamp/blob/main/img/lamp_img.png">
    </a>
</div>

## Script Description
This script is for the installation of Apache, PHP, OpenSSL, MySQL, phpMyAdmin and Webmin.

* [Tested Operating Systems](#tested-operating-systems)
* [Installed Software Module Versions](#installed-software-module-versions)
* [Install Commands](#install-commands)
* [Script Process](#script-process)
* [Copyright](#copyright)
* [Bugs & Issues](#bugs--issues)
* [Licence](#licence)

## Tested Operating Systems

* Ubuntu 24.04.x (Noble Numbat)

## Installed Software Module Versions
| Install Modules               | Version
|-------------------------------|-------------------------------|
| Apache                        | #.#.# (Ubuntu)
| PHP                           | #.#.#
| SSL                           | OpenSSL/#.#.#a
| MySQL                         | #.#.#-0ubuntu0.20.10.1
| phpMyAdmin                    | #####
| Webmin                        | #####
| FTP server (vsftpd)           | #####

## Install Commands - Install Git and clone the "lamp" package
```
sudo -i
sudo apt-get -y install wget git
git clone https://github.com/Valikahn/lamp.git
```

## Execute Script
```
cd lamp
chmod +x lamp.install-insentrica
sudo ./lamp.install-insentrica
```

## Script Process
1. UPDATE THE HOST
2. INSTALL APACHE AND CONFIGURE DIRECTORY PERMISSIONS
3. ENABLE FIREWALL AND INCLUDE AND PORTS
4. INSTALL MYSQL SERVER
5. INSTALL PHP / OTHER APPLICATIONS
6. INSTALL PHPMYADMIN
7. INSTALL WEBMIN
8. INSTALL VSFTPD TO ENABLE FTP ACCESS
9. CONFIGURE VSFTP/FTP TO INCLUDE SSL (FTPS)
10. CREATE A SELF-SIGNED CERTIFICATE TO USE WITH APACHE
11. CONFIGURE APACHE TO USE THE SELF-SIGNED CERTIFICATE
12. ENABLE APACHE SSL MODULE/CONFIGURATION

## Program Information
Program Version: 24.9.15-alpha<br />

## Bugs & Issues
Please feel free to report any bugs or issues to us.
* Issues:  <a href="https://github.com/Valikahn/lamp/issues">Via GitHub</a>
* Github:   https://github.com/Valikahn/lamp

## Licence
Licensed under the GPLv3 License.
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html 
