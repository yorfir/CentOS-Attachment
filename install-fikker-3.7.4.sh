#!/bin/bash
# Version:0.1
# Author:www.bgp.la
service iptables stop 2> /dev/null ; service ip6tables stop 2> /dev/null ; chkconfig iptables off 2> /dev/null ; chkconfig ip6tables off 2> /dev/null ; service httpd stop 2> /dev/null ; service nginx stop 2> /dev/null ; chkconfig httpd off 2> /dev/null ; chkconfig nginx off 2> /dev/null ; systemctl stop firewalld.service 2> /dev/null ; systemctl disable firewalld.service 2> /dev/null ; systemctl stop httpd.service 2> /dev/null ; systemctl stop nginx.service 2> /dev/null ; systemctl disable httpd.service 2> /dev/null ; systemctl disable nginx.service 2> /dev/null ; yum -y install wget ; cd /root ; wget --no-check-certificate -c https://raw.githubusercontent.com/yorfir/CentOS-Attachment/master/soft/fikkerd-3.7.4-linux-x86-64.tar.gz && tar zxf fikkerd-3.7.4-linux-x86-64.tar.gz && rm -rf fikkerd-3.7.4-linux-x86-64.tar.gz && cd fikkerd-3.7.3-linux-x86-64 && ./fikkerd.sh install && ./fikkerd.sh start && cd /root && sleep 5 && echo 'finished!'
