#!/bin/bash
apt update
apt -y install nginx
mkdir /var/www/ccc

cat <<EOF > /var/www/ccc/index.html
<html>
<body bgcolor="blue">
<h2><font color="red">Build by CustomData/UserData</font></h2><br><p> 
<h2>WebServer $(hostname) created $(date) by user $(whoami) </h2><br><br>
<font color="yellow"><b> Version 1.0 </b>
</body>
</html>
EOF

sudo service nginx start
