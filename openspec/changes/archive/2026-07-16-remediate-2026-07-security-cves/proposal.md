## Why

The 2026-07-16 dependency audit found that the fork's manually maintained CVE ledger had fallen behind the actual BOM: Jackson 2.21.4, Logback 1.5.34, and Tomcat 10.1.55 are affected by newly published advisories. The project needs a repeatable, documented remediation change while explicitly retaining the accepted decision to defer Log4j2 2.25.x because the default runtime uses Logback and the upgrade has known compatibility cost.

## What Changes

- Upgrade Jackson Databind/BOM from 2.21.4 to 2.21.5, covering CVE-2026-54512 through 54518 and CVE-2026-59888/59889.
- Upgrade Logback from 1.5.34 to 1.5.38, covering CVE-2026-13006 and preserving the official `ch.qos.logback` coordinates.
- Upgrade Tomcat from 10.1.55 to a release containing the CVE-2026-59083 fix (10.1.57 or newer compatible 10.1.x release).
- Assess and remediate Undertow 2.3.24.Final request-smuggling exposure (CVE-2026-28367/28368/28369), selecting the latest compatible 2.3.x release.
- Correct the vulnerability ledger: mark CVE-2024-53241 as not applicable (Linux/Xen, not Netty), and update affected/immune counts and dates.
- Record Log4j2 CVE-2026-34477/34478/34479/34480/34481 and CVE-2026-49844 as explicitly deferred because Logback is the default and 2.25.x has compatibility risks.
- Add regression/build verification and maintain the project requirement, CVE, GAV, and OpenSpec documentation.

## Capabilities

### New Capabilities

- `dependency-security-remediation`: Version remediation, CVE classification, verification, and documented risk acceptance for managed dependencies.

### Modified Capabilities

- `fork-gav-config`: Update the managed official Logback version to the remediated 1.5.x patch line.

## Impact

- Affects `gradle.properties`, `spring-boot-project/spring-boot-dependencies/build.gradle`, and dependency resolution/build verification.
- Affects generated BOM versions and downstream applications consuming the fork's dependency management.
- Updates `doc/REQUIREMENTS.md`, `doc/VULNERABILITY_REPORT.md`, `doc/CVE/`, `doc/NES_GAV_MAPPING.md` when mappings or versions change, plus OpenSpec artifacts.
- No public Java API is intentionally changed; clean build and core tests are required to detect transitive compatibility issues.
