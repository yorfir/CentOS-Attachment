#!/bin/bash
cd /root
wget --no-check-certificate https://github.com/raboof/nethogs/archive/v0.8.5.tar.gz -O nethogs-v0.8.5.tar.gz
yum -y install libpcap-devel  ncurses-devel
tar zxvf nethogs-v0.8.5.tar.gz
cd nethogs-v0.8.5
make && make install 
