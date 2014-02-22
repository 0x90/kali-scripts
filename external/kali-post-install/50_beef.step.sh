#!/bin/bash
. ask.sh

ask "Do you want to install BeEF (browser explotation framework)?)" Y || exit 3

apt-get -y install beef-xss beef-xss-bundle
