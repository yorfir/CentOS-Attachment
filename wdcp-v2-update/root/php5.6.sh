#!/bin/bash
# PHP 5.6.16 update scripts
# Author: wdlinux
# Url: http://www.wdlinux.cn
# Modify: KenGe

if [ ! $1 ];then
	Ver=5.6.16
else
	Ver=$1
fi

###yum
yum clean all
yum install -y gcc gcc-c++ make autoconf libtool-ltdl-devel gd-devel freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel curl-devel patch libmcrypt-devel libmhash-devel ncurses-devel bzip2-devel libcap-devel gmp-devel t1lib-devel libc-client-devel sqlite-devel aspell-devel readline-devel recode-devel libtidy-devel libxslt-devel openldap-devel
ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so
###
if [ ! -f php-${Ver}.tar.gz ];then
	wget -c http://cn2.php.net/distributions/php-${Ver}.tar.gz
fi
if [ ! -f iconv_ins.sh ];then
	wget -c http://down.wdlinux.cn/in/iconv_ins.sh
	sh iconv_ins.sh
fi

###
if [ -f /www/wdlinux/mysql/lib/libmysqlclient.so.18 ];then
	if [ -d /usr/lib64 ];then
		LIBNCU="/usr/lib64"
	else
		LIBNCU="/usr/lib"
	fi
	ln -sf /www/wdlinux/mysql/lib/libmysqlclient.so.18 $LIBNCU
fi

tar zxvf php-${Ver}.tar.gz
cd php-${Ver}
if [ -d /www/wdlinux/apache_php ];then
make clean
	./configure --prefix=/www/wdlinux/apache_php-${Ver} --with-config-file-path=/www/wdlinux/apache_php-${Ver}/etc --with-mysql=/www/wdlinux/mysql --with-iconv=/usr --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-inline-optimization --with-curl --enable-mbregex --enable-soap --with-imap --with-kerberos --with-imap-ssl --enable-mbstring --with-mcrypt=/usr --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-ftp --enable-sockets --enable-zip --with-apxs2=/www/wdlinux/apache/bin/apxs --with-mysqli=/www/wdlinux/mysql/bin/mysql_config --with-pdo-mysql=/www/wdlinux/mysql
[ $? != 0 ] && echo "configure err" && exit
make
[ $? != 0 ] && echo "make err" && exit
make install
[ $? != 0 ] && echo "make install err" && exit
cp php.ini-production /www/wdlinux/apache_php-${Ver}/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /www/wdlinux/apache_php-${Ver}/etc/php.ini
rm -f /www/wdlinux/apache_php
ln -sf /www/wdlinux/apache_php-${Ver} /www/wdlinux/apache_php
if [ ! -d /www/wdlinux/apache_php-${Ver}/lib/php/extensions ];then
	mkdir -p /www/wdlinux/apache_php-${Ver}/lib/php/extensions/no-debug-zts-20131226
	ln -sf /www/wdlinux/apache_php-${Ver}/lib/php/extensions/no-debug-zts-20131226 /www/wdlinux/apache_php-${Ver}/lib/php/extensions/no-debug-non-zts-20131226
fi
service httpd restart
echo
echo "php 升级成功！"
fi

if [ -d /www/wdlinux/nginx_php ];then
make clean
	./configure --prefix=/www/wdlinux/nginx_php-${Ver} --with-config-file-path=/www/wdlinux/nginx_php-${Ver}/etc --with-mysql=/www/wdlinux/mysql --with-iconv=/usr --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt=/usr --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-soap --with-imap --with-kerberos --with-imap-ssl  --enable-ftp --enable-sockets --enable-zip --enable-fpm --with-mysqli=/www/wdlinux/mysql/bin/mysql_config --with-pdo-mysql=/www/wdlinux/mysql
[ $? != 0 ] && echo "configure err" && exit
make
[ $? != 0 ] && echo "make err" && exit
make install
[ $? != 0 ] && echo "make install err" && exit
cp php.ini-production /www/wdlinux/nginx_php-${Ver}/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /www/wdlinux/nginx_php-${Ver}/etc/php.ini
service php-fpm stop
rm -f /www/wdlinux/nginx_php
ln -sf /www/wdlinux/nginx_php-${Ver} /www/wdlinux/nginx_php
cp /www/wdlinux/nginx_php-${Ver}/etc/php-fpm.conf.default /www/wdlinux/nginx_php-${Ver}/etc/php-fpm.conf
sed -i 's/user = nobody/user = www/g' /www/wdlinux/nginx_php/etc/php-fpm.conf
sed -i 's/group = nobody/group = www/g' /www/wdlinux/nginx_php/etc/php-fpm.conf
sed -i 's/;pid =/pid =/g' /www/wdlinux/nginx_php/etc/php-fpm.conf
cp -f sapi/fpm/init.d.php-fpm /www/wdlinux/init.d/php-fpm
chmod 755 /www/wdlinux/init.d/php-fpm
if [ ! -d /www/wdlinux/nginx_php-${Ver}/lib/php/extensions ];then
	mkdir -p /www/wdlinux/nginx_php-${Ver}/lib/php/extensions/no-debug-zts-20131226
	ln -sf /www/wdlinux/nginx_php-${Ver}/lib/php/extensions/no-debug-zts-20131226 /www/wdlinux/nginx_php-${Ver}/lib/php/extensions/no-debug-non-zts-20131226
fi
service php-fpm start
echo
echo "php 升级成功！"
fi
echo
