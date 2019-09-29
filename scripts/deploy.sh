#!/usr/bin/env bash
set -e

TARGET_ENV=${1:-dev}

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$( cd "${SCRIPTS_DIR}" && cd .. && pwd )"

if [[ -f "${PROJECT_DIR}/.env" ]]; then
  set -o allexport
  source "${PROJECT_DIR}/.env"
  set +o allexport
fi

if [[ -f "${PROJECT_DIR}/.env.${TARGET_ENV}" ]]; then
  set -o allexport
  source "${PROJECT_DIR}/.env.${TARGET_ENV}"
  set +o allexport
fi

cd "${PROJECT_DIR}"

echo "Deploying cloud functions to ${TARGET_ENV}"

export CLOUDSDK_CORE_DISABLE_PROMPTS=1
gcloud components update

gcloud config set account "${GOOGLE_ACCOUNT}"
gcloud config set project "${GOOGLE_PROJECT_ID}"

function deploy_python_cloud_function() {
  SOURCE_FOLDER=$1
  FUNCTION_NAME=$(basename "${SOURCE_FOLDER}")

  DEPLOY_NAME="${PROJECT_NAME}_${FUNCTION_NAME}"

  cd "${SOURCE_FOLDER}"

  pipenv lock -r

  echo "Deploying ${DEPLOY_NAME}..."
  gcloud functions deploy "${DEPLOY_NAME}" \
    --entry-point="handler" \
    --project="${GOOGLE_PROJECT_ID}" \
    --runtime=python37 \
    --trigger-http

  echo "Deployment Complete ${DEPLOY_NAME}"

  cd "${PROJECT_DIR}"
  DEPLOYED_URL=$(gcloud functions describe "${DEPLOY_NAME}" | grep url | awk '{print $2}')
}

# deploy_python_cloud_function "gcf" "handler"
FUNC_FOLDER_NAME="gcf-python"

FUNCS=`find "${PROJECT_DIR}/${FUNC_FOLDER_NAME}" -depth 1 -type d`
for FUNC_FOLDER_PATH in $FUNCS ; do
  deploy_python_cloud_function "$FUNC_FOLDER_PATH"
done
