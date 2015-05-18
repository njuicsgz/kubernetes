#! /bin/bash 
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin 
export WORKDIR=$( cd ` dirname $0 ` && pwd ) 

if [ $# -eq 1 ]; then
    version=$1
else
    echo "must specify a version, exit"
    exit 1
fi

build_img()
{
    local tar_dir=$1
    local img_name=$1

    cd ${tar_dir} || exit
    docker build -t xa.repo.ndp.com:5000/facebook_pmd/${img_name}:${version} .
    docker push xa.repo.ndp.com:5000/facebook_pmd/${img_name}:${version}
    cd ..
}

echo "begin build images with version: ${version}..."

build_img fbagent-services
build_img mq-services
build_img rdb-services
build_img walle-java
build_img walle-web
build_img config
build_img dubbo-monitor-svc
build_img dubbo-monitor-web
build_img scheduler

echo "build finished"
