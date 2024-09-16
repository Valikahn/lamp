<div align="center">
    <a href="https://github.com/Valikahn/lamp" target="_blank">
        <img alt="lamp" src="https://github.com/Valikahn/lamp/blob/master/web/img/lamp_img.png">
    </a>
</div>

## Script Description
LAMP (Linux, Apache, MySQL and PHP)
Apache, phpMyAdmin, Webmin and VSFTPD inc FTP and Self-Signed to work with Apache and VSFTPD.

* [Tested Operating Systems](#tested-operating-systems)
* [Installed Software Module Versions](#installed-software-module-versions)
* [Install Commands](#install-commands)
* [Script Process](#script-process)
* [Bugs & Issues](#bugs--issues)
* [Licence](#licence)
* [References](#references)

## Tested Operating Systems

* Ubuntu 24.04.x (Noble Numbat)

## Installed Software Module Versions
| Install Modules               | Version
|-------------------------------|-------------------------------|
| Apache                        | 2.4.58
| PHP                           | 8.3.6
| SSL                           | OpenSSL/3.0.13
| MySQL                         | 8.4
| phpMyAdmin                    | 5.2.1
| Webmin                        | 2.202 
| FTP server (vsftpd)           | 3.0.5

Please note that the above versions are the minimal versions that will be installed and may vary.
This deployment is not pulling specific versions but looking for the latest versions available.

## Install Commands
Install Git and clone the "lamp" package
```
sudo apt-get -y install wget git
git clone https://github.com/Valikahn/lamp.git
```

## Execute Script
```
cd lamp
chmod +x lamp.linux.deb.sh
sudo ./lamp.linux.deb.sh
```

## Script Process
1. UPDATE THE HOST
```
pro_attached=$(echo "$PRO_STATUS" | jq '.account')
    if [[ $pro_attached != "null" ]]; then
        echo "Ubuntu Pro is attached. Detaching and purging the client."
        pro detach --assume-yes
        apt-get purge ubuntu-pro-client -y
    fi

apt update && apt upgrade -y
apt-get -o Dpkg::Options::="--force-confdef" \
              -o Dpkg::Options::="--force-confold" \
              apt dist-upgrade -y
			  dpkg --configure -a

apt --purge autoremove -y
apt autoclean -y
```
2. INSTALL APACHE AND CONFIGURE DIRECTORY PERMISSIONS
3. INSTALL MYSQL SERVER
4. INSTALL PHPMYADMIN
5. INSTALL DEPENDENCIES
6. INSTALL WEBMIN
7. INSTALL VSFTPD TO ENABLE FTP ACCESS
8. CONFIGURE VSFTP/FTP TO INCLUDE SSL (FTPS)
9. CONFIGURE APACHE TO USE THE SELF-SIGNED CERTIFICATE
10. CREATE A SELF-SIGNED CERTIFICATE TO USE WITH APACHE
11. ENABLE APACHE SSL MODULE/CONFIGURATION
12. SSH PORT SECURITY | GENERATE PORT NUMBER BETWEEN 1024 and 65535 AND CHANGE
13. ENABLE FIREWALL AND ALLOW PORTS

## Program Information
Program Version: 24.9.17.244<br />
File Name: maws_h16s35-v24.9.17.244.linux.deb.sh<br />
Author:  Neil Jamieson (Valikahn)<br />

Program designed, developed, and tested while at university studying Computer Science for module "Managing a Web Server (maws_h16s35)"

## Bugs & Issues
Please feel free to report any bugs or issues to us.
* Issues:  <a href="https://github.com/Valikahn/lamp/issues">Via GitHub</a>

## Licence
Licensed under the GPLv3 License.
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html 

## References
Linux (Ubuntu 24.04.x) - https://ubuntu.com/download/server<br />
Apache - https://httpd.apache.org/<br />
MySQL - https://www.mysql.com/<br />
phpMyAdmin - https://www.phpmyadmin.net/<br />
Webmin - https://webmin.com/<br />
VSFTPD - https://wiki.archlinux.org/title/Very_Secure_FTP_Daemon<br />
OpenSSL - https://openssl-library.org/source/gitrepo/ and https://ubuntu.com/server/docs/openssl<br />
