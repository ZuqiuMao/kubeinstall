
# ------------------------
# docker

echo ---------------------------------
echo 2 - start docker install
echo ---------------------------------

# step 1: install system tools
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
# step 2: install GPG
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
 
# Step 3: write source--
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu bionic stable"
 
# look up avariable Docker-CE versoin:
sudo apt-cache madison docker-ce
 
# Step 2: install specific Docker-CE:
sudo apt-get -y install docker-ce=5:19.03.11~3-0~ubuntu-bionic
 
# lock version 
sudo apt-mark hold docker-ce=5:19.03.11~3-0~ubuntu-bionic
 
# 
# start docker, set auto start when boot  
sudo systemctl enable docker && sudo systemctl start docker
 
sudo mkdir /etc/docker
sudo touch /etc/docker/daemon.json

# config docker source images
# 172.18.0.1 for docker0 
sudo tee /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": ["https://g2djyyu3.mirror.aliyuncs.com"],
    "exec-opts": [ "native.cgroupdriver=systemd" ],
    "bip": "172.18.0.1/16"
}
EOF

 
# restart docker
sudo systemctl restart docker
 
# display docker status
#sudo systemctl status docker
 
# detail log
#sudo journalctl -u docker.server
 
 
# add current user_name to docker group to use, such userName is ubuntu
sudo usermod -aG docker ubuntu
