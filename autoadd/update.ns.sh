#!/bin/sh

templateid=$2
hostid=$1

snmpqueryidarray=(`./add_graphs.php --list-snmp-queries | grep -i netscaler | cut -f1 | xargs`)

for i in "${snmpqueryidarray[@]}"
do

	snmpquerytypeidarray=(`./add_graphs.php --quiet --list-query-types --snmp-query-id=$i | cut -f1 | xargs`)

	listsnmpfieldsarray=(`./add_graphs.php --quiet --list-snmp-fields  --host-id=$hostid --snmp-query-id=$i | cut -f1 | head -n1`)

	for j in "${snmpquerytypeidarray[@]}"
	do
		graphtemplateid=(`./add_graphs.php --quiet  --list-graph-templates --snmp-query-id=$i |  grep "^$j\b" |cut -f2`)
                for k in "${listsnmpfieldsarray[@]}"
                do
                        ./add_graphs.php --quiet --list-snmp-values --host-id=$hostid --snmp-query-id=$i --snmp-field=$k | cut -f1 | xargs  -d "\n\r"  -I {}  bash -c " ./add_graphs.php --graph-type=ds --graph-template-id=$graphtemplateid  --host-id=$hostid --snmp-query-id=$i --snmp-query-type-id=$j --snmp-field=$k --snmp-value=\"{}\""
		done
	done
done
