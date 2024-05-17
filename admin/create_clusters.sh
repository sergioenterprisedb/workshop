#!/bin/bash

# Install clusters
for i in {1..15}
do
  username="user$i"
  cd ~/${username}/cnp-demo/ && ~/${username}/cnp-demo/05_install_cluster.sh
done

