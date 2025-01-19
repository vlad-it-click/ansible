#!/bin/bash
apt update
apt -y install nginx procps net-tools curl vim
#mkdir /var/www/ccc

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="blue">
<h2><font color="red">Build by CustomData/UserData</font></h2><br><p> 
<h2>WebServer: $(hostname) ($(hostname -I | awk '{print $1}')) created:  $(date '+%Y-%m-%d %H:%M:%S')  by user:  $(whoami) </h2><br>
<h2>It has: MEMORY - $(free -h | awk '/^Mem:/ {print $2}');  DISK SIZE -  $(df -h / | awk 'NR==2 {print $2}')</h2><br><br>
<font color="yellow"><b> Version 1.0 </b>
</body>
</html>
EOF

sudo service nginx start
