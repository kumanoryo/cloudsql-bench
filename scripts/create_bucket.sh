#!/bin/sh
# shellcheck disable=SC1091

set -u

SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=./initializing.sh
. "${SCRIPTS_DIR}/function/initializing.sh"

echo_begin_script

echo_info "# Check is bucket exists?"
is_bucket_exists=$(gsutil ls | grep -c "gs://${BUCKET_NAME}")
if [ "${is_bucket_exists}" -eq 0 ]; then
  echo_info "# Create bucket gs://${BUCKET_NAME}."
  run gsutil mb -c "${BUCKET_CLASS}" -l "${REGION}" "gs://${BUCKET_NAME}" || { echo_abort; exit 1; } 
else
  echo_info "# Bucket gs://${BUCKET_NAME} is already exists."
fi

echo_end_script

exit 0
