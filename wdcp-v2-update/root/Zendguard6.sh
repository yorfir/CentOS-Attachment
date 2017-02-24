#!/bin/bash
case $1 in
"5.4")
        F="ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386"
        Aurl="http://downinfo.myhostadmin.net/guard/6.0.0"
        if [[ `uname -m` == "x86_64" ]];then
           F="ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64"
        fi
	F1=$F/php-5.4.x
;;
"5.5")
        F="zend-loader-php5.5-linux-i386"
        Aurl="http://downinfo.myhostadmin.net/guard/7.0.0"
        if [[ `uname -m` == "x86_64" ]];then
           F="zend-loader-php5.5-linux-x86_64"
        fi 
	F1=$F
;;
"5.6")
        F="zend-loader-php5.6-linux-i386"
        Aurl="http://downinfo.myhostadmin.net/guard/7.0.0"
        if [[ `uname -m` == "x86_64" ]];then
           F="zend-loader-php5.6-linux-x86_64"
        fi 
	F1=$F
;;
*)
echo "请执行sh Zendguard6.sh 5.4或5.5或5.6,暂不支持其他版本 "
exit
;;
esac

if [ ! -f $F ];then
	wget -c $Aurl/$F.tar.gz
fi
tar zxvf $F.tar.gz
[ $? != 0 ] && echo "file err" && exit
if [ ! -d /www/wdlinux/Zend/lib ];then
	mkdir -p /www/wdlinux/Zend/lib
fi
cp $F1/*.so /www/wdlinux/Zend/lib/
grep '\[Zend\]' /www/wdlinux/apache_php/etc/php.ini
if [ $? != 0 -a -f /www/wdlinux/apache_php/etc/php.ini ];then
echo '[Zend]
zend_extension = /www/wdlinux/Zend/lib/ZendGuardLoader.so
zend_loader.enable = 1' >> /www/wdlinux/apache_php/etc/php.ini
fi
grep '\[Zend\]' /www/wdlinux/nginx_php/etc/php.ini
if [ $? != 0 -a -f /www/wdlinux/nginx_php/etc/php.ini ];then
echo '[Zend]
zend_extension = /www/wdlinux/Zend/lib/ZendGuardLoader.so
zend_loader.enable = 1' >> /www/wdlinux/nginx_php/etc/php.ini
fi
echo
echo "ZendGuardLoader is OK"
