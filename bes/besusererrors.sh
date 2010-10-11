minsago=`date --date="15 minutes ago" +%s`
r=0;
function cacl () {
        if [ "$1" = "errors" ]
        then
                if [ $i -gt $minsago ]
                then
                        ((r++))
                fi
        else
                if [ $i -lt $minsago ]
                then
                        ((r++))
                fi

fi
}

for i in  `snmpbulkwalk  -v 2c  -c $2 $3 1.3.6.1.4.1.3530.5.30.1.11 | tr " " ":" | cut -d":" -f 7`
do
        cacl $1 $i
done
echo $r