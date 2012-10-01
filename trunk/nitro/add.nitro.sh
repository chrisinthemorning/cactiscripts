#!/bin/sh

templateid=`./add_device.php --list-host-templates | grep -i nitro  | cut -f1`

#add netscaler device
./add_device.php  --description=$2 --ip=$1  --version=0 --avail=ping --ping_method=icmp --template=$templateid

hostid=`./add_graphs.php  --list-hosts | grep $2 | cut -f1`

#add node to the tree
dcid=`echo $2 | cut -b 1-4 `
treeid=`./add_tree.php --list-trees | grep -i $dcid | cut -f1`
parentnode=`./add_tree.php --list-nodes --tree-id=$treeid | grep 'Load Balancers Source'  | cut -f2`
./add_tree.php --type=node --node-type=host --tree-id=$treeid --parent-node=$parentnode --host-id=$hostid

parentnode=`./add_tree.php --list-nodes --tree-id=$treeid | grep 'Load Balancers' | grep -v 'Source'  | grep '^Header' | cut -f2`
./add_tree.php --name=$2 --type=node --node-type=header --parent-node=$parentnode --host-id=$hostid --tree-id=$treeid

#add interfaces node
parentnode=`./add_tree.php --list-nodes --tree-id=$treeid | grep $2 | grep -v 'Source' | grep '^Header'  | cut -f2`
./add_tree.php --name='Interfaces' --type=node --node-type=header --parent-node=$parentnode --host-id=$hostid --tree-id=$treeid

#add system node
./add_tree.php --name='System'  --type=node --node-type=header --parent-node=$parentnode --host-id=$hostid --tree-id=$treeid
#add vserver node
./add_tree.php --name='CSVservers'  --type=node --node-type=header --parent-node=$parentnode --host-id=$hostid --tree-id=$treeid
./add_tree.php --name='LBVservers'  --type=node --node-type=header --parent-node=$parentnode --host-id=$hostid --tree-id=$treeid

#add Services node
./add_tree.php --name='Services'  --type=node --node-type=header --parent-node=$parentnode --host-id=$hostid --tree-id=$treeid
#add ServiceGroups node
./add_tree.php --name='ServiceGroups'  --type=node --node-type=header --parent-node=$parentnode --host-id=$hostid --tree-id=$treeid



#add basic graphs 
#./add_graphs.php --quiet --list-graph-templates --host-template-id=$templateid | cut -f1 | xargs -I {} ./add_graphs.php --graph-type=cg --graph-template-id={} --host-id=$hostid
dcid=`echo $2 | cut -b 1-4 `
treeid=`./add_tree.php --list-trees | grep -i $dcid | cut -f1`
echo $treeid
nodeidforsystem=`./add_tree.php --list-nodes --tree-id=$treeid | grep \`./add_tree.php --list-nodes --tree-id=$treeid | grep '^Header' | grep $2 | cut -f2\` | grep System | cut -f2`
echo $nodeidforsystem

graphtemplateidarray=(`./add_graphs.php --quiet --list-graph-templates --host-template-id=$templateid | cut -f1`)

for i in "${graphtemplateidarray[@]}"
do
	graphid=`./add_graphs.php --graph-type=cg --graph-template-id=$i --host-id=$hostid | cut -d '(' -f2 | cut -d ')' -f1`
echo $graphid
	#graphparentnode=`./add_tree.php --name="$hostid"  --type=node --node-type=header --parent-node=$nodeidforsystem --host-id=$hostid --tree-id=$treeid  | cut -d '(' -f2 | cut -d ')' -f1`
	./add_tree.php --type=node --node-type=graph --parent-node=$nodeidforsystem --tree-id=$treeid --host-id=$hostid --graph-id=$graphid
done

#add snmp data for interfaces , like discards and errors
#./update.snmpinterfaces.sh $hostid $templateid

#add dynamic graphs like vserver stats
./update.nitro.sh $hostid $templateid $2

