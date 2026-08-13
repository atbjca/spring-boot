## Why

The managed HttpCore5 5.3.6 baseline is inside the authoritative affected range for CVE-2026-54399, while the previously completed Parsson 1.1.9 upgrade is now known to be above the CVE-2026-9563 fixed boundary but is still documented as unrelated proactive maintenance. The project needs to remove the HttpCore5 exposure and reconcile the newly available Parsson advisory without overstating either implementation or verification evidence.

## What Changes

- Upgrade the Boot BOM's single `HttpCore5` library from 5.3.6 to the stable compatible fix 5.4.3, covering `httpcore5`, `httpcore5-h2`, and `httpcore5-reactive` without introducing module-level overrides or a 5.5 beta.
- Verify representative Apache HttpClient5, reactive HTTP, CLI, buildpack, documentation, smoke-test, and dependency-management paths resolve the one managed HttpCore5 version and retain expected behavior.
- Add an independent CVE-2026-54399 record with the affected range, unbounded HTTP/1.1 line/header memory-exhaustion trigger, selected fix, reachability, and actual verification evidence.
- Reclassify the existing Parsson 1.1.9 upgrade as fixing CVE-2026-9563 now that authoritative advisory evidence identifies 1.0.0 through 1.1.7 as affected and 1.1.8 as fixed.
- Preserve the documented Parsson compatibility boundary introduced in 1.1.8: the default 15,000,000 parser character-consumption limit and the downstream-only `org.eclipse.parsson.maxParsingLimit` override.
- Synchronize requirements, vulnerability overview and totals, independent CVE details, VEX decisions, GAV mapping, audit evidence, and OpenSpec specifications. Release version changes, publication, and Nexus deployment remain out of scope.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dependency-security-remediation`: Require the stable HttpCore5 security baseline, recognize the already-managed Parsson version against its newly assigned CVE, and define component-focused verification and synchronized evidence requirements.

## Impact

- Changes `spring-boot-project/spring-boot-dependencies/build.gradle` only for the centrally managed HttpCore5 version; no module-level dependency override or public Spring Boot Java API change is intended.
- Affects downstream dependency management for Apache HttpCore5 modules and representative consumers including Apache HttpClient5 and reactive HTTP paths.
- Updates `doc/REQUIREMENTS.md`, `doc/VULNERABILITY_REPORT.md`, `doc/CVE/`, `doc/NES_GAV_MAPPING.md`, `scripts/security-audit/vex-decisions.json`, security-audit fixtures/tests as required, and the dependency security OpenSpec capability.
- Parsson remains at 1.1.9; its code and dependency graph do not change, but its security classification changes from proactive maintenance to verified remediation based on newly available advisory evidence.
