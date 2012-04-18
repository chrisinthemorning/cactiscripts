#!/bin/sh
#
#
#	$1 - IP address
#	$2 - SNMP Community
#	$3 - Node Name
# -----------------------------------------------------------

sysdescr=`snmpget -v2c -c $2 $1 sysDescr.0`

case "$sysdescr" in

	*NetScaler*)
		echo 'Found NetScaler'
		./add.ns.sh $1 $2 $3
	;;
	*'C3750'*)
                echo 'Found Catalyst 3750'
                ./add.c3750.sh $1 $2 $3
        ;;

esac
