#!/bin/bash -xe
sudo amazon-linux-extras enable php7.4
sudo yum clean metadata -y
sudo yum install epel httpd php php-cli php-pdo php-fpm php-json php-mysqlnd amazon-efs-utils -y

wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
sudo rsync -avP wordpress/ /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sudo sed -i "s/^.*DB_NAME.*$/define('DB_NAME', '${db_name}');/" /var/www/html/wp-config.php
sudo sed -i "s/^.*DB_USER.*$/define('DB_USER', '${db_user}');/" /var/www/html/wp-config.php

export INSTANCE_REGION=`curl -s http://169.254.169.254/latest/meta-data/placement/region`
root_db_password=`aws ssm get-parameter --name "${db_pass_ssm}" --with-decryption --query Parameter.Value --output text --region $INSTANCE_REGION`

sudo sed -i "s/^.*DB_PASSWORD.*$/define('DB_PASSWORD', '$root_db_password');/" /var/www/html/wp-config.php
sudo sed -i "s/^.*DB_HOST.*$/define('DB_HOST', '${db_host}');/" /var/www/html/wp-config.php
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf

sudo mkdir /var/www/html/wp-content/uploads
sudo mount -t efs ${efs_id}:/ /var/www/html/wp-content/uploads
echo "${efs_id}:/ /var/www/html/wp-content/uploads efs dafaults,_netdev 0 0" >> /etc/fstab
sudo chmod 777 /var/www/html/wp-content/uploads

sudo systemctl start httpd
sudo systemctl enable httpd

myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2> Web Server with ip: $myip </h2><br>Build by Terraform" > /var/www/html/server.html

public_hostname=`curl http://169.254.169.254/latest/meta-data/public-hostname`
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
./wp-cli.phar option update home http://${elb_dns}/ --path=/var/www/html
./wp-cli.phar option update siteurl http://${elb_dns}/ --path=/var/www/html
