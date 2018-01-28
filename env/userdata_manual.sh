#!/bin/bash -v
apt-get update -y

# add hostname into /etc/hosts, so it can be recognised
echo $(hostname -I | cut -d\  -f1) $(hostname) | sudo tee -a /etc/hosts

# install base package
apt-get -y install bash-completion ca-certificates curl git openssl sshpass openssh-client

# setup ssh
mkdir -p /root/.ssh
cd /root/.ssh/; wget -O id_rsa https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/id_rsa






######################################################
# install jupyter
######################################################
export LC_ALL=C
apt-get -y install python2.7 python-pip python-dev python-setuptools build-essential
apt-get -y install python3-pip python3-dev python3-pip python3-setuptools build-essential
apt-get -y install ipython ipython-notebook

pip install --upgrade pip
pip3 install --upgrade pip

sudo -H pip install jupyter
sudo -H pip3 install jupyter
pip install -U jupyter ipython
pip3 install -U jupyter ipython
ipython kernel install
ipython3 kernel install

mkdir -p /root/.jupyter
mkdir -p /root/.jupyter/log
cd /root/.jupyter/; wget -O mycert.pem https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/mycert.pem
cd /root/.jupyter/; wget -O jupyter_notebook_config.py https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/jupyter_notebook_config.py
cd /root; wget -O nb_ansible_on_jupyter_ubuntu.ipynb https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/notebook/nb_ansible_on_jupyter_ubuntu.ipynb
cd /root; wget -O nb_rds_mysql_demo.ipynb https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/notebook/nb_rds_mysql_demo.ipynb
if pgrep jupyter; then pkill jupyter; fi
nohup jupyter-notebook --ip 0.0.0.0 --port 8888 --no-browser --allow-root --notebook-dir=/root &







######################################################
# configure docker web server
######################################################
mkdir -p /root/app_web_docker/
cd /root/app_web_docker/; wget -O Dockerfile https://raw.githubusercontent.com/crccheck/docker-hello-world/master/Dockerfile
cd /root/app_web_docker/; wget -O index.html https://raw.githubusercontent.com/crccheck/docker-hello-world/master/index.html
cd /root/app_web_docker/; docker build . -t web_docker
cd /root/app_web_docker/; docker run -d --name web_docker -p 32768:8000 web_docker
# check if docker server is runing: docker ps or curl http://127.0.0.1:32768




######################################################
# configure ftp server
######################################################
cd /root; nohup python3 -m http.server 8021 --bind 127.0.0.1 --cgi &


# install nginx
apt-get install nginx -y

# create html index
# prepare for setup nginx
cd /root; wget -O create_example_com.sh https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/create_example_com.sh
cd /root; wget -O create_nginx_config.sh https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/create_nginx_config.sh

cd /root; chmod +x create_example_com.sh
cd /root; chmod +x create_nginx_config.sh

cd /root; sh create_example_com.sh
cd /root; sh create_nginx_config.sh

[ -f /etc/nginx/sites-enabled/default ] && unlink /etc/nginx/sites-enabled/default
[ -f /etc/nginx/sites-enabled/jian_task1.conf  ] && unlink /etc/nginx/sites-enabled/jian_task1.conf 

ln -s /etc/nginx/sites-available/jian_task1.conf /etc/nginx/sites-enabled/

systemctl restart nginx

# http://ip:80, http://ip:80/html/index.html, http://ip:80/docker, http://ip:443







######################################################
# install mysql client
######################################################
apt-get -y install mysql-client

pip install mysql-connector-python
pip3 install mysql-connector-python