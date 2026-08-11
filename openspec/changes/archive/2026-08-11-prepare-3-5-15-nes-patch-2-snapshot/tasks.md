## 1. Confirm Version Scope

- [x] 1.1 Reconfirm that root `gradle.properties` is the single Spring Boot fork version source and classify every non-archived `3.5.15-nes.patch.1` reference as current-state or historical evidence.
- [x] 1.2 Confirm that Framework, Security, Authorization Server, Spring Data, Kafka, managed dependency versions, publication configuration, Nexus state, and Git tags are outside this snapshot-version change.

## 2. Advance the Snapshot Version

- [x] 2.1 Change only the root `version` property from `3.5.15-nes.patch.1` to `3.5.15-nes.patch.2-SNAPSHOT`, retaining `springBootVersion=3.5.15` and all internal dependency versions.
- [x] 2.2 Update the current fork version in `doc/REQUIREMENTS.md` without rewriting historical requirement or release evidence.
- [x] 2.3 Update the current Spring Boot fork version and representative Boot GAV in `doc/NES_GAV_MAPPING.md`, leaving other component versions unchanged.
- [x] 2.4 Update the current baseline in `doc/VULNERABILITY_REPORT.md` without changing the audit cutoff, CVE classifications, or recorded verification evidence.

## 3. Verify Version and Metadata Propagation

- [x] 3.1 Verify root and representative Spring Boot subproject Gradle properties report version `3.5.15-nes.patch.2-SNAPSHOT`, group `cn.bjca.footstone.bpring.boot`, and the existing rebranded project/artifact identity.
- [x] 3.2 Generate the `spring-boot-dependencies` Maven POM and verify its GAV uses `3.5.15-nes.patch.2-SNAPSHOT` while Framework, Security, Authorization Server, ActiveMQ, Artemis, and other managed dependency versions remain unchanged.
- [x] 3.3 Run `SpringBootVersionTests` and confirm the runtime baseline remains `3.5.15` rather than the NES snapshot version.
- [x] 3.4 Search non-archived project files for residual patch.1 current-state references and retain only explicitly historical/dataset/test-fixture occurrences.

## 4. Run Proportional Build Gates

- [x] 4.1 Run `make clean build-thin` and retain `BUILD SUCCESSFUL` evidence tied to the patch.2 snapshot version.
- [x] 4.2 Record why a second full runtime test-suite run is not required for this metadata-only change, unless version or build verification exposes a version-sensitive failure.

## 5. Validate the Completed Change

- [x] 5.1 Update the OpenSpec implementation evidence with the actual files, commands, and results, explicitly recording that no publish/deploy/tag operation occurred.
- [x] 5.2 Run `openspec validate prepare-3-5-15-nes-patch-2-snapshot --type change --strict` and resolve every validation error.
- [x] 5.3 Review the final tracked and untracked diff for single-source version ownership, documentation consistency, preserved patch.1 history, unchanged dependency versions, and absence of publication/Nexus/tag changes.
