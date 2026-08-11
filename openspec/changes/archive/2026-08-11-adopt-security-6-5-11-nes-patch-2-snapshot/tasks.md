## 1. Confirm Integration Scope

- [x] 1.1 Reconfirm that `springSecurityVersion` is the single Security version source and classify every non-archived patch.1 Security reference as current-state, historical evidence, or superseded canonical spec text.
- [x] 1.2 Confirm the Boot version, Framework, Authorization Server, Spring Data, Kafka, ActiveMQ, Artemis, publication configuration, Nexus state, and Git tags are outside this change.
- [x] 1.3 Resolve representative `6.5.11-nes.patch.2-SNAPSHOT` Security artifacts with a command-line property override and refreshed dependency metadata before editing project state.

## 2. Adopt the Security Snapshot

- [x] 2.1 Change only root `springSecurityVersion` from `6.5.11-nes.patch.1` to `6.5.11-nes.patch.2-SNAPSHOT`.
- [x] 2.2 Update the current Security fork version in `doc/REQUIREMENTS.md` while preserving historical requirements and release evidence.
- [x] 2.3 Update Security current-state rows and representative GAVs in `doc/NES_GAV_MAPPING.md` without changing unrelated component versions.
- [x] 2.4 Update the Security dependency baseline in `doc/VULNERABILITY_REPORT.md` without changing CVE classifications or claiming Security publication work performed by this repository.

## 3. Verify Resolution and Metadata

- [x] 3.1 Generate the `spring-boot-dependencies` Maven POM and verify the Security BOM/modules use the rebranded group/artifact names with version `6.5.11-nes.patch.2-SNAPSHOT`.
- [x] 3.2 Inspect representative Security dependency graphs and confirm core, config, web, and OAuth2 modules resolve to patch.2 snapshot without official or patch.1 fallback.
- [x] 3.3 Confirm Boot `3.5.15-nes.patch.2-SNAPSHOT`, Framework `6.2.19-nes.patch.1`, Authorization Server `1.5.8-nes.patch.1`, and unrelated managed versions remain unchanged.
- [x] 3.4 Search non-archived files for residual patch.1 Security current-state references and retain only explicit history or canonical text superseded by ordered delta sync.

## 4. Run Compatibility Gates

- [x] 4.1 Run targeted Security auto-configuration and integration tests covering representative servlet, reactive, OAuth2, and actuator paths supported by the existing test suite.
- [x] 4.2 Run `make clean build-thin` and retain `BUILD SUCCESSFUL` evidence tied to the Security patch.2 snapshot.
- [x] 4.3 Run `make test` and retain `BUILD SUCCESSFUL` evidence tied to the Security patch.2 snapshot.
- [x] 4.4 Run `make test-gate` if targeted/core tests fail or final risk review requires broader coverage; otherwise record the evidence-based reason it is not required.

## 5. Validate and Prepare Delivery

- [x] 5.1 Record implementation evidence with actual files, commands, selected Security coordinates, tests, and the absence of publish/deploy/Nexus/tag operations.
- [x] 5.2 Run `openspec validate adopt-security-6-5-11-nes-patch-2-snapshot --type change --strict` and resolve every validation error.
- [x] 5.3 Review tracked and untracked changes for single-source Security version ownership, documentation consistency, preserved user work, unchanged unrelated versions, and required archive order.
