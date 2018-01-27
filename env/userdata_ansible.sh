#!/bin/bash -v
apt-get update -y

# add hostname into /etc/hosts, so it can be recognised
echo $(hostname -I | cut -d\  -f1) $(hostname) | sudo tee -a /etc/hosts

# install ansible
apt-get install ansible -y

# install git
cd /root; wget -O setup_ansible_ssh.yml https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/setup_ansible_ssh.yml
cd /root; wget -O setup_jupyter.yml https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/setup_jupyter.yml
cd /root; wget -O setup_app_web_docker.yml https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/setup_app_web_docker.yml
cd /root; wget -O setup_app_ftp_python.yml https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/setup_app_ftp_python.yml
cd /root; wget -O setup_load_balancer.yml https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/setup_load_balancer.yml

cd /root; ansible-playbook setup_ansible_ssh.yml

# configure notebook server
cd /root; ansible-playbook setup_jupyter.yml
# nohup jupyter-notebook --ip 0.0.0.0 --port 8888 --no-browser --allow-root --notebook-dir=/root & # for manual operation

# configure docker web server
cd /root; ansible-playbook setup_app_web_docker.yml 
# check if docker server is runing: docker ps or curl http://127.0.0.1:32768

# configure ftp server
cd /root; ansible-playbook setup_app_ftp_python.yml


# prepare for setup nginx
cd /root; wget -O create_example_com.sh https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/create_example_com.sh
cd /root; wget -O create_nginx_config.sh https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/create_nginx_config.sh

cd /root; chmod +x create_example_com.sh
cd /root; chmod +x create_nginx_config.sh

cd /root; sh create_example_com.sh
cd /root; sh create_nginx_config.sh

ln -s /etc/nginx/sites-available/jian_task1.conf /etc/nginx/sites-enabled/

# configure load balancer with nginx via ansible
cd root; ansible-playbook setup_load_balancer.yml 

# nginx -t > /tmp/nginx_t.log # test if nginx has error
systemctl restart nginx

# http://ip:80, http://ip:80/html/index.html, http://ip:80/docker, http://ip:443