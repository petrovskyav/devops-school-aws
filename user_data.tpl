#!/bin/bash -xe
sudo amazon-linux-extras enable php7.4
sudo yum clean metadata -y
sudo yum install epel httpd php php-cli php-pdo php-fpm php-json php-mysqlnd -y

wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
sudo rsync -avP wordpress/ /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sudo sed -i "s/^.*DB_NAME.*$/define('DB_NAME', '${db_name}');/" /var/www/html/wp-config.php
sudo sed -i "s/^.*DB_USER.*$/define('DB_USER', '${db_user}');/" /var/www/html/wp-config.php

export INSTANCE_REGION=`curl -s http://169.254.169.254/latest/meta-data/placement/region`

root_db_password=`aws ssm get-parameter --name "/wp/mysql_root_password_location" --with-decryption --query Parameter.Value --output text --region $INSTANCE_REGION`
sudo sed -i "s/^.*DB_PASSWORD.*$/define('DB_PASSWORD', '$root_db_password');/" /var/www/html/wp-config.php
sudo sed -i "s/^.*DB_HOST.*$/define('DB_HOST', '${db_host}');/" /var/www/html/wp-config.php

sudo systemctl restart httpd
sudo systemctl enable httpd
