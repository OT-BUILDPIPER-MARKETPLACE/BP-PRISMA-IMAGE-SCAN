#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/getDataFile.sh
source /opt/buildpiper/shell-functions/execute-functions.sh

TASK_STATUS=0

CODEBASE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "I'll do processing at [$CODEBASE_LOCATION]"
sleep  $SLEEP_DURATION
cd  "${CODEBASE_LOCATION}"

if [ -d "reports" ]; then
    true
else
    mkdir reports 
fi

STATUS=0
if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logInfoMessage "Image name/tag is not provided in env variable $IMAGE_NAME checking it in BP data"
    logInfoMessage "Image Name -> ${IMAGE_NAME}"
    logInfoMessage "Image Tag -> ${IMAGE_TAG}"
    IMAGE_NAME=`getImageName`
    IMAGE_TAG=`getImageTag`
fi

if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logErrorMessage "Image name/tag is not available in BP data as well please check!!!!!!"
    logInfoMessage "Image Name -> ${IMAGE_NAME}"
    logInfoMessage "Image Tag -> ${IMAGE_TAG}"
    STATUS=1
else
    logInfoMessage "I'll scan image ${IMAGE_NAME}:${IMAGE_TAG}"
    sleep  $SLEEP_DURATION
    logInfoMessage "Executing command"
    # Execute the twistcli command and save the result to a variable

# Check if twistcli is available
if ! command -v twistcli &> /dev/null; then
    logErrorMessage "twistcli command not found. Please ensure it is installed and available in the PATH."
    exit 1
fi

# Determine which authentication method to use
if [ -n "$PRISMA_TOKEN" ]; then
    logInfoMessage "Using token-based authentication"
    SCAN_RESULT=$(twistcli images scan --address "$PRISMA_URL" --build "$BUILD_NUMBER" --job "$CODEBASE_DIR" --token "$PRISMA_TOKEN" "$IMAGE_NAME:$IMAGE_TAG")
elif [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    logInfoMessage "Using username and password for authentication"
    SCAN_RESULT=$(twistcli images scan --address "$PRISMA_URL" --build "$BUILD_NUMBER" --job "$CODEBASE_DIR" --user "$USERNAME" --password "$PASSWORD" "$IMAGE_NAME:$IMAGE_TAG")
else
    logErrorMessage "Authentication credentials not provided. Please provide either PRISMA_TOKEN or both USERNAME and PASSWORD."
    exit 1
fi

    # SCAN_RESULT=$(twistcli images scan --address "$PRISMA_URL" --build "$BUILD_NUMBER" --job "$CODEBASE_DIR" --token "$PRISMA_TOKEN" "$IMAGE_NAME:$IMAGE_TAG")
    # SCAN_RESULT=$(twistcli images scan --address "$PRISMA_URL" --build "$BUILD_NUMBER" --job "$CODEBASE_DIR" --user "$USERNAME" --password "$PASSWORD" "$IMAGE_NAME:$IMAGE_TAG")
    
    logInfoMessage "Scan initiated for image ${IMAGE_NAME}:${IMAGE_TAG}, and pushed data to "$PRISMA_URL" waiting for results..."
    
    # Wait for the command to finish
    sleep $SLEEP_DURATION

    # Beautify the output when available
    echo "================= SCAN RESULT =================="
    echo "Scan Results for Image: ${IMAGE_NAME}:${IMAGE_TAG}"
    echo "-------------------------------------------------"

    # Extract vulnerabilities and compliance information from the scan result
    VULNERABILITIES=$(echo "$SCAN_RESULT" | grep -i "Vulnerabilities found")
    VULN_TOTAL=$(echo "$VULNERABILITIES" | grep -oP "(?<=total - )\d+")
    VULN_CRITICAL=$(echo "$VULNERABILITIES" | grep -oP "(?<=critical - )\d+")
    VULN_HIGH=$(echo "$VULNERABILITIES" | grep -oP "(?<=high - )\d+")
    VULN_MEDIUM=$(echo "$VULNERABILITIES" | grep -oP "(?<=medium - )\d+")
    VULN_LOW=$(echo "$VULNERABILITIES" | grep -oP "(?<=low - )\d+")

    COMPLIANCE=$(echo "$SCAN_RESULT" | grep -i "Compliance found")
    COMP_TOTAL=$(echo "$COMPLIANCE" | grep -oP "(?<=total - )\d+")
    COMP_CRITICAL=$(echo "$COMPLIANCE" | grep -oP "(?<=critical - )\d+")
    COMP_HIGH=$(echo "$COMPLIANCE" | grep -oP "(?<=high - )\d+")
    COMP_MEDIUM=$(echo "$COMPLIANCE" | grep -oP "(?<=medium - )\d+")
    COMP_LOW=$(echo "$COMPLIANCE" | grep -oP "(?<=low - )\d+")

    echo "Vulnerabilities:"
    echo "  Total: $VULN_TOTAL"
    echo "  Critical: $VULN_CRITICAL"
    echo "  High: $VULN_HIGH"
    echo "  Medium: $VULN_MEDIUM"
    echo "  Low: $VULN_LOW"
    echo "-------------------------------------------------"
    echo "Compliance:"
    echo "  Total: $COMP_TOTAL"
    echo "  Critical: $COMP_CRITICAL"
    echo "  High: $COMP_HIGH"
    echo "  Medium: $COMP_MEDIUM"
    echo "  Low: $COMP_LOW"
    echo "-------------------------------------------------"

    # Threshold checks
    if [[ "$SCAN_RESULT" =~ "Vulnerability threshold check results: PASS" ]]; then
        echo "[Vulnerability Check]: PASS"
    else
        echo "[Vulnerability Check]: FAIL"
    fi

    if [[ "$SCAN_RESULT" =~ "Compliance threshold check results: PASS" ]]; then
        echo "[Compliance Check]: PASS"
    else
        echo "[Compliance Check]: FAIL"
    fi
    echo "================================================="
fi
STATUS=`echo $?`
if [ $STATUS -eq 0 ]
then
  logInfoMessage "Congratulations prisma scan succeeded!!!"
  generateOutput ${ACTIVITY_SUB_TASK_CODE} true "Congratulations prisma scan succeeded!!!"
elif [ $VALIDATION_FAILURE_ACTION == "FAILURE" ]
  then
    logErrorMessage "Please check prisma scan failed!!!"
    generateOutput ${ACTIVITY_SUB_TASK_CODE} false "Please check prisma scan failed!!!"
    exit 1
   else
    logWarningMessage "Please check prisma scan failed!!!"
    generateOutput ${ACTIVITY_SUB_TASK_CODE} true "Please check prisma scan failed!!!"
fi