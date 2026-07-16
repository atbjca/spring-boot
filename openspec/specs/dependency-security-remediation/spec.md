### Requirement: Managed vulnerable dependencies are remediated on compatible patch lines
The project MUST manage Jackson at 2.21.5 or newer compatible 2.21.x, Logback at 1.5.37 or newer compatible 1.5.x, Tomcat at 10.1.57 or newer compatible 10.1.x, and Undertow at a 2.3.x release verified to contain the applicable request-smuggling fixes.

#### Scenario: Generated BOM contains remediated versions
- **WHEN** the Spring Boot dependency BOM POM is generated
- **THEN** its managed Jackson, Logback, Tomcat, and Undertow versions satisfy the fixed-version requirements
- **AND** the coordinates remain consistent with the project's existing official/fork GAV policy

### Requirement: Security classification is evidence based
Every CVE entry changed by this work MUST record the managed component version, authoritative affected range or vendor advisory, project applicability, status, and audit cutoff date of 2026-07-16.

#### Scenario: False-positive CVE is classified correctly
- **WHEN** CVE-2024-53241 is reviewed in the vulnerability documentation
- **THEN** it is classified as not applicable to Netty because the CVE concerns Linux/Xen
- **AND** report totals and indexes reflect the corrected classification

#### Scenario: Newly affected dependency is documented
- **WHEN** an advisory includes the project's managed version
- **THEN** the vulnerability report and a CVE detail entry identify the affected range, fixed version, remediation decision, and verification evidence

### Requirement: Log4j2 deferral is explicit and bounded
The project MUST document Log4j2 2.24.3 vulnerabilities as deferred risk rather than fixed or immune, because Logback is the default runtime and the Log4j2 2.25.x upgrade has known compatibility issues.

#### Scenario: Default logging remains Logback
- **WHEN** the default starter dependency graph is inspected
- **THEN** Logback is the default logging implementation
- **AND** `spring-boot-starter-log4j2` is not introduced into the default runtime

#### Scenario: Log4j2 reevaluation triggers are documented
- **WHEN** the Log4j2 CVE decision is recorded
- **THEN** it lists official Spring Boot compatibility, downstream Log4j2 adoption, vulnerable appender/layout usage, and severity escalation as reevaluation triggers

### Requirement: Security upgrades pass clean verification
Dependency remediation MUST pass targeted dependency/BOM checks, a clean thin build, and the project's core test gate before CVEs are marked fixed or immune.

#### Scenario: Clean build and tests succeed
- **WHEN** the dependency changes are complete
- **THEN** `make clean build-thin` completes with BUILD SUCCESSFUL
- **AND** `make test` completes with BUILD SUCCESSFUL
- **AND** generated dependency/BOM evidence shows the intended fixed versions

### Requirement: Project documentation stays synchronized
The implementation MUST update the project requirements, vulnerability overview, individual CVE records, OpenSpec artifacts, and GAV mapping when dependency versions or coordinate mappings change.

#### Scenario: Documentation reflects implemented state
- **WHEN** the change is ready for archive
- **THEN** `doc/REQUIREMENTS.md` and `doc/VULNERABILITY_REPORT.md` match the implemented versions and decisions
- **AND** applicable files under `doc/CVE/` contain current status and evidence
- **AND** `doc/NES_GAV_MAPPING.md` is updated if managed versions or mappings shown there changed
