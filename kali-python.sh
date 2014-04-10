#!/bin/bash
#TODO: add check for hg
. helper.sh

if ask "Install pip & python modules" Y; then
    echo "Step 2: PIP & Python modules"
    apt-get -y install python-setuptools python-pip python-twisted python-virtualenv idle idle3 python-qt4

    echo "Step 2: PIP & Python modules"
    easy_install pip

    echo "Step 2: PIP & Python modules"
    pip install shodan mysql-python python-ntlm scipy selenium tornado netaddr matplotlib paramiko lxml pcapy \
    GitPython PyGithub SOAPpy SQLAlchemy Jinja2

fi


if ask "Install scapy?" Y; then
    pip install -e hg+https://bb.secdev.org/scapy
fi

if ask "Install scapytain?" Y; then
    apt-get install -y python-cherrypy3 graphviz python-genshi python-sqlobject python-formencode python-pyopenssl highlight python-trml2pdf python-pip
    pip install pyopenssl
    pip install -e hg+https://bb.secdev.org/scapytain

    mcedit /etc/scapytainrc
    mkdir /var/lib/scapytain
    scapytain_dbutil -c
fi

# Latest version of Pylorcon2 https://github.com/tom5760/pylorcon2
#
if ask "Install Lorcon?" Y; then

    print_status "Installing Lorcon dependecies"
    apt-get install libpcap0.8-dev libnl-dev

    #Requires lorcon2:
    print_status "Installing Lorcon"
    cd /usr/src
    git clone https://code.google.com/p/lorcon
    cd lorcon
    ./configure
    make
    make install

    # install pylorcon. Deprecated?
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

    # to make lorcon available to metasploit
    #cd ../ruby-lorcon/
    #ruby extconf.rb
    #make
    #make install

fi



#!/bin/sh
PYTHON='/usr/bin/python'
GIT_FILENAME='git-1.7.7.3-intel-universal-snow-leopard'
GIT_VOLUME='/Volumes/Git 1.7.7.3 Snow Leopard Intel Universal/'
GFORTRAN='gcc-42-5666.3-darwin11.pkg'
SUDO='sudo'
BRANCH='master'

if [ -z "$VIRTUAL_ENV" ]; then
    # Standard Python env
    PYTHON=/usr/bin/python
    SUDO=${SUDO}
else
    # Virtualenv
    PYTHON=python
    SUDO="" #${SUDO} is not required in a virtualenv
fi

if  [ -d ".git" ]; then

    SUPERPACK_PATH='.'

else

    SUPERPACK_PATH='ScipySuperpack'

    hash git &> /dev/null
    if [ $? -eq 1 ]; then
        hash brew &> /dev/null
        if [ $? -eq 1 ]; then
            echo 'Downloading Git for OS X ...'
            curl -o ${GIT_FILENAME}.dmg http://git-osx-installer.googlecode.com/files/${GIT_FILENAME}.dmg
            echo 'Installing Git ...'
            hdiutil mount ${GIT_FILENAME}.dmg
            ${SUDO} installer -pkg "${GIT_VOLUME}${GIT_FILENAME}.pkg" -target '/'
            hdiutil unmount "${GIT_VOLUME}"
            echo 'Cleaning up'
            rm ${GIT_FILENAME}.dmg
            echo 'Cloning Scipy Superpack'
            /usr/local/git/bin/git clone --depth=1 git://github.com/fonnesbeck/ScipySuperpack.git
        else
            brew install git
            echo 'Cloning Scipy Superpack'
            git clone --depth=1 git://github.com/fonnesbeck/ScipySuperpack.git
        fi
    else
        echo 'Cloning Scipy Superpack'
        git clone --depth=1 git://github.com/fonnesbeck/ScipySuperpack.git
    fi

    cd ${SUPERPACK_PATH}
    git checkout "${BRANCH}"
    cd ..
fi

hash brew &> /dev/null
if [ $? -eq 1 ]; then
    echo 'Downloading gFortran ...'
    curl -o ${GFORTRAN} http://r.research.att.com/tools/${GFORTRAN}
    echo 'Installing gFortran ...'
    ${SUDO} installer -pkg ${GFORTRAN} -target '/'
else
    brew install gfortran
fi

hash easy_install &> /dev/null
if [ $? -eq 1 ]; then
    echo 'Downloading ez_setup ...'
    curl -o ez_setup.py http://peak.telecommunity.com/dist/ez_setup.py
    echo 'Installing ez_setup ...'
    ${SUDO} "${PYTHON}" ez_setup.py
    rm ez_setup.py
fi

echo 'Installing Scipy Superpack ...'
${SUDO} "${PYTHON}" -m easy_install -N -Z ${SUPERPACK_PATH}/*.egg

echo 'Installing readline ...'
${SUDO} "${PYTHON}" -m easy_install -N -Z readline
echo 'Installing nose ...'
${SUDO} "${PYTHON}" -m easy_install -N -Z nose
echo 'Installing six'
${SUDO} "${PYTHON}" -m easy_install -N -Z six
echo 'Installing pyparsing'
${SUDO} "${PYTHON}" -m easy_install -N -Z pyparsing==1.5.7
echo 'Installing python-dateutil'
${SUDO} "${PYTHON}" -m easy_install -N -Z python-dateutil
echo 'Installing pytz'
${SUDO} "${PYTHON}" -m easy_install -N -Z pytz
echo 'Installing Tornado'
${SUDO} "${PYTHON}" -m easy_install -N -Z tornado==3.1.1
echo 'Installing pyzmq'
${SUDO} "${PYTHON}" -m easy_install -N -Z pyzmq
echo 'Installing pika'
${SUDO} "${PYTHON}" -m easy_install -N -Z pika
echo 'Installing jinja2'
${SUDO} "${PYTHON}" -m easy_install jinja2
echo 'Installing patsy'
${SUDO} "${PYTHON}" -m easy_install -N -Z patsy
echo 'Installing pygments'
${SUDO} "${PYTHON}" -m easy_install -N -Z pygments
echo 'Installing sphinx'
${SUDO} "${PYTHON}" -m easy_install -N -Z sphinx
if  [ ! -d ".git" ]; then
    echo 'Cleaning up'
    rm -rf ${SUPERPACK_PATH}
fi

echo 'Done'
