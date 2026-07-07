## Why

Downstream consumers now need the Spring Boot properties migrator under the forked BJCA GAV so application upgrades can use the same private Nexus dependency set as the rest of the Boot fork.

The module was previously excluded as part of the trimmed build surface, so `make clean deploy` could not publish `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-properties-migrator`.

## What Changes

- Re-include `spring-boot-project:spring-boot-tools:spring-boot-properties-migrator` in `settings.gradle`.
- Publish the module with the existing fork artifact naming convention:
  `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-properties-migrator:3.5.15-nes.patch.1-SNAPSHOT`.
- Keep the existing Nexus publication path and credentials model unchanged.
- Keep other previously trimmed modules excluded.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `settings-module-trim`: `spring-boot-properties-migrator` is no longer part of the explicit non-published module exclusion set.
- `nexus-publish-pipeline`: the Nexus publish pipeline must cover the properties migrator module when it is included as a deployable subproject.

## Impact

- Affected file: `settings.gradle`.
- Affected Gradle project: `:spring-boot-project:spring-boot-tools:spring-boot-properties-migrator`.
- Affected published coordinate: `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-properties-migrator`.
- No public Java API changes.
- No Nexus credential or repository URL changes.
