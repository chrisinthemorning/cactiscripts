#!/bin/sh

templateid=`./add_device.php --list-host-templates | grep -i netscaler  | cut -f1`

#add netscaler device
./add_device.php  --description=$3 --ip=$1 --avail=pingsnmp --ping_method=icmp --version=2 --community=$2 --template=$templateid

hostid=`./add_graphs.php  --list-hosts | grep $3 | cut -f1`

#add node to the tree
dcid=`echo $3 | cut -b 1-4 `
treeid=`./add_tree.php --list-trees | grep -i $dcid | cut -f1`
parentnode=`./add_tree.php --list-nodes --tree-id=$treeid | grep 'Load Balancers'  | cut -f2`

./add_tree.php --type=node --node-type=host --tree-id=$treeid --parent-node=$parentnode --host-id=$hostid

#add basic graphs
./add_graphs.php --quiet --list-graph-templates --host-template-id=$templateid | cut -f1 | xargs -I {} ./add_graphs.php --graph-type=cg --graph-template-id={} --host-id=$hostid

#add dynamic graphs like vserver stats
./update.ns.sh $hostid $templateid

#add snmp data for interfaces , like discards and errors
./update.ns.snmpinterfaces.sh $hostid $templateid
