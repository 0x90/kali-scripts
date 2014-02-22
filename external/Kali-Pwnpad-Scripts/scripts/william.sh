#!/bin/bash

# Script to pull out corresponding first and second packets of a 4-way handshake from a noisy capture
# Output file(s) can then be run through aircrack-ng, manually or automatically
# If I'd known how this would turn out, this wouldn't be a bash script!
#
# Author: Jerome Smith @exploresecurity
# Version: 0.1
# http://www.exploresecurity.com
# http://www.7safe.com
# Licence: free to modify and distribute if you retain original credits, otherwise grateful if you refer to original download link, thank you

if [ $# -lt 2 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	echo "WPA handshake extraction script"
	echo "USAGE"
	echo "`basename $0` <output_file> <input_file> [<input_file_2>...] [<mth_packet_2> [<nth_packet_1>]] [-f | -a] [-A <dict_file>] [-d]"
	echo "  m   mth second packet of 4-way handshake (default 1)"
	echo "  n   nth first packet of 4-way handshake that precedes the chosen second packet (default 1)"
	echo "  -f  seek first message from start of capture working forwards"
	echo "  -a  pair up ALL message 1s that precede the chosen message 2 (multiple output files)"
	echo "  -A  run aircrack-ng against output files using the supplied dictionary file" 
	echo "  -d  don't skip duplicate packets"
	if [ "$1" == "--help" ]; then
		echo -e "\nEXAMPLES\nSee also www.exploresecurity.com\n"
		echo "`basename $0` input.cap output.cap"
		echo -e "    Pair the 1st message 2 with the 1st message 1 that precedes it\n"
		echo "`basename $0` input.cap output.cap -a A pass.lst"
		echo -e "    Pair the 1st message 2 with all the message 1s that precede it"
		echo -e "    and run aircrack against all pairs with dictionary pass.lst\n"
		echo "`basename $0` input.cap output.cap 4"
		echo -e "    Pair the 4th message 2 with the 1st message 1 that precedes it\n"
		echo "`basename $0` input.cap output.cap -f 4"
		echo -e "    Pair the 4th message 2 with the 1st message 1\n"
		echo "`basename $0` input.cap output.cap -a 4"
		echo -e "    Pair the 4th message 2 with all the message 1s that precede it\n"
		echo "`basename $0` input.cap output.cap 4 3"
		echo -e "    Pair the 4th message 2 with the 3rd message 1 that precedes it\n"
		echo "`basename $0` input.cap output.cap -f 4 3"
		echo "    Pair the 4th message 2 with the 3rd message 1"
	else
		echo "  --help  extra help"
 	fi
	exit 1
fi

if [ ! -e "$2" ]; then
	echo "Input file $2 does not exist"
	exit 1
fi
cp "$2" in.tmp.cap

hash tshark 2>/dev/null || { echo "This script requires tshark"; exit 1; }
hash mergecap 2>/dev/null || { echo "This script requires mergecap"; exit 1; }

# Parse parameters
UNIQUE=true
MODE=REVERSE # seek first message working backwards from the chosen message 2
AIRCRACK=false # set when -A just seen, used to distinguish dictionary file from input files
for i in "${@:3}" # all parameters starting from the 3rd
do
	if [ "$i" == "-a" ]; then
		MODE=ALL
	elif [ "$i" == "-A" ]; then
		AIRCRACK=true
	elif [ "$i" == "-f" ]; then
		MODE=FORWARD
	elif [ "$i" == "-d" ]; then
		UNIQUE=false
	elif [[ "$i" =~ ^[0-9]+$ ]] ; then # it's an integer
		if [[ -z $m ]]; then
			m=$i
		else
			n=$i
		fi
	elif [[ -e $i ]]; then
		if $AIRCRACK; then # it's an aircrack dictionary file
			DICT_FILE="$i"
		else # assume it's another input file and merge them all togther - hack!
			cp in.tmp.cap in.tmp.tmp.cap # mergecap can't do input_file+=$i
			mergecap -F libpcap -w in.tmp.cap -a in.tmp.tmp.cap "$i"
			if [ $? -gt 0 ]; then
				exit 1
			fi
		fi
	else
		echo "Unknown argument $i, exiting"
		exit 1
	fi
	if $AIRCRACK && ([ "$i" != "-A" ] || [ "$i" == "${@: -1}" ]); then
		if [[ -z "$DICT_FILE" ]]; then
			echo "Running Aircrack requires you to set a dictionary file after -A"
			exit 1
		else
			AIRCRACK=false
		fi
	fi
done
# set m and n if not specified (mth second packet, nth first packet)
if [[ -z $m ]]; then
	m=1
fi
if [ $MODE == "ALL" ] && [[ ! -z $n ]]; then
	echo "Ignoring value for n, it must be 1 with -a"
	n=1
fi
if [[ -z $n ]]; then
	n=1
fi
echo -n "Mode=$MODE m=$m (second message) n=$n (first message) "
if $UNIQUE; then
	echo "ignoring duplicates"
else
	echo "including duplicates"
fi

# Get mth packet 2 of 4-way handshake
if $UNIQUE; then
	# consider packets with same eapol.keydes.mic to be duplicates
	# can't pull out frame number as otherwise all lines would be unique
	DATA=(`tshark -r in.tmp.cap -R "eapol.keydes.key_info == 0x010a || eapol.keydes.key_info == 0x0109" -T fields -e eapol.keydes.mic -e wlan.bssid -e eapol.keydes.key_info -e wlan.sa 2>/dev/null | uniq | sed -n -e "$m {p;q}"`)
else
	DATA=(`tshark -r in.tmp.cap -R "(eapol.keydes.key_info == 0x010a || eapol.keydes.key_info == 0x0109)" -T fields -e frame.number -e wlan.bssid -e eapol.keydes.key_info -e wlan.sa 2>/dev/null | sed -n -e "$m {p;q}"`)
fi
# DATA array of 4 elements: packet identification, BSSID, TKIP|CCMP, client MAC
if [[ -z $DATA ]]; then
	echo "Error"
	echo "- check the input file is a valid packet capture"
	echo "- check the input file contains EAPOL packets"
	if [ $m -gt 1 ]; then
		echo "- check your value of m is not too big"
	fi
	exit 1
fi
if $UNIQUE; then
	P2=`tshark -r in.tmp.cap -R "eapol.keydes.mic == ${DATA[0]}" -T fields -e frame.number 2>/dev/null | tail -n 1` # best to use tail to pick up signs of possible miscounting
else
	P2=${DATA[0]}
fi
echo "Using packet $P2 as second EAPOL packet"
tshark -r in.tmp.cap -R "frame.number == $P2" -F libpcap -w eapol.2.tmp.cap 2>/dev/null
echo "BSSID is ${DATA[1]}"

# Determine whether TKIP or CCMP for better efficiency later
TKIP=true
if [ ${DATA[2]} == "0x010a" ]; then
	TKIP=false
	echo -n "CCMP"
	MSG1_FILTER="eapol.keydes.key_info == 0x008a" # CCMP packet 1
	MSG2_FILTER="eapol.keydes.key_info == 0x010a" # CCMP packet 2
elif [ ${DATA[2]} == "0x0109" ]; then
	echo -n "TKIP"
	MSG1_FILTER="eapol.keydes.key_info == 0x0089" # TKIP packet 1
	MSG2_FILTER="eapol.keydes.key_info == 0x0109" # TKIP packet 2
else
	echo "Couldn't determine whether network is TKIP or CCMP"
	exit 1
fi
echo " network identified"
echo "Client station is ${DATA[3]}"
MSG1_FILTER="$MSG1_FILTER && wlan.sa == ${DATA[1]} && wlan.da == ${DATA[3]}"

if $UNIQUE; then
	# can't sort before uniq as order of packets would be lost but duplicates should be adjacent anyway
	# nonetheless look for sign of trouble if sort changes number of unique packets
	if [ `tshark -r in.tmp.cap -R "$MSG2_FILTER && frame.number <= $P2" -T fields -e eapol.keydes.mic 2>/dev/null | uniq | wc -l` -ne `tshark -r in.tmp.cap -R "$MSG2_FILTER && frame.number <= $P2" -T fields -e eapol.keydes.mic 2>/dev/null | sort | uniq | wc -l` ]; then
		echo "WARNING - non-adjacent duplicates detected so unique packets miscounted"
	fi
fi

# Pseudo-two-dimensional array of packets with a SSID to look for and their descriptions
def[0]="beacon frame"
filter[0]="(wlan.fc.type_subtype == 8) && wlan.bssid == ${DATA[1]} && !(wlan_mgt.tag.length == 0)"
def[1]="probe response"
filter[1]="wlan.fc.type_subtype == 5 && wlan.bssid == ${DATA[1]}"
def[2]="association request"
filter[2]="wlan.fc.type_subtype == 0 && wlan.bssid == ${DATA[1]}"
# Step through array
for i in $(seq 0 $((${#def[*]} - 1)))
do
	SSID=(`tshark -r in.tmp.cap -R "${filter[$i]}" -T fields -e frame.number -e wlan_mgt.ssid 2>/dev/null | head -n 1`) # array of 2 elements
	if [[ -z $SSID ]]; then
		echo "Cannot determine SSID from ${def[$i]}s"
	else
		echo "Determined SSID from ${def[$i]} (packet number ${SSID[0]})"
		echo "The SSID is ${SSID[@]:1}" # all array elements from the 2nd as SSID could include a space
		tshark -r in.tmp.cap -R "frame.number == ${SSID[0]}" -F libpcap -w SSID.tmp.cap 2>/dev/null
		break
	fi
done
if [[ -z $SSID ]] ; then
	echo "Cannot find SSID correponding to ${DATA[1]}"
	read -p "Enter the SSID if you know it: " SSID
	if [[ -z $SSID ]]; then
		echo "Aircrack-ng needs the SSID, cannot continue, sorry"
		exit 1
	fi
	hash text2pcap 2>/dev/null || { echo "This script requires text2pcap"; exit 1; }
	echo "Creating fake probe response to satisfy aircrack-ng"
	# Probe response structure:
	# 500000000123456789ab
	# BSSID BSSID
	# 609b39c48f069cd904006400110400
	# SSID length	# in hex, with leading 0 if < 0x10
	# SSID		# in hex
	# 0000010802040b160c12182432043048606c2d1a300917ffff000000000000000000000000000000000000000000
	# 03010330140100000fac040100000fac040100000fac020100
	echo -n "500000000123456789ab"`echo -n ${DATA[1]}|sed -e 's/://g'``echo -n ${DATA[1]}|sed -e 's/://g'`"609b39c48f069cd904006400110400"`printf '%02x' ${#SSID}``echo -n $SSID|xxd -p`"0000010802040b160c12182432043048606c2d1a300917ffff00000000000000000000000000000000000000000003010330140100000fac040100000fac040100000fac020100"|xxd -r -p|hd|text2pcap -q -l 105 - SSID.tmp.cap
	if [ $? -gt 0 ]; then
		echo "Error creating packet but let's see what happens"
	fi
fi

# Get nth packet 1 of 4-way handshake
if $UNIQUE; then
	# consider packets with same eapol.keydes.nonce to be duplicates
	NUM_FIRST=`tshark -r in.tmp.cap -R "$MSG1_FILTER && frame.number < $P2" -T fields -e eapol.keydes.nonce 2>/dev/null | uniq | wc -l`
else
	NUM_FIRST=`tshark -r in.tmp.cap -R "$MSG1_FILTER && frame.number < $P2" -T fields -e eapol.keydes.nonce 2>/dev/null | wc -l`
fi
echo "There are $NUM_FIRST first messages before the chosen second message"
if [ $MODE == "REVERSE" ]; then
	n=`expr $NUM_FIRST - $n + 1`
	if [ $n -lt 1 ]; then
		echo "- but you've asked to go back by `expr $NUM_FIRST - $n + 1`! Reduce the value of n"
		exit 1
	fi
fi
if $UNIQUE; then
	# can't pull out frame.number here as otherwise everything would be unique
	NONCE=`tshark -r in.tmp.cap -R "$MSG1_FILTER" -T fields -e eapol.keydes.nonce 2>/dev/null | uniq | sed -n -e "$n {p;q}"`
	P1=`tshark -r in.tmp.cap -R "$MSG1_FILTER && eapol.keydes.nonce == $NONCE" -T fields -e frame.number 2>/dev/null | tail -n 1` # need $MSG1_FILTER here as otherwise message 3 could be selected
else
	P1=`tshark -r in.tmp.cap -R "$MSG1_FILTER" -T fields -e frame.number 2>/dev/null | sed -n -e "$n {p;q}"`
fi
if [[ -z $P1 ]]; then
	echo "Error"
	echo "- could not find 1st packet of 4-way handshake"
	if [ $m -gt 1 ] || [ $n -gt 1 ]; then
		echo "- check your value of m or n is not too big"
	fi
	exit 1
fi
if [ $MODE != "ALL" ]; then
	echo Using packet $P1 as first EAPOL packet
fi

if $UNIQUE; then
	# can't sort before uniq as order of packets would be lost but duplicates should be adjacent anyway
	# nonetheless look for sign of trouble if sort changes number of unique packets
	if [ `tshark -r in.tmp.cap -R "$MSG1_FILTER && frame.number <= $P1" -T fields -e eapol.keydes.nonce 2>/dev/null | uniq | wc -l` -ne `tshark -r in.tmp.cap -R "$MSG1_FILTER && frame.number <= $P1" -T fields -e eapol.keydes.nonce 2>/dev/null | sort | uniq | wc -l` ]; then
		echo "WARNING - non-adjacent duplicates detected so unique packets miscounted"
	fi
fi

# Sanity check
if [ $P2 -lt $P1 ]; then
	echo "Doesn't make sense to pair a second packet with a first packet that was seen later"
	exit 1
fi
tshark -r in.tmp.cap -R "frame.number == $P1" -F libpcap -w eapol.1.tmp.cap 2>/dev/null

# Write packets out to file(s)
if [ $MODE != "ALL" ]; then
	NUM_FIRST=1 # quick hack so same ouput routine used for all modes
else
	# pull out EAPOL message 1 frames into temp file so we don't read input file in full quite as much
	tshark -r in.tmp.cap -R "$MSG1_FILTER && frame.number < $P2" -F libpcap -w eapol.tmp.cap 2>/dev/null
fi
for (( i=$NUM_FIRST; i>0; i-- ))
do
	if [ $NUM_FIRST -gt 1 ]; then
		OUT_FILE=`echo "$1" | cut -f1 -d'.'`.$i.`echo "$1" | cut -f2 -d'.'` # insert counter into output files
	else
		OUT_FILE="$1"
	fi
	echo -n "Writing packets to $OUT_FILE"
	mergecap -F libpcap -w "$OUT_FILE" -a SSID.tmp.cap eapol.1.tmp.cap eapol.2.tmp.cap # -a concatenate
	if [[ ! -z "$DICT_FILE" ]]; then
		echo " - and running through Aircrack"
		KEY=`aircrack-ng "$OUT_FILE" -w "$DICT_FILE" | awk '/FOUND/{print $4}' | head -n 1`
		if [[ ! -z $KEY ]]; then
			break
		else
			echo -n -e "\r"
		fi
	else
		echo
	fi
	if [ $MODE == "ALL" ]; then
		n=`expr $i - 1`
		if $UNIQUE; then
			NONCE=`tshark -r eapol.tmp.cap -T fields -e eapol.keydes.nonce 2>/dev/null | uniq | sed -n -e "$n {p;q}"`
			# P1 now relates to eapol.tmp.cap not input file
			P1=`tshark -r eapol.tmp.cap -R "eapol.keydes.nonce == $NONCE" -T fields -e frame.number 2>/dev/null | tail -n 1`
		else
			P1=`tshark -r eapol.tmp.cap -T fields -e frame.number 2>/dev/null | sed -n -e "$n {p;q}"`
		fi
		tshark -r eapol.tmp.cap -R "frame.number == $P1" -F libpcap -w eapol.1.tmp.cap 2>/dev/null
	fi
done

echo "Deleting temp files"
if [ -e in.tmp.tmp.cap ]; then
	mv in.tmp.cap merged.cap
	echo "- but leaving merged file \"merged.cap\" for reference"
else
	rm in.tmp.cap
fi
rm eapol.1.tmp.cap
rm eapol.2.tmp.cap
rm SSID.tmp.cap
if [ -e in.tmp.tmp.cap ]; then
	rm in.tmp.tmp.cap
fi
if [ -e eapol.tmp.cap ]; then
	rm eapol.tmp.cap
fi

if [[ -z "$DICT_FILE" ]]; then
	echo -n "Now run \"aircrack-ng "
	if [[ $NUM_FIRST -gt 1 ]]; then
		echo -n "on each $1 with "
	else
		echo -n "$1 "
	fi
	echo "-w <dictionary_file>\""
else
	if [[ -z $KEY ]]; then
		echo Passphrase not found
	else
		echo Passphrase is $KEY
	fi
fi

