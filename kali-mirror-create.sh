#!/bin/sh
# Based on http://docs.kali.org/kali-support/kali-linux-mirrors

adduser --disabled-password archvsync

mkdir /srv/mirrors/kali{,-security,-images}
chown archvsync:archvsync /srv/mirrors/kali{,-security,-images}

sed -i -e "s/RSYNC_ENABLE=false/RSYNC_ENABLE=true/" /etc/default/rsync

cat <<EOF > /etc/rsyncd.conf
uid = nobody
gid = nogroup
max connections = 25
socket options = SO_KEEPALIVE

[kali]
path = /srv/mirrors/kali
comment = The Kali Archive
read only = true

[kali-security]
path = /srv/mirrors/kali-security
comment = The Kali security archive
read only = true

[kali-images]
path = /srv/mirrors/kali-images
comment = The Kali ISO images
read only = true
EOF

service rsync start


sudo su - archvsync
wget http://archive.kali.org/ftpsync.tar.gz
tar zxf ftpsync.tar.gz

#Now we need to create two configurations files.
# We start from a template and we edit at least the MIRRORNAME, TO, RSYNC_PATH, and RSYNC_HOST parameters:
cp etc/ftpsync.conf.sample etc/ftpsync-kali.conf
cp etc/ftpsync.conf.sample etc/ftpsync-kali-security.conf
vim etc/ftpsync-kali.conf
grep -E '^[^#]' etc/ftpsync-kali.conf
MIRRORNAME=`hostname -f`
TO="/srv/mirrors/kali/"
RSYNC_PATH="kali"
RSYNC_HOST=archive.kali.org
vim etc/ftpsync-kali-security.conf
grep -E '^[^#]' etc/ftpsync-kali-security.conf
MIRRORNAME=`hostname -f`
TO="/srv/mirrors/kali-security/"
RSYNC_PATH="kali-security"
RSYNC_HOST=archive.kali.org
The last step is to setup the .ssh/authorized_keys file so that archive.kali.org can trigger your mirror:

mkdir -p .ssh
wget -O - -q http://archive.kali.org/pushmirror.pub >>.ssh/authorized_keys

#If you have not unpacked the ftpsync.tar.gz in the home directory,
# then you must adjust accordingly the “~/bin/ftpsync” path, which is hard-coded in .ssh/authorized_keys.
# Now you must send an email to devel@kali.org with all the URLs of your mirrors so that you can be added in the main mirror list
# and to open up your rsync access on archive.kali.org. Please indicate clearly who should be contacted in case of problems
# (or if changes must be made/coordinated to the mirror setup).
# Instead of waiting for the first push from archive.kali.org, you should run an initial rsync with a mirror close to you,
# using the mirror list linked above to select one. Assuming that you picked archive-4.kali.org, here’s what you can run as your
# dedicated mirror user:

rsync -qaH archive-4.kali.org::kali /srv/mirrors/kali/ &
rsync -qaH archive-4.kali.org::kali-security /srv/mirrors/kali-security/ &
rsync -qaH archive-4.kali.org::kali-images /srv/mirrors/kali-images/ &

# Manual Mirror of ISO Images
# The ISO images repository does not use push mirroring so you must schedule a daily rsync run.
# We provide a bin/mirror-kali-images script, which is ready to use that you can add in the crontab of your dedicated user.
# You just have to configure etc/mirror-kali-images.conf.
sudo su - archvsync
cp etc/mirror-kali-images.conf.sample etc/mirror-kali-images.conf
vim etc/mirror-kali-images.conf
grep -E '^[^#]' etc/mirror-kali-images.conf
TO=/srv/mirrors/kali-images/
crontab -e
crontab -l
# m h dom mon dow command
39 3 * * * ~/bin/mirror-kali-images

