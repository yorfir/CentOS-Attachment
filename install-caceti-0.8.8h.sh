# cacti 0.8.8h 一键安装脚本
# Make by Fenei
# E-Mail : babyfenei@qq.com
# Date : 13-Sep-2016
#  URL:http://babyfenei.blog.51cto.com/443861/1852324
#-----------------------------------------------------
# 本脚本自动安装 cacti0.8.8h rrdtool 1.5.6 
# 安装完成后自动修改5分钟值保存周期为1年
# 修改95计费模板，添加流入流出差值计算和百分比计算
# 添加华为s9312 s5700 CPU监控模板
#----------------------------------------------------
# Ver.:1.2
# Date : 15-Nov-2016
# 修改rrdtool为源码安装并在脚本中可以修改水印
# 增加weathermap等插件
# Ver.:1.3
# Date : 19-Nov-2016
# 修改graph_xport.php文件编码，防止中文图形下载出现乱码
# 修改php.ini配置文件，防止导出csv文件时超时出错
#!/bin/bash

stty erase ^h 
stty erase ^H
echo "关闭防火墙及SElinux"
chkconfig iptables off
service iptables stop
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
/usr/sbin/setenforce 0
echo "LANG=\"zh_CN.UTF-8\"" > /etc/sysconfig/i18n
yum install -y wget
rm -rf /usr/src/cacti
mkdir -p /usr/src/cacti
\cp -fr -R * /usr/src/cacti/ 
cd /usr/src/cacti/ 
echo -e "\033[33m 请输入mysql数据库密码并回车:\033[0m"
read MYSQLPASS
echo -e "\033[33m您输入的mysql数据库密码是'$MYSQLPASS'\033[0m"
echo "-------------------------------------------------------"
cd /usr/src/cacti/rrdtool/
tar xf rrdtool*.tar.gz
cd /usr/src/cacti/rrdtool/rrdtool*/
# 修改rrdtool水印
echo -e "\033[33m 是否修改rrdtool水印?(yes(y)|no(n)):\033[0m"
read rerrd
case $rerrd in
yes|y)
echo -e "\033[34m 请输入要修改的字符,可以为中文。输入完毕后回车继续 (输入特殊字符时请在前面加上转义符\)\033[0m"
read rrdlogo
echo -e "\033[35m 您要修改的水印是:$rrdlogo \033[0m"
#修改水印
sed -i 's/RRDTOOL \/ TOBI OETIKER/'$rrdlogo'/g' /usr/src/cacti/rrdtool/rrdtool*/src/rrd_graph.c
#修改水印透明度
sed -i 's/water_color.alpha = 0.3;/water_color.alpha = 0.5;/g' /usr/src/cacti/rrdtool/rrdtool*/src/rrd_graph.c
;;
no|n)
echo -e "\033[34m 您选择了不修改rrdtool水印，安装将继续！ \033[0m"
;;
esac
#更新阿里源
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
yum clean all
yum makecache

echo "安装apache及Mysql"
# 安装apache
yum install -y httpd
chkconfig httpd on
service httpd start
# 安装mysql
yum install -y mysql-server  mysql mysql-devel
chkconfig mysqld on
service mysqld start
# 创建数据库用户名密码
mysqladmin -u root password $MYSQLPASS
yum install -y php php-gd  php-mysql php-cli php-ldap php-snmp php-mbstring php-mcrypt rsyslog-mysql  ntpdate  openssh-clients gcc gcc-c++ make automake patch libtool net-snmp-devel openssl-devel  gettext  ruby  mkfontscale fontconfig
# 安装rrdtool支持库
yum install -y dejavu-fonts-common dejavu-lgc-sans-mono-fonts dejavu-sans-mono-fonts  fontpackages-filesystem

#编译安装rrdtool
echo -e "\033[37m 安装rrdtool！ \033[0m"
cd /usr/src/cacti/rrdtool/rrdtool*/
./configure --prefix=/usr/local/rrdtool && make && make install
#创建软链接
ln -s /usr/local/rrdtool/bin/rrdtool /usr/bin/rrdtool
service httpd restart
echo "安装中文字体"
# 安装字体
\cp -rf /usr/src/cacti/fonts/simsun.ttc /usr/share/fonts/
mkfontscale
fc-cache -f -v
echo -e "\033[34m 安装snmp！ \033[0m"
# 安装snmp
yum install -y net-snmp-utils 
yum install -y tftp-server
chkconfig xinetd on
service xinetd start
chkconfig snmpd on
service snmpd restart
# 安装cacti
echo -e "\033[34m 安装cacti！ \033[0m"
cd /usr/src/cacti/cacti/
tar xf cacti*.tar.gz
mv -f cacti*/* /var/www/html/
# 创建realtime cache文件夹
cd /usr/src/cacti/ 
mkdir  /var/www/html/cache/
chown -R apache:apache /var/www/html/
# 添加cacti中文标题字体支持
sed -i '$i setlocale(LC_CTYPE,"zh_CN.UTF-8");' /var/www/html/lib/functions.php
# 修改config.php文件中指定cacti网站的后缀名为/
sed -i 's/^.*url_path.*$/$url_path = "\/";/' /var/www/html/include/config.php
sed -i 's/^.*date.timezone.*$/date.timezone = "Asia\/Shanghai";/' /etc/php.ini
service httpd restart
# 设置数据库
mysql -u root -p$MYSQLPASS -e 'CREATE DATABASE `cacti` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -u root -p$MYSQLPASS  -e "CREATE USER 'cactiuser'@'localhost' IDENTIFIED BY 'cactiuser';"
mysql -u root -p$MYSQLPASS  -e 'GRANT ALL PRIVILEGES ON `cacti` . * TO 'cactiuser'@'localhost';'
mysql -u root -p$MYSQLPASS -e 'flush privileges;'
mysql -u cactiuser -pcactiuser cacti --default-character-set=utf8 < /var/www/html/cacti.sql
echo "*/5 * * * * root /usr/bin/php /var/www/html/poller.php > /dev/null 2>&1" > /etc/cron.d/cacti
# 同步时间命令
\cp -fr /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "*/5 * * * * root /usr/sbin/ntpdate time.windows.com > /dev/null 2>&1" > /etc/cron.d/ntp
service crond restart
# 安装spine
echo -e "\033[34m 安装spine！ \033[0m"
cd /usr/src/cacti/spine/
tar xf cacti-spine*.tar.gz
cd cacti-spine*
./configure 
make && make install
cp /usr/local/spine/etc/spine.conf.dist  /usr/local/spine/etc/spine.conf
# 如果出现不出图的情况，并运行/usr/local/spine/bin/spine 出错，拷贝spine配置文件到/etc目录
cp  /usr/local/spine/etc/spine.conf /etc/ 
/usr/local/spine/bin/spine
cd /usr/src/cacti/plugins/
# 安装插件
echo -e "\033[34m 安装插件！ \033[0m"
mkdir  /var/www/html/plugins/settings/
tar xf settings*.tgz
\cp -rf  settings*/* /var/www/html/plugins/settings/
chown -R apache:apache /var/www/html/plugins/settings/
mkdir  /var/www/html/plugins/aggregate/
tar xf aggregate*.tgz 
\cp -rf  aggregate*/* /var/www/html/plugins/aggregate/
chown -R apache:apache /var/www/html/plugins/aggregate/
mkdir  /var/www/html/plugins/syslog/
tar xf syslog*.tgz
\cp -rf  syslog*/* /var/www/html/plugins/syslog/
chown -R apache:apache /var/www/html/plugins/syslog/
mkdir  /var/www/html/plugins/clog/
tar xf clog*.tgz 
\cp -rf  clog*/* /var/www/html/plugins/clog/
chown -R apache:apache /var/www/html/plugins/clog/
mkdir  /var/www/html/plugins/thold/
tar xf thold*.tgz
\cp -rf  thold*/* /var/www/html/plugins/thold/
chown -R apache:apache /var/www/html/plugins/thold/
mkdir  /var/www/html/plugins/monitor/
tar xf monitor*.tgz 
\cp -rf  monitor*/* /var/www/html/plugins/monitor/
chown -R apache:apache /var/www/html/plugins/monitor/
mkdir  /var/www/html/plugins/realtime/
tar xf realtime*.tgz 
\cp -rf  realtime*/* /var/www/html/plugins/realtime/
mkdir -p /var/www/html/plugins/realtime/cache
chown -R apache:apache /var/www/html/plugins/realtime/

mkdir -p /var/www/html/plugins/boost/
tar xf boost*.gz 
\cp -rf  boost*/* /var/www/html/plugins/boost/
chown -R apache:apache /var/www/html/plugins/boost/
mkdir -p /var/www/html/plugins/cycle/
tar xf cycle*.gz 
\cp -rf  cycle*/* /var/www/html/plugins/cycle/
chown -R apache:apache /var/www/html/plugins/cycle/
mkdir -p /var/www/html/plugins/discovery/
tar xf discovery*.gz 
\cp -rf  discovery*/* /var/www/html/plugins/discovery/
chown -R apache:apache /var/www/html/plugins/discovery/
service httpd restart
# 安装syslog支持
echo -e "\033[34m 安装rsyslog！ \033[0m"
yum install -y  rsyslog-mysql
# 新建syslog数据库并赋予权限
mysql -uroot -p$MYSQLPASS -e 'create database `syslog` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;'
mysql -uroot -p$MYSQLPASS -e "GRANT ALL ON syslog.* TO cactiuser@localhost IDENTIFIED BY 'cactiuser';"
mysql -uroot -p$MYSQLPASS -e 'flush privileges;'
mysql -uroot -p$MYSQLPASS syslog --default-character-set=utf8 < /var/www/html/plugins/syslog/syslog.sql
# 更改syslog配置，使用单独数据库
sed -i 's/$use_cacti_db = true;/$use_cacti_db = false;/' /var/www/html/plugins/syslog/config.php
# 启用syslog前修改rsyslog部分参数
echo '*.* @@localhost:514' >> /etc/rsyslog.conf
echo '$ModLoad imudp' >> /etc/rsyslog.conf
echo '$ModLoad imklog' >> /etc/rsyslog.conf
echo '$ModLoad imuxsock' >> /etc/rsyslog.conf
echo '$ModLoad immark' >> /etc/rsyslog.conf
echo '$ModLoad imtcp' >> /etc/rsyslog.conf
echo '$UDPServerRun 514' >> /etc/rsyslog.conf
echo '$ModLoad ommysql' >> /etc/rsyslog.conf
echo '$template cacti_syslog,"INSERT INTO syslog_incoming(facility, priority, date, time, host, message) values (%syslogfacility%, %syslogpriority%, '"'"'%timereported:::date-mysql%'"'"', '"'"'%timereported:::date-mysql%'"'"', '"'"'%HOSTNAME%'"'"', '"'"'%msg%'"'"')", SQL' >> /etc/rsyslog.conf
echo '*.*    >localhost,syslog,cactiuser,cactiuser;cacti_syslog' >> /etc/rsyslog.conf
echo '*.*   /var/log/file.log' >> /etc/rsyslog.conf
chkconfig rsyslog on
service rsyslog restart
#修改rrd.php
sed -i 's/"--maxrows=10000" . RRD_NL;/"--maxrows=1000000000" . RRD_NL;/' /var/www/html/lib/rrd.php
sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php.ini
mysql -u cactiuser -pcactiuser cacti --default-character-set=utf8 < /usr/src/cacti/sql/cacti.sql
mysql -u cactiuser -pcactiuser syslog --default-character-set=utf8 < /usr/src/cacti/sql/syslog.sql
#修改graph_xport.php文件编码
vi +':w ++ff=unix' +':q' /var/www/html/graph_xport.php
{ echo ':set encoding=utf-8';echo ':set bomb';echo ':wq';} | vi /var/www/html/graph_xport.php;
service httpd restart
echo -e "\033[34m 安装完成! \033[0m" 
