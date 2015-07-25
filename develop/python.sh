#!/usr/bin/env bash
#
source ../helper/helper.sh

python_libs(){
    if ask "Install pip & python modules" Y; then
        apt-get -y install python-setuptools bpython python-setuptoolspython-twisted
        # python-pip removed because of too fresh version
#        easy_install pip==1.2.1

        apt-get install -y python-twisted python-virtualenv idle idle3 python-qt4
        pip install shodan mysql-python python-ntlm scipy selenium tornado netaddr matplotlib paramiko lxml pcapy \
        GitPython PyGithub SOAPpy SQLAlchemy Jinja2 readline nose six pyparsing==1.5.7 python-dateutil tornado==3.1.1 \
        pyzmq pytz pika pygments scipy patsy
    fi

    # http://www.scipy.org/install.html
    # http://pandas.pydata.org/pandas-docs/stable/install.html

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
