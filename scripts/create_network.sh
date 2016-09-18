#!/bin/sh
# shellcheck disable=SC1091

set -u

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd) || exit 1
# shellcheck source=./initializing.sh
. "${SCRIPTS_DIR}/function/initializing.sh"

HOME_DIR=$(cd "$(dirname "$0")"/..;pwd) || exit 1
DM_DIR="${HOME_DIR}/deployment-manager"

echo_begin_script

echo_info "# Create network."
run gcloud deployment-manager deployments create "${NETWORK}" --config "${DM_DIR}"/network.yml || exit 1

echo_end_script

exit 0
