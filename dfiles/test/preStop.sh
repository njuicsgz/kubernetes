#! /bin/bash
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

#num=`cat num.log || 0`

#if((num > 5));then
#    echo "ok"
#else
#    echo "not ok"
#    let "num=$num+1"
#    echo -n "$num" > num.log
#fi
echo "preStop running..." >> /tmp/preStop.log
