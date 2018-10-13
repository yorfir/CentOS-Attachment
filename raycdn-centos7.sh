yum install -y wget && wget  --http-user=cj22  --http-passwd=raycdn995225  https://www.cj22.cn/raycdn/raycdn_Centos7_dependence_rpm.tar.gz
tar  xf  raycdn_Centos7_dependence_rpm.tar.gz
cd  raycdn_Centos7_dependence_rpm
yum  localinstall  *  -y
wget  --http-user=cj22  --http-passwd=raycdn995225  https://www.cj22.cn/raycdn/raycdn-Centos7-1.0.0-1.el6.x86_64.rpm
rpm  -ivh  raycdn-Centos7-1.0.0-1.el6.x86_64.rpm
