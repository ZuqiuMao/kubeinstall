
echo ---------------------------------
echo 1 - start apt with chinese source
echo ---------------------------------
sudo cp /etc/apt/sources.list /etc/apt/sources.list_backup
 
#modify source of chinese for update speed
#sudo tee /etc/apt/sources.list <<EOF
# use ali mirror for update speed
#deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
#deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
#deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
#deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
#deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
#deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
#EOF
sudo python utility.py

# upate
sudo apt-get update
