#!/bin/bash
yum update -y
yum install -y python3 git python3-pip

cd /home/ec2-user
git clone https://github.com/zaga000/sandbox_miniWeb.git
cd your-repo-name

pip3 install -r requirements.txt

export DB_HOST="${rds_endpoint}"
export DB_USER="${db_user}"
export DB_PASSWORD="${db_password}"
export DB_NAME="${db_name}"

export GIT_SHA=$(git rev-parse --short HEAD)

nohup python3 main.py > /home/ec2-user/app.log 2>&1 &