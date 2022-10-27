Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"


#!/bin/bash
yum update -y # Update OS
yum -y install httpd mod_ssl # Install http deamon
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata # Get EC2 tools
chmod u+x ec2-metadata # allow execution
echo "Hello World from $(hostname -f)" ID= "$(./ec2-metadata -i)" AZ= "$(./ec2-metadata -z)" > /var/www/html/index.html # Create html text
service httpd start # Start httpd
chkconfig httpd on # Insure httpd service on
