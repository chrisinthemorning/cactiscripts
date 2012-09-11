#!/bin/sh

templateid=$2
hostid=$1
dcid=`echo $3 | cut -b 1-4 `
treeid=`./add_tree.php --list-trees | grep -i $dcid | cut -f1`
nodeidforvservers=`./add_tree.php --list-nodes --tree-id=$treeid | grep \`./add_tree.php --list-nodes --tree-id=$treeid | grep '^Header' | grep $3 | cut -f2\` | grep Vservers | cut -f2`
nodeidforservices=`./add_tree.php --list-nodes --tree-id=$treeid | grep \`./add_tree.php --list-nodes --tree-id=$treeid | grep '^Header' | grep $3 | cut -f2\` | grep Services | cut -f2`
nodeidforservicegroups=`./add_tree.php --list-nodes --tree-id=$treeid | grep \`./add_tree.php --list-nodes --tree-id=$treeid | grep '^Header' | grep $3 | cut -f2\` | grep ServiceGroups | cut -f2`

#snmpqueryidarray=(`./add_graphs.php --list-snmp-queries | grep -i netscaler | grep -v ServiceGroup | cut -f1 | xargs`)
snmpqueryidarray=(`./add_graphs.php --list-snmp-queries | grep -i netscaler | cut -f1 | xargs`)
for i in "${snmpqueryidarray[@]}"
do

        snmpquerytypeidarray=(`./add_graphs.php --quiet --list-query-types --snmp-query-id=$i | cut -f1 | xargs`)

        if [ `./add_graphs.php --quiet --list-snmp-fields  --host-id=$hostid --snmp-query-id=$i | cut -f1 | grep "vsvrName"` ]
         then
          listsnmpfieldsarray="vsvrName"
        elif [ `./add_graphs.php --quiet --list-snmp-fields  --host-id=$hostid --snmp-query-id=$i | cut -f1 | grep "svcName"` ]
         then
          listsnmpfieldsarray="svcName"
        elif [ `./add_graphs.php --quiet --list-snmp-fields  --host-id=$hostid --snmp-query-id=$i | cut -f1 | grep "svcgrpName"` ]
         then
          listsnmpfieldsarray="svcgrpName"
        else
         listsnmpfieldsarray=(`./add_graphs.php --quiet --list-snmp-fields  --host-id=$hostid --snmp-query-id=$i | cut -f1 | head -n1`)
        fi

        for j in "${snmpquerytypeidarray[@]}"
        do
                graphtemplateid=(`./add_graphs.php --quiet  --list-graph-templates --snmp-query-type-id=$i |  grep "^$j\b" |cut -f2`)
                for k in "${listsnmpfieldsarray[@]}"
                do
                  listsnmpvaluesarray=(`./add_graphs.php --quiet --list-snmp-values --host-id=$hostid --snmp-query-id=$i --snmp-field=$k | cut -f1 `)
                    for l in "${listsnmpvaluesarray[@]}"
                    do
                        graphid=`./add_graphs.php --graph-type=ds --graph-template-id=$graphtemplateid  --host-id=$hostid --snmp-query-id=$i --snmp-query-type-id=$j --snmp-field=$k --snmp-value=$l | cut -d '(' -f2 | cut -d ')' -f1`
                        if [ $k == "vsvrName" ]
                                then
                                        #add vserver subnodes $l
                                        graphparentnode=`./add_tree.php --name="$l"  --type=node --node-type=header --parent-node=$nodeidforvservers --host-id=$hostid --tree-id=$treeid  | cut -d '(' -f2 | cut -d ')' -f1`
                                        ./add_tree.php --type=node --node-type=graph --parent-node=$graphparentnode --tree-id=$treeid --host-id=$hostid --graph-id=$graphid
                        elif  [ $k == "svcName" ]
                                then
                                        graphparentnode=`./add_tree.php --name="$l"  --type=node --node-type=header --parent-node=$nodeidforservices --host-id=$hostid --tree-id=$treeid  | cut -d '(' -f2 | cut -d ')' -f1`
                                        ./add_tree.php --type=node --node-type=graph --parent-node=$graphparentnode --tree-id=$treeid --host-id=$hostid --graph-id=$graphid
                        elif  [ $k == "svcgrpName" ]
                                then
                                        graphparentnode=`./add_tree.php --name="$l"  --type=node --node-type=header --parent-node=$nodeidforservicegroups --host-id=$hostid --tree-id=$treeid  | cut -d '(' -f2 | cut -d ')' -f1`
                                        ./add_tree.php --type=node --node-type=graph --parent-node=$graphparentnode --tree-id=$treeid --host-id=$hostid --graph-id=$graphid


                        fi
                    done
#                       ./add_graphs.php --quiet --list-snmp-values --host-id=$hostid --snmp-query-id=$i --snmp-field=$k | cut -f1 | xargs  -d "\n\r"  -I {}  bash -c " ./add_graphs.php --graph-type=ds --graph-template-id=$graphtemplateid  --host-id=$hostid --snmp-query-id=$i --snmp-query-type-id=$j --snmp-field=$k --snmp-value=\"{}\""
                done
        done
done
