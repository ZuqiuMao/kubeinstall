
echo ---------------------------------
echo 3 - system config
echo ---------------------------------

# ---------------
# disable swap  temp
sudo swapoff -a
 
# disable swap forever, change/etc/fstab，comment out line with "swap" 
# to do 1
#sudo vi /etc/fstab

#-------------------------------------
# modify /etc/sysctl.d/10-network-security.conf
# to do 2
#sudo vi /etc/sysctl.d/10-network-security.conf
 
#modify following parameter from 2 to 1
#net.ipv4.conf.default.rp_filter=1
#net.ipv4.conf.all.rp_filter=1

sudo python utility.py

# valid it
sudo sysctl --system



cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system