[TOC]

###运行aria2
```shell
screen -dmS aria2 aria2c --conf-path=/root/.aria2/aria2.conf
```

###开机自启动
```shell
echo “screen -dmS aria2 aria2c --conf-path=/root/.aria2/aria2.conf” >> /etc/rc.local
```
