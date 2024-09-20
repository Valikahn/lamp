Change Log
----------

Date: September 2024
Version: 24.09.23

Issues resolved
---------------

###--------------------  INSTALL APACHE AND CONFIGURE DIRECTORY PERMISSIONS  --------------------###
##
Removed the index.html file from the web directory and touched out a new index.html file to echo the data required in order to store variables from the shell script.


###--------------------  HOST DATA COLLECTION  --------------------###
##
Included a application check for NMCLI and if not installed prompt user to install or use default method.
In host data collection this will be collected using the method the user requests (NMCLI or ifconfig).

###--------------------  CONFIGURE VSFTPD/FTP TO INCLUDE SSL (FTPS)  --------------------###
##
Configure randome port to become accessible when using VSFTPD
Included TCP ports 10000:10100 into the firewall; these are passive ports that VSFTPD uses.