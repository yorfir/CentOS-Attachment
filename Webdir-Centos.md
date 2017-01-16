[TOC]

###运行aria2
`screen -dmS aria2 aria2c --conf-path=/root/.aria2/aria2.conf`

###开机自启动
`echo “screen -dmS aria2 aria2c --conf-path=/root/.aria2/aria2.conf” >> /etc/rc.local`
