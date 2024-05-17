#!/bin/bash

export MINIO_PUBLIC_IP="15.237.210.27"

# Create k3d cluster
k3d cluster create cnp-demo --agents 3

# Taint
kubectl taint nodes k3d-cnp-demo-server-0 dedicated:NoSchedule

# Install Operator
kubectl apply --server-side  --force-conflicts -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.22/releases/cnpg-1.22.0.yaml
#kubectl apply --server-side  --force-conflicts -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.23/releases/cnpg-1.23.1.yaml
#sleep 20
kubectl get deploy -n cnpg-system cnpg-controller-manager -o wide

# Loop to add 10 users
for i in {1..15}
do
    username="user$i"
    password="password$i"

    cd /home/ec2-user
    mkdir $username
    cd $username

    #Copy from user0 (good template for the demo)
    cp -r /home/ec2-user/user0/cnp-demo/ /home/ec2-user/${username}
    cd cnp-demo

    # Configure cnp cluster
    echo "*** Install CloudNativePG ***"
    cp cluster-example-template.yaml cluster-example.yaml
    sed -i "s/cluster-example/cluster-${username}/g" cluster-example.yaml
    sed -i "s/192.168.1.18/${MINIO_PUBLIC_IP}/g" cluster-example-upgrade.yaml
    sed -i "s/cluster-restore/cluster-restore-${username}/g" restore.yaml

    sed -i "s/cluster-example/cluster-${username}/g" *.yaml

    mv cluster-example.yaml cluster-${username}.yaml
    mv cluster-example-13.yaml cluster-${username}-13.yaml
    mv cluster-example-template.yaml cluster-${username}-template.yaml
    mv cluster-example-upgrade-13-to-14.yaml cluster-${username}-upgrade-13-to-14.yaml
    mv cluster-example-upgrade-13-to-15.yaml cluster-${username}-upgrade-13-to-15.yaml
    mv cluster-example-upgrade.yaml cluster-${username}-upgrade.yaml

    sed -i "s/cluster-example/cluster-${username}/g" config.sh
    sed -i "s/cluster-example/cluster-${username}/g" 04*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 05*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 06*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 08*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 09*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 10*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 12*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 13*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 14*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 15*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 16*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 17*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 18*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 19*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 20*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 21*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 22*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 23*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 24*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 30*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 31*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 32*.sh
    sed -i "s/cluster-example/cluster-${username}/g" 33*.sh
    sed -i "s/MINIOIP/${MINIO_PUBLIC_IP}/g" 19_pitr_restore_line_one.sh
    #sed -i "s/MINIOIP/${MINIO_PUBLIC_IP}/g" pitr/restore.yaml
    sed -i "s/cluster-restore/cluster-restore-${username}/g" 19*.sh

    # Backup
    sed -i "s/backup-test/backup-test-${username}/g" 11_backup_describe.sh
    sed -i "s/backup-test/backup-test-${username}/g" backup.yaml
    sed -i "s/backup-test/backup-test-${username}/g" restore.yaml

done
cd /home/ec2-user

echo "*********************************************************"
echo "*** Warning:                                          ***"
echo "kubectl get deploy -n cnpg-system cnpg-controller-manager"
echo "*********************************************************"


