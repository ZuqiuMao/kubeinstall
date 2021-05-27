#!/bin/bash

#while :
#do
#    read -p "Please enter the network plugin you want to download [flannel|calico]: " name
#    if [ $name != "flannel" -a $name != "calico" ]
#    then
#        echo "Your input error, please enter [flannel|calico]"
#        break
#    fi

    read -p "Please enter the hostname: " HOSTNAME

    read -p "Please enter the version of K8S you want to install eg.[1.18.3|1.19.4|...]: " version
#    if [ $name -ne "1.[1-2][1-9].[1-9]" ]
#    then
#        break
#    else
#        echo "Your input error, please enter [1.18.3|1.19.4|...]"
#        break
#    fi

#done

# step 1. update apt source & config hosts file & change hostname
sudo tee /etc/apt/sources.list <<EOF
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
EOF

sudo curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main
EOF

sudo apt-get update

IP=`hostname -I | awk '{print $1}'`
cat >/etc/hosts<<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
$IP $HOSTNAME
EOF

hostnamectl set-hostname $HOSTNAME

# step 2. Close firewalld & selinux
sudo ufw disable
if [ ! -f "/etc/selinux/config" ];
then 
sudo tee "/etc/selinux/config" <<EOF    
SELINUX=permissive
EOF
else
    sudo sed -i '$a SELINUX=permissive' /etc/selinux/config
fi

# step 3. Close swap
sudo swapoff -a
#同时还需要修改/etc/fstab文件，注释掉 SWAP 的自动挂载，防止机子重启后swap启用。
python shutdownSwap.py

# step 4 Config ipvs
sudo sed -i '$a net.ipv4.ip_forward = 1' /etc/sysctl.conf

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl -p

#配置iptables参数，使得流经网桥的流量也经过iptables/netfilter防火墙
sudo tee /etc/sysctl.d/k8s.conf <<-'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

sudo cp /etc/resolvconf/resolv.conf.d/head /etc/resolvconf/resolv.conf.d/head.bak && sudo tee /etc/resolvconf/resolv.conf.d/head <<-'EOF'
nameserver 8.8.8.8
EOF

# step 5. Get Dokcer
#卸载旧docker
sudo apt-get remove docker docker-engine docker.io         

#安装依赖，使得apt可以使用https
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y

#添加docker的GPG key
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

#安装18.06.1版
sudo apt-get install -y docker-ce=18.06.3~ce~3-0~ubuntu

#启动并设置开机自启动docker
sudo systemctl enable docker && sudo systemctl start docker



# Step 5. Get kubelet kubeadm pkg and so on ...
sudo apt-get install kubelet=${version}-00 kubeadm=${version}-00 kubectl=${version}-00 -y
sudo systemctl enable kubelet && sudo systemctl enable docker && sudo systemctl start docker

# step 6. Config docker daemon.json
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
    "exec-opts": ["native.cgroupdriver=systemd"],
    "iptables": false,
    "ip-masq": false,
    "storage-driver": "overlay2"
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
echo ""
echo ""

# step 7. Download K8s images
#echo "************************K8s images Downloading************************"
#for i in kube-apiserver:v${version} kube-controller-manager:v${version} kube-scheduler:v${version} kube-proxy:v${version} pause:3.2 etcd:3.4.3-0 coredns:1.6.7
#do
#    docker pull registry.cn-shanghai.aliyuncs.com/rsq_k8s_images/$i
#done
#echo ""
#echo ""

# step 9. Kubeadm init
#sudo kubeadm init  --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.19.4   --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=Swap

sudo kubeadm init --config ./scripts/kubeadm-config-latest.yaml --ignore-preflight-errors=Swap

if [ "$?" != 0 ] ; then
   echo "kubeadm init Failed!!!"
   exit 2
fi

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "************************Network plugin install************************"
kubectl apply -f ./plugins/calico-v3.8.7/k8s-manifests/rbac/rbac-kdd-calico.yaml
kubectl apply -f ./plugins/calico-v3.8.7/k8s-manifests/calico.yaml
kubectl create clusterrolebinding kube-system-default-role-binding --clusterrole=cluster-admin --serviceaccount=kube-system:calico-node

# step 10. Apply network plugin
#if [ "$name" == "flannel" ]
#then
#	sudo kubectl apply -f ./plugins/flannel_v0.13.1/kube-flannel.yml
#elif [ "$name" == "calico" ]
#then
#	sudo kubectl apply -f ./plugins/calico_v3.8.2/calico-v3.8.2.yml
#fi

# step 11. Config Master schedulable
sudo kubectl taint nodes --all node-role.kubernetes.io/master-
