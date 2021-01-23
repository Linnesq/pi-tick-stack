#!/bin/bash
# shellcheck disable=SC2086
# https://wiki.bash-hackers.org/howto/getopts_tutorial 🍻

usage() {
  echo "  -i install telelgraf on the remote machine"
  echo "  -u username to use for ssh connection"
  echo "  -t target host or ip address for ssh connection"
  echo "  -r remote influx master node/hub ip address or hostname"
}

while getopts ":hiu:t:r:" opt; do
  case $opt in
    i ) INSTALL=1;;
    t ) PI_HOST=$OPTARG;;
    u ) PI_USER=$OPTARG;;
    h ) usage; exit 0;;
    r ) HUB_IP_OR_HOST=$OPTARG;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument. " >&2
      exit 1
      ;;
  esac
done

if [ -z ${PI_HOST} ] && [ -z ${PI_USER} ]; then echo "neither host nor username is set" && exit 1; fi
if [ -z ${PI_HOST} ] || [ -z ${PI_USER} ]; then echo "both host and username need to be set" && exit 1; fi
if [ -z ${HUB_IP_OR_HOST} ]; then echo "you need to use the -r flag, see -h for more info" && exit 1; fi
if [ -n "$INSTALL" ]; then echo "going to install telelgraf"; fi

PI_USER_AT_HOST="${PI_USER}@${PI_HOST}"

scp armv6/telegraf.conf "${PI_USER_AT_HOST}:/home/${PI_USER}/telegraf.conf"

ssh "${PI_USER_AT_HOST}" /bin/bash <<EOF

if [ -n "$INSTALL" ];
then
  echo "initial install"
  curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
  echo "deb https://repos.influxdata.com/debian buster stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
  sudo apt-get update && sudo apt-get install telegraf -y
  ## comment out the next line if you do not run docker on this machine
  sudo usermod -aG docker telegraf && echo 'usermod'
fi

echo "deployment"
sudo systemctl stop telegraf && echo 'stop'
cat /home/$PI_USER/telegraf.conf | sudo tee /etc/telegraf/telegraf.conf
export INFLUX_URL="http://$HUB_IP_OR_HOST:8086"
# remote variables are escaped, e.g. \$INFLUX_URL
echo "INFLUX_URL=\"\$INFLUX_URL\"" | sudo tee /etc/default/telegraf

sudo systemctl daemon-reload && echo 'reload'
sudo systemctl start telegraf && echo 'start' && sleep 4;
sudo systemctl status telegraf
EOF

echo "Telegraf config deployed to $PI_USER_AT_HOST 🍻"