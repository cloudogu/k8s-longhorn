# k8s-longhorn Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- Invalid value referenced for image in removePrivileges-job

## [v1.5.1-7] - 2024-11-18
### Added
- [#22] Helm hook that deletes an unused ClusterRoleBinding and ServiceAccount after installation/upgrade.

## [v1.5.1-6] - 2024-10-28
### Changed
- [#20] Use `ces-container-registries` secret for pulling container images as default.

## [v1.5.1-5] - 2024-09-19
### Changed
- [#18] Relicense to AGPL-3.0-only

## [v1.5.1-4] - 2024-01-03
### Changed
- [#16] The longhorn-backup-target can now be configured using an externally provided secret.

## [v1.5.1-3] - 2023-12-08
### Added
- [#14] Added component patch template file for mirroring this chart in offline environments.

### Changed
- [#14] Update makefiles and just use only the chart as yaml resources.

## [v1.5.1-2] - 2023-10-06
### Fixed
- Update makefiles to fix the release version.

## [v1.5.1-1] - 2023-10-06
### Added
- Add default values to configure the backup target #10
- Use official longhorn helm chart as dependency.

## [v1.4.1-2] - 2023-07-07
### Added
- Add additional helm chart as release artifact #8

## [v1.4.1-1] - 2023-04-05
## Changed
- Update longhorn to 1.4.1
- Set `Pod Deletion Policy When Node is Down` configuration to `delete-both-statefulset-and-deployment-pod`
  so that longhorn will delete stuck pods on a node failure #6

## Fixed
- Use correct annotations for the additional CES images #5

## [v1.3.1-4] - 2022-11-07
## Fixed
- Use correct release versions in jenkinsfile #3

## [v1.3.1-3] - 2022-11-07
### Changed
- Update `ces-build-lib` to version 1.58.0 #3

## [v1.3.1-2] - 2022-11-07
Re-Release because release workflow for version 1.3.1-1 was broken.

## [1.3.1-1] - 2022-11-07
### Added
- Add longhorn yaml manifest with additional images #1
- Use makefiles version 7.0.1
- Use jenkins pipeline to validate yaml


