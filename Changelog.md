# Changelog

## [registry.buildpiper.in/prisma-scan:0.7-token] - Previous Version
### Features
- Basic functionality for Prisma scanning with token-based authentication.
- Initial implementation of vulnerability and compliance scan using `twistcli`.

### Known Issues
- No fallback mechanism for username/password authentication if token fails.
- Limited logging for debugging purposes.
- Scan output parsing lacked detailed breakdown of results. 

## [registry.buildpiper.in/prisma-scan:0.8] - 2024-12-11
### Added
- Introduced logging statements to debug script behavior for better traceability.
- Improved authentication handling:
  - Added fallback for username/password if token-based authentication fails.
- Enhanced scan result parsing to include detailed breakdown of vulnerabilities and compliance issues.
- Beautified output formatting for easier readability.
- Ensured exit codes and error handling are consistent across different failure scenarios.
  
### Changed
- Transitioned from `registry.buildpiper.in/prisma-scan:0.7-token` to `registry.buildpiper.in/prisma-scan:0.8`.
- Improved the error messages for missing `twistcli` command.
- Added checks for missing environment variables (`IMAGE_NAME`, `IMAGE_TAG`, etc.) with descriptive logs.

### Fixed
- Resolved an issue where fallback to BP data (`getImageName`, `getImageTag`) was not logged properly.
- Fixed missing directory check for `reports`.
