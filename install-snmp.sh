yum install -y net-snmp && rocommunity zuanshi 128.1.235.43 && service snmpd start && chkconfig snmpd on && iptables -A INPUT  -p udp -s 128.1.235.43 --dport 161 -j ACCEPT && service iptables save
