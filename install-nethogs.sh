#!/bin/bash
cd /root
wget https://downloads.sourceforge.net/project/nethogs/nethogs/0.8/nethogs-0.8.0.tar.gz
yum -y install gcc "gcc-c++.x86_64"
yum install ncurses* -y
yum install libpcap-dev libncurses5-dev -y
tar zxvf nethogs-0.8.0.tar.gz
cd nethogs
make && make install

