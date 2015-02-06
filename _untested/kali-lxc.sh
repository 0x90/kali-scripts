#!/bin/bash
# template testing script
cp lxc-kali /usr/lib/lxc/templates/
lxc-create -n kali-testing -t kali


#!/bin/bash
SSH_PORT=65512
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfPIOm6TSo7pffbQzWCp9NILUZTPURMotgyfILXzbqb5xmaYGPN/CnDkbTD6EXoHklqhnT7eLVHjg2F93GtkNf8k5cy1UpPBkJ9YUGK9bJdaVN/VtFhU+lAUcXVu/DfPBfCywGDlznmlJItwCHY39vB8z+SqK+OEDkL1hARSmaG4ulhdymJ8wg8U5jOHmnaVi0eGXUrjVYK67jahru/7r90Vpt+3wWLzzHAH9hqI+IJImsFUxaNQuunLhmtGVg991Tz8tqwQjIJVaCdOcKN7KWhN+rXZPqYfX8OEe6S+BxPSW+13IBu6X61la96MjGGEm+XgsrkSLqBk7J75jlycwN"
DNS_SERVER="8.8.8.8"
MIRROR="http://ftp.uk.debian.org/debian"
DEBIAN_FRONTEND=noninteractive

configure_kali()
{
    rootfs=$1
    hostname=$2

    for tty in $(seq 1 4); do
	if [ ! -e $rootfs/dev/tty$tty ]; then
	    mknod $rootfs/dev/tty$tty c 4 $tty
	fi
    done

    # configure the inittab
    cat <<EOF > $rootfs/etc/inittab
id:3:initdefault:
si::sysinit:/etc/init.d/rcS
l0:0:wait:/etc/init.d/rc 0
l1:1:wait:/etc/init.d/rc 1
l2:2:wait:/etc/init.d/rc 2
l3:3:wait:/etc/init.d/rc 3
l4:4:wait:/etc/init.d/rc 4
l5:5:wait:/etc/init.d/rc 5
l6:6:wait:/etc/init.d/rc 6
# Normally not reached, but fallthrough in case of emergency.
z6:6:respawn:/sbin/sulogin
1:2345:respawn:/sbin/getty 38400 console
c1:12345:respawn:/sbin/getty 38400 tty1 linux
c2:12345:respawn:/sbin/getty 38400 tty2 linux
c3:12345:respawn:/sbin/getty 38400 tty3 linux
c4:12345:respawn:/sbin/getty 38400 tty4 linux
p6::ctrlaltdel:/sbin/init 6
p0::powerfail:/sbin/init 0
EOF

    # disable selinux in kali
    mkdir -p $rootfs/selinux
    echo 0 > $rootfs/selinux/enforce

    # configure the network using the dhcp
    cat <<EOF > $rootfs/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

    # set the hostname
    cat <<EOF > $rootfs/etc/hostname
$hostname
EOF
    cat <<EOF > $rootfs/etc/apt/sources.list
deb http://ftp.uk.debian.org/debian/ wheezy main contrib non-free
deb-src http://ftp.uk.debian.org/debian/ wheezy main contrib non-free
deb http://security.debian.org/ wheezy/updates main contrib non-free
deb-src http://security.debian.org/ wheezy/updates main contrib non-free
deb http://http.kali.org/kali kali main contrib non-free
deb-src http://http.kali.org/kali kali main contrib non-free
deb http://security.kali.org/kali-security kali/updates main contrib non-free
deb-src http://security.kali.org/kali-security kali/updates main contrib non-free
EOF
    cat <<EOF > $rootfs/etc/ssh/sshd_config
Port $SSH_PORT
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 768
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
X11Forwarding no
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
EOF
    cat <<EOF > $rootfs/etc/locale.gen
en_GB.UTF-8 UTF-8
pl_PL ISO-8859-2
pl_PL.UTF-8 UTF-8
EOF
    cat <<EOF > $rootfs/tmp/install.sh
#!/bin/bash
locale-gen
update-locale LANG=en_US.UTF-8
apt-key adv --keyserver pgp.mit.edu --recv-keys ED444FF07D8D0BF6

mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "$SSH_KEY" > /root/.ssh/authorized_keys2
chmod 600 /root/.ssh/authorized_keys2
echo "nameserver $DNS_SERVER" > /etc/resolv.conf
apt-get update
aptitude -f -y install ~prequired ~pstandard kali-linux
EOF
    chroot $rootfs /bin/bash /tmp/install.sh
    chroot $rootfs rm /tmp/install.sh
    # remove pointless services in a container
    chroot $rootfs /usr/sbin/update-rc.d -f checkroot.sh remove
    chroot $rootfs /usr/sbin/update-rc.d -f umountfs remove
    chroot $rootfs /usr/sbin/update-rc.d -f hwclock.sh remove
    chroot $rootfs /usr/sbin/update-rc.d -f hwclockfirst.sh remove

    echo "root:toor" | chroot $rootfs chpasswd
    echo "Root password is 'toor', please change !"

    return 0
}

cleanup()
{
    rm -rf $cache/partial-kali-$arch
    rm -rf $cache/rootfs-kali-$arch
}

download_debian()
{
    packages=ifupdown,locales,libui-dialog-perl,dialog,isc-dhcp-client,netbase,net-tools,iproute,openssh-server,build-essential,htop,mc,bmon,iptables,tcpdump,vim,git,subversion,rsyslog,cron,aptitude,apt-file,inetutils-ping,inetutils-telnet,nano,net-tools,netbase,netcat-traditional,traceroute,wget,logrotate,iproute,install-info,info,cpio,bsdmainutils,logrotate,lsb-release,psmisc,less,vim,emacs,unattended-upgrades,sudo,
    cache=$1
    arch=$2

    trap cleanup EXIT SIGHUP SIGINT SIGTERM
    mkdir -p "$cache/partial-kali-$arch"
    if [ $? -ne 0 ]; then
	echo "Failed to create '$cache/partial-kali-$arch' directory"
	return 1
    fi

    echo "Downloading debian minimal ..."
    debootstrap --verbose --variant=minbase --arch=$arch \
	--include=$packages \
	"wheezy" "$cache/partial-kali-$arch" $MIRROR
    if [ $? -ne 0 ]; then
	echo "Failed to download the rootfs, aborting."
	return 1
    fi

    mv "$1/partial-kali-$arch" "$1/rootfs-kali-$arch"
    echo "Download complete."
    trap EXIT
    trap SIGINT
    trap SIGTERM
    trap SIGHUP

    return 0
}

copy_debian()
{
    cache=$1
    arch=$2
    rootfs=$3

    # make a local copy of the minidebian
    echo -n "Copying rootfs to $rootfs..."
    mkdir -p $rootfs
    rsync -a "$cache/rootfs-kali-$arch"/ $rootfs/ || return 1
    return 0
}

install_kali()
{
    cache="/var/cache/lxc/kali"
    rootfs=$1
    mkdir -p /var/lock/subsys/
    (
	flock -x 200
	if [ $? -ne 0 ]; then
	    echo "Cache repository is busy."
	    return 1
	fi

	arch=$(dpkg --print-architecture)

	echo "Checking cache download in $cache/rootfs-kali-$arch ... "
	if [ ! -e "$cache/rootfs-kali-$arch" ]; then
	    download_debian $cache $arch
	    if [ $? -ne 0 ]; then
		echo "Failed to download 'debian base'"
		return 1
	    fi
	fi

	copy_debian $cache $arch $rootfs
	if [ $? -ne 0 ]; then
	    echo "Failed to copy rootfs"
	    return 1
	fi

	return 0

	) 200>/var/lock/subsys/lxc

    return $?
}

copy_configuration()
{
    path=$1
    rootfs=$2
    hostname=$3

    grep -q "^lxc.rootfs" $path/config 2>/dev/null || echo "lxc.rootfs = $rootfs" >> $path/config
    cat <<EOF >> $path/config
lxc.tty = 4
lxc.pts = 1024
lxc.utsname = $hostname
# uncomment the next line to run the container unconfined:
#lxc.aa_profile = unconfined
lxc.cgroup.devices.deny = a
# /dev/null and zero
lxc.cgroup.devices.allow = c 1:3 rwm
lxc.cgroup.devices.allow = c 1:5 rwm
# consoles
lxc.cgroup.devices.allow = c 5:1 rwm
lxc.cgroup.devices.allow = c 5:0 rwm
lxc.cgroup.devices.allow = c 4:0 rwm
lxc.cgroup.devices.allow = c 4:1 rwm
# /dev/{,u}random
lxc.cgroup.devices.allow = c 1:9 rwm
lxc.cgroup.devices.allow = c 1:8 rwm
lxc.cgroup.devices.allow = c 136:* rwm
lxc.cgroup.devices.allow = c 5:2 rwm
# rtc
lxc.cgroup.devices.allow = c 254:0 rwm

# mounts point
lxc.mount.entry=proc proc proc nodev,noexec,nosuid 0 0
lxc.mount.entry=sysfs sys sysfs defaults  0 0
EOF

    if [ $? -ne 0 ]; then
	echo "Failed to add configuration"
	return 1
    fi

    return 0
}

clean()
{
    cache="/var/cache/lxc/kali"

    if [ ! -e $cache ]; then
	exit 0
    fi

    # lock, so we won't purge while someone is creating a repository
    (
	flock -n -x 200
	if [ $? != 0 ]; then
	    echo "Cache repository is busy."
	    exit 1
	fi

	echo -n "Purging the download cache..."
	rm --preserve-root --one-file-system -rf $cache && echo "Done." || exit 1
	exit 0

    ) 200>/var/lock/subsys/lxc
}

usage()
{
    cat <<EOF
$1 -h|--help -p|--path=<path> --clean
EOF
    return 0
}

options=$(getopt -o hp:n:c -l help,path:,name:,clean -- "$@")
if [ $? -ne 0 ]; then
        usage $(basename $0)
	exit 1
fi
eval set -- "$options"

while true
do
    case "$1" in
        -h|--help)      usage $0 && exit 0;;
        -p|--path)      path=$2; shift 2;;
        -n|--name)      name=$2; shift 2;;
        -c|--clean)     clean=$2; shift 2;;
        --)             shift 1; break ;;
        *)              break ;;
    esac
done

if [ ! -z "$clean" -a -z "$path" ]; then
    clean || exit 1
    exit 0
fi

type debootstrap
if [ $? -ne 0 ]; then
    echo "'debootstrap' command is missing"
    exit 1
fi

if [ -z "$path" ]; then
    echo "'path' parameter is required"
    exit 1
fi

if [ "$(id -u)" != "0" ]; then
    echo "This script should be run as 'root'"
    exit 1
fi

# detect rootfs
config="$path/config"
if grep -q '^lxc.rootfs' $config 2>/dev/null ; then
    rootfs=`grep 'lxc.rootfs =' $config | awk -F= '{ print $2 }'`
else
    rootfs=$path/rootfs
fi


install_kali $rootfs
if [ $? -ne 0 ]; then
    echo "failed to install kali"
    exit 1
fi

configure_kali $rootfs $name
if [ $? -ne 0 ]; then
    echo "failed to configure kali for a container"
    exit 1
fi

copy_configuration $path $rootfs $name
if [ $? -ne 0 ]; then
    echo "failed write configuration file"
    exit 1
fi

if [ ! -z $clean ]; then
    clean || exit 1
    exit 0
fi
