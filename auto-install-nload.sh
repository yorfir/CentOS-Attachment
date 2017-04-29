yum -y install gcc gcc-c++ kernel-devel
yum -y install ncurses-devel
wget http://www.roland-riegel.de/nload/nload-0.7.4.tar.gz
tar zxvf nload-0.7.4.tar.gz
cd nload-0.7.4
./configure;make;make install
echo -e "\033[37;31;5mnload安装成功，输入nload查看...\033[39;49;0m"
