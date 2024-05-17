#!/bin/bash

# Tests
cd
for i in {1..20}
do
  username="user$i"
  cd ~/${username}/cnp-demo/
  #cd ~/${username}/cnp-demo/ && sed -i "s/cluster-example/cluster-${username}/g" config.sh
  #sed -i "s/cluster-example/cluster-${username}/g" 06*.sh
  #~/${username}/cnp-demo/07_insert_data.sh &
  ~/${username}/cnp-demo/09_upgrade.sh
  #~/${username}/cnp-demo/10_backup_cluster.sh

  # Instances
  #kubectl patch cluster "cluster-${username}"  --type='json' -p="[{'op':'replace', 'path':'/spec/instances', 'value': 3}]"
done
cd

