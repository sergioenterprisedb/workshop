#!/bin/bash

# Delete cluster
for i in {1..20}
do
  username="user$i"
  kubectl delete cluster cluster-${username}
done

