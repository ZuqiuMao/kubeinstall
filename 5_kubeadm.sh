echo ---------------------------------
echo 5 - kubeadm init 
echo ---------------------------------

sudo kubeadm init --pod-network-cidr 172.18.0.0/16 --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers --kubernetes-version=v1.18.3

mkdir -p $HOME/.kube
sudo cp -n /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config