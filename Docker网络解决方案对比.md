##对比表格
ps:由于无法粘帖表格，故分享链接。
http://note.youdao.com/share/?id=8387b9e886c84f413a97d678c3d01869&type=note

隔离性：Y表示支持；N表示不支持
稳定性：0~5分，4和5表示可接受；
易用性：0~5分，4和5表示可接受；是否简单易用，配置容易，接入k8s容易
性能：百分比，表示Host网络性能的损耗程度，80%表示损耗20%，100%表示无损；测试项为UDP、TCP长连接（TCP_RR）、TCP短连接（TCP_CRR）
支持k8s：Y表示支持k8s，受k8s官方推荐；N相反
可行性：总结性定论，是否可以采用。

##1. flannel v0.5特性：
1） 支持多个subnet，但是一个主机的所有docker container必须属于同一个subnet，弱隔离性，比较鸡肋
2） 限制性地支持AWS-VPC路由表设置，但是需要相关VPC权限，同事AWS最多只支持50个配置项。设置VPC后flannel不再重新封装为UDP包，速率估计会快上很多。有一定的安全风险！

##2. calico说明：
1）0.5.0 （2015.7.9）开始使用libnetwork，需要Docker 1.8支持，Docker 1.8目前还处于实验性阶段，非稳定版本。
2）依赖于etcd/consul/confd

##3. Socketplane
###缺点：
1）版本不稳定。截至目前（2015-07-20），只有一个release（v0.1-alpha.1 2014-12-27），且不再更新，被Docker收购之后，去开发libnetwork，libnetwork在Docker1.7.0加入，目前有关网络还有不少bug。http://blog.docker.com/2015/04/docker-networking-takes-a-step-in-the-right-direction-2/
2）无法与k8s直接集成。必须使用socketplane命令创建的container才有相关的网络，用docker命令创建的container网络还是走默认方式；或者使用环境变量创建container.
sudo DOCKER_HOST=localhost:2375 docker run -e SP_NETWORK=test -itd ubuntu [test是subnet的名称]
3）container的网络无法与host相通
###优点：
1）支持多个subnet，支持网络隔离

##4. OVS
OVS是一个比较成熟的产品，然则配置过程也相对繁复，这也是Socketplane基于OVS的原因。OVS在Local环境下配置没有问题，但网络波动较大，测试数据不够准确；线上环境配置出现问题，导致Container之间无法连通，介于时间关系，留待以后验证。

综合来看，目前使用的flannel在易用性、稳定性、网络性能各方面相对突出。
