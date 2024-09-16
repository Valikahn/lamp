<div align="center">
    <a href="https://github.com/Valikahn/lamp" target="_blank">
        <img alt="lamp" src="https://github.com/Valikahn/lamp/blob/master/web/img/lamp_img.png">
    </a>
</div>

## Script Description
LAMP (Linux, Apache, MySQL and PHP)
Apache, phpMyAdmin, Webmin and VSFTPD inc FTP and Self-Signed to work with Apache and VSFTPD.

## Purpose:
The script automates the installation, configuration, and setup of a LAMP (Linux, Apache, MySQL, and PHP) stack. 
It includes additional features like installing phpMyAdmin, Webmin, and VSFTPD for managing web servers and FTP services with SSL support.

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

## Features and Components
Initial Setup and Environment:
* Clears the terminal and sets the default text editor to nano.
* Defines variables for color outputs, versioning information, and host data collection (network interface, IP address, etc.).

Root/Sudo Check:
* Verifies if the script is being executed with root or sudo privileges. If not, it exits with an error message, as the script requires administrative privileges to run.

Password Generation:
* Generates random passwords for various services (MySQL root, phpMyAdmin user, etc.) using a random string generator function.

System Data Collection:
Detects the operating system (either RedHat/CentOS or Debian/Ubuntu) and collects key host information such as distribution version, hostname, and IP address. If the OS is unsupported, the script exits.

* User Confirmation:
Prompts the user for confirmation before proceeding with the setup.

Software Installation:
* Apache Web Server: Installs Apache and sets appropriate permissions for the /var/www/html directory.
* MySQL: Installs MySQL server, creates a secure root user, and sets up phpMyAdmin with a user and password.
* phpMyAdmin: Automatically configures phpMyAdmin for database management.
* Dependencies: Installs various packages, including PHP, required PHP modules, and other utilities like net-tools, nmap, and python3.

Webmin Setup:
* Installs Webmin, a web-based system configuration tool, enabling easier server management.

VSFTPD (FTP Server):
* Installs and configures VSFTPD for FTP access, including SSL for secure FTP (FTPS).

SSL Certificates:
* Generates self-signed SSL certificates for both VSFTPD and Apache to secure web and FTP services.

Firewall Configuration:
* Configures ufw (Uncomplicated Firewall) to allow necessary ports for Apache, HTTPS, FTP, MySQL, Webmin, and a dynamically generated SSH port (randomly selected to improve security).

Final Output:
* Provides the user with essential details, such as:
* * Apache access URLs (HTTP and HTTPS)
* * phpMyAdmin access details
* * Webmin login credentials
* * FTP server details
* * SSH port change information
* * Prompts for reboot, as it is recommended after installing and configuring the services.


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
