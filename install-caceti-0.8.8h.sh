#!/bin/bash

#Install all the needed packages and update everything to the latest version
yum -y install wget perl nano rrdtool httpd httpd-devel mariadb-server php-mysql php-pear php-common php-gd php-devel php php-mbstring php-cli php-snmp net-snmp-utils net-snmp-libs rrdtool tcpdump net-tools
yum -y update

#start and set these servers to start on bootup
systemctl start httpd.service
systemctl start mariadb.service
systemctl start snmpd.service
systemctl enable httpd.service
systemctl enable mariadb.service
systemctl enable snmpd.service

#download and extract cacti 0.8.8f into /usr/share and rename it as cacti
cd /usr/share
curl https://www.cacti.net/downloads/cacti-0.8.8h.tar.gz | tar xvz
mv cacti-0.8.8h cacti

#create a script to automate creation of database
echo "create database cacti;" >> /tmp/script.sql
echo "GRANT ALL ON cacti.* TO cacti@localhost IDENTIFIED BY 'jiasulocg';" >> /tmp/script.sql
echo "FLUSH privileges;" >> /tmp/script.sql

mysqladmin -u root password wuyukang
mysql -u root --password=wuyukang< /tmp/script.sql
mysql -u cacti --password=jiasulocg cacti < /usr/share/cacti/cacti.sql

sed -i 's/$database_password = "cactiuser";/$database_password = "jiasulocg";/' /usr/share/cacti/include/config.php
sed -i 's/$database_username = "cactiuser";/$database_username = "cacti";/' /usr/share/cacti/include/config.php

#add http access in the firewall config
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload

#fix selinux so apache can e-mail and connect via network
setsebool -P httpd_can_sendmail=1
setsebool -P httpd_can_network_connect=1

#update apache to host cacti
echo "Alias /cacti /usr/share/cacti" > /etc/httpd/conf.d/cacti.conf
echo " " >> /etc/httpd/conf.d/cacti.conf
echo "<Directory /usr/share/cacti/>" >> /etc/httpd/conf.d/cacti.conf
echo " <IfModule mod_authz_core.c>" >> /etc/httpd/conf.d/cacti.conf
echo " # httpd 2.4" >> /etc/httpd/conf.d/cacti.conf
echo " Require all granted" >> /etc/httpd/conf.d/cacti.conf
echo " </IfModule>" >> /etc/httpd/conf.d/cacti.conf
echo "</Directory>" >> /etc/httpd/conf.d/cacti.conf
systemctl restart httpd.service

echo "*/1 * * * * cacti /usr/bin/php /usr/share/cacti/poller.php > /dev/null 2>&1" > /etc/cron.d/cacti

#It annoys me to have to type /cacti at the end of the URL so I make cacti the default page. Skip this section if you enjoy typing /cacti.
sed -i 's/DocumentRoot "\/var\/www\/html"/DocumentRoot "\/usr\/share\/cacti"/' /etc/httpd/conf/httpd.conf
sed -i 's/\/\/$url_path = "\/cacti\/";/\/\/$url_path = "\/";/' /usr/share/cacti/include/config.php
sed -i 's/\/\/$url_path = "\/cacti\/";/\/\/$url_path = "\/";/' /usr/share/cacti/include/global.php
systemctl restart httpd.service

#set the PHP timezone if it fills your logs with annoying messages. If you're in Detroit then you can be lazy.
sed -i 's/;date.timezone =/date.timezone = America\/Detroit/' /etc/php.ini

/usr/sbin/useradd -b /usr/share -d /usr/share/cacti -m -r -s /sbin/nologin cacti
chown -R cacti /usr/share/cacti/rra
chown -R cacti /usr/share/cacti/log
echo -e "\033[34m Install Finished! \033[0m" 
