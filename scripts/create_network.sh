#!/bin/sh
# shellcheck disable=SC1091

set -u

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=./initializing.sh
. "${SCRIPTS_DIR}/function/initializing.sh"

HOME_DIR=$(cd "$(dirname "$0")"/..;pwd) || exit 1
TERRAFORM_DIR="${HOME_DIR}/terraform/network"

echo_begin_script

echo_info "# Set remote tfstate file."
terraform_cmd="docker run -i -t \
-v ${TERRAFORM_DIR}/:/opt/ \
-e TF_VAR_bucket_name=${BUCKET_NAME} \
hashicorp/terraform:light \
remote config \
-backend=gcs \
-backend-config=bucket=${BUCKET_NAME} \
-backend-config=path=/opt/terraform-template/terraform.tfstate"

echo_info "${terraform_cmd}"
eval "${terraform_cmd}" || { echo_abort; exit 1; }

echo_info "# Create network."
terraform_cmd="docker run -i -t \
-v ${TERRAFORM_DIR}/:/opt/ \
-e TF_VAR_project_id=${PROJECT_ID} \
-e TF_VAR_region=${REGION} \
-e TF_VAR_bucket_name=${BUCKET_NAME} \
-e TF_VAR_network_name=${NETWORK} \
-e TF_VAR_credentials=${CLOUDSDK_CONFIG}/application_default_credentials.json \
hashicorp/terraform:light \
apply /opt/terraform-template/"

echo_info "${terraform_cmd}"
eval "${terraform_cmd}" || { echo_abort; exit 1; }

echo_end_script

exit 0
