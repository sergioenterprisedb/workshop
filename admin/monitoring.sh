#!/bin/bash

#┌──┬──┐
#│  │  │
#├──┼──┤
#│  │  │
#└──┴──┘

function colors()
{
  # ANSI color escape codes
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  WHITE='\033[0;37m'
  BOLD='\033[1;33m'
  RESET='\033[0m' # Reset color to default
}
function s()
{
len=$2 ch=' '
STRING=$1
len_w=$(echo -n $STRING | wc -m)
printf $STRING
printf '%*s' "$(($len-$len_w))" | tr ' ' "$ch"
}

function monitoring()
{
  cluster_monitor=$(mktemp)
  pod_monitor=$(mktemp)
  svc_monitor=$(mktemp)
  pvc_monitor=$(mktemp)
  
  # Cluster monitoring
  kubectl_filter="\
  {range .items[*]}{.metadata.name}{','}\
  {.metadata.labels.cnpg\.io\/cluster}{','}\
  {.items[*]}{.status.phase}{','}\
  {.spec.containers[*].image}{','}\
  {.items[*]}{.metadata.labels.role}{','}\
  {.items[*]}{.spec.nodeName}{','}\
  {.items[*]}{.metadata.annotations.cnpg\.io\/operatorVersion}{'\n'}{end}"
  kubectl get cluster -o wide  > ${cluster_monitor}

  # Pod monitoring
  kubectl_filter="\
  {range .items[*]}{.metadata.name}{','}\
  {.metadata.labels.cnpg\.io\/cluster}{','}\
  {.items[*]}{.status.phase}{','}\
  {.spec.containers[*].image}{','}\
  {.items[*]}{.metadata.labels.role}{','}\
  {.items[*]}{.spec.nodeName}{','}\
  {.items[*]}{.metadata.annotations.cnpg\.io\/operatorVersion}{'\n'}{end}"
  kubectl get pod -o=jsonpath="$kubectl_filter"  > ${pod_monitor}

  # Services monitor
  kubectl get svc | tail -n +2 > ${svc_monitor}

  # PVC monitoring
  kubectl get pvc | tail -n +2 > ${pvc_monitor}

  # Cluster
  cluster_total=`cat ${cluster_monitor} | wc -l`
  cluster_healthy=`grep "Cluster in healthy state" ${cluster_monitor} | wc -l`
  cluster_setting=`grep "Setting up primary" ${cluster_monitor} | wc -l`
  cluster_creating=`grep "Creating a new replica" ${cluster_monitor} | wc -l`
  cluster_waiting=`grep "Waiting for the instances to become active" ${cluster_monitor} | wc -l`

  # Cluster formatting
  cluster_total=`s $cluster_total 5`
  cluster_healthy=`s $cluster_healthy 5`
  cluster_setting=`s $cluster_setting 5`
  cluster_creating=`s $cluster_creating 5`
  cluster_waiting=`s $cluster_waiting 5`

  # Pods
  pod_total=`cat ${pod_monitor} | wc -l`
  pod_primary=`grep primary ${pod_monitor} | wc -l`
  pod_replica=`grep replica ${pod_monitor} | wc -l`
  pod_running=`grep Running ${pod_monitor} | wc -l`
  pod_pending=`grep Pending ${pod_monitor} | wc -l`
  pod_succeeded=`grep Succeeded ${pod_monitor} | wc -l`

  # Pod formatting
  pod_total=`s $pod_total 5`
  pod_primary=`s $pod_primary 5`
  pod_replica=`s $pod_replica 5`
  pod_running=`s $pod_running 5`
  pod_pending=`s $pod_pending 5`
  pod_succeeded=`s $pod_succeeded 5`

  # Services
  svc_total=`cat ${svc_monitor} | wc -l`

  # Services formatting
  svc_total=`s $svc_total 5`

  # PVC
  pvc_total=`cat ${pvc_monitor} | wc -l`

  # PVC formatting
  pvc_total=`s $pvc_total 5`

  #echo "${cluster_monitor}"
  # delete temp files
  rm -f ${cluster_monitor}
  rm -f ${pod_monitor}
  rm -f ${pvc_monitor} 
}

function dashboard()
{
  colors
  monitoring

  printf "┌ K8s resources ─────────────────────────────────────┐\n"
  printf "│  Clusters:  ${cluster_total}                                  │\n"
  printf "│  Pods:      ${pod_total}                                  │\n"
  printf "│  Services:  ${svc_total}                                  │\n"
  printf "│  PVC's:     ${pvc_total}                                  │\n"
  printf "└────────────────────────────────────────────────────┘\n"
  printf "\n"
  printf "┌ Clusters ──────────────────────────────────────────┐\n"
  printf "│  Cluster in healthy state: ${GREEN}${cluster_healthy}${RESET}                   │\n"
  printf "├────────────────────────────────────────────────────┤\n"
  printf "│  Setting up primary:                         ${CYAN}${cluster_setting}${RESET} │\n"
  printf "│  Creating a new replica:                     ${CYAN}${cluster_creating}${RESET} │\n"
  printf "│  Waiting for the instances to become active: ${CYAN}${cluster_waiting}${RESET} │\n"
  printf "└────────────────────────────────────────────────────┘\n"
  printf "\n"
  printf "┌ Pods ───────────────────┬──────────────────────────┐\n"
  printf "│  Pods Running:   ${CYAN}${pod_primary}${RESET}  │ Pods Primary: ${GREEN}${pod_primary}${RESET}      │\n"
  printf "│  Pods Pending:   ${RED}${pod_pending}${RESET}  │ Pods Replica: ${CYAN}${pod_replica}${RESET}      │\n"
  printf "│  Pods Succeeded: ${CYAN}${pod_succeeded}${RESET}  │                          │\n"
  printf "└─────────────────────────┴──────────────────────────┘\n"
}

# Main
dashboard
