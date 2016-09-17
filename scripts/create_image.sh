#!/bin/sh
# shellcheck disable=SC1091

set -u

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=./initializing.sh
. "${SCRIPTS_DIR}/function/initializing.sh"

HOME_DIR=$(cd "$(dirname "$0")"/..;pwd) || exit 1
PACKER_DIR="${HOME_DIR}/packer/sysbench-client"

echo_begin_script

echo_info "# Get source image."
source_image="$(gcloud compute images list --project="${PROJECT_ID}" --format='table[no-heading](name)' --filter family='centos-7')" || { echo_abort; exit 1; }

echo_info "# Check old image."
if [ "$(gcloud compute images list --format='table[no-heading](name)' --project="${PROJECT_ID}" | grep -c "${IMAGE_NAME}")" -ne 0 ]; then
  echo_info "# Remove old image."
  run gcloud compute images delete "${IMAGE_NAME}" --project="${PROJECT_ID}" --quiet || { echo_abort; exit 1; }
fi

echo_info "# Create image."
packer_cmd="docker run -i -t \
-v ${PACKER_DIR}/:/opt/ \
-e PK_VAR_source_image=${source_image} \
-e PK_VAR_project_id=${IMAGE_PROJECT_ID} \
-e PK_VAR_network=${IMAGE_NETWORK} \
-e PK_VAR_zone=${IMAGE_ZONE} \
-e PK_VAR_ssh_username=${IMAGE_SSH_USERNAME} \
-e PK_VAR_image_name=${IMAGE_NAME} \
-e PK_VAR_cloudsql_instance_name=${IMAGE_CLOUDSQL_INSTANCE_NAME} \
-e PK_VAR_bucket_name=${IMAGE_BUCKET_NAME} \
hashicorp/packer:light \
build /opt/packer-template.json"

echo_info "${packer_cmd}"
eval "${packer_cmd}" || { echo_abort; exit 1; }

echo_end_script

exit 0
