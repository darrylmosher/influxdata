#!/bin/bash

#Set Required Variables
services="influxdb telegraf chronograf kapacitor"
influxdbConfig="/etc/influxdb/influxdb.conf"
telegrafConfig="/etc/telegraf/telegraf.conf"
kapacitorConfig="/etc/kapacitor/kapacitor.conf"
ipaddress="$(ifconfig | egrep -o "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)"
now="$( date '+%F_%H:%M:%S' )"
logfile="stacksetupout$now.log"
ostype="$(cat /etc/os-release | grep 'debian')"

#Create log ile
touch /tmp/$logfile
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3 15 RETURN
exec 1>/tmp/$logfile 2>&1
echo "Log Location: /tmp/$logfile" >&3
echo ""

#Add Influx repository
if [ ostype = "" ]; then
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF

#Install stack - rhel/centos
echo "Installing Services" >&3
echo "" >&3
yum -y install $services

else
wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

#Install stack - debian
echo "Installing Services" >&3
echo "" >&3
sudo apt-get update
sudo apt-get install $services -y >> /tmp/$logfile
fi

#Verify installation succeeded
installexit=$?
if [ $installexit -ne 0 ]; then 
echo "Installation Failed. Review /tmp/$logfile" >&3 ; exit 1
fi

#Start services
echo "Starting Services" >&3
echo "" >&3
for service in $services; do
    sudo systemctl start $service && systemctl enable $service 
    sleep 1
done	

#Start InfluxDB and create Admin User
function MakeAdmin ()
{
influx << EOF
CREATE USER "admin" WITH PASSWORD 'influxadmin' WITH ALL PRIVILEGES
EOF
}
MakeAdmin
adminexit=$?

if [ $adminexit -ne 0 ]; then 
echo "Failed to create Admin user" >&3
else echo "Created Admin user" >&3
fi
echo "" >&3

#Specify Telegraf output location and InfluxDB credentials
echo "Updating Configurations" >&3
echo "" >&3
sudo sed -i 's+# urls = ["http://127.0.0.1:8086"]+   urls = ["http://127.0.0.1:8086"]+g' $telegrafConfig
sudo sed -i 's+# username = "telegraf"+  username = "admin"+g' $telegrafConfig
sudo sed -i 's+# password = "metricsmetricsmetricsmetrics"+  password = "influxadmin"+g' $telegrafConfig

#Restart services
echo "Restarting Services" >&3
echo "" >&3
for service in $services; do
    sudo systemctl restart $service && systemctl enable $service 
    sleep 1
done	

#Final Step
echo "Complete" >&3
echo "" >&3
echo "Visit http://$ipaddress:8888 to finish setting up your stack" >&3