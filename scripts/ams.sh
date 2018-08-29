#!/bin/bash
# -------
# Script for maintenance shutdown of Alfresco
#
# Copyright 2013-2016 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

USER=www-data
ALF_HOME_WWW=/opt/alfresco/www
DOWNTIME=10

#((!$#)) && echo Supply expected downtime in minutes as argument! && exit 1

die () {
    echo >&2 "$@"
    exit 1
}

if [ "$#" -gt 0 ]
  then
   echo $1 | grep -E -q '^[0-9]+$' || die "Numeric argument required, $1 provided"
   DOWNTIME=$1
fi

echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Updating maintenance message script file"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo
echo "var downTime = ${DOWNTIME};" | sudo tee  ${ALF_HOME_WWW}/downtime.js
echo "var startTime = `date +%s`;" | sudo tee -a ${ALF_HOME_WWW}/downtime.js
echo "var specialMessage = '$2';" | sudo tee -a ${ALF_HOME_WWW}/downtime.js
sudo chown -R ${USER}:nogroup ${ALF_HOME_WWW}
echo
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Stopping the Alfresco tomcat instance"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo
sudo /opt/alfresco/alfresco-service.sh stop
