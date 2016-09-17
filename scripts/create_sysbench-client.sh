#!/bin/sh
# shellcheck disable=SC1091

set -u

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
HOME_DIR=$(cd "$(dirname "$0")"/..;pwd) || exit 1
TERRAFORM_DIR="${HOME_DIR}/terraform/sysbench-client"

# shellcheck source=./common.conf
. "${SCRIPTS_DIR}/conf/common.conf"
# shellcheck source=./echo_custom.sh
. "${SCRIPTS_DIR}/function/echo_custom.sh"
# shellcheck source=./set_service_account.sh
. "${SCRIPTS_DIR}/function/service_account.sh"

echo_begin_script

echo_info "# Set service account."
set_service_account || { echo_abort; exit 1; }

echo_info "# Upload startup-script."
run gsutil cp "${TERRAFORM_DIR}"/startup-script/start.sh gs://"${BUCKET_NAME}"/startup-script/start.sh || { echo_abort; exit 1; }

echo_info "# Set valiables."
run export TF_VAR_bucket_name="${CLIENT_BUCKET_NAME}"  || { echo_abort; exit 1; }
run export TF_VAR_project_id="${CLIENT_PROJECT_ID}"  || { echo_abort; exit 1; }
run export TF_VAR_credentials="${CLIENT_ACCOUNT_FILE}" || { echo_abort; exit 1; }
run export TF_VAR_source_image="${CLIENT_IMAGE_NAME}" || { echo_abort; exit 1; }
run export TF_VAR_bucket_name="${CLIENT_BUCKET_NAME}" || { echo_abort; exit 1; }
run export TF_VAR_machine_type="${CLIENT_MACHINE_TYPE:-n1-highcpu-32}" || { echo_abort; exit 1; }
run export TF_VAR_target_size="${CLIENT_TARGET_SIZE:-4}" || { echo_abort; exit 1; }
run export TF_VAR_region="${CLIENT_REGION:-asia-east1}" || { echo_abort; exit 1; }
run export TF_VAR_network_name="${CLIENT_NETWORK_NAME:-default}" || { echo_abort; exit 1; }
run export TF_VAR_zone="${CLIENT_ZONE:-asia-east1-c}" || { echo_abort; exit 1; }

echo_info "# Create VM."
terraform_cmd="terraform apply \
-state=${TERRAFORM_DIR}/terraform-template/terraform.tfstate \
${TERRAFORM_DIR}/terraform-template/"

echo_info "${terraform_cmd}"
eval "${terraform_cmd}" || { echo_abort; exit 1; }

echo_end_script

exit 0
