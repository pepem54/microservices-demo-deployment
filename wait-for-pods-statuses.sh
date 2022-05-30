#!/bin/bash 

iterator=1
maxIterations=10
error=1

while [ $iterator -le $maxIterations ] 
do
  kubectl get pods --all-namespaces -o jsonpath="{.items[*].status.containerStatuses[0].state}" | tr -s '[[:space:]]' '\n' > k3s-statuses.json
  statuses=`jq -r 'keys[]' k3s-statuses.json | uniq`
  readarray -t statusesArray < <(echo "$statuses")  
    
  #echo "Pods:"
  kubectl get pods
  #echo "Pods-json:"
  #cat k3s-statuses.json
  echo "Array:"
  echo "${statusesArray[@]}"
  #echo "Array count:"
  #echo "${#statusesArray[@]}"
  #echo "First element:"
  #echo "${statusesArray[0]}"

  if [ ${#statusesArray[@]} -eq 1 ]; then
    echo "X:"
    echo "${statusesArray[0]}"
    if [ "${statusesArray[0]}" = "Running" ]; then
      echo "Waiting finished"
      error=$((0))
      break
    fi
  fi

  echo "Sleeping...$iterator of $maxIterations"

  iterator=$((iterator+1))
  sleep 10
done

if [ $error -ne 0 ]; then
  echo "Statuses: ${statusesArray[@]}"
fi
