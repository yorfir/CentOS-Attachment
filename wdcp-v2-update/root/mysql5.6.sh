#!/bin/bash
# MySQL 5.5.36 update scripts
# Author: wdlinux
# Url: http://www.wdlinux.cn
# Modify: KenGe
IN_DIR="/www/wdlinux"
#cpu = `grep 'processor' /proc/cpuinfo | sort -u | wc -l`
if [ ! $1 ];then
	MYS_VER=5.5.36
	parameter="-DCMAKE_INSTALL_PREFIX=$IN_DIR/mysql-$MYS_VER -DSYSCONFDIR=$IN_DIR/etc -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_SSL=no -DWITH_DEBUG=OFF -DWITH_EXTRA_CHARSETS=complex -DENABLED_PROFILING=ON -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1"
else
	MYS_VER=5.6.28
	parameter="-DCMAKE_INSTALL_PREFIX=$IN_DIR/mysql-$MYS_VER -DSYSCONFDIR=$IN_DIR/etc -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_SSL=bundled -DWITH_DEBUG=OFF -DWITH_EXTRA_CHARSETS=complex -DENABLED_PROFILING=ON -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DENABLE_DOWNLOADS=1"
fi
if [ ! -f mysql-${MYS_VER}.tar.gz ];then
	wget -c http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-${MYS_VER}.tar.gz
fi
yum install -y cmake bison libmcrypt-devel libjpeg-devel libpng-devel freetype-devel curl-devel openssl-devel libxml2-devel zip unzip
tar zxvf mysql-${MYS_VER}.tar.gz
cd mysql-${MYS_VER}
cmake $parameter
[ $? != 0 ] && echo "configure err" && exit
make 
[ $? != 0 ] && echo "make err" && exit
make install
[ $? != 0 ] && echo "make install err" && exit
service mysqld stop
if [ ! -d $IN_DIR/mysql_west_bak ];then
mkdir -p $IN_DIR/mysql_west_bak
cp -pR $IN_DIR/mysql/var/* $IN_DIR/mysql_west_bak
fi
rm -f $IN_DIR/mysql
ln -sf $IN_DIR/mysql-$MYS_VER $IN_DIR/mysql
sh scripts/mysql_install_db.sh --user=mysql --basedir=$IN_DIR/mysql --datadir=$IN_DIR/mysql/data
chown -R mysql.mysql $IN_DIR/mysql/data
mv $IN_DIR/mysql/data $IN_DIR/mysql/databak
ln -s /home/wddata/var $IN_DIR/mysql/data
if [  $1 ];then
	sed -i "/^\[mysqld\]/a\explicit_defaults_for_timestamp=true" /home/wddata/etc/my.cnf
        ls $IN_DIR/mysql/data/ib*|xargs rm -rf
fi
cp support-files/mysql.server $IN_DIR/init.d/mysqld
sed -i 's/skip-locking/skip-external-locking/g' /home/wddata/etc/my.cnf

chmod 755 $IN_DIR/init.d/mysqld
sh scripts/mysql_install_db.sh --user=mysql --basedir=$IN_DIR/mysql --datadir=$IN_DIR/mysql/data

/www/wdlinux/mysql/bin/mysqld_safe --skip-grant-tables &
sleep 5
/www/wdlinux/mysql/bin/mysql_upgrade -uroot  -proot

service mysqld restart
#if [ -d $IN_DIR/mysql-5.1.63 ];then
	#只升级mysql,不重新编译php情况下用
	#ln -sf $IN_DIR/mysql-5.1.63/lib/mysql/libmysqlclient.so.16* /usr/lib/

	ln -sf $IN_DIR/mysql/lib/libmysqlclient.so.18.0.0 /usr/lib/libmysqlclient.so.18
	
	#编译了php5.3以上,mysqlclient仍想用旧版本用
	#ln -sf /www/wdlinux/mysql-5.1.61/lib/mysql/libmysqlclient.so.16.0.0 /usr/lib/libmysqlclient.so.18
#fi
sleep 2
sh $IN_DIR/tools/mysql_wdcp_chg.sh
service mysqld restart
echo
echo "MYSQL 升级结束！"
mysql -V