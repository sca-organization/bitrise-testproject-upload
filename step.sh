#!/bin/bash

#=======================================
# Upload an iOS or Android file to TestProject
# Reference: https://api.testproject.io/docs/v2/
#=======================================

set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $CURRENT_DIR/utils.sh

#=======================================
# Main
#=======================================

echo_details "* apk_ipa_filepath:         $apk_ipa_filepath"
echo_details "* testproject_access_key:   $testproject_access_key"
echo_details "* testproject_project_id:   $testproject_project_id"
echo_details "* testproject_app_id:       $testproject_app_id"

validate_required_input "apk_ipa_filepath" $apk_ipa_filepath
validate_required_input "testproject_access_key" $testproject_access_key
validate_required_input "testproject_project_id" $testproject_project_id
validate_required_input "testproject_app_id" $testproject_app_id

#=================
# Get TestProject storage url
#=================
echo_info "\n\nGetting upload url\n\n"
TESTPROJECT_URL_UPLOAD=$(curl -X GET "https://api.testproject.io/v2/projects/$testproject_project_id/applications/$testproject_app_id/file/upload-link" -H "accept: application/json" -H "Authorization: $testproject_access_key" | jq -r '.url')

echo_details "TESTPROJECT_URL_UPLOAD:    $TESTPROJECT_URL_UPLOAD"

#=================
# Upload file
#=================
echo_info "\n\nUploading file\n\n"

TESTPROJECT_URL_UPLOAD_RESULT=$(curl -v --request PUT --data-binary @$apk_ipa_filepath $TESTPROJECT_URL_UPLOAD)

echo_details "TESTPROJECT_URL_UPLOAD_RESULT:    ${TESTPROJECT_URL_UPLOAD_RESULT}"

#=================
# Confirm application file was uploaded to TestProject storage
# http status code 200 means success
#=================
echo_info "\n\nConfirm upload status\n\n"

filename=$(basename ${apk_ipa_filepath})

curl -X POST "https://api.testproject.io/v2/projects/$testproject_project_id/applications/$testproject_app_id/file" -H "accept: application/json" -H "Authorization: $testproject_access_key" -H "Content-Type: application/json" -d "{ \"fileName\": \"$filename\"}" | envman add --key TESTPROJECT_URL_UPLOAD_RESULT

echo_details "* TESTPROJECT_URL_UPLOAD_RESULT:     $TESTPROJECT_URL_UPLOAD_RESULT"
