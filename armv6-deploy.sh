#!/bin/bash

PI_USER=$1
PI_HOST=$2
HUB_IP_OR_HOST=$3
PI_USER_AT_HOST="${PI_USER}@${PI_HOST}"

scp armv6/telegraf.conf "${PI_USER_AT_HOST}:/home/${PI_USER}/telegraf.conf"

ssh "${PI_USER_AT_HOST}" /bin/bash <<EOF

#echo "initial install"
#curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
#echo "deb https://repos.influxdata.com/debian buster stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
#sudo apt-get update && sudo apt-get install telegraf -y
### comment out the next line if you do not run docker on this machine
#sudo usermod -aG docker telegraf && echo 'usermod'

echo "deployment"
sudo systemctl stop telegraf && echo 'stop'
cat /home/$PI_USER/telegraf.conf | sudo tee /etc/telegraf/telegraf.conf
export INFLUX_URL="http://$HUB_IP_OR_HOST:8086"
# remove variables are escaped, .e.g \$INFLUX_URL
echo "INFLUX_URL=\"\$INFLUX_URL\"" | sudo tee /etc/default/telegraf

sudo systemctl daemon-reload && echo 'reload'
sudo systemctl start telegraf && echo 'start' && sleep 4;
sudo systemctl status telegraf
EOF

echo "Telegraf config deployed to $PI_USER_AT_HOST 🍻"