## Why

The Boot dependency graph currently receives `org.eclipse.parsson:parsson` transitively at 1.1.7 from Yasson 3.0.4 and at 1.0.5 from the Elasticsearch Java client, while Parsson 1.1.9 is the current compatible 1.1.x release. Explicit BOM management is needed so downstream applications consistently receive the maintained JSON-P provider without forcing the broader Yasson 3.0.5 groupId migration.

## What Changes

- Add Parsson 1.1.9 to Spring Boot dependency management under its official `org.eclipse.parsson:parsson` coordinate.
- Preserve Yasson 3.0.4, Jakarta JSON API 2.1.3, Jakarta JSON Bind API 3.0.2, and all unrelated dependency versions.
- Verify generated BOM metadata and representative JSON-B test runtime graphs select Parsson 1.1.9 instead of Yasson's transitive 1.1.7.
- Update current dependency requirements, GAV mapping, and vulnerability-baseline documentation without claiming a CVE that is not present in authoritative advisory data.
- Keep publication, deployment, Nexus writes, release promotion, and Git tags outside this change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dependency-security-remediation`: Require the Boot BOM to manage the maintained Parsson 1.1.9 JSON-P provider and verify that representative JSON-B dependency graphs resolve it consistently.

## Impact

- Changes `spring-boot-project/spring-boot-dependencies/build.gradle` by adding one managed third-party library.
- Changes the generated `spring-boot-dependencies` Maven BOM to expose a `parsson.version` property and managed Parsson dependency.
- Affects downstream applications that consume Yasson or Parsson through Boot dependency management; no Boot Java API or source-code change is made, while Parsson's documented large-document parsing limit remains a downstream compatibility boundary.
- Updates project documentation and OpenSpec contracts for the managed dependency baseline.
