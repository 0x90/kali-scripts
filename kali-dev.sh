#!/bin/bash
. helper.sh

install_devel(){

    print_status "Installing development tools and environment"
    apt-get install -y build-essential module-assistant libncurses5-dev zlib1g-dev gawk flex gettext \
    gcc gcc-multilib dkms make linux-headers-$(uname -r) autoconf automake libssl-dev \
    kernel-package ncurses-dev fakeroot bzip2 linux-source
    success_check
    apt-get install -y build-essential openssl libreadline6 libreadline6-dev git-core zlib1g zlib1g-dev libssl-dev \
    libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison \
    libmysqlclient-dev libmagickcore-dev libmagick++-dev libmagickwand-dev libnetfilter-queue-dev
    success_check

    print_status "Installing git,hg,svn.."
    apt-get install -y git subversion mercurial

    print_status "System Pre-requirements"

    if ask "Install i386 support? Install to compile old software!" Y; then
        dpkg --add-architecture i386
        apt-get update -y && apt-get install ia32-libs -y
    fi

    if ask "Install MinGW compiler+tools?" N; then
        apt-get install -y binutils-mingw-w64 gcc-mingw-w64 mingw-w64 mingw-w64-dev
    fi
}

install_devel
