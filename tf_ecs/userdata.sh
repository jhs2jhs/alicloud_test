apt-get -y update
apt-get -y install git

cd /root; git clone https://github.com/jianhuashao/alicloud_test.git

cd /root/alicloud_test/env; sh userdata_manual.sh