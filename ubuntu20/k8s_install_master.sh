sh 1_apt.sh
sh 2_docker.sh
sh 3_system.sh

echo sleep 120s for apt-get finished
sleep 120

sh 4_kubernetes.sh
sh 5_kubeadm.sh
sh 6_calicoNetwork.sh
sh 7_kuboardMonitor.sh
