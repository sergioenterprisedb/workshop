#!/bin/bash

# Loop to add 10 users
for i in {1..20}
do
    username="user$i"

    # Delete directory
    cd /home/ec2-user
    rm -Rf $username
  
    echo "Directory $username deleted."
done

# Delete k3d cluster
k3d cluster delete cnp-demo

