#!/bin/bash
sleep 1m
# Log stdout to file
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/home/ec2-user/terraform.log 2>&1
# Update AL2
sudo yum update -y

# Install Tools
sudo yum install vim tmux jq -y

# Mount the EBS volume into /data
sudo mkfs.xfs /dev/sdb -f
sudo mkdir /data
sudo mount /dev/sdb /data
sudo chown -R ec2-user:ec2-user /data
sudo echo "UUID=$(lsblk -nr -o UUID,MOUNTPOINT | grep "/data" | cut -d ' ' -f 1) /data xfs defaults,nofail 1 2" >>/etc/fstab

# Install Python Dependencies
pip3 install urllib3==1.26.6
pip3 install jupyterlab

# Configure Jupyter for AWS HTTP
runuser -l ec2-user -c 'jupyter lab --generate-config'

CONFIG_FILE="/home/ec2-user/.jupyter/jupyter_lab_config.py"
sudo chown -R ec2-user:ec2-user $CONFIG_FILE

IP=$(curl http://169.254.169.254/latest/meta-data/public-hostname)

sed -i "s/# c.ServerApp.ip = 'localhost'/c.ServerApp.ip = '"${IP}"'/" $CONFIG_FILE
sed -i "s/# c.ServerApp.allow_origin = ''/c.ServerApp.allow_origin = '*'/g" $CONFIG_FILE
sed -i "s/# c.ServerApp.open_browser = False/c.ServerApp.open_browser = False/g" $CONFIG_FILE

echo 'DONE'
