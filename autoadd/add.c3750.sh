#!/bin/sh
#
#
# Changes required in:
#	1) Section 1: Create Host
#	2) Section 2: Define the Veriables
# -----------------------------------------------------------

##########################################################
# -----------[-< Section 1: Create Host >-]------------- #
#
# 1. Define Template in $templateid | grep -i 'xxx'
#
#       a) 'Netscaler'
#       b) 'Cisco Catalyst 3750'
#
# ------------------------------------------------------ #

templateid=`./add_device.php --list-host-templates | grep -i 'Cisco Catalyst 3750'  | cut -f1`

./add_device.php  --description=$3 --ip=$1 --avail=snmp --version=2 --community=$2 --template=$templateid


###################################################################
# -----------[-< Section 2: Define the Variables >-]------------- #
#
# 2. Define what tree you want to associate your host with
#    in $parentnode | grep 'xxx'
#
#	a) 'Load Balancers Source'
#	b) 'Firewalls Source'
#	c) 'Routers Source'
#	d) 'Switches Source'
#
# --------------------------------------------------------------- #

hostid=`./add_graphs.php  --list-hosts | grep $3 | cut -f1`

dcid=`echo $3 | cut -b 1-4 `
treeid=`./add_tree.php --list-trees | grep -i $dcid | cut -f1`
parentnode=`./add_tree.php --list-nodes --tree-id=$treeid | grep 'Switches Source'  | cut -f2`


#########################################################################
# -----------[-< Section 3: Associate Node with a Tree >-]------------- #

### Associate Node with a specific branch in a tree
./add_tree.php --type=node --node-type=host --tree-id=$treeid --parent-node=$parentnode --host-id=$hostid


######################################################################
# -----------[-< Secion 3: Add Graphs from Template >-]------------- #

### Host Template
./add_graphs.php --quiet --list-graph-templates --host-template-id=$templateid | cut -f1 | xargs -I {} ./add_graphs.php --graph-type=cg --graph-template-id={} --host-id=$hostid

#add dynamic graphs like vserver stats
### 
./update.3750.sh $hostid $templateid

### SNMP 64bit Interfaces
./update.snmpinterfaces.sh $hostid $templateid

