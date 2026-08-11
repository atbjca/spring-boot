## Why

The Spring Security fork now provides `6.5.11-nes.patch.2-SNAPSHOT`, containing the latest approved dependency-security maintenance while preserving the upstream 6.5.11 runtime baseline. The Boot fork must consume and verify that snapshot before its own `3.5.15-nes.patch.2-SNAPSHOT` development line can represent the current integrated security baseline.

## What Changes

- Change only `springSecurityVersion` from `6.5.11-nes.patch.1` to `6.5.11-nes.patch.2-SNAPSHOT`.
- Preserve the Boot fork version `3.5.15-nes.patch.2-SNAPSHOT`, Framework `6.2.19-nes.patch.1`, Authorization Server `1.5.8-nes.patch.1`, and all unrelated managed dependency versions.
- Verify the Security snapshot resolves from the configured repositories under the existing rebranded groupId/artifactId mapping.
- Verify generated Boot BOM metadata and representative Security dependency graphs use the patch.2 snapshot without falling back to official or patch.1 coordinates.
- Update current-state requirements, GAV mapping, and vulnerability-baseline documentation while preserving historical release evidence.
- Keep Security publication, Boot publication, Nexus writes, release promotion, and Git tags outside this change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fork-gav-config`: Adopt `6.5.11-nes.patch.2-SNAPSHOT` as the active Spring Security fork dependency while preserving all other fork/runtime version sources.
- `fork-security-gav-mapping`: Require transparent Security dependency and BOM mapping to resolve the patch.2 snapshot under the existing NES coordinates.

## Impact

- Changes one dependency-version property in `gradle.properties` and therefore the Security coordinates emitted by the generated Boot dependency-management BOM.
- Updates current-state documentation and OpenSpec requirements that describe the active Security fork version.
- Exercises repository resolution and Security-sensitive Boot tests against the new snapshot.
- Does not change Boot or Security Java APIs, publish artifacts, modify repository configuration, write to Nexus, or create release tags.
