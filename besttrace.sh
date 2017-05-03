#!/bin/bash
cd /root
wget --no-check-certificate https://raw.githubusercontent.com/yorfir/CentOS-Attachment/master/soft/besttrace4linux.zip
yum -y install unzip
unzip besttrace4linux.zip
chmod a+x besttrace
echo -e "\033[37;31;5mbesttrace安装成功，输入./besttrace+ip 使用...\033[39;49;0m"
