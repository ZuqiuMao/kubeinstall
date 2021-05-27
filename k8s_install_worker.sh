sh 1_apt.sh
sh 2_docker.sh
sh 3_system.sh
echo sleep 120s for apt-get finished
sleep 120
sh 4_kubernetes.sh

echo 5 to do: kubeadm join 
#sudo kubeadm join ip:port --token xxx    --discovery-token-ca-cert-hash sha256:xxxxxx