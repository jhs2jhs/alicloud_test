#!/bin/bash -v

# install nginx
apt-get install nginx -y

# create html index
mkdir -p /var/www/example.com/html
cat > /var/www/example.com/html/index.html <<'EOF'
welcome to jian-task1, a nginx static web server
EOF