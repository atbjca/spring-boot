## Context

The root `gradle.properties` is the authoritative version source for every Spring Boot fork module. It currently contains the immutable release version `3.5.15-nes.patch.1`, even though additional maintenance and CVE remediation work now exists on the development branch. Current-state documentation also presents patch.1 as the active build version, while archived release and dated testing records correctly describe historical patch.1 work and must remain unchanged.

The canonical `fork-gav-config` and `fork-gav-rebranding` specifications still contain earlier snapshot examples. This change must update the active Boot snapshot contract without changing the official runtime baseline (`springBootVersion=3.5.15`) or the already selected RELEASE versions of internal Framework, Security, Authorization Server, Spring Data, and Kafka dependencies.

## Goals / Non-Goals

**Goals:**

- Make `3.5.15-nes.patch.2-SNAPSHOT` the single active Spring Boot fork development version.
- Preserve the existing fork groupId/artifactId mapping and official 3.5.15 runtime identity.
- Verify Gradle properties and generated Maven/BOM metadata use the new snapshot version.
- Synchronize current-state requirements, GAV mapping, vulnerability-report baseline, and OpenSpec requirements.
- Complete proportional local verification without publishing artifacts externally.

**Non-Goals:**

- Change any managed dependency version or internal fork dependency version.
- Create the future `3.5.15-nes.patch.2` RELEASE, release commit, or Git tag.
- Run `make deploy`, write to Nexus, or alter publication repository configuration.
- Rewrite archived OpenSpec changes or dated historical testing evidence for patch.1.

## Decisions

1. **Change only the root `version` property.** All Boot module versions derive from `gradle.properties`, so changing module build files or adding per-publication overrides would create competing version sources. The `springBootVersion` property remains `3.5.15` because it represents the official upstream runtime baseline returned by `SpringBootVersion`.

2. **Keep internal fork dependencies on their existing RELEASE versions.** This snapshot identifies new Boot-layer development; it does not imply new Framework, Security, Authorization Server, Spring Data, or Kafka builds. Advancing those versions without available artifacts was rejected because it would break dependency resolution and broaden the change.

3. **Update current-state documentation but preserve historical records.** `doc/REQUIREMENTS.md`, `doc/NES_GAV_MAPPING.md`, and the vulnerability report baseline describe the current branch and will move to patch.2-SNAPSHOT. Dated `doc/TESTING.md` results, archived changes, and the patch.1 component-release specification remain historical/immutable evidence.

4. **Verify metadata locally without publication.** Root/subproject Gradle properties and the generated dependency-management POM provide direct evidence for version, groupId, and artifactId propagation. A clean thin build verifies that the snapshot version is accepted across the build. External publication, Nexus checks, and tagging are reserved for a separate release change.

5. **Use proportional testing.** The change alters only build metadata and current-state documentation, with no Java source or dependency change. Generated metadata checks plus a clean thin build are required; rerunning the full runtime test suite is not required unless those checks expose a version-sensitive failure.

## Risks / Trade-offs

- **[A current-version reference remains on patch.1]** → Search non-archived, non-historical files for the old version and review every remaining occurrence by context.
- **[Generated publications use mixed versions]** → Inspect root and representative subproject properties plus the generated `spring-boot-dependencies` POM for the exact patch.2-SNAPSHOT GAV.
- **[The patch.1 release appears mutable]** → Do not edit archived release evidence, the patch.1 release specification, Nexus assets, or tags.
- **[A snapshot is accidentally deployed]** → Do not run publish/deploy tasks or change Nexus configuration in this change.

## Migration Plan

1. Change the root version to `3.5.15-nes.patch.2-SNAPSHOT`.
2. Update current-state documentation and the two affected capability delta specs.
3. Verify root/subproject Gradle properties and generated dependency-management metadata.
4. Run the clean thin build and strict OpenSpec validation.
5. Archive this change after review; create a separate release change when patch.2 is ready for immutable publication.

Rollback restores the root version and current-state documentation to `3.5.15-nes.patch.1`. No remote artifact or Git-tag rollback is needed because this change performs no external publication.

## Open Questions

None.

## Implementation Evidence

- `gradle.properties` is the only active Boot fork version source; `version=3.5.15-nes.patch.2-SNAPSHOT` while `springBootVersion=3.5.15` and the existing internal fork dependency versions remain unchanged. Current-state references were synchronized in `doc/REQUIREMENTS.md`, `doc/NES_GAV_MAPPING.md`, and `doc/VULNERABILITY_REPORT.md`; dated and release-history records remain unchanged.
- `./gradlew properties :spring-boot-project:spring-boot:properties --console=plain` completed successfully in 1m01s. Root and representative subproject properties reported version `3.5.15-nes.patch.2-SNAPSHOT`, group `cn.bjca.footstone.bpring.boot`, and the existing `bjca-footstone-bpring-boot-*` project identity.
- `./gradlew :spring-boot-project:spring-boot-dependencies:generatePomFileForMavenPublication --console=plain` completed successfully in 15s. The generated BOM POM reported `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-dependencies:3.5.15-nes.patch.2-SNAPSHOT`; Framework `6.2.19-nes.patch.1`, Security `6.5.11-nes.patch.1`, Authorization Server `1.5.8-nes.patch.1`, ActiveMQ `6.2.8`, and Artemis `2.54.0` were unchanged.
- `./gradlew :spring-boot-project:spring-boot:test --tests 'org.springframework.boot.SpringBootVersionTests' -x checkstyleMain -x checkstyleTest --console=plain` completed successfully in 2m05s, confirming the runtime baseline remains `3.5.15`. Gradle reported a remote-cache 403 and disabled that cache; the local compilation and test task still succeeded.
- A non-archived `rg` audit found only historical requirement/release/test evidence, canonical pre-change spec text superseded by this delta at archive time, and explicit migration/rollback wording. No unreviewed current-state patch.1 reference remains.
- `make clean build-thin` completed successfully: clean phase 31s and assemble phase 4m34s, with `BUILD SUCCESSFUL` and 828 actionable tasks. The build's `publish...ToProjectRepository` tasks are local project-repository staging performed by assemble; no external publish, deploy, Nexus write, release commit, or Git tag operation was invoked.
- A second full runtime suite is not required for this change because it modifies only version metadata and current-state documentation: no Java source or dependency coordinate was changed by this change. The shared workspace also contains separate, pre-existing ActiveMQ/Artemis CVE remediation edits; those edits were preserved and are not attributed to this change. The preceding CVE remediation verification already recorded successful `make test` and final `make test-gate` results on the applicable code/dependency baseline. The targeted `SpringBootVersionTests`, generated metadata checks, and clean thin build provide the version-sensitive evidence for this change; any failure in those checks would require expanding the test scope.
