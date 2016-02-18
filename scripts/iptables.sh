#!/bin/bash
# -------
# Script to set up iptables for Alfresco use
#
# Copyright 2013-2016 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

# Change to public ip-adress on alfresco server
export IPADRESS=192.168.0.10

    # redirect FROM TO PROTOCOL
    # setup port redirect using iptables
    redirect() {
	    echo "Redirecting port $1 to $2 ($3)"
	    iptables -t nat -A PREROUTING -p $3 --dport $1 -j REDIRECT --to-ports $2
	    iptables -t nat -A OUTPUT -d localhost -p $3 --dport $1 -j REDIRECT --to-ports $2
	    # Add all your local ip adresses here that you need port forwarding for
	    iptables -t nat -A OUTPUT -d $IPADRESS -p $3 --dport $1 -j REDIRECT --to-ports $2
    }
    #
    # setup_iptables
    # setup iptables for redirection of CIFS and FTP
    setup_iptables () {

	    echo "1" >/proc/sys/net/ipv4/ip_forward
	    # Clear NATing tables
	    iptables -t nat -F
	    iptables -P INPUT ACCEPT
	    iptables -P FORWARD ACCEPT
	    iptables -P OUTPUT ACCEPT

	    # FTP NATing
	    redirect 21 2021 tcp

	    # CIFS NATing
	    redirect 445 1445 tcp
	    redirect 139 1139 tcp
	    redirect 137 1137 udp
	    redirect 138 1138 udp

	    # Forward http
	    #redirect 80 8080 tcp
    }
    remove_iptables () {

	    echo "0" >/proc/sys/net/ipv4/ip_forward
	    # Clear NATing tables
	    iptables -t nat -F
	    iptables -P INPUT ACCEPT
	    iptables -P FORWARD ACCEPT
	    iptables -P OUTPUT ACCEPT

    }
    # start, debug, stop, and status functions
    start() {
		echo "Setting up iptables for Alfresco"
		setup_iptables
    }

    stop() {
    	echo "Removing iptables"
    	remove_iptables

    }

    case "$1" in
      start)
            start
            ;;
      stop)
            stop
            ;;
      restart)
            stop
            start
            ;;
      *)
            echo "Usage: $0 {start|stop|restart}"
            exit 1
    esac

    exit $RETVAL
