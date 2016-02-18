#!/bin/bash
# -------
# Script for install of Mariadb to be used with Alfresco
#
# Copyright 2013-2016 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

export ALFRESCODB=alfresco
export ALFRESCODBBART=alfresco_rec
export ALFRESCOUSER=alfresco

echo
echo "--------------------------------------------"
echo "This script will install MYSQL-DB."
echo "and create alfresco database and user."
echo "You may first be prompted for sudo password."
echo "When prompted during MYSQL-DB Install,"
echo "type the default root password for MYSQL-DB."
echo "--------------------------------------------"
echo

read -e -p "Install MYSQL-DB? [y/n] " -i "n" installmysqldb
if [ "$installmysqldb" = "y" ]; then
  sudo apt-get install mysql-server
fi

read -e -p "Create Alfresco Database and user? [y/n] " -i "n" createdb
if [ "$createdb" = "y" ]; then
read -e -p "Enter the Alfresco database password:" ALFRESCOPASSWORD
read -e -p "Re-Enter the Alfresco database password:" ALFRESCOPASSWORD2
if [ "$ALFRESCOPASSWORD" == "$ALFRESCOPASSWORD2" ]
then
  echo "Creating Alfresco database and user."
  echo "You must supply the root user password for MYSQL-DB:"
  mysql -u root -p << EOF
create database $ALFRESCODB default character set utf8 collate utf8_bin;
create database $ALFRESCODBBART default character set utf8 collate utf8_bin;
grant all on $ALFRESCODB.* to '$ALFRESCOUSER'@'localhost' identified by '$ALFRESCOPASSWORD' with grant option;
grant all on $ALFRESCODB.* to '$ALFRESCOUSER'@'localhost.localdomain' identified by '$ALFRESCOPASSWORD' with grant option;

grant all on $ALFRESCODBBART.* to '$ALFRESCOUSER'@'localhost' identified by '$ALFRESCOPASSWORD' with grant option;
grant all on $ALFRESCODBBART.* to '$ALFRESCOUSER'@'localhost.localdomain' identified by '$ALFRESCOPASSWORD' with grant option;
EOF
  echo
  echo "Remember to update alfresco-global.properties with the alfresco database password"
  echo
else
  echo
  echo "Passwords do not match. Please run the script again for better luck!"
  echo
fi
fi
