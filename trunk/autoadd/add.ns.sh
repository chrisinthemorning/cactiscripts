#!/bin/sh

templateid=`./add_device.php --list-host-templates | grep -i netscaler  | cut -f1`

./add_device.php  --description=$3 --ip=$1 --avail=pingsnmp --ping_method=icmp --version=2 --community=$2 --template=$templateid

hostid=`./add_graphs.php  --list-hosts | grep $3 | cut -f1`

./add_graphs.php --quiet --list-graph-templates --host-template-id=$templateid | cut -f1 | xargs -I {} ./add_graphs.php --graph-type=cg --graph-template-id={} --host-id=$hostid

./update.ns.sh $hostid $templateid
