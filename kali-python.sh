#!/bin/bash
. helper.sh

python_libs(){
    if ask "Install pip & python modules" Y; then
        apt-get -y install python-setuptools bpython python-setuptoolspython-twisted
        # python-pip removed because of too fresh version
        easy_install pip==1.2.1

        apt-get install -y python-twisted python-virtualenv idle idle3 python-qt4
        pip install shodan mysql-python python-ntlm scipy selenium tornado netaddr matplotlib paramiko lxml pcapy \
        GitPython PyGithub SOAPpy SQLAlchemy Jinja2 readline nose six pyparsing==1.5.7 python-dateutil tornado==3.1.1 \
        pyzmq pytz pika pygments scipy patsy
    fi

    # http://www.scipy.org/install.html
    # http://pandas.pydata.org/pandas-docs/stable/install.html

    if ask "Install scapy?" Y; then
        print_status "Installing Scapy dependencies"
        apt-get install tcpdump graphviz imagemagick python-gnuplot python-crypto python-pyx wireshark -y
        
        #pip install -e hg+https://bb.secdev.org/scapy#egg=scapy --insecure
        cd /tmp
        hg clone https://bb.secdev.org/scapy --insecure
        cd scapy
        ./setup.py install

        #Cleanup
        cd ..
        rm -rf scapy/*
        rm -rf scapy/.hg*
        rmdir scapy
    fi

    if ask "Install scapytain?" N; then
        
        apt-get install -y python-cherrypy3 graphviz python-genshi python-sqlobject python-formencode python-pyopenssl highlight python-trml2pdf python-pip
        # pip install   http://www.satchmoproject.com/snapshots/trml2pdf-1.2.tar.gz
        pip install pyopenssl
        
        #pip install -e hg+ --insecure
        # udo pip install -e hg+http://bb.secdev.org/scapytain#egg=scapytain --insecure
        cd /tmp
        hg clone https://bb.secdev.org/scapytain --insecure
        cd scapytain
        ./setup.py install

        mcedit /etc/scapytainrc
        mkdir /var/lib/scapytain
        scapytain_dbutil -c

        #Cleanup
        cd /tmp
        rm -rf scapytain/*
        rm -rf scapytain/.hg*
        rmdir scapytain
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
    fi


    if ask "Install Jetbrains PyCharm Community Edition?" N; then
        print_status "Installing Oracle JDK 7 + prequerements"
        print_status "Downloading to /usr/sbin/add-apt-repository.."
        wget http://blog.anantshri.info/content/uploads/2010/09/add-apt-repository.sh.txt -O /usr/sbin/add-apt-repository
        chmod o+x /usr/sbin/add-apt-repository
        #chown root:root /usr/sbin/add-apt-repository
        add-apt-repository ppa:webupd8team/java && apt-get update -y
        #TODO: Can we agree the license in auto mode?
        apt-get install oracle-java7-installer -y

        cd /opt
        wget http://download.jetbrains.com/python/pycharm-community-3.4.1.tar.gz
        tar xzvf pycharm-community-3.4.1.tar.gz
        rm -f pycharm-community-3.4.1.tar.gz
        mv pycharm-community-3.4.1 pycharm-community
    fi

}

python_libs
