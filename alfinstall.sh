#!/bin/bash
# -------
# Script for install of Alfresco
#
# Copyright 2013-2014 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

export ALF_HOME=/opt/alfresco
export ALF_DATA_HOME=$ALF_HOME/alf_data
export CATALINA_HOME=$ALF_HOME/tomcat
export ALF_USER=alfresco
export ALF_GROUP=$ALF_USER
export APTVERBOSITY="-qq -y"
export TMP_INSTALL=/tmp/alfrescoinstall

# Branch name to pull from server. Use master for stable.
BRANCH=master
export BASE_DOWNLOAD=https://raw.githubusercontent.com/loftuxab/alfresco-ubuntu-install/$BRANCH
export KEYSTOREBASE=https://svn.alfresco.com/repos/alfresco-open-mirror/alfresco/HEAD/root/projects/repository/config/alfresco/keystore

#Change this to prefered locale to make sure it exists. This has impact on LibreOffice transformations
#export LOCALESUPPORT=sv_SE.utf8
export LOCALESUPPORT=en_US.utf8

export TOMCAT_DOWNLOAD=http://www.us.apache.org/dist/tomcat/tomcat-7/v7.0.63/bin/apache-tomcat-7.0.63.tar.gz
export JDBCPOSTGRESURL=https://jdbc.postgresql.org/download
export JDBCPOSTGRES=postgresql-9.4-1201.jdbc41.jar
export JDBCMYSQLURL=http://cdn.mysql.com/Downloads/Connector-J
export JDBCMYSQL=mysql-connector-java-5.1.35.tar.gz

export LIBREOFFICE=http://downloadarchive.documentfoundation.org/libreoffice/old/4.4.3.2/deb/x86_64/LibreOffice_4.4.3.2_Linux_x86-64_deb.tar.gz

export SWFTOOLS=http://www.swftools.org/swftools-2013-04-09-1007.tar.gz

export ALFREPOWAR=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco/5.0.d/alfresco-5.0.d.war
export ALFSHAREWAR=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/share/5.0.d/share-5.0.d.war
export GOOGLEDOCSREPO=https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/integrations/alfresco-googledocs-repo/3.0.2/alfresco-googledocs-repo-3.0.2.amp
export GOOGLEDOCSSHARE=https://artifacts.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/integrations/alfresco-googledocs-share/3.0.2/alfresco-googledocs-share-3.0.2.amp
export SPP=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-spp/5.0.d/alfresco-spp-5.0.d.amp

export SOLR4_CONFIG_DOWNLOAD=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-solr4/5.0.d/alfresco-solr4-5.0.d-config-ssl.zip
export SOLR4_WAR_DOWNLOAD=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-solr4/5.0.d/alfresco-solr4-5.0.d-ssl.war


export BASE_BART_DOWNLOAD=https://raw.githubusercontent.com/toniblyx/alfresco-backup-and-recovery-tool/master/src/

export BART_PROPERTIES=alfresco-bart.properties
export BART_EXECUTE=alfresco-bart.sh


# Color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgre=${txtbld}$(tput setaf 2) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

echoblue () {
  echo "${bldblu}$1${txtrst}"
}
echored () {
  echo "${bldred}$1${txtrst}"
}
echogreen () {
  echo "${bldgre}$1${txtrst}"
}
cd /tmp
if [ -d "alfrescoinstall" ]; then
	rm -rf alfrescoinstall
fi
mkdir alfrescoinstall
cd ./alfrescoinstall

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echogreen "Alfresco Ubuntu installer by Loftux AB."
echogreen "Please read the documentation at"
echogreen "https://github.com/loftuxab/alfresco-ubuntu-install."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Checking for the availability of the URLs inside script..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo

URLERROR=0

for REMOTE in $TOMCAT_DOWNLOAD $JDBCPOSTGRESURL/$JDBCPOSTGRES $JDBCMYSQLURL/$JDBCMYSQL \
        $LIBREOFFICE $SWFTOOLS $ALFWARZIP $GOOGLEDOCSREPO $GOOGLEDOCSSHARE $SOLR4_WAR_DOWNLOAD $SOLR4_CONFIG_DOWNLOAD $SPP

do
        wget --spider $REMOTE --no-check-certificate >& /dev/null
        if [ $? != 0 ]
        then
                echored "In alfinstall.sh, please fix this URL: $REMOTE"
                URLERROR=1
        fi
done

if [ $URLERROR = 1 ]
then
    echo
    echored "Please fix the above errors and rerun."
    echo
    exit
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Preparing for install. Updating the apt package index files..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sudo apt-get $APTVERBOSITY update;
echo

if [ "`which curl`" = "" ]; then
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "You need to install curl. Curl is used for downloading components to install."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sudo apt-get $APTVERBOSITY install curl;
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "You need to add a system user that runs the tomcat Alfresco instance."
echo "Also updates locale support."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add alfresco system user${ques} [y/n] " -i "n" addalfresco
if [ "$addalfresco" = "y" ]; then
  sudo adduser --system --disabled-login --disabled-password --group $ALF_USER
  echo
  echo "Adding locale support"
  #install locale to support that locale date formats in open office transformations
  sudo locale-gen $LOCALESUPPORT
  echo
  echogreen "Finished adding alfresco user"
  echo
else
  echo "Skipping adding alfresco user"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Ubuntu default for number of allowed open files in the file system is too low"
echo "for alfresco use and tomcat may because of this stop with the error"
echo "\"too many open files\". You should update this value if you have not done so."
echo "Read more at http://wiki.alfresco.com/wiki/Too_many_open_files"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add limits.conf${ques} [y/n] " -i "n" updatelimits
if [ "$updatelimits" = "y" ]; then
  echo "alfresco  soft  nofile  8192" | sudo tee -a /etc/security/limits.conf
  echo "alfresco  hard  nofile  65536" | sudo tee -a /etc/security/limits.conf
  echo
  echogreen "Updated /etc/security/limits.conf"
  echo
  echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session
  echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session-noninteractive
  echo
  echogreen "Updated /etc/security/common-session*"
  echo
else
  echo "Skipped updating limits.conf"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Tomcat is the application server that runs Alfresco."
echo "You will also get the option to install jdbc lib for Postgresql or MySql/MariaDB."
echo "Install the jdbc lib for the database you intend to use."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Tomcat${ques} [y/n] " -i "n" installtomcat

if [ "$installtomcat" = "y" ]; then
  echogreen "Installing Tomcat"
  echo "Downloading tomcat..."
  curl -# -L -O $TOMCAT_DOWNLOAD
  # Make sure install dir exists
  sudo mkdir -p $ALF_HOME
  echo "Extracting..."
  tar xf "$(find . -type f -name "apache-tomcat*")"
  sudo mv "$(find . -type d -name "apache-tomcat*")" $CATALINA_HOME
  # Remove apps not needed
  sudo rm -rf $CATALINA_HOME/webapps/*
  # Get Alfresco config
  echo "Downloading tomcat configuration files..."
  sudo curl -# -o $CATALINA_HOME/conf/server.xml $BASE_DOWNLOAD/tomcat/server.xml
  sudo curl -# -o $CATALINA_HOME/conf/catalina.properties $BASE_DOWNLOAD/tomcat/catalina.properties
  sudo curl -# -o $CATALINA_HOME/conf/tomcat-users.xml $BASE_DOWNLOAD/tomcat/tomcat-users.xml
  sudo curl -# -o /etc/init/alfresco.conf $BASE_DOWNLOAD/tomcat/alfresco.conf
  sudo sed -i "s/@@LOCALESUPPORT@@/$LOCALESUPPORT/g" /etc/init/alfresco.conf
  # Create /shared
  sudo mkdir -p $CATALINA_HOME/shared/classes/alfresco/extension
  sudo mkdir -p $CATALINA_HOME/shared/classes/alfresco/web-extension
  sudo mkdir -p $CATALINA_HOME/shared/lib
  # Add endorsed dir
  sudo mkdir -p $CATALINA_HOME/endorsed
  echo
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  echo "You need to add the dns name, port and protocol for your server(s)."
  echo "It is important that this is is a resolvable server name."
  echo "This information will be added to default configuration files."
  echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  read -e -p "Please enter the public host name for Share server (fully qualified domain name)${ques} [`hostname`] " -i "`hostname`" SHARE_HOSTNAME
  read -e -p "Please enter the protocol to use for public Share server (http or https)${ques} [http] " -i "http" SHARE_PROTOCOL
  SHARE_PORT=80
  if [ "${SHARE_PROTOCOL,,}" = "https" ]; then
    SHARE_PORT=443
  fi
  read -e -p "Please enter the host name for Alfresco Repository server (fully qualified domain name)${ques} [$SHARE_HOSTNAME] " -i "$SHARE_HOSTNAME" REPO_HOSTNAME

  # Add default alfresco-global.propertis
  ALFRESCO_GLOBAL_PROPERTIES=/tmp/alfrescoinstall/alfresco-global.properties
  sudo curl -# -o $ALFRESCO_GLOBAL_PROPERTIES $BASE_DOWNLOAD/tomcat/alfresco-global.properties
  sed -i "s/@@ALFRESCO_SHARE_SERVER@@/$SHARE_HOSTNAME/g" $ALFRESCO_GLOBAL_PROPERTIES
  sed -i "s/@@ALFRESCO_SHARE_SERVER_PORT@@/$SHARE_PORT/g" $ALFRESCO_GLOBAL_PROPERTIES
  sed -i "s/@@ALFRESCO_SHARE_SERVER_PROTOCOL@@/$SHARE_PROTOCOL/g" $ALFRESCO_GLOBAL_PROPERTIES
  sed -i "s/@@ALFRESCO_REPO_SERVER@@/$REPO_HOSTNAME/g" $ALFRESCO_GLOBAL_PROPERTIES
  sudo mv $ALFRESCO_GLOBAL_PROPERTIES $CATALINA_HOME/shared/classes/

  read -e -p "Install Share config file (recommended)${ques} [y/n] " -i "n" installshareconfig
  if [ "$installshareconfig" = "y" ]; then
    SHARE_CONFIG_CUSTOM=/tmp/alfrescoinstall/share-config-custom.xml
    sudo curl -# -o $SHARE_CONFIG_CUSTOM $BASE_DOWNLOAD/tomcat/share-config-custom.xml
    sed -i "s/@@ALFRESCO_SHARE_SERVER@@/$SHARE_HOSTNAME/g" $SHARE_CONFIG_CUSTOM
    sed -i "s/@@ALFRESCO_REPO_SERVER@@/$REPO_HOSTNAME/g" $SHARE_CONFIG_CUSTOM
    sudo mv $SHARE_CONFIG_CUSTOM $CATALINA_HOME/shared/classes/alfresco/web-extension/
  fi

  echo
  read -e -p "Install Postgres JDBC Connector${ques} [y/n] " -i "n" installpg
  if [ "$installpg" = "y" ]; then
	curl -# -O $JDBCPOSTGRESURL/$JDBCPOSTGRES
	sudo mv $JDBCPOSTGRES $CATALINA_HOME/lib
  fi
  echo
  read -e -p "Install Mysql JDBC Connector${ques} [y/n] " -i "n" installmy
  if [ "$installmy" = "y" ]; then
    cd /tmp/alfrescoinstall
	curl -# -L -O $JDBCMYSQLURL/$JDBCMYSQL
	tar xf $JDBCMYSQL
	cd "$(find . -type d -name "mysql-connector*")"
	sudo mv mysql-connector*.jar $CATALINA_HOME/lib
  fi
  sudo chown -R $ALF_USER:$ALF_GROUP $ALF_HOME
  echo
  echogreen "Finished installing Tomcat"
  echo
else
  echo "Skipping install of Tomcat"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Nginx can be used as frontend to Tomcat."
echo "This installation will add config default proxying to Alfresco tomcat."
echo "The config file also have sample config for ssl and proxying"
echo "to Sharepoint plugin."
echo "You can run Alfresco fine without installing nginx."
echo "If you prefer to use Apache, install that manually. Or you can use iptables"
echo "forwarding, sample script in $ALF_HOME/scripts/iptables.sh"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install nginx${ques} [y/n] " -i "n" installnginx
if [ "$installnginx" = "y" ]; then
  echoblue "Installing nginx. Fetching packages..."
  echo
sudo -s << EOF
  echo "deb http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" >> /etc/apt/sources.list
  sudo curl -# -o /tmp/alfrescoinstall/nginx_signing.key http://nginx.org/keys/nginx_signing.key
  apt-key add /tmp/alfrescoinstall/nginx_signing.key
  #echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list
  #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
  # Alternate with spdy support and more, change  apt install -> nginx-custom
  #echo "deb http://ppa.launchpad.net/brianmercer/nginx/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list
  #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8D0DC64F
EOF
  sudo apt-get $APTVERBOSITY update && sudo apt-get $APTVERBOSITY install nginx
  sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
  sudo curl -# -o /etc/nginx/nginx.conf $BASE_DOWNLOAD/nginx/nginx.conf
  sudo mkdir -p /var/cache/nginx/alfresco
  sudo mkdir -p $ALF_HOME/www
  if [ ! -f "$ALF_HOME/www/maintenance.html" ]; then
    echo "Downloading maintenance html page..."
    sudo curl -# -o $ALF_HOME/www/maintenance.html $BASE_DOWNLOAD/nginx/maintenance.html
  fi
  sudo chown -R www-data:root /var/cache/nginx/alfresco
  sudo chown -R www-data:root $ALF_HOME/www
  ## Reload config file
  sudo service nginx reload

  echo
  echogreen "Finished installing nginx"
  echo
else
  echo "Skipping install of nginx"
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Java JDK."
echo "This will install Oracle Java 8 version of Java. If you prefer OpenJDK"
echo "you need to download and install that manually."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Oracle Java 8${ques} [y/n] " -i "n" installjdk
if [ "$installjdk" = "y" ]; then
  echoblue "Installing Oracle Java 8. Fetching packages..."
  sudo apt-get $APTVERBOSITY install software-properties-common
  sudo add-apt-repository ppa:webupd8team/java
  sudo apt-get $APTVERBOSITY update
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
  sudo apt-get $APTVERBOSITY install oracle-java8-installer
  sudo update-java-alternatives -s java-8-oracle
  echo
  echogreen "Finished installing Oracle Java 8"
  echo
else
  echo "Skipping install of Oracle Java 8"
  echored "IMPORTANT: You need to install other JDK and adjust paths for the install to be complete"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install LibreOffice."
echo "This will download and install the latest LibreOffice from libreoffice.org"
echo "Newer version of Libreoffice has better document filters, and produce better"
echo "transformations. If you prefer to use Ubuntu standard packages you can skip"
echo "this install."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install LibreOffice${ques} [y/n] " -i "n" installibreoffice
if [ "$installibreoffice" = "y" ]; then

  cd /tmp/alfrescoinstall
  curl -# -L -O $LIBREOFFICE
  tar xf LibreOffice*.tar.gz
  cd "$(find . -type d -name "LibreOffice*")"
  cd DEBS
  sudo dpkg -i *.deb
  echo
  echoblue "Installing some support fonts for better transformations."
  # libxinerama1 libglu1-mesa needed to get LibreOffice 4.4 to work. Add the libraries that Alfresco mention in documentatinas required.
  sudo apt-get $APTVERBOSITY install ttf-mscorefonts-installer fonts-droid libxinerama1 libglu1-mesa libsm6 libxt6 libxrender1 libfontconfig1 libcups2
  echo
  echogreen "Finished installing LibreOffice"
  echo
else
  echo
  echo "Skipping install of LibreOffice"
  echored "If you install LibreOffice/OpenOffice separetely, remember to update alfresco-global.properties"
  echored "Also run: sudo apt-get install ttf-mscorefonts-installer fonts-droid libxinerama1"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install ImageMagick."
echo "This will ImageMagick from Ubuntu packages."
echo "It is recommended that you install ImageMagick."
echo "If you prefer some other way of installing ImageMagick, skip this step."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install ImageMagick${ques} [y/n] " -i "n" installimagemagick
if [ "$installimagemagick" = "y" ]; then

  echoblue "Installing ImageMagick. Fetching packages..."
  sudo apt-get $APTVERBOSITY install imagemagick ghostscript libgs-dev libjpeg62 libpng3
  echo
  IMAGEMAGICKVERSION=`ls /usr/lib/|grep -i imagemagick`
  echoblue "Creating symbolic link for ImageMagick."
  sudo ln -s /usr/lib/$IMAGEMAGICKVERSION /usr/lib/ImageMagick
  echo
  echogreen "Finished installing ImageMagick"
  echo
else
  echo
  echo "Skipping install of ImageMagick"
  echored "Remember to install ImageMagick later. It is needed for thumbnail transformations."
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Swftools."
echo "This will download and install swftools used for transformations to Flash."
echo "Since the swftools Ubuntu package is not included in all versions of Ubuntu,"
echo "this install downloads from swftools.org and compiles."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Swftools${ques} [y/n] " -i "n" installswftools

if [ "$installswftools" = "y" ]; then
  echoblue "Installing build tools and libraries needed to compile swftools. Fetching packages..."
  sudo apt-get $APTVERBOSITY install make build-essential ccache g++ libgif-dev libjpeg62-dev libfreetype6-dev libpng12-dev libt1-dev
  cd /tmp/alfrescoinstall
  echo "Downloading swftools..."
  curl -# -O $SWFTOOLS
  tar xf swftools*.tar.gz
  cd "$(find . -type d -name "swftools*")"
  ./configure
  sudo make && sudo make install
  echo
  echogreen "Finished installing Swftools"
  echo
else
  echo
  echo "Skipping install of Swftools."
  echored "Remember to install swftools via Ubuntu packages or by any other mean."
  echo
fi

echo
echoblue "Adding basic support files. Always installed if not present."
echo
# Always add the addons dir and scripts
  sudo mkdir -p $ALF_HOME/addons/war
  sudo mkdir -p $ALF_HOME/addons/share
  sudo mkdir -p $ALF_HOME/addons/alfresco
  if [ ! -f "$ALF_HOME/addons/apply.sh" ]; then
    echo "Downloading apply.sh script..."
    sudo curl -# -o $ALF_HOME/addons/apply.sh $BASE_DOWNLOAD/scripts/apply.sh
    sudo chmod u+x $ALF_HOME/addons/apply.sh
  fi
  if [ ! -f "$ALF_HOME/addons/alfresco-mmt.jar" ]; then
    sudo curl -# -o $ALF_HOME/addons/alfresco-mmt.jar $BASE_DOWNLOAD/scripts/alfresco-mmt.jar
  fi

  sudo mkdir -p $ALF_HOME/scripts
  if [ ! -f "$ALF_HOME/scripts/mariadb.sh" ]; then
    echo "Downloading mariadb.sh install and setup script..."
    sudo curl -# -o $ALF_HOME/scripts/mariadb.sh $BASE_DOWNLOAD/scripts/mariadb.sh
  fi
  if [ ! -f "$ALF_HOME/scripts/postgresql.sh" ]; then
    echo "Downloading postgresql.sh install and setup script..."
    sudo curl -# -o $ALF_HOME/scripts/postgresql.sh $BASE_DOWNLOAD/scripts/postgresql.sh
  fi

  if [ ! -f "$ALF_HOME/scripts/mysql.sh" ]; then
    echo "Downloading mysql.sh install and setup script..."
    sudo curl -# -o $ALF_HOME/scripts/mysql.sh $BASE_DOWNLOAD/scripts/mysql.sh
  fi

  if [ ! -f "$ALF_HOME/scripts/limitconvert.sh" ]; then
    echo "Downloading limitconvert.sh script..."
    sudo curl -# -o $ALF_HOME/scripts/limitconvert.sh $BASE_DOWNLOAD/scripts/limitconvert.sh
  fi
  if [ ! -f "$ALF_HOME/scripts/createssl.sh" ]; then
    echo "Downloading createssl.sh script..."
    sudo curl -# -o $ALF_HOME/scripts/createssl.sh $BASE_DOWNLOAD/scripts/createssl.sh
  fi
  if [ ! -f "$ALF_HOME/scripts/libreoffice.sh" ]; then
    echo "Downloading libreoffice.sh script..."
    sudo curl -# -o $ALF_HOME/scripts/libreoffice.sh $BASE_DOWNLOAD/scripts/libreoffice.sh
    sudo sed -i "s/@@LOCALESUPPORT@@/$LOCALESUPPORT/g" $ALF_HOME/scripts/libreoffice.sh
  fi
  if [ ! -f "$ALF_HOME/scripts/iptables.sh" ]; then
    echo "Downloading iptables.sh script..."
    sudo curl -# -o $ALF_HOME/scripts/iptables.sh $BASE_DOWNLOAD/scripts/iptables.sh
  fi
  if [ ! -f "$ALF_HOME/scripts/alfresco-iptables.conf" ]; then
    echo "Downloading alfresco-iptables.conf upstart script..."
    sudo curl -# -o $ALF_HOME/scripts/alfresco-iptables.conf $BASE_DOWNLOAD/scripts/alfresco-iptables.conf
  fi
  if [ ! -f "$ALF_HOME/scripts/ams.sh" ]; then
    echo "Downloading maintenance shutdown script..."
    sudo curl -# -o $ALF_HOME/scripts/ams.sh $BASE_DOWNLOAD/scripts/ams.sh
  fi
  sudo chmod u+x $ALF_HOME/scripts/*.sh

  # Keystore
  sudo mkdir -p $ALF_DATA_HOME/keystore
  # Only check for precesence of one file, assume all the rest exists as well if so.
  if [ ! -f " $ALF_DATA_HOME/keystore/ssl.keystore" ]; then
    echo "Downloading keystore files..."
    sudo curl -# -o $ALF_DATA_HOME/keystore/browser.p12 $KEYSTOREBASE/browser.p12
    sudo curl -# -o $ALF_DATA_HOME/keystore/generate_keystores.sh $KEYSTOREBASE/generate_keystores.sh
    sudo curl -# -o $ALF_DATA_HOME/keystore/keystore $KEYSTOREBASE/keystore
    sudo curl -# -o $ALF_DATA_HOME/keystore/keystore-passwords.properties $KEYSTOREBASE/keystore-passwords.properties
    sudo curl -# -o $ALF_DATA_HOME/keystore/ssl-keystore-passwords.properties $KEYSTOREBASE/ssl-keystore-passwords.properties
    sudo curl -# -o $ALF_DATA_HOME/keystore/ssl-truststore-passwords.properties $KEYSTOREBASE/ssl-truststore-passwords.properties
    sudo curl -# -o $ALF_DATA_HOME/keystore/ssl.keystore $KEYSTOREBASE/ssl.keystore
    sudo curl -# -o $ALF_DATA_HOME/keystore/ssl.truststore $KEYSTOREBASE/ssl.truststore
  fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Alfresco war files."
echo "Download war files and optional addons."
echo "If you have downloaded your war files you can skip this step add them manually."
echo "This install place downloaded files in the $ALF_HOME/addons and then use the"
echo "apply.sh script to add them to tomcat/webapps. Se this script for more info."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add Alfresco war files${ques} [y/n] " -i "n" installwar
if [ "$installwar" = "y" ]; then

  echogreen "Downloading alfresco and share war files..."
  sudo curl -# -o $ALF_HOME/addons/war/alfresco.war $ALFREPOWAR
  sudo curl -# -o $ALF_HOME/addons/war/share.war $ALFSHAREWAR

  cd /tmp/alfrescoinstall
  read -e -p "Add Google docs integration${ques} [y/n] " -i "n" installgoogledocs
  if [ "$installgoogledocs" = "y" ]; then
  	echo "Downloading Google docs addon..."
    curl -# -O $GOOGLEDOCSREPO
    sudo mv alfresco-googledocs-repo*.amp $ALF_HOME/addons/alfresco/
    curl -# -O $GOOGLEDOCSSHARE
    sudo mv alfresco-googledocs-share* $ALF_HOME/addons/share/
  fi

  read -e -p "Add Sharepoint plugin${ques} [y/n] " -i "n" installspp
  if [ "$installspp" = "y" ]; then
    echo "Downloading Sharepoint addon..."
    curl -# -O $SPP
    sudo mv alfresco-spp*.amp $ALF_HOME/addons/alfresco/
  fi

  # Check if Java is installed before trying to apply
  if type -p java; then
    _java=java
  elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    _java="$JAVA_HOME/bin/java"
  else
    echored "No JDK installed. When you have installed JDK, run "
    echored "$ALF_HOME/addons/apply.sh all"
    echored "to install addons with Alfresco."
  fi
  if [[ "$_java" ]]; then
    sudo $ALF_HOME/addons/apply.sh all
  fi

  echo
  echogreen "Finished adding Alfresco war files"
  echo
else
  echo
  echo "Skipping adding Alfresco war files"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Solr4 indexing engine."
echo "You can run Solr4 on a separate server, unless you plan to do that you should"
echo "install the Solr4 indexing engine on the same server as your repository server."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Solr4 indexing engine${ques} [y/n] " -i "n" installsolr
if [ "$installsolr" = "y" ]; then

  # Make sure we have unzip available
  sudo apt-get $APTVERBOSITY install unzip

  # Check if we have an old install
  if [ -d "$ALF_HOME/solr4" ]; then
     sudo mv $ALF_HOME/solr4 $ALF_HOME/solr4_BACKUP_`eval date +%Y%m%d%H%M`
  fi
  sudo mkdir -p $ALF_HOME/solr4
  cd $ALF_HOME/solr4

  echogreen "Downloading solr4.war file..."
  sudo curl -# -o $CATALINA_HOME/webapps/solr4.war $SOLR4_WAR_DOWNLOAD

  echogreen "Downloading config file..."
  sudo curl -# -o $ALF_HOME/solr4/solrconfig.zip $SOLR4_CONFIG_DOWNLOAD
  echogreen "Expanding config file..."
  sudo unzip -q solrconfig.zip
  sudo rm solrconfig.zip

  echogreen "Configuring..."

  # Make sure dir exist
  sudo mkdir -p $CATALINA_HOME/conf/Catalina/localhost
  sudo mkdir -p $ALF_DATA_HOME/solr4
  mkdir -p $TMP_INSTALL

  # Remove old config if exists
  if [ -f "$CATALINA_HOME/conf/Catalina/localhost/solr.xml" ]; then
     sudo rm $CATALINA_HOME/conf/Catalina/localhost/solr.xml
  fi

  # Set the solr data path
  SOLRDATAPATH="$ALF_DATA_HOME/solr4"
  # Escape for sed
  SOLRDATAPATH="${SOLRDATAPATH//\//\\/}"

  sudo mv $ALF_HOME/solr4/workspace-SpacesStore/conf/solrcore.properties $ALF_HOME/solr4/workspace-SpacesStore/conf/solrcore.properties.orig
  sudo mv $ALF_HOME/solr4/archive-SpacesStore/conf/solrcore.properties $ALF_HOME/solr4/archive-SpacesStore/conf/solrcore.properties.orig
  sed "s/@@ALFRESCO_SOLR4_DATA_DIR@@/$SOLRDATAPATH/g" $ALF_HOME/solr4/workspace-SpacesStore/conf/solrcore.properties.orig >  $TMP_INSTALL/solrcore.properties
  sudo mv  $TMP_INSTALL/solrcore.properties $ALF_HOME/solr4/workspace-SpacesStore/conf/solrcore.properties
  sed "s/@@ALFRESCO_SOLR4_DATA_DIR@@/$SOLRDATAPATH/g" $ALF_HOME/solr4/archive-SpacesStore/conf/solrcore.properties.orig >  $TMP_INSTALL/solrcore.properties
  sudo mv  $TMP_INSTALL/solrcore.properties $ALF_HOME/solr4/archive-SpacesStore/conf/solrcore.properties

  echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > $TMP_INSTALL/solr4.xml
  echo "<Context debug=\"0\" crossContext=\"true\">" >> $TMP_INSTALL/solr4.xml
  echo "  <Environment name=\"solr/home\" type=\"java.lang.String\" value=\"$ALF_HOME/solr4\" override=\"true\"/>" >> $TMP_INSTALL/solr4.xml
  echo "  <Environment name=\"solr/model/dir\" type=\"java.lang.String\" value=\"$ALF_HOME/solr4/alfrescoModels\" override=\"true\"/>" >> $TMP_INSTALL/solr4.xml
  echo "  <Environment name=\"solr/content/dir\" type=\"java.lang.String\" value=\"$ALF_DATA_HOME/solr4\" override=\"true\"/>" >> $TMP_INSTALL/solr4.xml
  echo "</Context>" >> $TMP_INSTALL/solr4.xml
  sudo mv $TMP_INSTALL/solr4.xml $CATALINA_HOME/conf/Catalina/localhost/solr4.xml

  echogreen "Setting permissions..."
  sudo chown -R $ALF_USER:$ALF_GROUP $CATALINA_HOME/webapps
  sudo chown -R $ALF_USER:$ALF_GROUP $ALF_DATA_HOME/solr4
  sudo chown -R $ALF_USER:$ALF_GROUP $ALF_HOME/solr4

  echo
  echogreen "Finished installing Solr4 engine."
  echored "Verify your setting in alfresco-global.properties."
  echo "Set property value index.subsystem.name=solr4"
  echo
else
  echo
  echo "Skipping installing Solr4."
  echo "You can always install Solr4 at a later time."
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Alfresco BART - Backup and Recovery Tool"
echo "Alfresco BART is a backup and recovery tool for Alfresco ECM. Is a shell script"
echo "tool based on Duplicity for Alfresco backups and restore from a local file system,"
echo "FTP, SCP or Amazon S3 of all its components: indexes, data base, content store "
echo "and all deployment and configuration files."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -p "Install B.A.R.T${ques} [y/n] " -i "n" installbart

if [ "$installbart" = "y" ]; then
 echogreen "Installing B.A.R.T"


 sudo mkdir -p $ALF_HOME/scripts/bart
 sudo mkdir -p $ALF_HOME/logs/bart
 sudo curl -# -o $TMP_INSTALL/$BART_PROPERTIES $BASE_BART_DOWNLOAD$BART_PROPERTIES
 sudo curl -# -o $TMP_INSTALL/$BART_EXECUTE $BASE_BART_DOWNLOAD$BART_EXECUTE

 # Update bart settings
 ALFHOMEESCAPED="${ALF_HOME//\//\\/}"
 BARTLOGPATH="$ALF_HOME/logs/bart"
 ALFBRTPATH="$ALF_HOME/scripts/bart"
 INDEXESDIR="\$\{ALF_DIRROOT\}/solr4"
 # Escape for sed
 BARTLOGPATH="${BARTLOGPATH//\//\\/}"
 ALFBRTPATH="${ALFBRTPATH//\//\\/}"
 INDEXESDIR="${INDEXESDIR//\//\\/}"

 sed -i "s/ALF_INSTALLATION_DIR\=.*/ALF_INSTALLATION_DIR\=$ALFHOMEESCAPED/g" $TMP_INSTALL/$BART_PROPERTIES
 sed -i "s/ALFBRT_LOG_DIR\=.*/ALFBRT_LOG_DIR\=$BARTLOGPATH/g" $TMP_INSTALL/$BART_PROPERTIES
 sed -i "s/INDEXES_DIR\=.*/INDEXES_DIR\=$INDEXESDIR/g" $TMP_INSTALL/$BART_PROPERTIES
 sudo cp $TMP_INSTALL/$BART_PROPERTIES $ALF_HOME/scripts/bart/$BART_PROPERTIES
 sed -i "s/ALFBRT_PATH\=.*/ALFBRT_PATH\=$ALFBRTPATH/g" $TMP_INSTALL/$BART_EXECUTE
 sudo cp $TMP_INSTALL/$BART_EXECUTE $ALF_HOME/scripts/bart/$BART_EXECUTE

 sudo chmod 700 $ALF_HOME/scripts/bart/$BART_PROPERTIES
 sudo chmod 774 $ALF_HOME/scripts/bart/$BART_EXECUTE

 # Install dependency
 sudo apt-get $APTVERBOSITY install duplicity;

 # Add to cron tab
 tmpfile=/tmp/crontab.tmp

 # read crontab and remove custom entries (usually not there since after a reboot
 # QNAP restores to default crontab: http://wiki.qnap.com/wiki/Add_items_to_crontab#Method_2:_autorun.sh
 sudo -u $ALF_USER crontab -l | grep -vi "alfresco-bart.sh" > $tmpfile

 # add custom entries to crontab
 echo "0 5 * * * $ALF_HOME/scripts/bart/$BART_EXECUTE backup" >> $tmpfile

 #load crontab from file
 sudo -u $ALF_USER crontab $tmpfile

 # remove temporary file
 rm $tmpfile

 # restart crontab
 sudo service cron restart

 echogreen "B.A.R.T Cron is installed to run in 5AM every day as the $ALF_USER user"

fi

# Finally, set the permissions
sudo chown -R $ALF_USER:$ALF_GROUP $ALF_HOME
if [ -d "$ALF_HOME/www" ]; then
   sudo chown -R www-data:root $ALF_HOME/www
fi

echo
echogreen "- - - - - - - - - - - - - - - - -"
echo "Scripted install complete"
echored "Manual tasks remaining:"
echo "1. Add database. Install scripts available in $ALF_HOME/scripts"
echored "   It is however recommended that you use a separate database server."
echo "2. Verify Tomcat memory and locale settings in /etc/init/alfresco.conf."
echo "   Alfresco runs best with lots of memory. Add some more to \"lots\" and you will be fine!"
echo "   Match the locale LC_ALL (or remove) setting to the one used in this script."
echo "   Locale setting is needed for LibreOffice date handling support."
echo "3. Update database and other settings in alfresco-global.properties"
echo "   You will find this file in $CATALINA_HOME/shared/classes"
echo "4. Update properties for BART (if installed) in $ALF_HOME/scripts/bart/alfresco-bart.properties"
echo "   DBNAME,DBUSER,DBPASS,DBHOST,REC_MYDBNAME,REC_MYUSER,REC_MYPASS,REC_MYHOST,DBTYPE "
echo "5. Update cpu settings in $ALF_HOME/scripts/limitconvert.sh if you have more than 2 cores."
echo "6. Start nginx if you have installed it: /etc/init.d/nginx start"
echo "7. Start Alfresco/tomcat: sudo service alfresco start"
echo

echo
echo "${warn}${bldblu} - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ${warn}"
echogreen "Thanks for using Alfresco Ubuntu installer by Loftux AB."
echogreen "Please visit https://loftux.com for more Alfresco Services and add-ons."
echogreen "You are welcome to contact us at info@loftux.se"
echo "${warn}${bldblu} - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ${warn}"
echo
