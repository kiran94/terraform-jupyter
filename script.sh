#!/bin/bash

LOCAL_USER=ec2-user

echo "export PS1='\t \u@\h '" >> .bashrc

# Log stdout to file
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/home/$LOCAL_USER/terraform.log 2>&1

# Install Tools
sudo yum update -y
sudo yum install vim git tmux jq -y

# Mount the EBS volume into /data
sudo mkfs.xfs /dev/sdb -f
sudo mkdir /data
sudo mount /dev/sdb /data
sudo chown -R $LOCAL_USER:$LOCAL_USER /data
sudo echo "UUID=$(lsblk -nr -o UUID,MOUNTPOINT | grep "/data" | cut -d ' ' -f 1) /data xfs defaults,nofail 1 2" >>/etc/fstab

# Install Python Dependencies
pip3 install urllib3==1.26.6
pip3 install jupyterlab

# Configure Jupyter for AWS HTTP
runuser -l $LOCAL_USER -c 'jupyter lab --generate-config'

CONFIG_FILE="/home/$LOCAL_USER/.jupyter/jupyter_lab_config.py"
sudo chown -R $LOCAL_USER:$LOCAL_USER $CONFIG_FILE

IP=$(curl http://169.254.169.254/latest/meta-data/public-hostname)

sed -i "s/# c.ServerApp.ip = 'localhost'/c.ServerApp.ip = '"${IP}"'/" $CONFIG_FILE
sed -i "s/# c.ServerApp.allow_origin = ''/c.ServerApp.allow_origin = '*'/g" $CONFIG_FILE
sed -i "s/# c.ServerApp.open_browser = False/c.ServerApp.open_browser = False/g" $CONFIG_FILE

# Configure Jupyter Logging Levels
echo "c.Application.log_level = 'WARN'" >>$CONFIG_FILE
echo "c.ServerApp.log_level = 'WARN'" >>$CONFIG_FILE

# Configure Jupyter Overrides
JUPYTERLAB_SETTINGS_DIR=/home/$LOCAL_USER/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/

runuser -l $LOCAL_USER -c "mkdir -p ${JUPYTERLAB_SETTINGS_DIR}"

cat <<EOF >$JUPYTERLAB_SETTINGS_DIR/themes.jupyterlab-settings
{
    "theme": "JupyterLab Dark"
}
EOF

# Install Pyenv
sudo yum install gcc make patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel -y

runuser -l $LOCAL_USER -c 'curl https://pyenv.run | bash'

echo 'export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"' >> /home/$LOCAL_USER/.bashrc

echo '. ~/.bashrc' >> /home/$LOCAL_USER/.bash_profile

echo 'DONE'
