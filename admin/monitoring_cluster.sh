#!/bin/bash

kubectl_filter="\
{range .items[*]}{.metadata.name}{','}\
{.metadata.labels.cnpg\.io\/cluster}{','}\
{.items[*]}{.status.phase}{','}\
{.spec.containers[*].image}{','}\
{.items[*]}{.metadata.labels.role}{','}\
{.items[*]}{.spec.nodeName}{','}\
{.items[*]}{.metadata.annotations.cnpg\.io\/operatorVersion}{'\n'}{end}"

cluster_monitor=$(mktemp)
cluster_monitor1=$(mktemp)

echo "Instance Name,Cluster Name,Status,Image Version,Role,Node name,Operator Version" > ${cluster_monitor}

kubectl get cluster -o wide  > ${cluster_monitor}
cat ${cluster_monitor} | sort | column -s, -t > ${cluster_monitor1}

# ANSI color escape codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1;33m'
RESET='\033[0m' # Reset color to default

# Loop through each line in the file
while IFS= read -r line; do
    # Apply color to each line
    if [[ "$line" == *"STATUS"* ]]; then
        printf "%b\n" "${BOLD}${line}${RESET}"
    elif [[ "$line" == *"Cluster in healthy state"* ]]; then
        printf "%b\n" "${GREEN}${line}${RESET}"
    elif [[ "$line" == *"Setting"* ]]; then
        printf "%b\n" "${CYAN}${line}${RESET}"
    elif [[ "$line" == *"Creating"* ]]; then
        printf "%b\n" "${CYAN}${line}${RESET}"
    elif [[ "$line" == *"Waiting"* ]]; then
        printf "%b\n" "${YELLOW}${line}${RESET}"
    else
        printf "%b\n" "${RED}${line}${RESET}"
    fi
done < ${cluster_monitor1}

