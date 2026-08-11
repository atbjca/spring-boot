## Why

The 2026-08-06 full-BOM security audit found that the fork still manages ActiveMQ Classic 6.1.8 and ActiveMQ Artemis 2.40.0, both of which are inside authoritative affected ranges for newly inventoried vulnerabilities. The messaging batch includes remotely exploitable code-injection and denial-of-service issues, a CISA KEV-listed ActiveMQ vulnerability, and a Critical unauthenticated Artemis federation flaw, so it should be remediated without waiting for broader dependency-coordinate work.

## What Changes

- Upgrade managed ActiveMQ Classic from 6.1.8 to 6.2.8, covering the 12 identified ActiveMQ advisories through the highest required 6.2.x fix level.
- Upgrade managed ActiveMQ Artemis from 2.40.0 to 2.54.0, covering CVE-2026-27446, CVE-2026-32642, and CVE-2026-40914; switch the BOM import to `org.apache.artemis:artemis-bom` while retaining supported `org.apache.activemq:artemis-*` module coordinates through the new BOM's relocation entries.
- Align the Artemis Docker test image from 2.53.0 to 2.54.0 so runtime verification exercises the selected fixed release.
- Verify the ActiveMQ client starter, embedded broker support, Artemis client starter, embedded Artemis support, generated BOM, and relevant smoke/integration paths against the selected versions.
- Refresh `doc/REQUIREMENTS.md`, `doc/VULNERABILITY_REPORT.md`, and individual `doc/CVE/` records with authoritative ranges, applicability, trigger conditions, fixed versions, and a 2026-08-06 audit cutoff.
- Keep release/version metadata and Nexus deployment outside this change; publication remains a separate maintainer-owned release workflow.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dependency-security-remediation`: Extend managed fixed-version requirements and verification/documentation coverage to ActiveMQ Classic 6.2.8 and ActiveMQ Artemis 2.54.0.

## Impact

- Changes the ActiveMQ and Artemis library pins, the Artemis BOM import groupId in `spring-boot-project/spring-boot-dependencies/build.gradle`, the aligned Artemis test image, and the generated dependency-management BOM.
- Downstream users of `spring-boot-starter-activemq`, `spring-boot-starter-artemis`, embedded ActiveMQ/Artemis support, or directly managed messaging modules receive newer dependency versions without intentional Spring Boot API changes.
- ActiveMQ moves from the 6.1.x to 6.2.x line and Artemis spans multiple 2.x releases, so protocol/configuration compatibility and embedded-broker behavior require targeted regression testing before the findings are marked fixed.
- Updates the project security ledger, requirements documentation, and `doc/NES_GAV_MAPPING.md` for the upstream Artemis BOM groupId migration.
