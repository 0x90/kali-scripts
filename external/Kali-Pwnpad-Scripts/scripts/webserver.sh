#!/bin/bash
if [ -d "/opt/pwnpad/web-interface" ]; then
	echo "Starting webserver on localhost:8000"
	service atd start
	cd /opt/pwnpad/web-interface
	php -S localhost:8000
else
	echo "This will install necessary pre-requistes such as"
	echo "autossh, PHP, and AT needed for webserver"
	apt-get -y install php5 php5-cli php-pear autossh at
	cd /opt/pwnpad
	git clone https://github.com/binkybear/web-interface.git
	echo "Starting webserver on localhost:8000"
	service atd start
	cd /opt/pwnpad/web-interface/infusions
	rm -r .gitignore
	cd /opt/pwnpad/web-interface
	php -S localhost:8000
fi