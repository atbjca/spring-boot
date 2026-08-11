## Why

The fork is still identified as the immutable `3.5.15-nes.patch.1` release while new security and maintenance work is accumulating on the branch. Advancing to `3.5.15-nes.patch.2-SNAPSHOT` gives subsequent builds unique development coordinates without overwriting or confusing the published patch.1 release.

## What Changes

- Change the root project version from `3.5.15-nes.patch.1` to `3.5.15-nes.patch.2-SNAPSHOT` while retaining `springBootVersion=3.5.15`.
- Keep the existing Framework, Security, Authorization Server, Spring Data, and Kafka fork versions unchanged; this change advances only the Spring Boot fork version.
- Verify the Gradle project version and generated Maven publication/BOM metadata use `3.5.15-nes.patch.2-SNAPSHOT` with the existing fork groupId and artifactId mapping.
- Synchronize current-version references in `doc/REQUIREMENTS.md`, `doc/NES_GAV_MAPPING.md`, and `doc/VULNERABILITY_REPORT.md`; preserve dated historical test and archived release records.
- Keep publishing, Nexus deployment, release tagging, and release-commit creation outside this change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fork-gav-config`: Advance the active Spring Boot fork development version to `3.5.15-nes.patch.2-SNAPSHOT` while preserving the 3.5.15 runtime baseline and existing internal dependency versions.
- `fork-gav-rebranding`: Require generated/local Spring Boot fork artifacts to retain the existing rebranded GAV with the new patch.2 snapshot version.

## Impact

- Changes the version source in `gradle.properties` and therefore the version of all generated Spring Boot fork publications.
- Updates current-state documentation and OpenSpec requirements that present the active fork GAV.
- Does not change Java APIs, dependency versions, runtime behavior, publication repository configuration, Nexus contents, Git tags, or the immutable `3.5.15-nes.patch.1` release records.
