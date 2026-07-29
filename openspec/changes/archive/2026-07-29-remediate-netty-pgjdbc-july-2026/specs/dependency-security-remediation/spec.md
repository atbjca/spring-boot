## MODIFIED Requirements

### Requirement: Managed vulnerable dependencies are remediated on compatible patch lines
The project MUST manage Jackson at 2.21.5 or newer compatible 2.21.x, Logback at 1.5.37 or newer compatible 1.5.x, Tomcat at 10.1.57 or newer compatible 10.1.x, Undertow at a 2.3.x release verified to contain the applicable request-smuggling fixes, Netty at 4.1.136.Final or newer compatible 4.1.x (without adopting 4.2.x), and PostgreSQL JDBC at 42.7.13 or newer compatible 42.7.x.

#### Scenario: Generated BOM contains remediated versions
- **WHEN** the Spring Boot dependency BOM POM is generated
- **THEN** its managed Jackson, Logback, Tomcat, Undertow, Netty, and PostgreSQL JDBC versions satisfy the fixed-version requirements
- **AND** the coordinates remain consistent with the project's existing official/fork GAV policy
- **AND** Netty remains on the 4.1.x line prohibited from 4.2.0 and newer

### Requirement: Security classification is evidence based
Every CVE entry changed by this work MUST record the managed component version, authoritative affected range or vendor advisory, project applicability, status, and audit cutoff date of 2026-07-29.

#### Scenario: False-positive CVE is classified correctly
- **WHEN** CVE-2024-53241 is reviewed in the vulnerability documentation
- **THEN** it is classified as not applicable to Netty because the CVE concerns Linux/Xen
- **AND** report totals and indexes reflect the corrected classification

#### Scenario: Newly affected dependency is documented
- **WHEN** an advisory includes the project's managed version
- **THEN** the vulnerability report and a CVE detail entry identify the affected range, fixed version, remediation decision, and verification evidence

#### Scenario: Netty 4.1.136 security batch is documented
- **WHEN** Netty is upgraded to 4.1.136.Final
- **THEN** assigned CVE IDs from the official 4.1.136.Final security announcement are recorded as remediated
- **AND** any announcement placeholders without a public CVE ID are noted as pending identity rather than invented

#### Scenario: Tomcat examples-only advisory is classified without upgrade
- **WHEN** CVE-2026-66299 is reviewed
- **THEN** it is classified as not applicable or immune for the default Boot-embedded Tomcat runtime because it affects only the examples WebSocket chat application
- **AND** Tomcat remains on 10.1.57 until a published 10.1.x fix is deliberately adopted in a later change

### Requirement: Security upgrades pass clean verification
Dependency remediation MUST pass targeted dependency/BOM checks, a clean thin build, and the project's core Phase 1 test target before CVEs are marked fixed or immune.

#### Scenario: Clean build and tests succeed
- **WHEN** the dependency changes are complete
- **THEN** `make clean build-thin` completes with BUILD SUCCESSFUL
- **AND** `make test` completes with BUILD SUCCESSFUL
- **AND** generated dependency/BOM evidence shows Netty 4.1.136.Final and PostgreSQL JDBC 42.7.13

### Requirement: Project documentation stays synchronized
The implementation MUST update the project requirements, vulnerability overview, individual CVE records, OpenSpec artifacts, and GAV mapping when dependency versions or coordinate mappings change.

#### Scenario: Documentation reflects implemented state
- **WHEN** the change is ready for archive
- **THEN** `doc/REQUIREMENTS.md` and `doc/VULNERABILITY_REPORT.md` match the implemented versions and decisions
- **AND** applicable files under `doc/CVE/` contain current status and evidence for the Netty 4.1.136 batch and CVE-2026-54291
- **AND** `doc/NES_GAV_MAPPING.md` is updated if managed versions or mappings shown there changed

## ADDED Requirements

### Requirement: PostgreSQL JDBC channel-binding downgrade is remediated
The project MUST manage `org.postgresql:postgresql` at 42.7.13 or newer on the 42.7.x line so that CVE-2026-54291 is outside the affected range.

#### Scenario: Managed pgjdbc meets fixed version
- **WHEN** the Spring Boot dependency BOM POM is generated
- **THEN** the managed PostgreSQL JDBC version is 42.7.13 or a newer compatible 42.7.x release
- **AND** CVE-2026-54291 is recorded as fixed with authoritative affected range `>= 42.7.4, < 42.7.12`
