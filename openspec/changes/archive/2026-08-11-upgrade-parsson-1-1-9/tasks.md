## 1. Confirm Scope and Baseline

- [x] 1.1 Confirm Parsson is not directly managed and that Yasson 3.0.4 currently requests Parsson 1.1.7.
- [x] 1.2 Confirm Maven Central provides Parsson 1.1.9 and authoritative advisory data does not identify an applicable Parsson 1.1.7 CVE.
- [x] 1.3 Confirm Yasson, Jakarta JSON APIs, internal fork versions, publication configuration, Nexus state, and Git tags are outside this change.

## 2. Manage Parsson 1.1.9

- [x] 2.1 Add a `Parsson` 1.1.9 library entry for `org.eclipse.parsson:parsson` to `spring-boot-dependencies`.
- [x] 2.2 Update `doc/REQUIREMENTS.md` with the explicit Parsson dependency-management requirement.
- [x] 2.3 Update `doc/NES_GAV_MAPPING.md` with the official Parsson coordinate and managed version without classifying it as a fork.
- [x] 2.4 Update `doc/VULNERABILITY_REPORT.md` with the proactive Parsson maintenance baseline and no unsupported CVE claim.

## 3. Verify BOM and Resolution

- [x] 3.1 Generate the `spring-boot-dependencies` Maven POM and verify `parsson.version=1.1.9` and the managed Parsson coordinate.
- [x] 3.2 Inspect representative JSON-B test runtime graphs and verify Yasson's Parsson 1.1.7 request selects 1.1.9.
- [x] 3.3 Confirm Yasson 3.0.4, Jakarta JSON API 2.1.3, Jakarta JSON Bind API 3.0.2, and unrelated managed versions remain unchanged.

## 4. Run Compatibility Gates

- [x] 4.1 Run focused JSON-B auto-configuration and tester tests against Parsson 1.1.9.
- [x] 4.2 Run `make clean build-thin` and retain the final result.
- [x] 4.3 Run `make test` and retain the final result, distinguishing any unrelated captured-output flake from Parsson behavior.
- [x] 4.4 Run `make test-gate` if focused/core tests fail for a potentially relevant reason or final risk review requires broader coverage; otherwise record why it is unnecessary.

## 5. Validate and Prepare Delivery

- [x] 5.1 Record implementation evidence with actual files, commands, selected coordinates, tests, advisory lookup, and the absence of publish/deploy/Nexus/tag operations.
- [x] 5.2 Run `openspec validate upgrade-parsson-1-1-9 --type change --strict` and resolve every validation error.
- [x] 5.3 Review tracked and untracked changes for scope, documentation consistency, preserved user work, and archive ordering constraints.
