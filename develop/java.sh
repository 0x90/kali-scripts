#!/usr/bin/env bash

install_jdk(){
    add-apt-repository ppa:webupd8team/java && apt-get update -y
    #TODO: Can we agree the license in auto mode?
    apt-get install oracle-java7-installer -y
}