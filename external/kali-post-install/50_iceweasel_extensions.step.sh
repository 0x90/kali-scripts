#!/bin/bash
. ask.sh

ask "Do you want to install some extensions for iceweasel? (still in development) " N || exit 3

rm -f ~/.mozilla/firefox/*.default/places.sqlite
rm -f ~/.mozilla/firefox/*.default/bookmarkbackups/*

mkdir ~/extensions
cd ~/extensions

declare -A addons
addons[adblockplus]=1865
addons[noscript]=722

for addon in ${!addons[@]}
do
	echo
	echo "installing '$addon'"
	echo

	xpi_id=${addons[$addon]}
	wget https://addons.mozilla.org/firefox/downloads/latest/$xpi_id/addon-$xpi_id-latest.xpi
	unzip ~/extensions/addon-$xpi_id-latest.xpi -d "$xpi_id"
	rm addon-$xpi_id-latest.xpi
	addon_id=`cat "$xpi_id/install.rdf" | \grep -oh "\\{[0-9a-z-]*\\}" | head -n 1`
	mv "$xpi_id" "$addon_id"
done

mv ~/extensions/* /usr/lib/iceweasel/extensions/
rmdir ~/extensions
