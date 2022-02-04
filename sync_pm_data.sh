#!/bin/bash

# Declare how Market names map to market IDs
basedir=/oamdata/minio_client_test/NOM_PM
marketnames=()
marketnames+=("NewYork:106,110,111")
marketnames+=("Boston:112,117,410")
marketnames+=("Miami:411,412,417")

dates=()
dates+=(`date '+%Y%m%d'`)
#dates+=(`date -d "yesterday" '+%Y%m%d'`)
#dates+=(`date -d "2 days ago" '+%Y%m%d'`)

### Get all market IDs present in PM files on this NOM ###
allmarkets=`./mc ls ajnom-ltetool/nokia-airscale-bts/${dates[0]}/MRBTS|awk '{print substr($NF,1,3)}'|sort|uniq`
allmarketsa=()
echo "Market IDs found on this NOM"
for market in $allmarkets
 do
  echo "Market is $market"
  allmarketsa+=($market)
 done

for date in ${dates[@]}
 do
        for marketdef in "${marketnames[@]}"
         do
          market=`echo $marketdef|cut -d\: -f1`
          market_ids=`echo $marketdef|cut -d\: -f2|sed 's/,/ /g'`
          excludelist=("${allmarketsa[@]}")
          echo "===== $market ====="
          echo "Exclude list before is ${excludelist[@]}"
          for id in $market_ids
           do
            echo "Id:$id"
            for((i=0;i<${#excludelist[@]};i++))
             do
              #echo "Comparing value from excludelist ${excludelist[$i]} with Id:$id"
              if [ ${excludelist[$i]} -eq $id ]
               then
                #echo "Removing ID:$id from excludelist"
                excludelist[$i]=000
               fi
             done
           done
           echo "Exclude list after is ${excludelist[@]}"
           mccmd="./mc mirror "
           for exclude in ${excludelist[@]}
            do
             if [ $exclude != '000' ]
              then
               mccmd+='--exclude "'
               mccmd+=$exclude
               mccmd+='*" '
              fi
            done
           mccmd+="ajnom-ltetool/nokia-airscale-bts/${date}/MRBTS ${basedir}/${market}/${date}/MRBTS"
           echo "mc commnad is $mccmd"
           bash -c "$mccmd"
         done
 done
