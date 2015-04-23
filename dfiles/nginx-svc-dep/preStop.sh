#! /bin/bash
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

echo "preStop.sh running..." >> /tmp/sd.log
sleep 3

echo "preStop.sh over." >> /tmp/sd-stop.log
sleep 60
