## Context

The Boot fork is already on `3.5.15-nes.patch.2-SNAPSHOT`, but its Security mapping still selects the immutable `6.5.11-nes.patch.1` release. The independently maintained Spring Security fork now exposes `6.5.11-nes.patch.2-SNAPSHOT` under the existing `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-*` coordinates. That snapshot preserves the upstream `6.5.11` runtime identity and integrates the latest approved dependency-security maintenance.

The working tree also contains completed Boot-version and ActiveMQ/Artemis changes. This change must remain separately attributable, preserve those edits, and be archived after the earlier Boot version change so the final canonical version spec retains the newer Security requirement.

## Goals / Non-Goals

**Goals:**

- Adopt `6.5.11-nes.patch.2-SNAPSHOT` through the existing single `springSecurityVersion` property.
- Prove that representative Security modules and the Security BOM resolve from configured repositories without fallback to official or patch.1 artifacts.
- Verify generated Boot BOM metadata and Security-sensitive Boot tests against the snapshot.
- Synchronize current-state requirements, GAV mapping, vulnerability baseline, and OpenSpec contracts.
- Preserve all unrelated dependency and release state.

**Non-Goals:**

- Publish or rebuild the Spring Security snapshot.
- Change Spring Security source code or its upstream runtime identity.
- Change the Boot, Framework, Authorization Server, Spring Data, Kafka, ActiveMQ, Artemis, or other managed versions.
- Publish Boot artifacts, write to Nexus, create a release commit, or create/push a Git tag.

## Decisions

1. **Change only `springSecurityVersion`.** The root resolution strategy and dependency BOM already derive all Spring Security module and BOM coordinates from this property. Adding module-specific overrides would create mixed Security versions and competing ownership.

2. **Validate snapshot availability before relying on generated metadata.** A dependency-resolution check with the target version and refreshed changing-module metadata will establish that the snapshot is consumable. Generated POM inspection alone is insufficient because it can emit a coordinate without resolving the artifact.

3. **Require both targeted and project gates.** Security auto-configuration and representative dependency graphs provide focused compatibility evidence. Because the change replaces a runtime dependency family, clean `make build-thin` and `make test` remain mandatory; `make test-gate` is required if targeted or core tests expose a wider regression or final risk review identifies insufficient coverage.

4. **Keep Security publication ownership separate.** The user confirms that the snapshot exists. This repository only consumes it; it does not invoke Security publication, Boot publication, Nexus deployment, or tag operations.

5. **Archive deltas in dependency order.** The completed `prepare-3-5-15-nes-patch-2-snapshot` change must sync before this change. This adoption change must sync afterward so its Security patch.2 snapshot requirement is the final canonical state.

## Risks / Trade-offs

- **[Snapshot metadata is cached or changes remotely]** → Resolve with refreshed dependency metadata and record the selected coordinates; reproducible RELEASE promotion remains a later task.
- **[Only some Security modules move to patch.2]** → Inspect representative module graphs plus the generated Security BOM import and search for patch.1/official Security fallbacks.
- **[The snapshot's dependency upgrades expose Boot incompatibility]** → Run Security-focused tests followed by clean build and core test gates; expand to `make test-gate` on failure or elevated risk.
- **[Archiving order reverts the canonical requirement]** → Archive the earlier Boot version change first and this adoption change last.

## Migration Plan

1. Resolve the existing Security patch.2 snapshot using a command-line property override without editing project state.
2. Change the root `springSecurityVersion` property and current-state documentation.
3. Generate and inspect Boot dependency-management metadata and representative Security dependency graphs.
4. Run targeted Security tests, clean build, core tests, and strict OpenSpec validation.
5. Archive completed changes in dependency order, then commit and push the reviewed combined result.

Rollback restores `springSecurityVersion=6.5.11-nes.patch.1` and the corresponding current-state documentation. No remote rollback is needed because this change performs no publication.

## Open Questions

None.

## Implementation Evidence

Evidence captured during the integrated Boot 3.5.15 patch.2 snapshot verification:

- `gradle.properties` contains the single active Security version source, `springSecurityVersion=6.5.11-nes.patch.2-SNAPSHOT`; Framework remains `6.2.19-nes.patch.1`, Authorization Server remains `1.5.8-nes.patch.1`, and the Boot project remains `3.5.15-nes.patch.2-SNAPSHOT`.
- The generated `spring-boot-dependencies` POM and representative dependency reports selected `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-*` and the corresponding Security BOM at `6.5.11-nes.patch.2-SNAPSHOT`, with no selected official or patch.1 Security fallback.
- Targeted Boot Security coverage passed for representative servlet, reactive, OAuth2 client/resource/authorization-server, test auto-configuration, and actuator management-security paths.
- `make clean build-thin` completed with `BUILD SUCCESSFUL`; the final complete `make test` run completed with `BUILD SUCCESSFUL in 9m 5s` against the integrated patch.2 snapshot state.
- `make test-gate` was not repeated for this adoption: targeted Security tests passed, the clean thin build passed, and the final complete core test passed. The only earlier core-test failure was the unrelated `ReactorClientHttpConnectorBuilderTests.redirectDefault(GET)` case, which passed on exact rerun before the successful complete rerun.
- `doc/REQUIREMENTS.md`, `doc/NES_GAV_MAPPING.md`, and `doc/VULNERABILITY_REPORT.md` describe the current Security snapshot without attributing publication work to this repository.
- No Security or Boot `publish`, `deploy`, remote Nexus write, release promotion, or Git tag operation was performed.
