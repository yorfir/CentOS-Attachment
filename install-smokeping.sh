#!/bin/bash
#Date 2018/9/15
#mail kg@noc.im
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
sed -i "s/SELINUX=enforcing/SELINUX=disabled/"  /etc/selinux/config
setenforce 0
which  ntpdate
if [ $? -eq 0 ];then
    /usr/sbin/ntpdate time1.aliyun.com
    echo "*/5 * * * * /usr/sbin/ntpdate -s time1.aliyun.com">>/var/spool/cron/root 
else
    yum install ntpdate -y
    /usr/sbin/ntpdate time1.aliyun.com
    echo "*/5 * * * * /usr/sbin/ntpdate -s time1.aliyun.com">>/var/spool/cron/root 
fi
clear
echo "##########################################"
echo "Auto Install smokeping-2.6.11          ##"
echo "Press Ctrl + C to cancel                ##"
echo "Any key to continue                    ##"
echo "##########################################"
read -n 1
/etc/init.d/iptables status >/dev/null 2>&1
if [ $? -eq 0 ]
then
iptables -I INPUT -p tcp --dport 80 -j ACCEPT &&
iptables-save >/dev/null 2>&1
else
    echo -e "\033[32m iptables is stopd\033[0m"
fi
IP=`/sbin/ifconfig|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/1p'|sed -n '1p'`
sed -i "s/SELINUX=enforcing/SELINUX=disabled/"  /etc/selinux/config
setenforce 0
rpm -Uvh http://apt.sw.be/RedHat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm 1>/dev/null
yum -y install perl perl-Net-Telnet perl-Net-DNS perl-LDAP perl-libwww-perl perl-RadiusPerl perl-IO-Socket-SSL perl-Socket6 perl-CGI-SpeedyCGI perl-FCGI perl-CGI-SpeedCGI perl-Time-HiRes perl-ExtUtils-MakeMaker perl-RRD-Simple rrdtool rrdtool-perl curl fping echoping  httpd httpd-devel gcc make  wget libxml2-devel libpng-devel glib pango pango-devel freetype freetype-devel fontconfig cairo cairo-devel libart_lgpl gcc libart_lgpl-devel mod_fastcgi wget wqy-*
if [ -d /opt ];then
    cd /opt
else
    mkdir -p /opt && cd /opt
fi
wget -c http://oss.oetiker.ch/smokeping/pub/smokeping-2.6.11.tar.gz
tar -xvf smokeping-2.6.11.tar.gz 1>/dev/null
cd /opt/smokeping-2.6.11
./setup/build-perl-modules.sh /usr/local/smokeping/thirdparty
./configure -prefix=/usr/local/smokeping
/usr/bin/gmake install  1>/dev/null
cd /usr/local/smokeping
mkdir cache data var 1>/dev/null
touch /var/log/smokeping.log
chown -R apache:apache cache data var
chown -R apache:apache /var/log/smokeping.log
mv /usr/local/smokeping/htdocs/smokeping.fcgi.dist  /usr/local/smokeping/htdocs/smokeping.fcgi
mv /usr/local/smokeping/etc/config.dist  /usr/local/smokeping/etc/config
cp -f /usr/local/smokeping/etc/config /usr/local/smokeping/etc/config.back
sed -i "s/some.url/IP/g" /usr/local/smokeping/etc/config
chmod 600 /usr/local/smokeping/etc/smokeping_secrets.dist
 
if [ -d /opt ];then
    cd /opt
else
    mkdir -p /opt && cd /opt
fi
wget -c -O /opt/fping-4.0.tar.gz http://fping.org/dist/fping-4.0.tar.gz
tar zxvf fping-4.0.tar.gz
cd fping-4.0
./configure --prefix=/usr/local/fping
make && make install
sed -i "s#`grep fping /usr/local/smokeping/etc/config`#binary = /usr/local/fping/sbin/fping#g" /usr/local/smokeping/etc/config
sed -i "148i'--font TITLE:20:"WenQuanYi\ Zen\ Hei\ Mono"'\," /usr/local/smokeping/lib/Smokeping/Graphs.pm
cp -rf /etc/httpd/conf/httpd.conf  /etc/httpd/conf/httpd.conf.back
cat >> /etc/httpd/conf/httpd.conf <<'EOF'
Alias /cache "/usr/local/smokeping/cache/"
Alias /cropper "/usr/local/smokeping/htdocs/cropper/"
Alias /smokeping "/usr/local/smokeping/htdocs/smokeping.fcgi"
<Directory "/usr/local/smokeping">
AllowOverride None
Options All
AddHandler cgi-script .fcgi .cgi
Order allow,deny
Allow from all
DirectoryIndex smokeping.fcgi
</Directory>
EOF
 
if [ -f /etc/init.d/smokeping ];then
    echo "/etc/init.d/smokeping is exist"
else
    touch /etc/init.d/smokeping
    cat > /etc/init.d/smokeping <<'EOF'
    #!/bin/bash
    #chkconfig: 2345 80 05
    # Description: Smokeping init.d script
    # Create by : Mox
    # Get function from functions library
    . /etc/init.d/functions
    # Start the service Smokeping
    smokeping=/usr/local/smokeping/bin/smokeping
    prog=smokeping
    pidfile=${PIDFILE-/usr/local/smokeping/var/smokeping.pid}
    lockfile=${LOCKFILE-/var/lock/subsys/smokeping}
    RETVAL=0
    STOP_TIMEOUT=${STOP_TIMEOUT-10}
    LOG=/var/log/smokeping.log
 
    start() {
        echo -n $"Starting $prog: "
        LANG=$HTTPD_LANG daemon --pidfile=${pidfile} $smokeping $OPTIONS
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch ${lockfile}
        return $RETVAL
    }
 
 
    # Restart the service Smokeping
    stop() {
        echo -n $"Stopping $prog: "
        killproc -p ${pidfile} -d ${STOP_TIMEOUT} $smokeping
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && rm -f ${lockfile} ${pidfile}
    }
 
    STOP_TIMEOUT=${STOP_TIMEOUT-10}
    LOG=/var/log/smokeping.log
 
    start() {
        echo -n $"Starting $prog: "
        LANG=$HTTPD_LANG daemon --pidfile=${pidfile} $smokeping $OPTIONS
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch ${lockfile}
        return $RETVAL
    }
 
 
    # Restart the service Smokeping
    stop() {
        echo -n $"Stopping $prog: "
        killproc -p ${pidfile} -d ${STOP_TIMEOUT} $smokeping
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && rm -f ${lockfile} ${pidfile}
    }
 
    case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    status)
        status -p ${pidfile} $httpd
        RETVAL=$?
    ;;
    restart)
        stop
        start
        ;;
    *)
        echo $"Usage: $prog {start|stop|restart|status}"
        RETVAL=2
 
    esac
 
EOF
fi
 
cat > /usr/local/smokeping/etc/config <<'EOF'
*** General ***
 
owner    = xiaomatechnology
contact  = kg@noc.im
#mailhost = smtp.163.com:25
#mailusr  = xuel@linuxidc
#mailpwd  = kg@noc.im
#sendmail = /usr/sbin/sendmail
# NOTE: do not put the Image Cache below cgi-bin
# since all files under cgi-bin will be executed ... this is not
# good for images.
imgcache = /usr/local/smokeping/cache
imgurl  = cache
datadir  = /usr/local/smokeping/data
piddir  = /usr/local/smokeping/var
cgiurl  = http://$IP/smokeping.cgi
smokemail = /usr/local/smokeping/etc/smokemail.dist
tmail = /usr/local/smokeping/etc/tmail.dist
# specify this to get syslog logging
syslogfacility = local0
# each probe is now run in its own process
# disable this to revert to the old behaviour
# concurrentprobes = no
 
*** Alerts ***
to = zhugeyufeng@139.com
from = noc@xiaoma.tw
 
+someloss
type = loss
# in percent
pattern = >0%,*12*,>0%,*12*,>0%
comment = loss 3 times  in a row
 
+rttdetect
type = rtt
 #in milli seconds
pattern = <10,<10,<10,<10,<10,<100,>100,>100,>100
edgetrigger = yes
comment = routing messed up again ?
 
+lossdetect
type = loss
# in percent
pattern = ==0%,==0%,==0%,==0%,>20%,>20%,>20%
edgetrigger = yes
comment = suddenly there is packet loss
 
+miniloss
type = loss
# in percent
pattern = >0%,*12*,>0%,*12*,>0%
edgetrigger = yes
#pattern = >0%,*12*
comment = detected loss 1 times over the last two hours
 
#+rttdetect
#type = rtt
# in milliseconds
#pattern = <1,<1,<1,<1,<1,<2,>2,>2,>2
#comment = routing messed up again ?
 
+rttbad
type = rtt
# in milliseconds
edgetrigger = yes
pattern = ==S,>20
comment = route
 
+rttbadstart
type = rtt
# in milliseconds
edgetrigger = yes
pattern = ==S,==U
comment = offline at startup
*** Database ***
 
step    = 60
pings    = 20
 
# consfn mrhb steps total
 
AVERAGE  0.5  1  1008
AVERAGE  0.5  12  4320
    MIN  0.5  12  4320
    MAX  0.5  12  4320
AVERAGE  0.5 144  720
    MAX  0.5 144  720
    MIN  0.5 144  720
 
*** Presentation ***
charset = utf-8
template = /usr/local/smokeping/etc/basepage.html.dist
 
+ charts
 
menu = 排行榜
title = 排行榜
 
++ stddev
sorter = StdDev(entries=>4)
title = 综合指数排行
menu = 综合指数排行
format = 综合指数 %f
 
++ max
sorter = Max(entries=>5)
title = 最大延迟排行
menu = 最大延迟排行
format = 最大延迟时间 %f 秒
 
++ loss
sorter = Loss(entries=>5)
title = 丢包率排行
menu = 丢包率排行
format = 丢包 %f
 
++ median
sorter = Median(entries=>5)
title = 平均延迟排行
menu = 平均延迟排行
format = 平均延迟 %f 秒
 
+ overview
 
width = 860
height = 150
range = 10h
 
+ detail
 
width = 860
height = 200
unison_tolerance = 2
 
"Last 3 Hours"    3h
"Last 30 Hours"  30h
"Last 10 Days"    10d
"Last 30 Days"  30d
"Last 90 Days"  90d
#+ hierarchies
#++ owner
#title = Host Owner
#++ location
#title = Location
 
*** Probes ***
 
+ FPing
 
binary = /usr/local/fping/sbin/fping
 
*** Slaves ***
secrets=/usr/local/smokeping/etc/smokeping_secrets.dist
+boomer
display_name=boomer
color=0000ff
 
+slave2
display_name=another
color=00ff00
 
*** Targets ***
 
probe = FPing
 
menu = Top
#title = Network Latency Grapher
title = 欢迎访问XiaoMa Technology网络节点质量监控
#remark = Welcome to the SmokePing website of xxx Company. \
#        Here you will learn all about the latency of our network.
remark = XiaoMa Technology网络质量监控系统
 
 
#+ Mobile
+ YD_huabei
menu = China Mobile huabei
title = 移动 华北地区
 
++ YD_beiing
menu = 移动北京
title = YD_beijing 218.200.240.1
host = 218.200.240.1
 
++ YD_tianjin
menu = 移动天津
title = YD_tianjin 211.137.160.1
host = 211.137.160.1
 
++ YD_shijiazhuang
menu = 移动石家庄
title = YD_shijiazhuang 218.207.64.1
host = 218.207.64.1
 
++ YD_taiyuan
menu = 移动太原
title = YD_taiyuan 211.142.0.1
host = 211.142.0.1
 
++ YD_huabeibb
menu = 移动华北骨干
title = YD_huabeibb 211.136.67.101
host = 211.136.67.101
 
+ YD_dongbei
menu = China Mobile dongbei
title = 移动东北地区
 
++ YD_shenyang
menu = 移动沈阳
title = YD_shenyang 221.180.131.1
host = 221.180.131.1
 
++ YD_changchun
menu = 移动长春
title = YD_changchun 211.141.71.1
host = 211.141.71.1
 
+ YD_huadong
menu = China Mobile huadong
title = 移动华东地区
 
++ YD_huadongbb
menu = 移动华东骨干
title = YD_huadongbb 211.141.71.1
host = 211.141.71.1
 
++ YD_shanghai
menu = 移动上海
title = YD_shanghai 117.131.0.1
host = 117.131.0.1
 
++ YD_wuxi
menu = 移动无锡
title = YD_wuxi 120.195.152.1
host = 120.195.152.1
 
++ YD_yantai
menu = 移动烟台
title = YD_yantai 211.137.206.113
host = 211.137.206.113
 
++ YD_hangzhou
menu = 移动杭州
title = YD_hangzhou 211.140.0.8
host = 211.140.0.8
 
+ YD_zhongnan
menu = China Mobile zhongnan
title = 移动中南地区
 
++ YD_wuhan
menu = 移动武汉
title = YD_wuhan 120.202.0.1
host = 120.202.0.1
 
++ YD_guangzhou
menu = 移动广州
title = YD_guangzhou 211.139.145.239
host = 211.139.145.239
 
++ YD_changsha
menu = 移动长沙
title = YD_changsha 211.143.5.1
host = 211.143.5.1
 
+ YD_xibei
menu = China Mobile xibei
title = 移动西北地区
 
++ YD_xining
menu = 移动西宁
title = YD_xining 111.12.255.29
host = 111.12.255.29
 
++ YD_yinchuan
menu = 移动银川
title = YD_yinchuan 111.49.10.1
host = 111.49.10.1
 
++ YD_xian
menu = 移动西安
title = YD_xian 218.200.63.185
host = 218.200.63.185
 
+ YD_HuiZong
menu = China Mobile HuiZong
title = 移动汇总
 
++ YD_HuiZong
menu = 移动汇总
title = YD_HuiZong
host = /YD_huabei/YD_beiing /YD_huabei/YD_tianjin /YD_huabei/YD_shijiazhuang /YD_huabei/YD_taiyuan /YD_huabei/YD_huabeibb /YD_dongbei/YD_shenyang /YD_dongbei/YD_changchun /YD_huadong/YD_huadongbb /YD_huadong/YD_shanghai /YD_huadong/YD_wuxi /YD_huadong/YD_yantai /YD_huadong/YD_hangzhou /YD_zhongnan/YD_wuhan /YD_zhongnan/YD_guangzhou /YD_zhongnan/YD_changsha /YD_xibei/YD_xining /YD_xibei/YD_yinchuan /YD_xibei/YD_xian
 
#+ Unicom
+ UN_xibei
menu = China Unicom xibei
title = 联通西北地区
 
++ UN_lanzhou
menu = 联通兰州
title = UN_lanzhou 115.85.195.1
host = 115.85.195.1
 
++ UN_xian
menu = 联通西安
title = UN_xian 124.89.76.1
host = 124.89.76.1
 
++ UN_jiuquan
menu = 联通酒泉
title = UN_jiuquan 221.7.43.1
host = 221.7.43.1
 
+ UN_xinan
menu = China Unicom xinan
title = 联通西南地区
 
++ UN_xinanbb
menu = 联通西南骨干
title = UN_xinanbb 219.158.14.66
host = 219.158.14.66
 
++ UN_chongqing
menu = 联通重庆
title = UN_chongqing 221.5.203.86
host = 221.5.203.86
 
++ UN_guiyang
menu = 联通贵阳
title = UN_guiyang 58.16.254.82
host = 58.16.254.82
 
++ UN_puer
menu = 联通普洱
title = UN_puer 221.3.161.1
host = 221.3.161.1
 
+ UN_zhongnan
menu = China Unicom zhongnan
title = 联通中南地区
 
++ UN_zhongnanbb
menu = 联通中南骨干
title = UN_zhongnanbb 219.158.112.46
host = 219.158.112.46
 
++ UN_kaifeng
menu = 联通开封
title = UN_kaifeng 61.53.134.1
host = 61.53.134.1
 
++ UN_changsha
menu = 联通长沙
title = UN_changsha 58.20.127.238
host = 58.20.127.238
 
++ UN_nanning
menu = 联通南宁
title = UN_nanning 221.7.128.68
host = 221.7.128.68
 
++ UN_guangzhou
menu = 联通广州
title = UN_guangzhou 221.4.66.66
host = 221.4.66.66
 
++ UN_wuhan
menu = 联通武汉
title = UN_wuhan 218.104.111.122
host = 218.104.111.122
 
++ UN_zhengzhou
menu = 联通郑州
title = UN_zhengzhou 125.46.62.1
host = 125.46.62.1
 
+ UN_huadong
menu = China Unicom huadong
title = 联通华东地区
 
++ UN_shanghai
menu = 联通上海
title = UN_shanghai 58.246.48.1
host = 58.246.48.1
 
++ UN_hangzhou
menu = 联通杭州
title = UN_hangzhou 60.12.141.49
host = 60.12.141.49
 
++ UN_putian
menu = 联通莆田
title = UN_putian 58.22.128.2
host = 58.22.128.2
 
++ UN_nanchang
menu = 联通南昌
title = UN_nanchang 58.17.30.1
host = 58.17.30.1
 
++ UN_xiamen
menu = 联通厦门
title = UN_xiamen 36.250.77.34
host = 36.250.77.34
 
++ UN_qingdao
menu = 联通青岛
title = UN_qingdao 202.102.128.68
host = 202.102.128.68
 
+ UN_dongbei
menu = China Unicom dongbei
title = 联通东北地区
 
++ UN_dongbeibb
menu = 联通东北骨干
title = UN_dongbeibb 219.158.105.234
host = 219.158.105.234
 
++ UN_shenyang
menu = 联通沈阳
title = UN_shenyang 124.95.173.47
host = 124.95.173.47
 
++ UN_jilin
menu = 联通吉林
title = UN_jilin 139.214.195.240
host = 139.214.195.240
 
++ UN_haerbin
menu = 联通哈尔滨
title = UN_haerbin 202.97.207.240
host = 202.97.207.240
 
++ UN_fushun
menu = 联通抚顺
title = UN_fushun 60.18.95.1
host = 60.18.95.1
 
+ UN_huabei
menu = China Unicom huabei
title = 联通华北地区
 
++ UN_huabeibb
menu = 联通华北骨干
title = UN_huabeibb 219.158.104.134
host = 219.158.104.134
 
++ UN_alashan
menu = 联通阿拉善
title = UN_alashan 1.24.64.1
host = 1.24.64.1
 
++ UN_shijiazhuang
menu = 联通石家庄
title = UN_shijiazhuang 110.228.158.1
host = 110.228.158.1
 
++ UN_tianjin
menu = 联通天津
title = UN_tianjin 113.31.41.119
host = 113.31.41.119
 
++ UN_beijing
menu = 联通北京
title = UN_beijing 125.34.224.1
host = 125.34.224.1
 
++ UN_datong
menu = 联通大同
title = UN_datong 118.72.100.1
host = 118.72.100.1
 
++ UN_tangshan
menu = 联通唐山
title = UN_tangshan 60.2.61.88
host = 60.2.61.88
 
++ UN_changzhi
menu = 联通长治
title = UN_changzhi 60.220.216.97
host = 60.220.216.97
 
+ UN_HuiZong
menu = China Unicom HuiZong
title = 联通汇总
 
++ UN_HuiZong
menu = 联通汇总
title = UN_HuiZong
host = /UN_xibei/UN_lanzhou /UN_xibei/UN_xian /UN_xibei/UN_jiuquan /UN_xinan/UN_xinanbb /UN_xinan/UN_chongqing /UN_xinan/UN_guiyang /UN_xinan/UN_puer /UN_zhongnan/UN_zhongnanbb /UN_zhongnan/UN_kaifeng /UN_zhongnan/UN_changsha /UN_zhongnan/UN_nanning /UN_zhongnan/UN_guangzhou /UN_zhongnan/UN_wuhan /UN_zhongnan/UN_zhengzhou /UN_huadong/UN_shanghai /UN_huadong/UN_hangzhou /UN_huadong/UN_putian /UN_huadong/UN_nanchang /UN_huadong/UN_xiamen /UN_huadong/UN_qingdao /UN_dongbei/UN_dongbeibb /UN_dongbei/UN_shenyang /UN_dongbei/UN_jilin /UN_dongbei/UN_haerbin /UN_dongbei/UN_fushun /UN_huabei/UN_huabeibb /UN_huabei/UN_alashan /UN_huabei/UN_shijiazhuang /UN_huabei/UN_tianjin /UN_huabei/UN_beijing /UN_huabei/UN_datong /UN_huabei/UN_tangshan /UN_huabei/UN_changzhi
 
 
#+ Telecom
+ DX_huabei
menu = China Telecom huabei
title = 电信华北地区
 
++ DX_beijingbb
menu = 电信北京骨干
title = DX_beijingbb 180.149.128.1
host = 180.149.128.1
 
++ DX_beijing
menu = 电信北京
title = DX_beijing 106.120.186.61
host = 106.120.186.61
 
++ DX_baotou
menu = 电信包头
title = DX_baotou 1.180.80.5
host = 1.180.80.5
 
++ DX_changzhi
menu = 电信长治
title = DX_changzhi 1.70.0.1
host = 1.70.0.1
 
++ DX_tianjin
menu = 电信天津
title = DX_tianjin 202.97.79.202
host = 202.97.79.202
 
++ DX_chifeng
menu = 电信赤峰
title = DX_chifeng 123.178.241.2
host = 123.178.241.2
 
++ DX_zhangjiakou
menu = 电信张家口
title = DX_zhangjiakou 219.148.106.1
host = 219.148.106.1
 
++ DX_hebeibb
menu = 电信河北骨干
title = DX_hebeibb 218.30.102.126
host = 218.30.102.126
 
++ DX_chengde
menu = 电信承德
title = DX_chengde 27.129.62.66
host = 27.129.62.66
 
+ DX_dongbei
menu = China Telecom dongbei
title = 电信东北地区
 
++ DX_baicheng
menu = 电信白城
title = DX_baicheng 123.172.195.1
host = 123.172.195.1
 
++ DX_shenyang
menu = 电信沈阳
title = DX_shenyang 219.148.224.170
host = 219.148.224.170
 
++ DX_haerbin
menu = 电信哈尔滨
title = DX_haerbin 112.100.4.130
host = 112.100.4.130
 
+ DX_huadong
menu = China Telecom huadong
title = 电信华东地区
 
++ DX_hefei
menu = 电信合肥
title = DX_hefei 115.238.250.95
host = 115.238.250.95
 
++ DX_hangzhou
menu = 电信杭州
title = DX_hangzhou 183.136.237.178
host = 183.136.237.178
 
++ DX_nanchang
menu = 电信南昌
title = DX_nanchang 220.175.137.1
host = 220.175.137.1
 
++ DX_yantai
menu = 电信烟台
title = DX_yantai 222.173.223.97
host = 222.173.223.97
 
++ DX_zhangzhou
menu = 电信漳州
title = DX_zhangzhou 27.157.0.1
host = 27.157.0.1
 
++ DX_shanghai
menu = 电信上海
title = DX_shanghai 114.80.243.1
host = 114.80.243.1
 
+ DX_zhongnan
menu = China Telecom zhongnan
title = 电信中南地区
 
++ DX_zhengzhou
menu = 电信郑州
title = DX_zhengzhou 1.192.0.1
host = 1.192.0.1
 
++ DX_maoming
menu = 电信茂名
title = DX_maoming 121.10.173.117
host = 121.10.173.117
 
++ DX_changsha
menu = 电信长沙
title = DX_changsha 124.232.137.133
host = 124.232.137.133
 
++ DX_dongguan
menu = 电信东莞
title = DX_dongguan 125.93.74.17
host = 125.93.74.17
 
++ DX_nanning
menu = 电信南宁
title = DX_nanning 171.107.80.102
host = 171.107.80.102
 
++ DX_haikou
menu = 电信海口
title = DX_haikou 220.174.236.1
host = 220.174.236.1
 
+ DX_xinan
menu = China Telecom xinan
title = 电信西南地区
 
++ DX_kunming
menu = 电信昆明
title = DX_kunming 116.53.255.34
host = 116.53.255.34
 
++ DX_chongqing
menu = 电信重庆
title = DX_chongqing 119.84.87.231
host = 119.84.87.231
 
++ DX_chengdu
menu = 电信成都
title = DX_chengdu 125.64.99.162
host = 125.64.99.162
 
++ DX_zhidi
menu = 电信芝地
title = DX_zhidi 202.98.246.129
host = 202.98.246.129
 
++ DX_yuxi
menu = 电信玉溪
title = DX_yuxi 222.220.206.1
host = 222.220.206.1
 
+ DX_xibei
menu = China Telecom xibei
title = 电信西北地区
 
++ DX_lanzhou
menu = 电信兰州
title = DX_lanzhou 118.180.5.222
host = 118.180.5.222
 
++ DX_yinchuan
menu = 电信银川
title = DX_yinchuan 124.224.255.46
host = 124.224.255.46
 
++ DX_kuerle
menu = 电信库尔勒
title = DX_kuerle 222.83.32.6
host = 222.83.32.6
 
++ DX_wulumuqi
menu = 电信乌鲁木齐
title = DX_wulumuqi 61.128.111.1
host = 61.128.111.1
 
++ DX_yanan
menu = 电信延安
title = DX_yanan 36.43.0.1
host = 36.43.0.1
 
+ DX_HuiZong
menu = China Telecom HuiZong
title = 电信汇总
 
++ DX_HuiZong
menu = 电信汇总
title = DX_HuiZong
host = /DX_huabei/DX_beijingbb /DX_huabei/DX_beijing /DX_huabei/DX_baotou /DX_huabei/DX_changzhi /DX_huabei/DX_tianjin /DX_huabei/DX_chifeng /DX_huabei/DX_zhangjiakou /DX_huabei/DX_hebeibb /DX_huabei/DX_chengde /DX_dongbei/DX_baicheng /DX_dongbei/DX_shenyang /DX_dongbei/DX_haerbin /DX_huadong/DX_hefei /DX_huadong/DX_hangzhou /DX_huadong/DX_nanchang /DX_huadong/DX_yantai /DX_huadong/DX_zhangzhou /DX_huadong/DX_shanghai /DX_zhongnan/DX_zhengzhou /DX_zhongnan/DX_maoming /DX_zhongnan/DX_changsha /DX_zhongnan/DX_dongguan  /DX_zhongnan/DX_nanning /DX_zhongnan/DX_haikou /DX_xinan/DX_kunming /DX_xinan/DX_chongqing /DX_xinan/DX_chengdu /DX_xinan/DX_zhidi /DX_xinan/DX_yuxi /DX_xibei/DX_lanzhou /DX_xibei/DX_yinchuan /DX_xibei/DX_kuerle /DX_xibei/DX_wulumuqi /DX_xibei/DX_yanan
 
EOF
chmod +x /etc/init.d/smokeping
chkconfig smokeping on
chkconfig httpd on
/etc/init.d/httpd start
/etc/init.d/smokeping start
if [ $? -eq 0 ];then
echo -e "\\033[32m smokeping setup successfull URR：http://$IP/smokeping\\033[0m"
fi
