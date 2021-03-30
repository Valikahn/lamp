## LAMP (Linux, Apache, MySQL and PHP) by Valikahn

Copyright (C) 2020 - 2021 Valikahn <git@insentrica.net><br />
Program v0.1-alpha - Code Name: Anubis<br />
This has been tested on Ubuntu 20.10 (Groovy Gorilla)<br />
Licensed under the GPLv3 License.<br />

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
* Website:  https://www.insentrica.net
* Github:   https://github.com/Valikahn/lamp
* GPLv3 Licence:  https://www.gnu.org/licenses/gpl-3.0.en.html 

## Software Versions

| Apache & Additional Modules   | Version
|-------------------------------|-------------------------------|
| Apache                        | 
| PHP                           |
| SSL                           | 
| MySQL                         | 
| phpMyAdmin                    | 
| Webmin                        | 

#### Install Git and download "lamp"
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
