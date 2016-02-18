#!/bin/sh
#
# Script for handling letsencrypt with Alfresco
#
# Copyright 2013 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

export INSTALLDIR=/opt/letsencrypt
# Location where you put your letsencrypt config files
export CONFIGDIR=/etc/letsencrypt/configs/
# Location to webpath-root where letsencrypt places domain verification files.
# Amended with the domain when using init.
export BASECHALLENGELOCATION=/usr/share/nginx


export APTVERBOSITY="-qq -y"
# Branch name to pull from server. Use master for stable.
BRANCH=experimental
export BASE_DOWNLOAD=https://raw.githubusercontent.com/loftuxab/alfresco-ubuntu-install/$BRANCH

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

init() {
    if [ "`which git`" = "" ]; then
    echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo "You need to install git. Git is used to install (clone) letsencrypt."
    echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    sudo apt-get $APTVERBOSITY install git;
    fi


    if [ ! -d "$INSTALLDIR" ]; then
        sudo git clone https://github.com/letsencrypt/letsencrypt.git $INSTALLDIR
    fi

    sudo mkdir -p $CONFIGDIR
    sudo mkdir -p mkdir $BASECHALLENGELOCATION/$2

    if [ ! -f "$CONFIGDIR/letsencryptc.com.conf.sample" ]; then
      echo "Downloading sample domain config..."
      sudo curl -# -o $CONFIGDIR/letsencryptc.com.conf.sample $BASE_DOWNLOAD/nginx/letsencrypt/letsencryptc.com.conf
    fi

}

create() {
    echoblue "Creating certificates for $1"
    if [ -f "$CONFIGDIR/$1.conf" ]; then
        cd $INSTALLDIR
        sudo ./letsencrypt-auto --config "$CONFIGDIR/$1.conf" certonly
    else
        echored "You must supply the config file to use without .conf ending."
        echored "Keept the config file the same as domain name."
    fi

    echoblue "You must now configure nginx manually to use"
    echoblue "the new certificates and restart."
}

renew() {
    cd $INSTALLDIR
    for conf in $(ls $CONFIGDIR/*.conf); do
        sudo ./letsencrypt-auto --renew --config "$conf" certonly
    done
    sudo service alfresco restart
}

case "$1" in
  create)
        create $2
        ;;
  renew)
        renew
        ;;
  init)
        init
        ;;
  *)
        echored "Usage: $0 {init|create|renew}"
        echogreen "init: Install letsencrypt and sample config"
        echogreen "create: Create first time certificate. Require second parameter for domain."
        echogreen "renew: Renew existing certificates. Will loop all existing configs."
        exit 1
esac

exit $RETVAL
