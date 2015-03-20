#! /bin/bash 
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin 
export WORKDIR=$( cd ` dirname $0 ` && pwd ) 

cd fbagent-services || exit
docker build -t allen01:5000/facebook_pmd/fbagent-services .
docker push allen01:5000/facebook_pmd/fbagent-services
cd ..

cd mq-services || exit
docker build -t allen01:5000/facebook_pmd/mq-services .
docker push allen01:5000/facebook_pmd/mq-services
cd ..

cd rdb-services || exit
docker build -t allen01:5000/facebook_pmd/rdb-services .
docker push allen01:5000/facebook_pmd/rdb-services
cd ..

cd walle || exit
docker build -t allen01:5000/facebook_pmd/walle-java .
docker push allen01:5000/facebook_pmd/walle-java
cd ..

cd scheduler || exit
docker build -t allen01:5000/facebook_pmd/scheduler .
docker push allen01:5000/facebook_pmd/scheduler
cd ..

