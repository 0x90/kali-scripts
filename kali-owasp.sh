#!/bin/sh
# Kali Linux additional tools installation script
# RUN AS ROOT. NO FUCKING SUDO.

# Step 1: System Pre-requirements
apt-get install -y mc gcc screen python-setuptools python-pip python-twisted git subversion mercurial
apt-get install -y curl build-essential openssl libreadline6 libreadline6-dev git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion libmysqlclient-dev libmagickcore-dev libmagick++-dev libmagickwand-dev

# Step 2: OWASP Tools
apt-get install zaproxy owasp-mantra-ff

# Step 3: PIP & Python modules
easy_install pip
pip install shodan scapy scipy selenium tornado netaddr  matplotlib paramiko lxml pcapy GitPython PyGithub SOAPpy SQLAlchemy Jinja2

# Step 4: RVM & Ruby modules
curl -L https://get.rvm.io | bash -s stable
source /usr/local/rvm/scripts/rvm
rvm install 1.9.3
rvm use 1.9.3 --default
gem install bundler risu

# Step 5: OWTF
cd /root
git clone https://github.com/7a/owtf/
cd owtf
python install/install.py


# Step 6: Kali Lazy
cd /root
git clone https://code.google.com/p/lazykali/
lazykali/lazykali.sh