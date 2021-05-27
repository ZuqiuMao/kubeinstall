# kubeinstall

kubeinstall is one click intall tool of kubenetes. It uses aliyun source.

## version

```
ubuntu：20.04;
docker：19.03.11；
Kubernetes：1.18.3
```

## One command install 

master
```
sh k8s_install_master.sh
```

Node
```
sh k8s_install_worker.sh
```

Join
```
sudo kubeadm join ip:port --token xxx    --discovery-token-ca-cert-hash sha256:xxx
```

xxx is from master install result

## Reference
- https://github.com/kubernetes/kubeadm
