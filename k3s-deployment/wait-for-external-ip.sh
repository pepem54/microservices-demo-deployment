#!/bin/bash 

iterator=1
maxIterations=$1
sleepTime=$2
             
while [ $iterator -le $((maxIterations)) ] 
do
 loadBnalancerStatus=`kubectl get svc sl-boutique-frontend -o json| jq -r .status.loadBalancer`

 if [ ! "$loadBnalancerStatus" == "{}" ]; then
   echo "$loadBnalancerStatus" > loadBnalancerStatus.json
   export BOUTIQUE_FRONTEND_IP=`jq -r .ingress[].ip loadBnalancerStatus.json`

   if [ ! -z "$BOUTIQUE_FRONTEND_IP" ]; then
     break
   fi               
 fi

 echo "Retrying... $iterator of $maxIterations"
 iterator=$((iterator+1))
 sleep $((sleepTime))
done

echo "IP: $BOUTIQUE_FRONTEND_IP"
