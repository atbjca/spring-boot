## Context

The fork manages third-party versions in the Spring Boot dependency BOM and documents security posture manually. The current report was last refreshed on 2026-07-02 and misses advisories published through 2026-07-16. Current managed versions include Jackson 2.21.4, Logback 1.5.34, Tomcat 10.1.55, Undertow 2.3.24.Final, and Log4j2 2.24.3.

The default logging stack is Logback. Log4j2 is optional and a prior clean-build assessment showed that 2.25.x requires Spring Boot 3.5 source adaptations. Security remediation must therefore separate direct/default exposure from optional dependency risk and preserve evidence in the project documentation.

## Goals / Non-Goals

**Goals:**

- Move default/runtime-relevant managed dependencies to compatible fixed patch releases.
- Verify generated BOM output, dependency resolution, clean compilation, and core tests.
- Make CVE classifications reproducible from authoritative sources as of 2026-07-16.
- Record Log4j2 deferral as an explicit risk-acceptance decision with reevaluation triggers.
- Keep requirements, vulnerability reports, CVE detail files, mappings, and OpenSpec artifacts synchronized.

**Non-Goals:**

- Port Spring Boot 3.5's Log4j2 integration to Log4j2 2.25.x in this change.
- Upgrade Undertow from 2.3.x to the potentially breaking 2.4.x line.
- Change public Spring Boot APIs or replace official Logback/Tomcat coordinates with NES forks.
- Claim that a version-only scanner finding is exploitable without evaluating component usage and trigger conditions.

## Decisions

1. **Use patch-line upgrades for the default stack.** Jackson moves to 2.21.5, Logback to 1.5.38, Tomcat to 10.1.57, and Undertow to the newest compatible 2.3.x release containing relevant fixes. This minimizes compatibility risk while removing known affected versions, including CVE-2026-59889 which is fixed in Jackson 2.21.5.

2. **Treat the BOM as the source of truth.** Version changes are made through existing version properties/library declarations, followed by generated-POM and dependency-resolution checks. Direct overrides in individual modules are avoided.

3. **Defer Log4j2 with guardrails rather than silently ignoring it.** Log4j2 remains 2.24.3 because Logback is the default and 2.25.x has known build incompatibilities. Documentation records affected CVEs, non-default status, prohibited/unused vulnerable layouts and appenders, and reevaluation triggers.

4. **Correct false positives and stale classifications.** CVE-2024-53241 is classified as not applicable because it concerns Linux/Xen rather than Netty. Existing entries are recalculated from authoritative affected-version ranges instead of inherited prose.

5. **Require clean verification.** Dependency upgrades must be tested after cleaning caches/output sufficiently to avoid the misleading incremental-build behavior previously observed with Log4j2.

## Risks / Trade-offs

- **[Patch releases introduce source or test incompatibilities]** → Upgrade one library group at a time, inspect release notes, and run targeted tests before the full gate.
- **[Undertow upstream version may not clearly map to Red Hat SP backports]** → Verify upstream commits/release notes for CVE-2026-28367/28368/28369 before declaring remediation complete.
- **[Log4j2 remains version-range vulnerable for optional users]** → Keep it out of the default runtime, document unsupported vulnerable configurations, and require a separate change if downstream usage is introduced.
- **[Manual documentation drifts again]** → Record audit cutoff, current managed version, authoritative reference, affected range, and verification evidence for every status change.

## Migration Plan

1. Update managed versions and resolve any compatibility failures.
2. Run targeted dependency/BOM checks and component-specific regression tests.
3. Run clean `make build-thin` and `make test` validation.
4. Update all security and requirement documentation with results and timestamps.
5. Roll back individual version changes if a regression cannot be resolved without expanding scope; retain the CVE as deferred with evidence rather than marking it fixed.

## Open Questions

- Which exact Undertow 2.3.x release contains the upstream equivalents of the Red Hat SP2 request-smuggling fixes? This must be established from upstream commits/release notes during implementation.
- Does Tomcat 10.1.57 remain the minimum compatible fixed version at implementation time, or has a newer 10.1.x patch superseded it?
