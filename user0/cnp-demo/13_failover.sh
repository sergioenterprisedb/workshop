#!/bin/bash
. ./config.sh

#kubectl delete pod cluster-example-2 --force
#primary=`kubectl get pod -o=jsonpath="{range .items[*]}{.metadata.name}{'\t'}{.status.podIP}{'\t'}{.metadata.labels.role}{'\n'}" | grep primary | awk '{print $1}'`
export primary=`kubectl get pod -o=jsonpath="{range .items[*]}{.metadata.name}{'\t'}{.status.podIP}{'\t'}{.metadata.labels.role}{'\n'}" | grep ${cluster_name}- | grep primary | awk '{print $1}'`

printf "${yellow}Primary instance: ${red}${primary}${reset}\n"
printf "${yellow}Deleting pvc and pod from primary instance ${primary}...${reset}\n"

printf "${green}kubectl delete pvc/${primary} pod/${primary} --force${reset}\n"
kubectl delete pvc/${primary} pod/${primary} --force

