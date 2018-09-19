#!/bin/sh

set -u

CMDNAME=$(basename "$0")
USAGE="Usage: ${CMDNAME} -h HOST [-u USER] [-p PASSWORD] [-d DATABASE] [-b BUCKET] [-t TIME]"

while getopts h:b:u:p:d:t: OPT
do
  case $OPT in
    "h" ) VALUE_HOST="$OPTARG" ;;
    "b" ) VALUE_BUCKET="$OPTARG" ;;
    "u" ) VALUE_USER="$OPTARG" ;;
    "p" ) VALUE_PASSWORD="$OPTARG" ;;
    "d" ) VALUE_DATABASE="$OPTARG" ;;
    "t" ) VALUE_MAX_TIME="$OPTARG" ;;
      * ) echo "${USAGE}" 1>&2
          exit 1 ;;
  esac
done

if [ -z "${VALUE_HOST}" ]; then
  echo "${USAGE}"
  exit 1
fi

MYSQL_IP="${VALUE_HOST}"
BUCKET_NAME="${VALUE_BUCKET:-{{ bucket_name }}}"
SYSBENCH_USER="${VALUE_USER:-sysbench}"
SYSBENCH_PASSWORD="${VALUE_PASSWORD:-sysbench}"
SYSBENCH_DB="${VALUE_DATABASE:-sbtest}"
MAX_TIME="${VALUE_MAX_TIME:-600}"

vm_host_array=$(gcloud compute instances list --format json | jq -r ' .[] | select( .tags.items[] == "sysbench-client") | .name')

for vm_host in ${vm_host_array} ;  do
  gcloud compute instances "${vm_host}" sh /srv/sysbench/read-heavy.sh -h "${MYSQL_IP}" -b "${BUCKET_NAME}" -u "${SYSBENCH_USER}" -p "${SYSBENCH_PASSWORD}" -d "${SYSBENCH_DB}" -t "${MAX_TIME}" &
done;

wait;

