#!/bin/bash 

iterator=1
maxIterations=10
error=1
statusToIgnore="terminated"

while [ $iterator -le $maxIterations ] 
do
  kubectl get pods --namespace=default -o jsonpath="{.items[*].status.containerStatuses[0].state}" | tr -s '[[:space:]]' '\n' > k3s-statuses.json
  statuses=`jq -r 'keys[]' k3s-statuses.json | sort | uniq`
  readarray -t statusesArray < <(echo "$statuses")  
  statusesArray=(${statusesArray[@]/$statusToIgnore})
    
  #echo "Pods:"
  kubectl get pods
  #echo "Pods-json:"
  #cat k3s-statuses.json
  echo "Array: ${statusesArray[@]}"
  #echo "Array count:"
  #echo "${#statusesArray[@]}"    

  if [ ${#statusesArray[@]} -eq 1 ]; then
    if [ "${statusesArray[0]}" = "running" ]; then
      echo "Waiting finished"
      error=$((0))
      break
    fi
  fi

  echo "Retrying...$iterator of $maxIterations"

  iterator=$((iterator+1))
  sleep 10
done

if [ $error -ne 0 ]; then
  echo "Statuses: ${statusesArray[@]}"
fi
