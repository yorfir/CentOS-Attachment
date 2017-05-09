#!/usr/bin/env bash

#2017年5月10日
#安装执行需要下载zabbix3.2.6源包
#获取当前路径
Path=`pwd`
wget --no-check-certificate https://raw.githubusercontent.com/yorfir/CentOS-Attachment/master/soft/zabbix-3.2.6.tar.gz
#安装atomic-release YUM源
rpm -Uvh http://www6.atomicorp.com/channels/atomic/centos/6/x86_64/RPMS/atomic-release-1.0-21.el6.art.noarch.rpm

#安装所需组件
yum -y install httpd libcurl-devel libxml2-devel mysql mysql-devel mysql-server net-snmp net-snmp-devel \
               ntp redhat-lsb php php-bcmath php-gd php-mbstring php-mysql php-xmlreader \
               php-xmlwriter vim wget

#同步系统时间
ntpdate time.windows.com

#解压zabbix源码
tar -xzf zabbix-3.2.6.tar.gz

#创建用户组、用户
groupadd zabbix
useradd -g zabbix zabbix

#启动数据库，设置开机启动
service mysqld start
chkconfig --level 3 mysqld on

#修改数据库密码
mysqladmin -u'root' password "root"

#创建zabbix数据库
mysql -h'127.0.0.1' -u'root' -p'root' -P'3306' -e "CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;"
mysql -h'127.0.0.1' -u'root' -p'root' -P'3306' -e "GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost IDENTIFIED BY 'zabbix';"   

#导入数据表到zabbix数据库
mysql -h'127.0.0.1' -u'zabbix' -p'zabbix' -P'3306' zabbix < ./zabbix-3.2.6/database/mysql/schema.sql 
mysql -h'127.0.0.1' -u'zabbix' -p'zabbix' -P'3306' zabbix < ./zabbix-3.2.6/database/mysql/images.sql 
mysql -h'127.0.0.1' -u'zabbix' -p'zabbix' -P'3306' zabbix < ./zabbix-3.2.6/database/mysql/data.sql 

#编译安装
cd zabbix-3.2.6
./configure --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
make
make install

#拷贝zabbix web到
mkdir /var/www/html/zabbix/
cp -ar ${Path}/zabbix-3.2.6/frontends/php/* /var/www/html/zabbix/
chown -R daemon:daemon /var/www/html/zabbix/

#返回脚本所在目录
cd ${Path}

#修改配置文件
sed -i "s/# DBHost=localhost/DBHost=localhost/g;
        s/# ListenPort=10051/ListenPort=10051/g;
        s/# DBPassword=/DBPassword=zabbix/g" /usr/local/etc/zabbix_server.conf

sed -i "s/post_max_size = 8M/post_max_size = 16M/g;
        s/max_execution_time = 30/max_execution_time = 300/g;
        s/max_input_time = 60/max_input_time = 300/g;
        s/;date.timezone =/date.timezone = Asia\/Shanghai/g" /etc/php.ini

#设置zabbix_agentd、zabbix_server开机启动
cp -a ${Path}/zabbix-3.2.6/misc/init.d/fedora/core/zabbix_* /etc/init.d/
chown root:root /etc/init.d/zabbix_*

chkconfig --add zabbix_agentd
chkconfig --add zabbix_server

chkconfig --level 3 zabbix_agentd on
chkconfig --level 3 zabbix_server on

#启动zabbix_agentd、zabbix_server
service zabbix_agentd start
service zabbix_server start

#启动Apache，设置开机启动
service httpd start
chkconfig --level 3 httpd on

#修改iptables，允许访问80、10050、10051
LineNumber=`iptables -t filter -nv -L INPUT --line-numbers | egrep 'reject-with icmp-host-prohibited' | awk '{print $1}'`

iptables -I INPUT ${LineNumber} -p tcp --dport 80 -j ACCEPT
iptables -I INPUT ${LineNumber} -p tcp --dport 10050 -j ACCEPT
iptables -I INPUT ${LineNumber} -p tcp --dport 10051 -j ACCEPT

service iptables save

#关闭selinux
if [ `getenforce` == 'Enforcing' ];then
    setenforce 0
    sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
fi

#是否重启
read -p 'Would you like to reboot this mechine ?[Y/N]' UserInput
if [ ${UserInput} == 'y' ] || [ ${UserInput} == 'Y' ];then
    reboot
else
    echo '任务已结束，稍后请自行重启！'
fi
