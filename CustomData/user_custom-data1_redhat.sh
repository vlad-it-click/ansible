#!/bin/bash
yum -y update
yum -y install httpd


cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="blue">
<h2><font color="red">Build by CustomData/UserData</font></h2><br><p> 
<h2>WebServer $(hostname) created $(date) by user $(whoami) </h2><br><br>
<font color="yellow"><b> Version 1.0 </b>
</body>
</html>
EOF

sudo service httpd start
chkconfig httpd on