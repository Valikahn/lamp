<div align="center">
    <a href="https://github.com/Valikahn/lamp" target="_blank">
        <img alt="lamp" src="https://github.com/Valikahn/lamp/blob/master/web/img/lamp_img.png">
    </a>
</div>

## Purpose:
The script is modular built with many differnt interating files sourced in to complete a task.  This automates the installation, configuration, and setup of a LAMP (Linux, Apache, MySQL, and PHP) stack. It includes additional features like installing phpMyAdmin, Webmin, and VSFTPD for managing web servers and FTP services with SSL support.  As this is a webserver, this is best on a host that has a static IP address.<br /><br />
Program designed, developed, and tested while at university studying Computer Science for module "Managing a Web Server (maws_h16s35)"<br />

Program Version: 24.9.24<br />
File Name: maws_hp2v48.v24.9.24.linux.deb.sh<br />
Written by:  Neil Jamieson [Licence](#licence)<br />

* [Tested Operating Systems](#tested-operating-systems)
* [Installed Software Module Versions](#installed-software-module-versions)
* [Additional Installed Software](#additional-installed-software)
* [Features of Deployment](#features-of-deployment)
* [Key Advantages](#key-advantages)
* [Install Commands](#install-commands)
* [Change Log](#change-log)
* [Bugs & Issues](#bugs--issues)
* [Licence](#licence)
* [References](#references)

## Tested Operating Systems
* Ubuntu 24.04.x LTS (Noble Numbat) ![Unit Tests](https://github.com/Valikahn/lamp/blob/master/web/img/test-badge-passing.svg)
* Ubuntu 22.04.x LTS (Jammy Jellyfish) ![Unit Tests](https://github.com/Valikahn/lamp/blob/master/web/img/test-badge-failing.svg)
* Ubuntu 20.04.x LTS (Focal Fossa) ![Unit Tests](https://github.com/Valikahn/lamp/blob/master/web/img/test-badge-failing.svg)
* Ubuntu 18.04.6 LTS (Bionic Beaver) ![Unit Tests](https://github.com/Valikahn/lamp/blob/master/web/img/test-badge-failing.svg)
 
## Installed Software Module Versions
This deployment is not pulling specific versions but looking for the latest versions available. The versions detailed below are the minimal versions that will be installed; this may vary as applications owners update there software. 

| Install Modules               | Version
|-------------------------------|-------------------------------|
| Apache                        | 2.4.58
| PHP                           | 8.3.6
| ionCube                       | 13.3.1
| OpenSSL                       | 3.0.13
| MySQL                         | 8.4
| phpMyAdmin                    | 5.2.1
| Webmin                        | 2.202 
| FTP server (vsftpd)           | 3.0.5

## Additional Installed Software
This is a list of software that is dependencies, supporting, and enhancement applications. Extensions, network tools and security modules.  These all work well with the installation of LAMP and are all auto installed, cleaned up, and have a basic configuration.

| Application                   | Description
|-------------------------------|-------------------------------|
| ionCube                       | A PHP extension used to encrypt and protect PHP code from unauthorized use or modification.
| libapache2-mod-php            | An Apache module for running PHP scripts directly on the server using the Apache web server.
| php-mysql                     | A PHP extension that allows PHP to communicate with MySQL databases.
| php-cli                       | The PHP Command Line Interface, enabling PHP scripts to be run directly from the terminal.
| php-curl                      | A PHP extension for transferring data using URLs with various protocols, supporting cURL functions.
| php-json                      | A PHP extension that enables PHP to work with JSON data (JavaScript Object Notation).
| php-xml                       | A PHP extension providing XML parsing capabilities.
| php-zip                       | A PHP extension for handling ZIP files, allowing for creation and extraction.
| net-tools                     | A package that provides basic networking utilities like ifconfig, netstat, route, and others.
| nmap                          | A network discovery and security auditing tool used for scanning networks and finding open ports or vulnerabilities.
| tcpdump                       | A command-line packet analyzer used to capture and inspect network traffic in real time.
| cifs-utils                    | Utilities for mounting and managing file systems using the CIFS/SMB protocol (common for network shares).
| dnsutils                      | A set of DNS-related utilities, including tools like dig and nslookup, used for DNS queries.
| default-jre                   | The default Java Runtime Environment (JRE) for running Java applications.
| dos2unix                      | A utility to convert plain text files from DOS/Windows format (CRLF line endings) to Unix format (LF line endings).
| rar                           | A utility for compressing files into the RAR format.
| unrar                         | A utility to extract files from RAR archives.
| perl                          | A high-level programming language often used for system administration, web development, and text manipulation.
| python3                       | The third major version of the Python programming language, known for its readability and versatility.
| python3-pip                   | A package manager for Python that allows the installation and management of Python libraries.

## Features of Deployment
Initial Setup and Environment:
* Clears the terminal and sets the default text editor to nano.
* Defines variables for color outputs, versioning information, and host data collection (network interface, IP address, etc.).

Root/Sudo Check:
* Verifies if the script is being executed with root or sudo privileges. If not, it exits with an error message, as the script requires administrative privileges to run.

Password Generation:
* Generates random passwords for various services (MySQL root, phpMyAdmin user, etc.) using a random string generator function.

System Data Collection:
* Detects the operating system (either RedHat/CentOS or Debian/Ubuntu) and collects key host information such as distribution version, hostname, and IP address. If the OS is unsupported, the script exits.

IP Address Check (Static)
* Detects if the host has been configured with a static IP address.  If not this will check if NMCLI is installed and prompt to installed by user choice.
* Either (y/n) will continue with configuration of static IP address setup using NMCLI or Default build-in.  NMCLI is preferred but will work either way. 

Software Removal:
* Ubuntu Pro is detached and purged from the host.
* Cloud-init is deleted and purged from the host.
 
Software Installation:
* Apache Web Server: Installs Apache and sets appropriate permissions for the /var/www/html directory.
* MySQL: Installs MySQL server, creates a secure root user, and sets up phpMyAdmin with a user and password.
* phpMyAdmin: Automatically configures phpMyAdmin for database management.
* Dependencies: Installs various packages, including PHP, required PHP modules, and other utilities like net-tools, nmap, perl, and python.

Webmin Setup:
* Installs Webmin, a web-based system configuration tool, enabling easier server management.

VSFTPD (FTP Server):
* Installs and configures VSFTPD for FTP access, including SSL for secure FTP (FTPS).

SSL Certificates:
* Generates self-signed SSL certificates for both VSFTPD and Apache to secure web and FTP services.

Firewall Configuration:
* Configures ufw (Uncomplicated Firewall) to allow necessary ports for Apache, HTTPS, FTP, MySQL, Webmin, and a dynamically generated SSH port (randomly selected to improve security).

## Key Advantages:
* **Fully Automated**: Once executed, the script handles everything from software installation to firewall configuration, reducing the need for manual intervention.
* **Security Enhancements**: The script automatically sets up SSL certificates for both Apache and FTP services and changes the default SSH port to a random high number, enhancing system security.
* **Convenient Access**: After installation, tools like Webmin and phpMyAdmin provide a GUI-based method to manage the server and databases, respectively.
* **Efficient Deployment**: The script is suitable for users who want to deploy a web server with minimal effort on an Ubuntu system. It simplifies the process by integrating several services into one automated setup.

## Install Commands
Install Git and clone the "lamp" package
```
sudo apt-get -y install wget git
git clone https://github.com/Valikahn/lamp.git
```

## Execute Script
Change directory -->  Make shell file executable -->  sudo run the script<br />
Thats it - there is only one interaction required (y/n)
```
cd lamp
chmod +x maws_hp2v48-v24.9.24.linux.deb.sh
sudo ./maws_hp2v48-v24.9.24.linux.deb.sh
```

## Change Log
Please refer to our change log as this will be updated with the changes made and to what release.
* Release 24.9.24: <a href="https://github.com/Valikahn/lamp/blob/master/change_logs/CHANGE_LOG_(230924).md">Change Log</a>

## Bugs & Issues
Please let me know if there is any bugs or issues with this script.
* Issues: <a href="https://github.com/Valikahn/lamp/issues">Via GitHub</a>

## Licence
Licensed under the GPLv3 License.
Copyright (C) 2024 Neil Jamieson

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.<br /><br />
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.<br /><br />
You should have received a copy of the GNU General Public License along with this program. If not, see <a href="https://www.gnu.org/licenses/gpl-3.0.en.html ">GNU General Public License</a>.<br />

## References
Linux (Ubuntu 24.04.x) - https://ubuntu.com/download/server<br />
Apache: https://httpd.apache.org/<br />
MySQL: https://www.mysql.com/<br />
phpMyAdmin: https://www.phpmyadmin.net/<br />
Webmin: https://webmin.com/download/<br />
VSFTPD: https://wiki.archlinux.org/title/Very_Secure_FTP_Daemon<br />
OpenSSL: https://openssl-library.org/source/gitrepo/ and https://ubuntu.com/server/docs/openssl<br />
ionCube: https://www.ioncube.com/<br />