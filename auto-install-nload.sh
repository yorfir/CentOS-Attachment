yum install gcc gcc-c++ kernel-devel
yum install ncurses-devel
wget http://www.roland-riegel.de/nload/nload-0.7.4.tar.gz
tar zxvf nload-0.7.4.tar.gz
cd nload-0.7.4
./configure;make;make install
