<div align="center">
    <a href="https://insentrica.net/" target="_blank">
        <img alt="lamp" src="https://github.com/Valikahn/lamp/blob/main/img/lamp_img.png">
    </a>
</div>

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
* Website:  https://www.insentrica.net
* Github:   https://github.com/Valikahn/lamp
* GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html 

## Script Description
This script is for the installation of Apache, PHP, OpenSSL, MySQL, phpMyAdmin and Webmin.  There is only 2 sections that require human input listed below in the [Script Process](#script-process) section.

* [Tested Operating Systems](#tested-operating-systems)
* [Installed Software Module Versions](#installed-software-module-versions)
* [Script Process](#script-process)
* [Copyright](#copyright)
* [Bugs & Issues](#bugs--issues)
* [Licence](#licence)

## Tested Operating Systems

* Ubuntu-20.x (recommend)

## Installed Software Module Versions
| Install Modules               | Version
|-------------------------------|-------------------------------|
| Apache                        | 2.4.46 (Ubuntu)
| PHP                           | 7.4.9
| SSL                           | OpenSSL/1.1.1f
| MySQL                         | 8.0.23-0ubuntu0.20.10.1
| phpMyAdmin                    | 4.9.7deb1
| Webmin                        | 1.973

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
#### SSL Configuration
After the process has completed installing Apache it will generate an RSA private key.<br />
You will be promped for the following data:
```
Country Name (2 letter code) [AU]:
State or Province Name (full name) [Some-State]:
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:
Email Address []:
```

#### phpMyAdmin Configuration
The installation process will ask for configuration during setup
```
* Select Apache2 for the server.
* Choose YES when asked about whether to configure the database for phpMyAdmin with dbconfig-common.
* Enter your MySQL password when prompted.
* Enter the password that you want to use to log into phpMyAdmin.
```

## Copyright
Copyright (C) 2020 - 2021 Valikahn <git@insentrica.net><br />
Program v0.1-alpha - Code Name: Anubis<br />

## Bugs & Issues
Please feel free to report any bugs or issues to us, email to: git@insentrica.net or <a href="https://github.com/Valikahn/Calorie-Intake-Guide/issues">Issues</a> on GitHub.

## Licence
Copyright (C) 2020 - 2021 Valikahn <git@insentrica.net>

Licensed under the GPLv3 License.
