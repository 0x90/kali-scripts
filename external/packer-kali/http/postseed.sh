#!/bin/sh

apt-get install -y sudo

cp /etc/sudoers /etc/sudoers.bak

cat <<EOF > /etc/sudoers
Defaults	env_reset
Defaults	mail_badpass
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

root	ALL=(ALL:ALL) ALL
%sudo	ALL=(ALL) NOPASSWD: ALL
EOF

update-rc.d ssh enable

