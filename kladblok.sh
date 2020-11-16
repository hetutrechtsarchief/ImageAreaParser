# 5 minuten
MAXTRIES=300

TRIPLY_DATASET=UDS
API="https://data.netwerkdigitaalerfgoed.nl/_api"
JSON="tmp.json"
graphname=kladblok
# KLADBLOK=test.ttl

URL=http://hualab.nl/kladblok/kladblok.ttl

# upload
if [ $# -eq 0 ]
  then
    echo "usage: ./kladblok.sh file.ttl"
    exit
fi

scp $1 hualab.nl:/home/rick/hualab/kladblok/kladblok.ttl
# kladblok.ttl

# put in queue 

curl -s --request POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TRIPLY_TOKEN" "$API/datasets/$TRIPLY_USER/$TRIPLY_DATASET/jobs" --data-binary '{"url":"'$URL'","type":"download"}' > $JSON
JOBID=`ggrep -o -E "\"jobId\":\s+\".*\"" $JSON | awk -F\" '{print $4}'`
STATUS=`ggrep -o -E "\"status\":\s+\".*\"" $JSON | awk -F\" '{print $4}'`

while [[ ( "$STATUS" = "downloading" || "$STATUS" = "cleaning"  || "$STATUS" = "indexing" || "$STATUS" = "created" ) && $MAXTRIES>0 ]]; do
    curl -s -H 'Content-Type: application/json' -H "Authorization: Bearer $TRIPLY_TOKEN" "$API/datasets/$TRIPLY_USER/$TRIPLY_DATASET/jobs/$JOBID" > $JSON
    STATUS=`ggrep -o -E "\"status\":\s+\".*\"" $JSON | awk -F\" '{print $4}'`
    echo "STATUS: $STATUS (MAXTRIES: $MAXTRIES)"
    sleep 1
    MAXTRIES=$((MAXTRIES-1))

    echo "x"
done

if [ "$STATUS" == "error" ]; then
  echo "error!"
fi

if [ "$STATUS" == "finished" ]; then
    graph=`ggrep -o -E https://data.netwerkdigitaalerfgoed.nl/$TRIPLY_USER/$TRIPLY_DATASET/graphs/[a-z0-9\-]+ $JSON`

    curl -s --request GET -H 'Content-Type: application/json' -H "Authorization: Bearer $TRIPLY_TOKEN" "$API/datasets/$TRIPLY_USER/$TRIPLY_DATASET/graphs" > $JSON

    graphId=`ggrep -Pzo '"graphName": "'$graph'",\n\s*"id": "(.*?)"' $JSON | tail -1 | sed 's/\s*"id": "//' | sed 's/"//' | tr '\0' '\n' ` 

    graphId=`echo $graphId | sed 's/ *$//g'`   # trim


    kladblokId=`ggrep -Pzo '"graphName": ".*?kladblok",\n\s*"id": "(.*?)"' $JSON | tail -1 | sed 's/\s*"id": "//' | sed 's/"//' | tr '\0' '\n'`

    kladblokId=`echo $kladblokId | sed 's/ *$//g'`   # trim


    if [ ! -z "$kladblokId" ]; then
      echo "Remove kladblok graph with id $kladblokId"
      curl -s -X DELETE -H 'Content-Type: application/json' -H "Authorization: Bearer $TRIPLY_TOKEN" "$API/datasets/$TRIPLY_USER/$TRIPLY_DATASET/graphs/$kladblokId"
    fi

    echo "Renaming graph $graphId from $graph to $graphname"
    curl -s -X PATCH -H 'Content-Type: application/json' -H "Authorization: Bearer $TRIPLY_TOKEN"  --data-binary '{"graphName":"https://data.netwerkdigitaalerfgoed.nl/'$TRIPLY_USER'/'$TRIPLY_DATASET'/graphs/'$graphname'"}' "$API/datasets/$TRIPLY_USER/$TRIPLY_DATASET/graphs/$graphId" > $JSON
    
    cat $JSON
    # rm $JSON

    echo "done"
fi

