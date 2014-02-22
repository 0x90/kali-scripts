#!/bin/sh

echo ""
echo "BeEF uses port 3000 as a default with login/password: beef"
echo "PLEASE SELECT AN OPTION TO CONTINUE"
echo ""
echo "1 = Use Default [3000]"
echo "2 = Select a different port"
echo ""
echo "OPTION NUMBER: \c"
read option

if [ $option = "1" ]; then
	echo "STARTING BEEF SERVER"
	cd /usr/share/beef-xss/
  ./beef
exit

else
if [ $option = "2" ]; then

  sleep 1
  echo ""
  echo "WHAT PORT WOULD YOU LIKE TO USE? \c"
  read port
  sleep 1
  echo ""
  echo "STARTING BEEF SERVER"
  cd /usr/share/beef-xss/
  ./beef -p $port
  exit

fi
fi