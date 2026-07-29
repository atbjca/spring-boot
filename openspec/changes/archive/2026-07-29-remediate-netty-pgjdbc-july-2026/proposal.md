## Why

The fork still manages Netty 4.1.135.Final and PostgreSQL JDBC 42.7.11. Netty 4.1.136.Final is a security release that fixes CVE-2026-59901 and a large batch of additional codec/handler advisories; pgjdbc 42.7.11 remains in the affected range for CVE-2026-54291 (High). The vulnerability ledger last refreshed on 2026-07-16 still claims Netty 4.1.135 is sufficient, so BOM and documentation have drifted from current advisories.

## What Changes

- Upgrade managed Netty from 4.1.135.Final to 4.1.136.Final (remain on 4.1.x; 4.2.x stays prohibited).
- Document the full Netty 4.1.136.Final security batch in the vulnerability ledger (not only CVE-2026-59901).
- Upgrade managed PostgreSQL JDBC from 42.7.11 to 42.7.13 (covers CVE-2026-54291 fixed in 42.7.12+).
- Refresh `doc/REQUIREMENTS.md`, `doc/VULNERABILITY_REPORT.md`, and `doc/CVE/` entries with audit cutoff 2026-07-29.
- Record Tomcat CVE-2026-66299 as not applicable / immune for default Boot embed (examples-only; 10.1.58 not yet released) without changing Tomcat 10.1.57 in this change.
- Verify with `make clean build-thin` and `make test`. Release / Nexus redeploy of `3.5.15-nes.patch.1` remains out of scope.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dependency-security-remediation`: Extend managed fixed-version requirements to Netty ≥ 4.1.136.Final and PostgreSQL JDBC ≥ 42.7.13 on compatible 4.1.x / 42.7.x lines; refresh evidence-based CVE documentation and verification expectations for this batch.

## Impact

- Affects `spring-boot-project/spring-boot-dependencies/build.gradle` Netty and Postgresql library pins and generated BOM managed versions.
- Downstream apps consuming the fork BOM pick up patched Netty and pgjdbc without coordinate changes.
- Updates security/requirement documentation under `doc/`; GAV mapping only if those docs list the managed versions.
- No intentional public Java API changes; no release metadata / version bump in this change.
- Log4j2 deferral and existing Jackson/Logback/Tomcat/Undertow remediations remain unchanged.
