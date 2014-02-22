#!/bin/sh
# Credit goes to the TH3CR@CK3R at http://top-hat-sec.com/forum/index.php?topic=3127.0
# Removed Firefox launch

clear
sleep 0.5
echo ""
echo "PLEASE SELECT AN OPTION TO CONTINUE"
echo "WITH LAUNCHING SUBTERFUGE..."
echo ""
echo "1 = START ON DEFAULT PORT [80]"
echo "2 = SELECT ALTERNATE PORT NUMBER"
echo ""
echo "OPTION NUMBER: \c"
read option


if [ $option = "1" ]; then

  sleep 1
  xterm -e subterfuge -s 127.0.0.1:80 &
  sleep 4
  
else
if [ $option = "2" ]; then

  sleep 1
  echo ""
  echo "WHAT PORT WOULD YOU LIKE TO USE? \c"
  read port
  sleep 1
  xterm -e subterfuge -s 127.0.0.1:$port

fi
fi
