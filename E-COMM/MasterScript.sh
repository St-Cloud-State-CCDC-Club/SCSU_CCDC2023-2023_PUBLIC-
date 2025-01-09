#! /bin/bash

#move this file to home directory!!

#installing dependencies
yum install git

#Firewall Rules

#firewall inputs

systemctl enable --now firewalld

read -p "Enter Internal Interface: " intInterface
read -p "Enter External Interface: " extInterface

#resetting firewall to default settings
firewall-cmd --remove-service=ssh --permanent
firewall-cmd --remove-service=dhcpv6-client --permanent
firewall-cmd --complete-reload
firewall-cmd --set-default-zone=drop --permanent
firewall-cmd --zone=trusted --add-interface=$intInterface --permanent
firewall-cmd --zone=public --add-interface=$extInterface --permanent

#setting http and https to be passed through the public interface
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent

#allowing splunk forwarder
firewall-cmd --zone=public --add-port=9997/tcp --permanent

#allow time network protocols
firewall-cmd --zone=public --add-port=123/udp --permanent
firewall-cmd --zone=public --add-port=323/udp --permanent

#allowing DNS
firewall-cmd --zone=public --add-service=dns --permanent

#allowing NTP
firewall-cmd --zone=public --add-service=ntp --permanent

#allowing ICMP requests
firewall-cmd --zone=public --add-icmp-block=echo-request --permanent

#allowing local MariaDB connections
firewall-cmd --zone=trusted --add-port=3306/tcp --permanent

#reloading firewall rules to apply them
firewall-cmd --reload

#listing current firewall rules
firewall-cmd --list-all --zone=trusted
firewall-cmd --list-all --zone=public

#disabling ipv6 traffic. 
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -p

echo 'This should not include ipv6 info:'
ip a | grep inet6


#removing ssh
chkconfig sshd off
service sshd stop
yum remove ssh
yum remove openssh-server

#installing and running lynis
git clone https://github.com/CISOfy/lynis
cd lynis && ./lynis audit system --report-file /home/$USER/lynis-report.dat
cd ..
#listing installed packages
yum list installed > installed_packages.txt

#finishing script
echo -e 'Remember to run:\n netstat -plant\n netstat-planu\n top(htop, btop)\n crontab -l [user]\n systemctl --type=service\n jobs -p (shows current jobs)\n check /etc/hosts file'


