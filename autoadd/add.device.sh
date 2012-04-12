#!/bin/sh
sysdescr=`snmpget -v2c -c $2 $1 sysDescr.0`

case "$sysdescr" in

        *NetScaler*)
                echo 'Found NetScaler'
                ./add.ns.sh $1 $2 $3
        ;;

esac
