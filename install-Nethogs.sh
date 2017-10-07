#!/bin/bash
cd /root
wget --no-check-certificate https://sourceforge.net/projects/nethogs/files/nethogs/0.8/nethogs-0.8.0.tar.gz/download
yum -y install libpcap-devel  ncurses* gcc "gcc-c++.x86_64"
tar zxvf nethogs-v0.8.0.tar.gz
cd nethogs-v0.8.0
make && make install

