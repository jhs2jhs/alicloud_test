#!/bin/bash -v

# install nginx
apt-get install nginx -y

# create configuration file
mkdir -p /etc/nginx/sites-available
cat > /etc/nginx/sites-available/jian_task1.conf <<'EOF'
upstream app_notebook {
    server 127.0.0.1:8888; # a local ftp server 
}
upstream app_welcome {
    server 127.0.0.1:32768; # a docker container hello world web sever
}
upstream app_ftp {
    server 127.0.0.1:8021; # a local ftp server 
}

server {
        listen 443;
        listen [::]:443;
        location / {
            proxy_pass http://app_notebook/;
            proxy_set_header        HOST $host;
            
            # websocket support
            proxy_http_version    1.1;
            proxy_set_header      Upgrade "websocket";
            proxy_set_header      Connection "Upgrade";
            proxy_read_timeout    86400;
        }
        location ~ /api/kernels/ {
            proxy_pass            http://app_notebook;
            proxy_set_header      Host $host;
            # websocket support
            proxy_http_version    1.1;
            proxy_set_header      Upgrade "websocket";
            proxy_set_header      Connection "Upgrade";
            proxy_read_timeout    86400;
        }
        location ~ /terminals/ {
            proxy_pass            http://app_notebook;
            proxy_set_header      Host $host;
            # websocket support
            proxy_http_version    1.1;
            proxy_set_header      Upgrade "websocket";
            proxy_set_header      Connection "Upgrade";
            proxy_read_timeout    86400;
        }
}

server {
        listen 80;
        listen [::]:80;

        location / {
            proxy_pass http://app_ftp/;
            proxy_set_header        X-Real-IP $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header        X-Forwarded-Proto $scheme;
            proxy_set_header        HOST $host;
            proxy_read_timeout      90;
            proxy_redirect    off;
        }

        location /docker {
            proxy_pass http://app_welcome/;
        }

        location /html {
            rewrite ^/html/(.*) /$1 break;
            root /var/www/example.com/html;
            index  index.html index.htm index.nginx-debian.html;
        }
}
EOF