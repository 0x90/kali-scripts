#!/bin/bash

# recon.sh

# USAGE
# recon.sh <interface> <network>
# Ex:  recon.sh eth0 10.0.0.0

# SYNOPSIS
# Uses ARP scan to identify hosts, then scans them with nmap.
# Dumps the results to a folder structure on the user's desktop.

if [ "$1" = "" -o "$2" = "" ]; then
	echo "Invalid syntax.  Valid syntax is recon.sh <interface> <network>"
	echo "Example:  recon.sh eth0 10.0.0.0"
	exit 0
fi

targets.txt=targets.txt

# Grab the date and format it
day=`date +%d-%A`
month=`date +%B`
year=`date +%Y`

# Set the working directory
DIRECTORY=~/Desktop/"$year"-engagements/"$month"/"$day"/

# Create folder structure

if [ ! -d "$DIRECTORY" ]; then
	echo "Creating new directory at $DIRECTORY"
	mkdir -p $DIRECTORY
fi

# ARP scan a network for hosts and dump the output to targets.txt.
echo ---------------------------------------------------------------------------------
echo Running netdiscover to locate hosts on "$2" and dumping to targets.txt
echo ---------------------------------------------------------------------------------

/usr/sbin/netdiscover -i "$1" -r "$2" -P | awk '{print $1}' | sed -e 's/_____________________________________________________________________________//' -e 's/IP//' -e 's/-----------------------------------------------------------------------------//' -e 's/--//' -e '/^$/d' > "$DIRECTORY"/targets.txt

for i in `cat "$DIRECTORY"\targets.txt`
do
	((c++))
done
echo DONE - $c targets loaded into targets.txt
echo " "

# Find Windows Hosts
# Reset windows-hostlist.txt file
cat /dev/null > "$DIRECTORY"/windows-hostlist.txt
echo "Scanning for windows hosts..."
c=0
#d=0
for i in `cat "$DIRECTORY"\targets.txt`
do
	nmap -Pn -p 445 -oG nmap.grep $i > /dev/null
	winHost=`cat nmap.grep | awk '/445\/open/ {print $2}'`
	if [ -n "$winHost" ]; then
		echo $winHost >> "$DIRECTORY"/windows-hostlist.txt
		((c++))
	fi
done
echo "$c Windows hosts discovered.  Results stored in windows-hostlist.txt."
echo ""

# Find FTP servers
c=0
echo "Scanning for FTP servers..."
for i in `cat "$DIRECTORY"\targets.txt`
do
	nmap -Pn -p 21 -oG nmap.grep $i > /dev/null
	ftpHost=`cat nmap.grep | awk '/21\/open/ {print $2}'`
	if [ -n "$ftpHost" ]; then
		echo $ftpHost >> "$DIRECTORY"/ftp-hostlist.txt
		((c++))
	fi
done
echo "$c FTP hosts discovered.  Results stored in ftp-hostlist.txt"
echo ""

# Find HTTP servers
c=0
echo "Scanning for HTTP servers..."
for i in `cat "$DIRECTORY"\targets.txt`
do
	nmap -Pn -p 80 -oG nmap.grep $i > /dev/null
	httpHost=`cat nmap.grep | awk '/80\/open/ {print $2}'`
	if [ -n "$httpHost" ]; then
		echo $httpHost >> "$DIRECTORY"/http-hostlist.txt
		((c++))
	fi
done
echo "$c HTTP hosts discovered.  Results stored in http-hostlist.txt"
echo ""

# Find MSSQL Servers
c=0
echo "Scanning for MSSQL servers..."
for i in `cat "$DIRECTORY"\targets.txt`
do
	nmap -Pn -p 1433 -oG nmap.grep $i > /dev/null
	mssqlHost=`cat nmap.grep | awk '/1433\/open/ {print $2}'`
	if [ -n "$mssqlHost" ]; then
		echo $mssqlHost >> "$DIRECTORY"/mssql-hostlist.txt
		((c++))
	fi
done
echo "$c MSSQL hosts discovered.  Results stored in mssql-hostlist.txt"
echo ""

# Find Oracle Servers
c=0
echo "Scanning for Oracle DB servers..."
for i in `cat "$DIRECTORY"\targets.txt`
do
	nmap -Pn -p 1521 -oG nmap.grep $i > /dev/null
	oracleHost=`cat nmap.grep | awk '/1521\/open/ {print $2}'`
	if [ -n "$oracleHost" ]; then
		echo $oracleHost >> "$DIRECTORY"/oracle-hostlist.txt
		((c++))
	fi
done
echo "$c Oracle DB hosts discovered.  Results stored in oracle-hostlist.txt"
echo ""

# Find MySQL Servers
c=0
echo "Scanning for MySQL servers..."
for i in `cat "$DIRECTORY"\targets.txt`
do
	nmap -Pn -p 3306 -oG nmap.grep $i > /dev/null
	mysqlHost=`cat nmap.grep | awk '/3306\/open/ {print $2}'`
	if [ -n "$mysqlHost" ]; then
		echo $mysqlHost >> "$DIRECTORY"/mysql-hostlist.txt
		((c++))
	fi
done
echo "$c MySQL hosts discovered.  Results stored in mysql-hostlist.txt"
echo ""

