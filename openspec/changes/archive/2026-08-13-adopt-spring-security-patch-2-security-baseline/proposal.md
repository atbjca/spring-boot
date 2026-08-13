## Why

Spring Boot 2.7 NES still manages the immutable Spring Security `5.8.16-nes.patch.1`, while the maintained Security fork has published `5.8.16-nes.patch.2-SNAPSHOT` with seven applicable 2026 CVE backports and hardened Java 8 consumer metadata. Boot must adopt and verify that candidate without relying only on repository-local Gradle substitution or overstating a SNAPSHOT as a formal release.

## What Changes

- Advance the Boot development line's managed Spring Security version to `5.8.16-nes.patch.2-SNAPSHOT` while retaining patch.1 as the previous immutable release identity.
- Verify the existing Boot dependency-management POM imports the patch.2 NES Security BOM and that Gradle requests for official Spring Security modules resolve to the corresponding NES modules.
- Validate the published contract with minimal independent Maven and Gradle consumers; reuse the Security producer's CVE and Java 8 evidence instead of duplicating its full test suite, while still exercising the Boot-managed graph on a real Java 8 runtime or equivalent bytecode gate.
- Restore the existing Spring Security 5.8 test adaptations for the moved OAuth2 resource-server and SAML filter classes so Boot tests inspect the filters actually installed in the chain rather than deprecated compatibility stubs.
- Evaluate the mixed Boot graph in which SendGrid contributes `bcprov-jdk15on:1.70` while Security SAML/Crypto uses Bouncy Castle `jdk18on:1.84`; establish and verify an explicit exclusion, upgrade, or documented compatibility boundary before claiming graph convergence.
- Synchronize only the affected current-version, GAV, vulnerability-status, upgrade-history, and verification records. Keep patch.1 release examples historical, and do not present patch.2-SNAPSHOT as a RELEASE.
- Require a separate Security patch.2 release/tag and a RELEASE-only Boot metadata check before any formal Boot release may depend on patch.2.

## Capabilities

### New Capabilities

- `nes-spring-security-dependencies`: Defines Boot BOM import, Gradle coordinate mapping, independent consumer verification, Java 8 compatibility, mixed Bouncy Castle graph handling, and SNAPSHOT/RELEASE boundaries for the NES Spring Security fork.
- `spring-security-2026-security-baseline`: Defines the seven applicable 2026 CVE dispositions, Boot integration regression coverage, Security 5.8 test-class migration handling, and evidence-backed documentation requirements.

### Modified Capabilities

None. Existing `component-release` requirements already forbid internal SNAPSHOT dependencies in a formal Boot RELEASE, and existing managed-security requirements already require evidence-backed Java 8 compatibility.

## Impact

- Dependency management: `gradle.properties`, the existing `spring-boot-dependencies` Security BOM import, root Spring Security substitution, and generated Maven/Gradle publication metadata.
- Tests: build/BOM contract tests, Security servlet/reactive/OAuth2/SAML integration tests, and minimal Maven/Gradle Java 8 consumer smoke tests.
- Dependency graph: Security modules and their Bouncy Castle, OpenSAML, XMLSec, Woodstox, Guava, Commons Collections, and Xerces constraints; the SendGrid `bcprov-jdk15on` path requires an explicit decision.
- Documentation: current component identity, GAV mapping, component upgrade history, seven CVE records, vulnerability totals/statuses, and actual verification evidence. User-facing SNAPSHOT examples change only if this change explicitly supports SNAPSHOT trial consumption.
- Release coordination: Boot development may consume the verified snapshot, but formal Boot release preparation remains blocked until Security `5.8.16-nes.patch.2` is Nexus-verified and tagged.
