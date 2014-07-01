#!/bin/sh

apt-get install vidalia privoxy -y

echo forward-socks4a / 127.0.0.1:9050 . >> /etc/privoxy/config

mkdir -p /var/run/tor
chown debian-tor:debian-tor /var/run/tor
chmod 02750 /var/run/tor

/etc/init.d/tor start
/etc/init.d/privoxy start

#USE SOCKS PROXY 127.0.0.1:9059