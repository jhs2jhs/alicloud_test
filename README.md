# CODE STRUCTURE
1. tf_ecs: using terrform to automate Alicloud\_ECS provision.
2. tf_rds: using terrform to automate Alicloud\_RDS provision.
3. env: using ansible to config Alicloud_ECS servers.
4. notebook: using jupyter notebook to demostrate ansible operation on Alicloud\_ECS and mysql operation on Alicloud\_RDS.


---

# register and manage alicloud account for automation
```
    # create RAM sub user account for user [jianhuashao], so it will not mass up with root account
    # following the instruction [https://help.aliyun.com/document_detail/28643.html](https://help.aliyun.com/document_detail/28643.html), [https://help.aliyun.com/document_detail/28642.html](https://help.aliyun.com/document_detail/28642.html) 

    # add admin right & permission for jianhuashao-ram. 
    # for simple test purpose, I just add "AdministratorAccess" to enable all permission. 

    # If the ECS instance is in mainland China, you will need to pass realname authentication, other will get error message in terrform as Code:"RealNameAuthenticationError", Message:"Your account has not passed the real-name authentication yet."
    # The ealist way to avoid realname authentication is to spin up service outside of mainland China. 

    # terraform will require you to tell credential from environment or input in run time.
    # I prefer to set up as local environemnt. 

    mkdir -p ~/.alicloud/
    touch ~/.alicloud/config_alicloud_accesskey.sh
    echo 'export ALICLOUD_ACCESS_KEY="***"' >> config_alicloud_accesskey.sh
    echo 'export ALICLOUD_SECRET_KEY="***"' >> config_alicloud_accesskey.sh
    echo 'export ALICLOUD_REGION="us-west-1"' >> config_alicloud_accesskey.sh # to avoid realname authentication
    
    # varify the configuration
    cat ~/.alicloud/config_alicloud_accesskey.sh
    source ~/.alicloud/config_alicloud_accesskey.sh
    echo $ALICLOUD_ACCESS_KEY # it should return the key been used. 

```

---

## using terraform to build infrastructure as code
```
    # pre check
    # terraform support Alicloud since v0.8.7
    # alicloud provider as: https://www.terraform.io/docs/providers/alicloud/index.html

    # install terraform on macos
    brew install terraform 

    # get latest alicloud resource provider
    # be attention: the official terraform provider for alicloud only support v0.6 which is very out of date. 
    wget -O terraform-provider-alicloud_darwin-amd64_v1.6.2.tgz https://github.com/alibaba/terraform-provider/releases/download/V1.6.2/terraform-provider-alicloud_darwin-amd64.tgz 

    # update the latest alicloud terraform provider
    tar -xvzf terraform-provider-alicloud_darwin-amd64_v1.6.2.tgz
    mkdir -p ~/.terraform.d/plugins/darwin_amd64/
    cp ./bin/terraform-provider-alicloud ~/.terraform.d/plugins/darwin_amd64/terraform-provider-alicloud_v1.6.2_x4
    terraform version # should see "+ provider.alicloud v1.6.2" in the output, can ignore if it does, as terraform init can search for the "~/.terrform.d/plugins" folder in first order. 

    # bring my alicloud credential into the environment
    source ~/.alicloud/config_alicloud_accesskey.sh

    # initial alicloud
    terraform init # should see "* provider.alicloud: version = "~> 1.6"" in the output

    # create deploy plan
    terraform validate
    terraform plan

    # deploy
    terraform apply

    # I have used security group to allow ingress traffic on port: 80, 8888, 443 (https), 20 (ssh)

    # get status
    terraform refresh
    terraform show
    terraform output
    
    # destory
    terraform destroy
```

---

## using ansible to configure server
```
    # purpose: build a jupyter notebook server, docker and other service

    # config ssh to let ansible can access to the host
    # the Ubuntu 16 image in Alicloud does not suport hostname automatically, so I needs to register local host
    echo $(hostname -I | cut -d\  -f1) $(hostname) | sudo tee -a /etc/hosts
    # load the ssh key and save to all nodes to be managed if applied
    cd /root/.ssh/; wget -O id_rsa https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/id_rsa

    # configure https, jupyter server rely on ssl, needs to manage certificate. 
    cd /root/.jupyter/; wget -O mycert.pem https://raw.githubusercontent.com/jianhuashao/alicloud_test/master/env/mycert.pem
    # simply use nohop to manage jupyter process, the better way is to managed by tools like supervisord or use jupyter hub. 
    nohup jupyter-notebook --ip 0.0.0.0 --port 8888 --no-browser --allow-root --notebook-dir=/root &

    # ansible is quite convient to be used in Alicloud_ECS
    # the only problem I saw is to be easily timeout. some packages (e.g. jupyter) are slow to download by using mirrowed repository from alicloud. 
```


---

## using docker to build container for web host
```
    # reusing a existing dockerfile from crccheck/docker-hello-world
    # the docker container is using httpd as web server
    mkdir -p /root/app_web_docker/
    cd /root/app_web_docker/; wget -O Dockerfile https://raw.githubusercontent.com/crccheck/docker-hello-world/master/Dockerfile
    cd /root/app_web_docker/; wget -O index.html https://raw.githubusercontent.com/crccheck/docker-hello-world/master/index.html
    cd /root/app_web_docker/; docker build . -t web_docker
    cd /root/app_web_docker/; docker run -d --name web_docker -p 32768:8000 web_docker
```

---

## using python3 http_server as FTP
```
    cd /root; nohup python3 -m http.server 8021 --bind 127.0.0.1 --cgi &
```

---

## using nginx as load balancer
```
    # nginx config
    cat /etc/nginx/sites-available/jian_task1.conf

    # toplogy
    https: 
        https://public_id (jupyter notebook server)
    http:
        http://public_id (ftp server)
        http://public_id/docker (docker web server)
        http://public_id/html/index.html (nginx static web server)
```

---

## Alicloud_RDS
Alicloud RDS is not very stable by using terraform. So I show how to configure via the console. 

---

# Pros and Cons about Alicloud 
1. Pros: 
    2. low cost
    3. relative low restriction on 
    4. ansible support is quite stable
2. Cons:
    3. Swith between zone is not very smooth. 
    4. terraform support is still not wide available. 
    5. package repository is slow in connection. often to have connection timeout. 


---

# TODO:
1. ADD Server Load Balancer (SLB) service
2. ADJUST ECS instance type in terraform, due to time limitation for investigation
3. Currently use a self-certifcate SSL/HTTPS, as timie is limited to register a certificate
4. IMPROVE condition checking in terraform and ansible script. 

