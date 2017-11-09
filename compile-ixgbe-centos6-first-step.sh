yum install gcc make perl wget screen -y && yum install kernel-devel
wget https://sourceforge.net/projects/e1000/files/ixgbe%20stable/5.3.3/ixgbe-5.3.3.tar.gz
tar -xvf ixgbe-5.3.3.tar.gz && cd ixgbe-5.3.3/src && make


