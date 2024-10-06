# BP-PRISMA-IMAGE-SCAN

This project enables scanning container images with Prisma. The version of script supports both token-based authentication and username-password authentication.

## Environment Variables

Users need to set the following environment variables:

- **PRISMA_TOKEN**: *(Optional)* API token for authentication with Prisma. This token is used if provided.
  
- **USERNAME**: *(Optional)* Username for Prisma authentication. Required if `PRISMA_TOKEN` is not provided.

- **PASSWORD**: *(Optional)* Password for Prisma authentication. Required if `PRISMA_TOKEN` is not provided.

- **PRISMA_URL**: *(Required)* The Prisma instance URL used for the scan.

- **IMAGE_NAME**: *(Optional)* Name of the image to be scanned. If not provided, it will be retrieved using `BP-DATA`.

- **IMAGE_TAG**: *(Optional)* Tag of the image to be scanned. If not provided, it will be retrieved using `BP-DATA`.

- **WORKSPACE**: *(Provided by BuildPiper)* The workspace directory where the codebase is located.

- **CODEBASE_DIR**: *(Provided by BuildPiper)* The directory name within `WORKSPACE` where the code is checked out.

- **SLEEP_DURATION**: *(Optional)* Duration in seconds for which the script pauses between certain steps. Default is `2` seconds.

- **BUILD_NUMBER**: *(Provided by BuildPiper)* The build number associated with the scan job.

- **ACTIVITY_SUB_TASK_CODE**: *(Provided by BuildPiper)* A code used for generating outputs, e.g., for logging or reporting purposes.

- **VALIDATION_FAILURE_ACTION**: *(Provided by BuildPiper)* Action to take if validation fails. Use `FAILURE` to mark the task as failed.

## Twistcli Binary

The `twistcli` binary is required to perform the Prisma scans. Since it cannot be pushed to this repository, please download the `twistcli` binary from your Prisma environment and place it in the root directory of this project. 

**Ensure that the binary is named `twistcli`** so it matches the script references. 

To download `twistcli`:
1. Log in to your Prisma Cloud Console.
2. Navigate to the **Compute** section.
3. Go to **Manage > System Components > Utilities**.
4. Download the `twistcli` binary for your environment.

## Setup

1. Clone the code available at [BP-PRISMA-IMAGE-SCAN](https://github.com/OT-BUILDPIPER-MARKETPLACE/BP-PRISMA-IMAGE-SCAN).

2. Build the Docker image:

   ```bash
   git submodule init
   git submodule update
   cd BP-BASE-SHELL-STEPS
   git checkout v1.0
   # Using TOKEN for authentication
   docker build -t registry.buildpiper.in/prisma-scan:0.6 .

   # Using USERNAME and PASSWORD for authentication
   docker build -t registry.buildpiper.in/prisma-scan:0.7 .

   # Supports both TOKEN or USERNAME and PASSWORD for authentication
   docker build -t registry.buildpiper.in/prisma-scan:0.8 .
   ```

3. Perform local testing:

   ```bash
   docker run -it --rm -v $PWD:/src -e PRISMA_URL="your_prisma_url" -e IMAGE_NAME="your_image_name" -e IMAGE_TAG="your_image_tag" -e PRISMA_TOKEN="your_token" -e WORKSPACE="your_workspace" -e CODEBASE_DIR="your_codebase_dir" -e BUILD_NUMBER="your_build_number" registry.buildpiper.in/prisma-scan:0.8
   ```

4. For debugging purposes:

   ```bash
   docker run -it --rm -v $PWD:/src -e PRISMA_URL="your_prisma_url" -e IMAGE_NAME="your_image_name" -e IMAGE_TAG="your_image_tag" -e PRISMA_TOKEN="your_token" -e WORKSPACE="your_workspace" -e CODEBASE_DIR="your_codebase_dir" -e BUILD_NUMBER="your_build_number" --entrypoint sh registry.buildpiper.in/prisma-scan:0.8
   ```

This README provides instructions for setting up the twistcli binary, necessary environment variables, and Docker build and testing commands. Be sure to download and name the twistcli binary appropriately to ensure smooth operation of the script.