#!/bin/sh
# Kali Linux additional tools installation script

if [[ $EUID -ne 0 ]]; then
   echo "You must be root to do this." 1>&2
   exit 1
fi

echo "Step 0: Fresh the system"
apt-get update && apt-get upgrade

echo "Step 1: System Pre-requirements"
apt-get install -y mc gcc screen python-setuptools python-pip python-twisted git subversion mercurial curl build-essential \
 openssl libreadline6 libreadline6-dev git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev \
 libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion libmysqlclient-dev libmagickcore-dev \
 libmagick++-dev libmagickwand-dev libnetfilter-queue-dev

echo "Step 2: PIP & Python modules"
easy_install pip
pip install shodan scapy scipy selenium tornado netaddr matplotlib paramiko lxml pcapy GitPython PyGithub SOAPpy SQLAlchemy Jinja2

echo "Step 3: RVM & Ruby modules & watobo"
curl -L https://get.rvm.io | bash -s stable
source /usr/local/rvm/scripts/rvm
rvm install 1.9.3
rvm use 1.9.3 --default
gem install bundler risu ffi multi_json childprocess selenium-webdriver mechanize fxruby net-http-digest_auth net-http-persistent nokogiri domain_name unf webrobots ntlm-http net-http-pipeline nfqueue watobo

echo "Step 4: OWASP Tools"
apt-get install zaproxy owasp-mantra-ff

echo "Step 5: OWTF"
cd /root
git clone https://github.com/7a/owtf/
cd owtf
python install/install.py

echo "Step 6: Installing Kali Lazy.."
curl https://lazykali.googlecode.com/git/lazykali.sh > /usr/bin/lazykali
lazykali
#cd /root
#git clone https://code.google.com/p/lazykali/
#lazykali/lazykali.sh