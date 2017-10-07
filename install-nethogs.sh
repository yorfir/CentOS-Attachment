#!/bin/bash
cd /root
wget -c https://github.com/raboof/nethogs/archive/v0.8.5.tar.gz
yum -y install gcc "gcc-c++.x86_64"
yum install ncurses* -y
yum install libpcap-dev libncurses5-dev -y
tar zxvf v0.8.5.tar.gz
cd ./nethogs-0.8.5/
make && sudo make install

