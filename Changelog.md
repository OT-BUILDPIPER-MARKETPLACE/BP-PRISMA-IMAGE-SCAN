# Changelog

## [registry.buildpiper.in/prisma-scan:0.7-token] - Previous Version
### Features
- Basic functionality for Prisma scanning with token-based authentication.
- Initial implementation of vulnerability and compliance scan using `twistcli`.

### Known Issues
- No fallback mechanism for username/password authentication if token fails.
- Limited logging for debugging purposes.
- Scan output parsing lacked detailed breakdown of results. 


## [registry.buildpiper.in/prisma-scan:0.8] - 2024-12-12
### Added  
- Introduced logging statements to enhance script behavior traceability.  
- Improved authentication handling:  
  - Added fallback to username/password if token-based authentication fails.  
- Enhanced scan result parsing to provide a detailed breakdown of vulnerabilities and compliance issues.  
- Beautified output formatting for improved readability.  
- Consistent exit codes and error handling across different failure scenarios.  
- Created CSV reports for scan summaries and added functionality to encode and send reports to the MI server.  

### Changed  
- Transitioned from `registry.buildpiper.in/prisma-scan:0.7-token` to `registry.buildpiper.in/prisma-scan:0.8`.  
- Improved error messages for missing `twistcli` command.  
- Added checks for missing environment variables (`IMAGE_NAME`, `IMAGE_TAG`, etc.) with more descriptive logs.  

### Fixed  
- Resolved an issue where fallback to BP data (`getImageName`, `getImageTag`) lacked proper logging.  
- Fixed missing directory check and ensured the `reports` directory is created if absent.  
- Addressed an issue with CSV report generation to ensure file integrity.  

Here’s the continuation and completion of the script:

### Summary of Additions:
- **Data Push to MI Server:** Added functionality to encode scan results and push them to the MI server for metrics tracking.
- **Error Handling for MI Push:** Logs and tracks if any metrics fail to send to the MI server.
- **Temporary File Cleanup:** Ensures temporary files such as `prisma.mi` are cleaned up after execution to maintain a clean workspace.
- **Detailed Status Logging:** Enhanced feedback to indicate success or issues during data transmission to MI.

This addition ensures the script not only performs Prisma scans but also integrates with MI for centralized monitoring and reporting.

## [registry.buildpiper.in/prisma-scan:0.9] - 2024-12-20

### Added  
- Introduced logging statements to enhance script behavior traceability.  
- Improved authentication handling:  
  - Added fallback to username/password if token-based authentication fails.  
- Enhanced scan result parsing to provide a detailed breakdown of vulnerabilities and compliance issues.  
- Beautified output formatting for improved readability.  
- Consistent exit codes and error handling across different failure scenarios.  
- Created CSV reports for scan summaries and added functionality to encode and send reports to the MI server.  
- Added detailed status logging to indicate success or issues during data transmission to MI.  
- Integrated temporary file cleanup to ensure a clean workspace post-execution.  

### Changed  
- Updated the `--job` parameter in Prisma scan command from `$CODEBASE_DIR` to `$APPLICATION_NAME/$CODEBASE_DIR/$MASTER_ENV/$APPLICATION_ENV/BuildPiper`.  
- Transitioned from `registry.buildpiper.in/prisma-scan:0.8` to `registry.buildpiper.in/prisma-scan:0.9`.  
- Improved error messages for missing `twistcli` command.  
- Added checks for missing environment variables (`IMAGE_NAME`, `IMAGE_TAG`, etc.) with more descriptive logs.  

### Fixed  
- Resolved an issue where fallback to BP data (`getImageName`, `getImageTag`) lacked proper logging.  
- Fixed missing directory check and ensured the `reports` directory is created if absent.  
- Addressed an issue with CSV report generation to ensure file integrity.  

## [registry.buildpiper.in/prisma-scan:1.0] - 2025-04-22

### Added
- Updated `twistcli` version to `34.00.137` for enhanced scanning capabilities and compatibility with the latest Prisma features.

### Changed
- Transitioned from `registry.buildpiper.in/prisma-scan:0.9` to `registry.buildpiper.in/prisma-scan:1.0`.

### Fixed
- Addressed minor bugs and improved overall stability of the scanning process.