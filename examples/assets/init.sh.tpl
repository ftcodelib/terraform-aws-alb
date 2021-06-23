#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1 

sleep 120
sudo yum -y install httpd
sudo systemctl enable httpd
sudo mkdir -p /var/www/example.com/html
sudo mkdir -p /var/www/example.com/log
sudo chown -R $USER:$USER /var/www/example.com/html
sudo chmod -R 755 /var/www
sudo bash -c 'cat << EOF > /var/www/example.com/html/index.html
<html>
  <head>
    <title>Welcome to ${SERVER_NAME} !</title>
  </head>
  <body>
    <h1>Success! The ${SERVER_NAME} virtual host is working!</h1>
  </body>
</html>
EOF'
sudo mkdir /etc/httpd/sites-available /etc/httpd/sites-enabled
sudo bash -c 'echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf'
sudo bash -c 'cat << EOF > /etc/httpd/sites-available/example.com.conf
<VirtualHost *:80>
    ServerName www.example.com
    ServerAlias example.com
    DocumentRoot /var/www/example.com/html
    ErrorLog /var/www/example.com/log/error.log
    CustomLog /var/www/example.com/log/requests.log combined
</VirtualHost>
EOF'
sudo ln -s /etc/httpd/sites-available/example.com.conf /etc/httpd/sites-enabled/example.com.conf
sudo systemctl restart httpd

#### POST INIT ####
sudo echo "user data script completed" > /root/status.txt
sudo reboot