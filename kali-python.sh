#!/bin/bash
#TODO: add check for hg
. helper.sh

python_libs(){
    if ask "Install pip & python modules" Y; then
        echo "Step 2: PIP & Python modules"
        apt-get -y install python-setuptools #python-pip
        easy_install pip==1.2.1

        echo "Step 2: Python modules.."
        apt-get install python-twisted python-virtualenv idle idle3 python-qt4
        pip install shodan mysql-python python-ntlm scipy selenium tornado netaddr matplotlib paramiko lxml pcapy \
        GitPython PyGithub SOAPpy SQLAlchemy Jinja2 readline nose six pyparsing==1.5.7 python-dateutil tornado==3.1.1 \
        pyzmq pytz pika pygments scipy patsy

    fi


    if ask "Install scapy?" Y; then
        pip install -e hg+https://bb.secdev.org/scapy#egg=scapy
    fi

    if ask "Install scapytain?" Y; then
        apt-get install -y python-cherrypy3 graphviz python-genshi python-sqlobject python-formencode python-pyopenssl highlight python-trml2pdf python-pip
        pip install pyopenssl
        pip install -e hg+https://bb.secdev.org/scapytain#egg=scapytain

        mcedit /etc/scapytainrc
        mkdir /var/lib/scapytain
        scapytain_dbutil -c
    fi

    # Latest version of Pylorcon2 https://github.com/tom5760/pylorcon2
    if ask "Install Lorcon?" Y; then

        print_status "Installing Lorcon dependecies"
        apt-get install libpcap0.8-dev libnl-dev

        #Requires lorcon2:
        print_status "Installing Lorcon"
        cd /usr/src
        git clone https://code.google.com/p/lorcon
        cd lorcon
        ./configure
        make && make install

        #TODO: Deprecated?
        #echo "Install pylorcon"
        #cd /usr/src
        #svn checkout http://pylorcon.googlecode.com/svn/trunk/ pylorcon
        #cd pylorcon
        #python setup.py build
        #python setup.py install

        # install pylorcon2
        print_status "Install pylorcon2"
        cd /usr/src
        svn checkout http://pylorcon2.googlecode.com/svn/trunk/ pylorcon2
        cd pylorcon2
        python setup.py build
        python setup.py install

        #TODO: move to ruby
        # to make lorcon available to metasploit
        #cd ../ruby-lorcon/
        #ruby extconf.rb
        #make
        #make install
    fi
}

if ask "Do you want to install python modules?" Y; then
    python_libs
fi