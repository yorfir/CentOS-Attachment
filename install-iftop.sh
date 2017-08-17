yum -y install gcc-c++ && yum -y install flex && yum -y install bison
cd /root
wget http://www.tcpdump.org/release/libpcap-1.8.1.tar.gz
tar zxvf libpcap-1.8.1.tar.gz
cd libpcap-1.8.1
./configure
make && make install
cd /root
wget http://www.ex-parrot.com/~pdw/iftop/download/iftop-0.17.tar.gz
tar zxvf iftop-0.17.tar.gz
cd iftop-0.17
./configure
make && make install
