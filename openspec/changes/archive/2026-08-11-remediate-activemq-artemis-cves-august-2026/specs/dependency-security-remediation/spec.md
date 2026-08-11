## MODIFIED Requirements

### Requirement: Managed vulnerable dependencies are remediated on compatible patch lines
The project MUST manage Jackson at 2.21.5 or newer compatible 2.21.x, Logback at 1.5.37 or newer compatible 1.5.x, Tomcat at 10.1.57 or newer compatible 10.1.x, Undertow at a 2.3.x release verified to contain the applicable request-smuggling fixes, Netty at 4.1.136.Final or newer compatible 4.1.x (without adopting 4.2.x), PostgreSQL JDBC at 42.7.13 or newer compatible 42.7.x, ActiveMQ Classic at 6.2.8 or newer compatible 6.2.x, and ActiveMQ Artemis at 2.54.0 or newer compatible 2.x verified by the project's messaging tests.

#### Scenario: Generated BOM contains remediated versions
- **WHEN** the Spring Boot dependency BOM POM is generated
- **THEN** its managed Jackson, Logback, Tomcat, Undertow, Netty, PostgreSQL JDBC, ActiveMQ Classic, and ActiveMQ Artemis versions satisfy the fixed-version requirements
- **AND** the coordinates remain consistent with the project's existing official/fork GAV policy
- **AND** Netty remains on the 4.1.x line prohibited from 4.2.0 and newer
- **AND** ActiveMQ Classic remains on the selected 6.2.x maintenance line rather than moving to 6.3.x without a separate compatibility decision
- **AND** Artemis imports `org.apache.artemis:artemis-bom:2.54.0` and manages both `org.apache.artemis:artemis-*` and relocation-compatible `org.apache.activemq:artemis-*` modules without module-specific version overrides

### Requirement: Security classification is evidence based
Every CVE entry changed by this work MUST record the managed component version, authoritative affected range or vendor advisory, project applicability, status, and audit cutoff date of 2026-08-06.

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

#### Scenario: ActiveMQ advisory batch records module-specific applicability
- **WHEN** the ActiveMQ Classic 6.1.8 advisory batch is documented
- **THEN** the batch explicitly covers CVE-2025-66168, CVE-2026-33227, CVE-2026-34197, CVE-2026-39304, CVE-2026-40046, CVE-2026-40466, CVE-2026-41043, CVE-2026-41044, CVE-2026-42253, CVE-2026-42588, CVE-2026-45505, and CVE-2026-49270
- **AND** each assigned CVE identifies whether it affects client, broker, MQTT, web console, Jolokia, or aggregate modules
- **AND** optional starter or console usage is recorded as a trigger condition rather than used to classify an affected managed version as immune
- **AND** ActiveMQ 6.2.8 verification evidence is recorded before the findings are marked fixed

#### Scenario: Artemis advisories record protocol prerequisites
- **WHEN** CVE-2026-27446, CVE-2026-32642, and CVE-2026-40914 are documented
- **THEN** the Core federation, OpenWire, and STOMP authorization trigger conditions are recorded with the affected 2.40.0 managed version
- **AND** Artemis 2.54.0 verification evidence is recorded before all three findings are marked fixed

### Requirement: Security upgrades pass clean verification
Dependency remediation MUST pass targeted dependency/BOM checks, affected-component regression tests, a clean thin build, and the project's core Phase 1 test target before CVEs are marked fixed or immune.

#### Scenario: Clean build and tests succeed
- **WHEN** the dependency changes are complete
- **THEN** `make clean build-thin` completes with BUILD SUCCESSFUL
- **AND** `make test` completes with BUILD SUCCESSFUL
- **AND** generated dependency/BOM evidence shows Netty 4.1.136.Final, PostgreSQL JDBC 42.7.13, ActiveMQ Classic 6.2.8, and ActiveMQ Artemis 2.54.0

#### Scenario: Messaging regression tests succeed
- **WHEN** ActiveMQ Classic and ActiveMQ Artemis are upgraded
- **THEN** relevant client starter, auto-configuration, embedded-broker, Core, OpenWire, STOMP, smoke, and available Docker-backed tests complete successfully
- **AND** any skipped environment-dependent test is recorded with its prerequisite and compensating evidence

### Requirement: Project documentation stays synchronized
The implementation MUST update the project requirements, vulnerability overview, individual CVE records, OpenSpec artifacts, and GAV mapping when dependency versions or coordinate mappings change.

#### Scenario: Documentation reflects implemented state
- **WHEN** the change is ready for archive
- **THEN** `doc/REQUIREMENTS.md` and `doc/VULNERABILITY_REPORT.md` match the implemented versions and decisions
- **AND** applicable files under `doc/CVE/` contain current status, applicability, authoritative references, and verification evidence for the ActiveMQ Classic and ActiveMQ Artemis findings
- **AND** the vulnerability overview uses an audit cutoff of 2026-08-06 or later
- **AND** `doc/NES_GAV_MAPPING.md` is updated if managed versions or mappings shown there changed
