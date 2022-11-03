#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user
mkdir /tmp/docker
cat<< EOT > /tmp/docker/Dockerfile
FROM ubuntu:18.04
# Install dependencies
RUN apt-get update && \
apt-get -y install apache2
# Install apache and write hello world message
RUN echo 'Hello World, CS55C demo of Apache running in a Docker Container!!' > /var/www/html/index.html
# Configure apache
RUN echo '. /etc/apache2/envvars' > /root/run_apache.sh && \
echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh && \
echo 'mkdir -p /var/lock/apache2' >> /root/run_apache.sh && \
echo '/usr/sbin/apache2 -D FOREGROUND' >> /root/run_apache.sh && \
chmod 755 /root/run_apache.sh
EXPOSE 80
CMD /root/run_apache.sh
EOT
docker build -t hello-world /tmp/docker/.
docker run -p 80:80 hello-world
