#!/usr/bin/env bash
#

print_status(){
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

print_good(){
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

print_error(){
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

print_notification(){
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}

read_default(){
    return read -e -p "$1" -i "$2"
}