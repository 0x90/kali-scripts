#!/bin/bash
. helper.sh


install_zsh(){
    if ask "Do you want to install zsh?" Y; then
        apt-get install zsh -y
    fi

    # https://github.com/robbyrussell/oh-my-zsh
    if ask "Do you want to install oh-my-zsh?" Y; then

        if command_exists curl ; then
            curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
        elif command_exists wget ; then
            wget --no-check-certificate https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
        fi

    fi
}


install_zsh



