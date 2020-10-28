#!/bin/sh
RED='\033[0;31m'
GREEN='\033[0;32m'

while [ 1 ]
do
        CODE=$(curl -f --connect-timeout 1 http://10.48.168.190:8080 --silent --output /dev/null -w '%{http_code}')
         if [[ "$CODE" = 000 ]]; then
                 printf "${RED} server is down\n"
         elif [[ "$CODE" = 200 ]]; then
                 printf "${GREEN} server is up\n"
         fi
         sleep 3
 done

