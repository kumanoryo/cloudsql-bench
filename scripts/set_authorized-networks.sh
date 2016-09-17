#!/bin/sh
# shellcheck disable=SC1091

set -u

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)

# shellcheck source=./common.conf
. "${SCRIPTS_DIR}/conf/common.conf"
# shellcheck source=./echo_custom.sh
. "${SCRIPTS_DIR}/function/echo_custom.sh"
# shellcheck source=./set_service_account.sh
. "${SCRIPTS_DIR}/function/service_account.sh"

echo_begin_script

echo_info "# Set service account."
set_service_account || { echo_abort; exit 1; }

VM_IP=$(gcloud compute instances list --project="${PROJECT_ID}" --filter='tags.items:sysbench-client' --format='table[no-heading](networkInterfaces[0].accessConfigs[0].natIP)') || { echo_abort; exit 1; }

echo_info "# Set authorized networks."
run gcloud sql instances patch "${CLOUDSQL_INSTANCE_NAME}" --project="${PROJECT_ID}" --authorized-networks "${VM_IP}" || { echo_abort; exit 1; }

echo_end_script

exit 0
