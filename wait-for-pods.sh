#!/bin/bash 

iterator=1
maxIterations=10
error=1

while [ $iterator -le $maxIterations ] 
do
  statuses=`kubectl get pods --all-namespaces -o jsonpath="{.items[*].status.phase}" | tr -s '[[:space:]]' '\n' | sort | uniq`

  readarray -t statusesArray < <(echo "$statuses")


  if [ ${#statusesArray[@]} -eq 1 ]; then
    echo "One status"
    if [ "$statuses[0]" -eq "Running" ]; then
     "Status: running"
      error=$((0))
      break
    fi
  fi

  echo "Sleeping...$iterator"

  iterator=$((iterator+1))
  sleep 1
done

if [ $error -ne 0 ]; then
  echo "Statuses: ${statusesArray[@]}"
fi
