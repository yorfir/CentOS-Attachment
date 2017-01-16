###CentOS安装
如果没有git/wget命令请安装，安装代码如下
```
yum install -y git 
或者
yum install -y wget
```

如果没有screen请使用以下代码安装
```
yum install -y screen
```


##1.安装配置Aria2
1-1.安装repoforge应用源（[使用指南](http://repoforge.org/use/)）
```
cat /etc/redhat-release   #查看EL版本
uname -a #查看32位或64位
wget package-filename-url #下载最新repoforge应用源
rpm -ivh package-filename #安装最新repoforge应用源
```
1.2安装Aria2
```
yum -y install aria2
```

1.3配置Aria2
```
mkdir /root/.aria2
wget --no-check-certificate https://raw.githubusercontent.com/yorfir/CentOS-Attachment/master/aria2.config /root/.aria2/aria2.config
wget --no-check-certificate https://raw.githubusercontent.com/yorfir/CentOS-Attachment/master/dht.dat /root/.aria2/dht.dat
echo '' > /root/aria2.session 
```
1.4启动Aria2
```shell
screen -dmS aria2 aria2c --conf-path=/root/.aria2/aria2.conf
```

##2.设置开机自启动
```shell
echo “screen -dmS aria2 aria2c --conf-path=/root/.aria2/aria2.conf” >> /etc/rc.local
```
##3.关闭iptables
```
永久开启：chkconfig iptables on
永久关闭：chkconfig iptables off
```

另外Webdir的PHP要求在PHP5.4及以上
推荐另外再用上webui-Aria2来进行管理
