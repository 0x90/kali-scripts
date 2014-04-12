#!/bin/bash
#
. helper.sh



if ask "Do you want to install RVM ands set ruby-1.9.3 to default?" Y; then
    curl -L https://get.rvm.io | bash -s stable
    source /usr/local/rvm/scripts/rvm
    rvm install 1.9.3
    rvm use 1.9.3 --default

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
