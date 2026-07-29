## Context

The NES Spring Boot 3.5 fork manages third-party versions through `spring-boot-dependencies` library pins. After the 2026-07-16 remediation batch, Jackson 2.21.5, Logback 1.5.38, Tomcat 10.1.57, and Undertow 2.3.26.Final are already on fixed lines. Netty remains at 4.1.135.Final and PostgreSQL JDBC at 42.7.11.

Netty 4.1.136.Final (2026-07-09) is a security release covering CVE-2026-59901 (Bzip2Decoder infinite loop) plus a large batch of HTTP/HTTP2/STOMP/HAProxy/XML/OCSP/DNS advisories. The BOM already prohibits Netty `[4.2.0,)` because Reactor Netty is not ready for 4.2 on Boot 3.5.x. PostgreSQL JDBC CVE-2026-54291 (High) affects 42.7.4 through 42.7.11 and is fixed in 42.7.12+; upstream current maintenance release is 42.7.13.

Tomcat CVE-2026-66299 (Low) affects only the examples WebSocket chat application; 10.1.58 is not yet released on Maven Central. Boot embed does not ship Tomcat examples.

## Goals / Non-Goals

**Goals:**

- Move managed Netty to 4.1.136.Final and PostgreSQL JDBC to 42.7.13 via existing BOM pins.
- Record the Netty 4.1.136 security batch and CVE-2026-54291 with evidence-based classification as of 2026-07-29.
- Classify CVE-2026-66299 without upgrading Tomcat in this change.
- Verify with clean `make build-thin` and `make test`.
- Keep requirements, vulnerability report, CVE detail files, and OpenSpec artifacts synchronized.

**Non-Goals:**

- Release / Nexus redeploy of `3.5.15-nes.patch.1` (maintainer-owned outside this change; existing immutable release design unchanged).
- Upgrade Netty to 4.2.x.
- Upgrade Tomcat to 10.1.58 before it is published.
- Change Log4j2 deferral or re-open Jackson/Logback/Undertow pins.
- Run `make test-gate` as a required gate for this change (optional if time permits).
- Public Spring Boot API changes.

## Decisions

1. **Single remediation change for Netty + pgjdbc.** Both are July 2026 managed-dependency gaps with patch-line fixes and shared verification/docs workflow. Splitting would duplicate BOM/docs churn without reducing risk.

2. **Stay on Netty 4.1.136.Final, not 4.2.x.** The existing `prohibit { versionRange "[4.2.0,)" }` remains authoritative. 4.1.136 is the minimum fixed release for the 4.1 line and is available on Maven Central.

3. **Document the full Netty 4.1.136 security batch.** Ledger entries cover every assigned CVE ID from the official 4.1.136 announcement. Placeholder `CVE-2026-XXXXX` items are recorded as “announced in 4.1.136 release notes; public CVE ID pending” rather than inventing IDs. Status for assigned IDs is ✅ after BOM verification.

4. **pgjdbc target 42.7.13.** Minimum fix is 42.7.12; 42.7.13 is the current maintenance release that includes the security fix plus follow-up hardening and is what July NES guidance ships.

5. **Tomcat 10.1.57 stays; CVE-2026-66299 marked immune/not applicable for default embed.** Trigger is examples-only; fix version not published yet. Reevaluate when 10.1.58 is released.

6. **BOM pins are the source of truth.** Change `library("Netty", …)` and `library("Postgresql", …)` only; avoid module-level overrides.

7. **Verification gate matches prior remediation:** `make clean build-thin` and `make test`. Release process remains the separate `component-release` path.

## Risks / Trade-offs

- **[Netty 4.1.136 tightens HTTP/MQTT/HTTP2 validation]** → Prefer clean build + core tests; if failures appear, inspect release notes/PRs before expanding scope.
- **[Large Netty CVE list increases documentation load]** → Use a batch overview in `VULNERABILITY_REPORT.md` plus individual `doc/CVE/` files for assigned IDs; group applicability notes where trigger conditions share a codec.
- **[pgjdbc channel-binding fix may fail-closed under `channelBinding=require` with unsupported cert algorithms]** → Correct security behavior; note in CVE doc that fail-closed is intentional.
- **[Tomcat 10.1.58 arrives mid-implementation]** → Do not block this change; optionally note “newer patch available” without expanding scope unless asked.
- **[Manual ledger drifts again]** → Audit cutoff 2026-07-29; every status change records managed version, authoritative range, and verification evidence.

## Migration Plan

1. Update Netty and Postgresql library versions in `spring-boot-dependencies/build.gradle`.
2. Confirm generated BOM / dependency resolution shows 4.1.136.Final and 42.7.13.
3. Run `make clean build-thin` and `make test`; record results.
4. Update REQUIREMENTS, VULNERABILITY_REPORT, and CVE detail files; sync OpenSpec specs on archive.
5. If a regression cannot be resolved on the patch line, roll back that pin and keep the CVE deferred with evidence rather than marking fixed.

Rollback: revert the two library version lines and regenerate docs status.

## Open Questions

None blocking implementation. Optional later: whether to bump Tomcat when 10.1.58 publishes; whether a future change should require `test-gate` for dependency remediations.
