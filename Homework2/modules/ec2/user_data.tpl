#!/usr/bin/env bash

# ------------------------------------
# Set logging
# ------------------------------------
export LOGFILE=/var/log/user-data.log
exec >$LOGFILE
exec 2>&1

echo "Started user data script at $(date) ..."

# ------------------ami-08ca3fed11864d6bb------------------
# Get metadata
# ------------------------------------
echo ""
echo "Getting metadata ..."
export AWS_AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
export AWS_REGION=$(echo "$AWS_AZ" | sed 's/[a-z]$//')
export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

export NAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
# ------------------------------------
# Instance Information
# ------------------------------------
echo -e "
---------------------
Instance Information
---------------------
Region:            $AWS_REGION
Availability Zone: $AWS_AZ
Instance ID:       $INSTANCE_ID
IP:                $PRIVATE_IP
Host name :        $NAME
Instance Name:     ${deployment_name}
"

sudo mkfs -t xfs /dev/nvme1n1
sudo mkdir /ebs
sudo mount /dev/nvme1n1 /ebs
ID=`sudo blkid | grep nvme1n1 | awk  -F\" '{print $2}'\n`
sudo echo "UUID=$${ID}  /ebs  xfs  defaults,nofail  0  2" >>  /etc/fstab
sudo mount -a


sudo yum install -y epel-release
sudo yum install -y -q  nginx

sudo systemctl enable nginx


sudo mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html.bck
echo "<html>
<header><title>This is title</title></header>
<body>
Welcome to Grandpa's Whiskey on host $NAME
</body>
</html>
" > /usr/share/nginx/html/index.html

sudo systemctl start nginx.service
echo ""


sudo yum install -y  awscli
# Set region for CLI
mkdir -p ~/.aws

cat > ~/.aws/config << EOF
[default]
region = "$${AWS_REGION}"
EOF

cront=$(crontab -e)
#(crontab -l && echo "00 *  * * *  aws s3 cp /var/log/nginx/access.log s3://${bucket_name}/") | crontab -
echo "00 *  * * *  aws s3 cp /var/log/nginx/access.log s3://${bucket_name}/" >> $cront

# ------------------------------------
# Terminate Function
# ------------------------------------
function terminate() {
  shutdown -h now
}

echo ""
echo "user data script completed at $(date) ..."