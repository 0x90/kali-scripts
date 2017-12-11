#!/usr/bin/env bash
#
. postinstall.sh

install_jdk(){
    apt-get -y install default-jdk openjdk-6-jdk
    apt_add_repo ppa:webupd8team/java

    #TODO: Can we agree the license in auto mode?
    apt-get install oracle-java7-installer -y
}

install_python(){
    if ask "Install pip and other python modules" Y; then
        apt-get -y install bpython python-setuptools python-twisted python-shodan  \
        python-virtualenv python-pygments python-tornado python-sqlalchemy python-lxml python-pymongo \
        python-gnuplot python-matplotlib python-pandas python-scipy \
        python-requests python-gevent
        pip install virtualenvwrapper cookiecutter
    fi

    if ask "Install Jetbrains PyCharm Community Edition?" N; then
        cd /opt
        wget http://download-cf.jetbrains.com/python/pycharm-community-4.5.3.tar.gz
        tar xzvf pycharm-community-*.tar.gz
        rm -f pycharm-community-*.tar.gz
        mv pycharm-community-* pycharm-community
    fi
}

install_ruby(){
    if ask "Do you want to install RVM ands set ruby-1.9.5 to default?" Y; then
        curl -L https://get.rvm.io | bash -s stable
        source /usr/local/rvm/scripts/rvm
        rvm install 1.9.5 && rvm use 1.9.5 --default
#        source /etc/profile.d/rvm.sh

        # This loads RVM into a shell session.
        #echo [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" >> ~/.bashrc
        echo source /usr/local/rvm/scripts/rvm >> ~/.bashrc
    fi

    if ask "Do you want to install ruby and extras?" Y; then
        # This tells RubyGems to not generate documentation for every library it installs.
        echo "gem: --no-rdoc --no-ri" > ~/.gemrc

        apt-get -y install ruby-full ruby-dev libpcap-ruby libpcap-dev libsp-gxmlcpp-dev libsp-gxmlcpp1 libxslt1.1 libxslt1-dev libxrandr-dev libfox-1.6-dev
        update-alternatives --config ruby

        gem install bundler risu ffi multi_json childprocess selenium-webdriver mechanize fxruby net-http-digest_auth pcaprub \
        net-http-persistent nokogiri domain_name unf webrobots ntlm-http net-http-pipeline nfqueue pry colorize mechanize
    fi
}

install_dev(){
    print_status "Installing development tools and environment"
    echo "deb http://security.debian.org/debian-security wheezy/updates main" >> /etc/apt/sources.list
    apt-get update -y
    apt-get install -y cmake cmake-data autoconf build-essential module-assistant libncurses5-dev zlib1g-dev gawk flex gettext \
    gcc gcc-multilib dkms make patchutils strace wdiff linux-headers-amd64 autoconf automake libssl-dev \
    kernel-package libncurses5-dev fakeroot bzip2 linux-source openssl libreadline7 libreadline-dev git-core zlib1g zlib1g-dev libssl-dev \
    libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev autoconf libc6-dev libncurses5-dev automake libtool bison \
    libmysqlclient18 libmagickwand-6.q16-dev libmagickcore-6.q16-dev libmagick++-6.q16-dev libmagickcore-dev libmagick++-dev libmagickwand-dev \
    libnetfilter-queue-dev git subversion mercurial
    check_success
    print_status "System Pre-requirements"

    if ask "Install i386 support? Install to compile old software!" Y; then
        install_32bit
    fi

    if ask "Install JDK?" Y; then
        install_jdk
    fi

    if ask "Install Python tools?" Y; then
        install_python
    fi

    if ask "Install RVM+Ruby?" Y; then
        install_ruby
    fi

    if ask "Install Sublime?" N; then
        apt_add_repo ppa:webupd8team/sublime-text-3
        apt-get install sublime-text-installer
    fi

    if ask "Install MinGW compiler+tools?" N; then
        apt-get install -y binutils-mingw-w64 gcc-mingw-w64 mingw-w64 \
        mingw-w64-x86-64-dev mingw-w64-i686-dev
    fi
}

if [ "${0##*/}" = "dev.sh" ]; then
    install_dev
fi
