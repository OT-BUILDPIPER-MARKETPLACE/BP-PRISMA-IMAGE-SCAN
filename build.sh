#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/getDataFile.sh
source /opt/buildpiper/shell-functions/execute-functions.sh
source /opt/buildpiper/shell-functions/mi-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh

TASK_STATUS=0

CODEBASE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "I'll do processing at [$CODEBASE_LOCATION]"
sleep  $SLEEP_DURATION
cd  "${CODEBASE_LOCATION}"

if [ ! -d "reports" ]; then
    mkdir reports 
fi

STATUS=0
if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logInfoMessage "Image name/tag is not provided in env variable $IMAGE_NAME checking it in BP data"
    IMAGE_NAME=`getImageName`
    IMAGE_TAG=`getImageTag`
    logInfoMessage "Image Name -> ${IMAGE_NAME}"
    logInfoMessage "Image Tag -> ${IMAGE_TAG}"
fi

if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_TAG" ]
then
    logErrorMessage "Image name/tag is not available in BP data as well please check!!!!!!"
    logInfoMessage "Image Name -> ${IMAGE_NAME}"
    logInfoMessage "Image Tag -> ${IMAGE_TAG}"
    STATUS=1
else
    HYPERLINK="\e]8;;${PRISMA_URL}\e\\${PRISMA_URL}\e]8;;\e\\"
    logInfoMessage "I'll scan image ${IMAGE_NAME}:${IMAGE_TAG} using Prisma URL -> ${HYPERLINK}"
    sleep  $SLEEP_DURATION
    logInfoMessage "Executing command"

    # Check if twistcli is available
    if ! command -v twistcli &> /dev/null; then
        logErrorMessage "twistcli command not found. Please ensure it is installed and available in the PATH."
        exit 1
    fi

    logInfoMessage "twistcli version"
    twistcli -v
    MASTER_ENV=`getMasterEnv`
    APPLICATION_ENV=`getProjectEnv`

    CONNECTION_SUCCESS=false

    # Attempt token-based authentication
    if [ -n "$PRISMA_TOKEN" ]; then
        logInfoMessage "Using token-based authentication"
        SCAN_RESULT=$(twistcli images scan --address "$PRISMA_URL" --build "$BUILD_NUMBER" --job "$APPLICATION_NAME/$CODEBASE_DIR/$MASTER_ENV/$APPLICATION_ENV/BuildPiper" --token "$PRISMA_TOKEN" "$IMAGE_NAME:$IMAGE_TAG" 2>&1)
        if [[ $? -eq 0 ]]; then
            CONNECTION_SUCCESS=true
        else
            logWarningMessage "Token-based authentication failed. Error: $SCAN_RESULT"
        fi
    fi

    # Attempt username and password authentication if token fails
    if [ "$CONNECTION_SUCCESS" = false ] && [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
        logInfoMessage "Falling back to username and password authentication"
        SCAN_RESULT=$(twistcli images scan --address "$PRISMA_URL" --build "$BUILD_NUMBER" --job "$APPLICATION_NAME/$CODEBASE_DIR/$MASTER_ENV/$APPLICATION_ENV/BuildPiper" --user "$USERNAME" --password "$PASSWORD" "$IMAGE_NAME:$IMAGE_TAG" 2>&1)
        if [[ $? -eq 0 ]]; then
            CONNECTION_SUCCESS=true
        else
            logWarningMessage "Username and password authentication failed."
            logErrorMessage "$SCAN_RESULT"
        fi
    fi

    # If both methods fail, exit with error
    if [ "$CONNECTION_SUCCESS" = false ]; then
        logErrorMessage "Both token-based and username/password authentication failed. Exiting..."
        exit 1
    fi

    logInfoMessage "Scan initiated for image ${IMAGE_NAME}:${IMAGE_TAG}, and pushed data to "$PRISMA_URL" waiting for results..."
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

logInfoMessage "------------------------Publishing Data on MI------------------------"

    # Generate CSV report
    echo "total,critical,high,medium,low" > reports/prisma_summary.csv
    echo "$VULN_TOTAL,$VULN_CRITICAL,$VULN_HIGH,$VULN_MEDIUM,$VULN_LOW" >> reports/prisma_summary.csv

    # Check if the CSV was created
    if [ ! -f reports/prisma_summary.csv ]; then
        logErrorMessage "Failed to create prisma_summary.csv"
        exit 1
    fi

    logInfoMessage "Summary file created: reports/prisma_summary.csv"
    cat reports/prisma_summary.csv

    # Push metrics to MI server
    METRICS=("total" "critical" "high" "medium" "low")
    VALUES=("$VULN_TOTAL" "$VULN_CRITICAL" "$VULN_HIGH" "$VULN_MEDIUM" "$VULN_LOW")

    # Display the summary
    cat reports/prisma_summary.csv

    # Encode the report file content
    export base64EncodedResponse=$(encodeFileContent reports/prisma_summary.csv)

    for i in "${!METRICS[@]}"; do
        export source_key="${METRICS[$i]}"
        export report_file_path=null
        export application=${APPLICATION_NAME}
        export environment=`getProjectEnv`
        export service=`getServiceName`                                                                             
        export organization=$ORGANIZATION
                                                                                                           
        generateMIDataJson /opt/buildpiper/data/mi.template prisma.mi
        if ! sendMIData prisma.mi ${MI_SERVER_ADDRESS}; then
            logErrorMessage "Failed to push data for ${METRICS[$i]} to MI server"
            MI_SEND_STATUS=1
        else
            logInfoMessage "Successfully sent data for ${METRICS[$i]}"
            MI_SEND_STATUS=0
        fi
    done

    # Log final status
    if [ "$MI_SEND_STATUS" -eq 0 ]; then
        logInfoMessage "Prisma scan succeeded, and all metrics were sent to the MI server successfully!"
    else
        logErrorMessage "Some metrics failed to send. Please check the MI server or JSON format."
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
