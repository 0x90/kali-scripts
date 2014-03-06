#!/bin/bash

# make sure to use new aliases
shopt -s expand_aliases

. ask.sh

echo "This script might break some installations or config files if it's not used on a fresh installed kali linux"
ask "Do you still want to continue on your own risk?" N || exit

for f in ./external/kali-post-install/*.step.sh; do bash $f; done
