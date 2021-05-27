echo ---------------------------------
echo 4 - kubernetes install, kubeadm, kubelet, kubectl
echo ---------------------------------

## ----------
# Kubernetes

sudo apt-get update && sudo apt-get install -y ca-certificates curl software-properties-common apt-transport-https curl
sudo curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
 
sudo apt-get update
 
# lookup avariable version 
sudo apt-cache madison kubelet
 
# instal specific version 
sudo apt-get install -y kubelet=1.18.3-00 kubeadm=1.18.3-00 kubectl=1.18.3-00
 
# config auto start 
sudo systemctl enable kubelet && sudo systemctl start kubelet


# lookup requirement images
kubeadm config images list --kubernetes-version=v1.18.3
 
# pull image form new url 
sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.18.3
sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.18.3
sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.18.3
sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.18.3
sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2
sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.4.3-0
sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.6.7
 
# tag image with k8s.gcr.io tag 
sudo docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.18.3 k8s.gcr.io/kube-apiserver:v1.18.3
sudo docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.18.3 k8s.gcr.io/kube-controller-manager:v1.18.3
sudo docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.18.3 k8s.gcr.io/kube-scheduler:v1.18.3
sudo docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.18.3 k8s.gcr.io/kube-proxy:v1.18.3
sudo docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2 k8s.gcr.io/pause:3.2
sudo docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.4.3-0 k8s.gcr.io/etcd:3.4.3-0
sudo docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.6.7 k8s.gcr.io/coredns:1.6.7
