#!/bin/bash

while :
do
#    read -p "Please enter the network plugin you want to download [flannel|calico]: " name
#    if [ $name != "flannel" -a $name != "calico" ]
#    then
#        echo "Your input error, please enter [flannel|calico]"
#        break
#    fi

    read -p "Please enter the node hostname: " NODE_HOSTNAME
    read -p "Please enter the master ip: " MASTER_IP
    read -p "Please enter the master hostname: " MASTER_HOSTNAME

    read -p "Please enter the version of K8S you want to install eg.[1.18.3|1.19.4|...]: " version
    if [ $name != "1.[1-2][1-9].[1-9]" ]
    then
        break
    else
        echo "Your input error, please enter [1.18.3|1.19.4|...]"
        break
    fi

done

# step 1. Node init
sudo tee /etc/apt/sources.list <<-'EOF'
{
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-proposed main restricted universe multiverse
deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable
# deb-src [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable
deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu xenial stable
# deb-src [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu xenial stable
}
EOF

sudo apt-get update

NODE_IP=`hostname -I | awk '{print $1}'`
cat >>/etc/hosts<<EOF
$NODE_IP $NODE_HOSTNAME
$MASTER_IP $MASTER_HOSTNAME
EOF

hostnamectl set-hostname $NODE_HOSTNAME

# step 2. Close firewalld & selinux
sudo systemctl stop firewalld
sudo systemctl disable firewalld

sudo setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# step 3. Close swap
sudo swapoff -a
sudo sed -ri 's/.*swap.*/#&/' /etc/fstab

# step 4. Get kubelet kubeadm pkg and so on ...
sudo apt-get install kubelet-${version}-00 kubeadm-${version}-00 kubectl-${version}-00 docker-ce-19.03.12-3.el7 -y
sudo systemctl enable kubelet && sudo systemctl enable docker && sudo systemctl start docker

# step 5. Config docker daemon.json
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://kfwkfulq.mirror.aliyuncs.com",
        "https://2lqq34jg.mirror.aliyuncs.com",
        "https://pee6w651.mirror.aliyuncs.com",
        "https://registry.docker-cn.com",
        "http://hub-mirror.c.163.com"
    ],
    "iptables": false,
    "ip-masq": false,
    "storage-driver": "overlay2",
    "exec-opts":["native.cgroupdriver=systemd"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
echo ""
echo ""


echo "load local docker image"
docker load -input ./plugins/calico-v3.8.7/images/calico-cni.tar
docker load -input ./plugins/calico-v3.8.7/images/calico-kube-controllers.tar
docker load -input ./plugins/calico-v3.8.7/images/calico-node.tar
docker load -input ./plugins/calico-v3.8.7/images/calico-pod2daemon-flexvol.tar
echo "load docker image done"


# step 7. Open iptables rule and ip_forward
sudo echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables 
sudo echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
sudo cat >>/etc/rc.local<<EOF
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables 
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/ipv4/ip_forward
EOF

# step 8. Node Join Cluster
echo "***************************************************************************************************************"
echo "You will need to manually execute the script on Master for get kubeadm join command: [./get_token.sh]"
echo "***************************************************************************************************************"
