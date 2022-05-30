#!/bin/bash 

iterator=1
maxIterations=6
error=1

while [ $iterator -le $maxIterations ] 
do
  kubectl get pods --all-namespaces -o jsonpath="{.items[*].status.containerStatuses[0].state}" | tr -s '[[:space:]]' '\n' > k3d-statuses.json
  statuses=`jq -r 'keys[]' k3d-statuses.json | uniq`
  kubectl get pods
  
  readarray -t statusesArray < <(echo "$statuses")  

  if [ ${#statusesArray[@]} -eq 1 ]; then
    echo "One status"
    if [ ${statusesArray[0]}="Running" ]; then
      echo "Status: running"
      error=$((0))
      break
    fi
  fi

  echo "Sleeping...$iterator"

  iterator=$((iterator+1))
  sleep 10
done

if [ $error -ne 0 ]; then
  echo "Statuses: ${statusesArray[@]}"
fi
