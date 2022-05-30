#!/bin/bash 

iterator=1
maxIterations=6
error=1

while [ $iterator -le $maxIterations ] 
do
  phases=`kubectl get pods --namespace=default -o jsonpath="{.items[*].status.phase}" | tr -s '[[:space:]]' '\n' | sort | uniq` 
  readarray -t phasesArray < <(echo "$phases")
  
  kubectl get pods
  echo "Array: ${phasesArray[@]}"

  if [ ${#phasesArray[@]} -eq 1 ]; then         
    if [ "${phasesArray[0]}" = "Running" ]; then
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
  echo "Phases: ${phasesArray[@]}"
fi
