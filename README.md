<div align="center">
    <a href="https://insentrica.net/" target="_blank">
        <img alt="lamp" src="https://github.com/Valikahn/lamp/blob/main/img/lamp_img.png">
    </a>
</div>

## Script Description
This script is for the installation of Apache, PHP, OpenSSL, MySQL, phpMyAdmin and Webmin.  There are a few sections that require human input listed below in the [Script Process](#script-process) section, please read this section to ensure you understand what the program is asking of you.

* [Tested Operating Systems](#tested-operating-systems)
* [Installed Software Module Versions](#installed-software-module-versions)
* [Install Commands](#install-commands)
* [Script Process](#script-process)
* [Copyright](#copyright)
* [Bugs & Issues](#bugs--issues)
* [Licence](#licence)

## Tested Operating Systems

* Ubuntu 18.x (Bionic Beaver)
* Ubuntu 20.04.x (Focal Fossa)
* Ubuntu 20.10.x (Groovy Gorilla)

#### Under Testing

* Ubuntu 21.04.x (Hirsute Hippo)

## Installed Software Module Versions
| Install Modules               | Version
|-------------------------------|-------------------------------|
| Apache                        | 2.4.46 (Ubuntu)
| PHP                           | 7.4.9
| SSL                           | OpenSSL/1.1.1f
| MySQL                         | 8.0.23-0ubuntu0.20.10.1
| phpMyAdmin                    | 4.9.7deb1
| Webmin                        | 1.973
| FTP server (vsftpd)           | 3.0.3

## Install Commands
#### Install Git and clone the "lamp" package
```
sudo -i
sudo apt-get -y install wget git
git clone https://github.com/Valikahn/lamp.git
```

#### Execute Script

```
cd lamp
chmod +x lamp.install-insentrica
sudo ./lamp.install-insentrica
```

## Script Process
#### Apache and FTP Server SSL Configuration
After the process has completed installing Apache and FTP (vsftpd), it will generate an RSA private key.<br />
You will be asked to enter some details like country, etc. You don’t have to fill these in. You can just press ENTER for defaults.<br />
Like below:
```
Country Name (2 letter code) [AU]:
State or Province Name (full name) [Some-State]:
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:
Email Address []:
```
#### Firewall Configuration
The script will configure the Uncomplicated Firewall after installing the FTP Server (VSFTPD), it will open the following ports/applications:
```
OpenSSH
80/tcp (HTTP)
443/tcp (HPPTS)
10000/tcp (Webmin)
20/tcp (FTP Client)
21/tcp (FTP Server)
40000:50000/tcp (Ubuntu Passive Ports)
990/tcp (SFTP)
```
You will be prompted with a confirmation to proceed with operation as below: 
```
Command may disrupt existing ssh connections. Proceed with operation (y|n)?
```
Press 'y' and press enter to contine with the script.

#### phpMyAdmin Configuration
The installation process will ask for configuration during setup
```
* Select Apache2 for the server.
* Choose YES when asked about whether to configure the database for phpMyAdmin with dbconfig-common.
* Enter your MySQL password when prompted.
* Enter the password that you want to use to log into phpMyAdmin.
```

#### Security on PhpMyAdmin Login Interface
PhpMyAdmin is a web based MySQL database manage application, you will be prompted to secure phpMyAdmin interface with password protect on Linux systems.
When prompted enter a password twice, this is to prevent anyone not in the www-data or apache group from being able to read the .htpasswd


## Copyright
Copyright (C) 2020 - 2021 Valikahn <git@insentrica.net><br />
Program v1.1-alpha - Code Name: Anubis<br />

## Bugs & Issues
Please feel free to report any bugs or issues to us.
* Email:  git@insentrica.net 
* Issues:  <a href="https://github.com/Valikahn/lamp/issues">Via GitHub</a>
* Website:  https://www.insentrica.net
* Github:   https://github.com/Valikahn/lamp

## Licence
Licensed under the GPLv3 License.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html 
