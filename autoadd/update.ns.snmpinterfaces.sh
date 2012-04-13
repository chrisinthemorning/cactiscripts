#!/bin/sh

templateid=$2
hostid=$1

snmpqueryidarray=(`./add_graphs.php --list-snmp-queries | grep -i 'SNMP - Interface Statistics' | cut -f1 | xargs`)

for i in "${snmpqueryidarray[@]}"
do

        snmpquerytypeidarray=(`./add_graphs.php --quiet --list-query-types --snmp-query-id=$i |  egrep "In/Out Bits \(64-bit Counters\)|In/Out Errors/Discarded Packets" | cut -f1 | xargs`)

        listsnmpfieldsarray=(`./add_graphs.php --quiet --list-snmp-fields  --host-id=$hostid --snmp-query-id=$i | cut -f1 | grep -i ifindex`)

        for j in "${snmpquerytypeidarray[@]}"
        do
                for k in "${listsnmpfieldsarray[@]}"
                do
                        ./add_graphs.php --quiet --list-snmp-values --host-id=$hostid --snmp-query-id=$i --snmp-field=$k | cut -f1 | xargs  -d "\n\r"  -I {}  bash -c " ./unsafe_add_graphs.php --graph-type=ds --graph-template-id=$templateid  --host-id=$hostid --snmp-query-id=$i --snmp-query-type-id=$j --snmp-field=$k --snmp-value=\"{}\""

                done

        done
done
