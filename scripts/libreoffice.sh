#!/bin/sh
#
# Script for starting/stopping LibreOffice without restarting Alfresco
#
# Copyright 2013-2016 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

    # JDK locations
    export JAVA_HOME="/usr/lib/jvm/java-8-oracle"
    export JRE_HOME=$JAVA_HOME/jre

    # User under which tomcat will run
    USER=alfresco
    ALF_HOME=/opt/alfresco
    cd "$ALF_HOME"
    # export LC_ALL else openoffice may use en settings on dates etc
    export LC_ALL=@@LOCALESUPPORT@@
    export CATALINA_PID="${ALF_HOME}/tomcat.pid"

    RETVAL=0

    start() {
        OFFICE_PORT=`ps ax|grep office|grep 8100|wc -l`
        if [ $OFFICE_PORT -ne 0 ]; then
            echo "Alfresco Open Office service already started"
	        CURRENT_PROCID=`ps axf|grep office|grep 8100|awk -F " " 'NR==1 {print $1}'`
	        echo $CURRENT_PROCID
        else
            #Only start if Alfresco is already running
            SHUTDOWN_PORT=`netstat -vatn|grep LISTEN|grep 8005|wc -l`
            export JAVA_HOME=$JAVA_HOME
            if [ $SHUTDOWN_PORT -ne 0 ]; then
            /bin/su -s /bin/bash $USER -c "/opt/libreoffice6.4/program/soffice.bin \"--accept=socket,host=localhost,port=8100;urp;StarOffice.ServiceManager\" \"-env:UserInstallation=file:///opt/alfresco/alf_data/oouser\" --nologo --headless --nofirststartwizard --norestore --nodefault &" >/dev/null
            echo "Alfresco Open Office starting"
	        logger Alfresco Open Office service started
            fi

        fi
    }
    stop() {
        # Start Tomcat in normal mode
        OFFICE_PORT=`ps ax|grep office|grep 8100|wc -l`
        if [ $OFFICE_PORT -ne 0 ]; then
            echo "Alfresco Open Office started, killing"
	        CURRENT_PROCID=`ps axf|grep office|grep 8100|awk -F " " 'NR==1 {print $1}'`
	        echo $CURRENT_PROCID
	        kill $CURRENT_PROCID
	        logger Alfresco Open Office service stopped
        fi
    }
    status() {
        # Start Tomcat in normal mode
        OFFICE_PORT=`ps ax|grep office|grep 8100|wc -l`
        if [ $OFFICE_PORT -ne 0 ]; then
            echo "Alfresco LibreOffice service started"
        else
            echo "Alfresco LibreOffice service NOT started"
        fi
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
	    sleep 2
            start
            ;;
      status)
            status
            ;;
      *)
            echo "Usage: $0 {start|stop|restart|status}"
            exit 1
    esac

    exit $RETVAL
