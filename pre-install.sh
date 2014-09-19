#!/bin/sh
##
## Installs the pre-requisites for running edX on a single Ubuntu 12.04
## instance.  This script is provided as a convenience and any of these
## steps could be executed manually.
##
## Note that this script requires that you have the ability to run
## commands as root via sudo.  Caveat Emptor!
##

##
## Sanity check
##
if [[ ! "$(lsb_release -d | cut -f2)" =~ $'Ubuntu 12.04' ]]; then
   echo "This script is only known to work on Ubuntu 12.04, exiting...";
   exit;
fi

##
## Change ubuntu repo
##
sudo cp  /etc/apt/sources.list  /etc/apt/sources.list.bak
sudo sed -i 's/security.ubuntu.com/mirror.bit.edu.cn/g' /etc/apt/sources.list
sudo sed -i 's/cn.archive.ubuntu.com/mirror.bit.edu.cn/g' /etc/apt/sources.list
sudo sed -i 's/us.archive.ubuntu.com/mirror.bit.edu.cn/g' /etc/apt/sources.list

##
## Set pypi index-url
##

sudo mkdir /root/.pip
mkdir ~/.pip

cat << EOF > ~/.pip/pip.conf
[global]
index-url = http://pypi.douban.com/simple
timeout = 60
EOF

sudo cp ~/.pip/pip.conf /root/.pip/

##
## Install system pre-requisites
##
sudo apt-get update
sudo apt-get install -y build-essential software-properties-common python-software-properties curl git-core libxml2-dev libxslt1-dev libfreetype6-dev python-pip python-apt python-dev
sudo pip install --upgrade pip
sudo pip install --upgrade virtualenv

##
## Clone the configuration repository and run Ansible
##
cd /var/tmp
git clone  https://github.com/eduStack/configuration

##
## Install the ansible requirements
##
cd /var/tmp/configuration
sudo pip install -r requirements.txt

##
## Run the eduStack.yml playbook in the configuration/playbooks directory
##
cd /var/tmp/configuration/playbooks/edx-east
sudo ansible-playbook -c local --limit "localhost:127.0.0.1" ../eduStack.yml -i "localhost," -e 'EDXAPP_PREVIEW_LMS_BASE=preview.edustack.net  EDXAPP_LMS_BASE=www.edustack.net EDXAPP_CMS_BASE=studio.edustack.net EDXAPP_LMS_PREVIEW_NGINX_PORT=80 EDXAPP_CMS_NGINX_PORT=80 EDXAPP_LMS_NGINX_PORT=80 edx_platform_version=master '
