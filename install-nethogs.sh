#!/bin/bash
cd /root
wget --no-check-certificate https://downloads.sourceforge.net/project/nethogs/nethogs/0.8/nethogs-0.8.0.tar.gz
yum -y install libpcap-devel  ncurses* gcc "gcc-c++.x86_64"
tar zxvf nethogs-0.8.0.tar.gz
cd nethogs-0.8.0
make && make install

