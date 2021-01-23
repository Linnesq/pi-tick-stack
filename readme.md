# pi-tick-stack

https://www.influxdata.com/time-series-platform/ for raspberry pi with docker.

## Requirements

- at least one Arm v7-supporting Pi (pi3, pi4) to act as the hub
  * running raspian
  * with [docker](https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script) and [docker-compose](https://docs.docker.com/compose/install/) installed
- (optional) some other Pi's to connect to the hub
  * running raspian with ssh enabled (to use automation scripts)
    
## Installing the Hub

1. Log in to your Pi
2. clone this repository and `cd` into it
3. (optional) to have this Pi's hostname show up in metrics, run: `export TELEGRAF_HOST="$(hostname)"`
4. (optional) `docker-compose config` to output the compose file with the actual env vars set.
5. `docker-compose up` (to see logs) or `docker-compose up -d` to run detached/in background.

Visit http://localhost:5000/sources/0/hosts if running locally, or 
`http://<your-pi-hostname.local-or-ip>:5000/sources/0/hosts` to check your metrics are coming through for the "hub".

## Installing Telegraf on Nodes (Arm v6)

The official telegraf image won't work on Arm v6 Pi's. 
Instead, we need to install telegraf on the host with `apt`.

There is a file ([armv6-deploy.sh](armv6-deploy.sh) included which can install telegraf on your pi and start it up with a
config file, see [armv6/telegraf.conf](armv6/telegraf.conf).

```
./armv6-deploy.sh -h
  -i install telelgraf on the remote machine
  -u username to use for ssh connection
  -t target host or ip address for ssh connection
  -r remote influx master node/hub ip address or hostname
```

If you usually SSH into your pi like: `ssh pi@pi2.local` and the hub running the TICK stack is `192.168.0.2`, **and** you
want to install `telegraf`, then you'd run the script like this:

```
./armv6-deploy.sh -i -u pi -t pi2.local -r 192.168.0.2
```

Once you have installed telegraf on a given machine, you shouldn't use the `-i` flag again.

Do look at the script and try to understand what it does before running it 😜

### TODO

* How to run telegraf on arm v7