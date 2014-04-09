#!/bin/sh



apt-get install -y python-cherrypy3 graphviz python-genshi python-sqlobject python-formencode python-pyopenssl highlight python-trml2pdf python-pip
pip install pyopenssl

mcedit /etc/scapytainrc

mkdir /var/lib/scapytain
scapytain_dbutil -c
