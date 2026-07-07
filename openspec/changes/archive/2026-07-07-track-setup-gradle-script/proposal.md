## Why

The root `Makefile` invokes `./scripts/setup-gradle-local.sh` before Gradle-backed targets, but the `scripts/` directory was not tracked. Fresh checkouts therefore cannot run `make clean`, `make deploy`, or other Makefile targets without reconstructing the helper script manually.

## What Changes

- Add `scripts/setup-gradle-local.sh` to version control.
- Document that the Makefile setup target relies on this script to install local Gradle distribution zips into the wrapper cache without network access.
- Keep the script parameterized via `LOCAL_GRADLE_DIR`, `GRADLE_USER_HOME`, and `UNPACK`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fork-build-tooling`: the fork build tooling must include the local Gradle wrapper-cache setup helper referenced by the root Makefile.

## Impact

- Affected file: `scripts/setup-gradle-local.sh`.
- Affected workflow: `make setup-gradle`, and all Makefile targets that depend on `setup-gradle`.
- No Maven artifact, Java API, or Nexus publication behavior changes.
