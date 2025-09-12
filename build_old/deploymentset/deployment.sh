#!/bin/bash

# Test with command to replace application-default

# curl "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" -H "Metadata-Flavor: Google"
# curl "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email" -H "Metadata-Flavor: Google"


# Exit immediately if a command exits with a non-zero status.
set -e

# --- Input Validation ---
# Check if exactly 4 arguments were provided ($# holds the count)
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <deployment_file> <blueprint_file> <output_dir> <gcs_bucket>"
    exit 1
fi

# Assign the command-line arguments to variables for clarity
DEPLOYMENT_FILE="$1"
BLUEPRINT_FILE="$2"
OUTPUT_DIR="$3"
GCS_BUCKET="gs://$4" # The bucket name is the fourth argument

# --- Main Script ---
echo "Starting cluster deployment with gcluster..."
echo "Deployment file: ${DEPLOYMENT_FILE}"
echo "Blueprint file: ${BLUEPRINT_FILE}"
echo "Output directory: ${OUTPUT_DIR}"
echo "GCS bucket: ${GCS_BUCKET}"

# Deploy the cluster using gcluster

GOOGLE_APPLICATION_CREDENTIALS="/root/.config/gcloud/application_default_credentials.json"
gcluster deploy -d "${DEPLOYMENT_FILE}" "${BLUEPRINT_FILE}" -o "${OUTPUT_DIR}" --auto-approve

echo "Deployment complete. Copying output files to GCS bucket: ${GCS_BUCKET}"
# Recursively copy the local output directory to the specified GCS bucket
gsutil cp -r "${OUTPUT_DIR}" "${GCS_BUCKET}"

echo "Script finished successfully."
