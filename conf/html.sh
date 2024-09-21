###--------------------  INDEX.HTML  --------------------###
#
INDEX_HTML() {
echo "<!DOCTYPE html>" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "<!-- LAMP Logo at top of HTML document -->" >> /var/www/html/index.html
echo "<div align="center">" >> /var/www/html/index.html
echo "	<a href="https://github.com/Valikahn/lamp" target="_blank">" >> /var/www/html/index.html
echo "		<img alt="lamp" src="img/lamp_img.png">" >> /var/www/html/index.html
echo "	</a>" >> /var/www/html/index.html
echo "</div>" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "<!-- HEAD containing the page title and link to external CSS  -->" >> /var/www/html/index.html
echo "<html lang="en">" >> /var/www/html/index.html
echo "<head>" >> /var/www/html/index.html
echo "	<meta charset="UTF-8">" >> /var/www/html/index.html
echo "	<meta name="viewport" content="width=device-width, initial-scale=1.0">" >> /var/www/html/index.html
echo "	<link rel="stylesheet" href="css/styles.css">" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "	<title>LAMP (Linux, Apache, MySQL and PHP)</title>" >> /var/www/html/index.html
echo "</head>" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "<!-- BODY containing the page information -->" >> /var/www/html/index.html
echo "<body>" >> /var/www/html/index.html
echo "	<h2 align="center">_________________________________________________</h3><br>" >> /var/www/html/index.html
echo "	<h2 align="center">LAMP (Linux, Apache, MySQL and PHP)</h2><br>" >> /var/www/html/index.html
echo "	<h3 align="center">Apache, MySQL, phpMyAdmin, Webmin and VSFTPD inc FTP and Self-Signed Certificate to work with Apache and VSFTPD.</h3>" >> /var/www/html/index.html
echo "	<br>" >> /var/www/html/index.html
echo "	<h3 align="center">Program Version: $SCRIPTVERSION.$BUILD</h3>" >> /var/www/html/index.html
echo "	<h3 align="center">File Name: $FILENAME</h3>" >> /var/www/html/index.html
echo "	<h3 align="center">Author:  Neil Jamieson (Valikahn)</h3>" >> /var/www/html/index.html
echo "	<br>" >> /var/www/html/index.html
echo "	<h3 align="center">Program designed, developed, and tested while at university studying Computer Science for module 'Managing a Web Server (MAWS_HP2V48)'</h3>" >> /var/www/html/index.html
echo "	<br>" >> /var/www/html/index.html
echo "	<h3 align="center">Please refer to the GitHub README file for specific information about this script.</h3>" >> /var/www/html/index.html
echo "	<h3 align="center">Github: <a href="https://github.com/Valikahn/lamp" target="_blank">Valikahn / lamp</a></h3>" >> /var/www/html/index.html
echo "  <a href='http://$IP_ADDRESS' style='color: white; margin-right: 15px;'>HTTP</a>" >> /var/www/html/index.html
echo "  <a href='https://$IP_ADDRESS' style='color: white; margin-right: 15px;'>HTTPS</a>" >> /var/www/html/index.html
echo "  <a href='http://10.11.22.51/phpmyadmin' style='color: white; margin-right: 15px;'>phpMyAdmin</a>" >> /var/www/html/index.html
echo "  <a href='https://10.11.22.51:10000' style='color: white; margin-right: 15px;'>Webmin</a>" >> /var/www/html/index.html
echo "	<h3 align="center">FTP server running with SSL enabled on port $FTP_PORT'</h3>" >> /var/www/html/index.html
echo "	<h3 align="center">SSH port has been changed to $SSH_PORT'</h3>" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "	<h3 align="center">Please ensure you update your connection settings accordingly.'</h3>" >> /var/www/html/index.html
echo "	<h2 align="center">_________________________________________________</h3><br>" >> /var/www/html/index.html
echo >> /var/www/html/index.html
echo "  <footer>" >> /var/www/html/index.html
echo "    <div style='text-align: center; padding: 10px; background-color: #333; color: white;'>" >> /var/www/html/index.html
echo "      <p>&copy; 2024 Copyright 2024 Neil Jamieson '<Valikahn>'</p>" >> /var/www/html/index.html
echo "      <nav>" >> /var/www/html/index.html
echo "        <a href='http://$IP_ADDRESS/phpinfo.php' style='color: white; margin-right: 15px;'>PHP Info</a>" >> /var/www/html/index.html
echo "        <a href='https://github.com/Valikahn/lamp/issues' style='color: white; margin-right: 15px;'>Bugs & Issues</a>" >> /var/www/html/index.html
echo "        <a href='https://github.com/Valikahn/lamp/blob/master/change_logs/CHANGE_LOG_(230924).md' style='color: white; margin-right: 15px;'>Change Log</a>" >> /var/www/html/index.html
echo "        <a href='https://www.gnu.org/licenses/gpl-3.0.en.html' style='color: white;'>GPLv3 Licence</a>" >> /var/www/html/index.html
echo "      </nav>" >> /var/www/html/index.html
echo "    </div>" >> /var/www/html/index.html
echo "  </footer>" >> /var/www/html/index.html
}