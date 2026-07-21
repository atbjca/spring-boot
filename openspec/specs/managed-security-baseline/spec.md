# managed-security-baseline Specification

## Purpose
TBD - created by archiving change upgrade-managed-security-baseline-2026-07. Update Purpose after archive.
## Requirements
### Requirement: Managed vulnerable components MUST use Java 8 compatible security versions
The dependency management BOM SHALL manage PostgreSQL JDBC 42.7.13, H2 2.2.220, Hazelcast 5.2.5, RabbitMQ Java Client 5.18.0, Spring LDAP 2.4.4, Sun/Jakarta Mail 1.6.8, Undertow 2.2.40.Final, and Tomcat 9.0.120 unless validation proves a target incompatible and the design is updated before completion. Derby SHALL remain at 10.14.2.0 because no Java 8 security-fix artifact is published to Maven Central.

#### Scenario: Generated Maven BOM
- **WHEN** the Spring Boot dependency-management POM is generated
- **THEN** every listed component resolves to the target version with no stale managed version

#### Scenario: Gradle dependency resolution
- **WHEN** a relevant Spring Boot module resolves its compile or test runtime classpath
- **THEN** it contains a single version of each upgraded component and that version matches the managed target

### Requirement: Security baseline upgrades MUST preserve Java 8
Every upgraded runtime component SHALL be usable on the project Java 8 baseline. Bytecode or documented compiler target MUST be checked before acceptance.

#### Scenario: Candidate requires Java 11
- **WHEN** a candidate security version has class major 55 or otherwise requires Java 11+
- **THEN** it MUST NOT replace the Java 8 managed version and the unresolved risk MUST be documented

### Requirement: Derby and HSQLDB MUST remain explicitly constrained
Derby SHALL remain at 10.14.2.0 while no Java 8 security-fix artifact is publicly available. HSQLDB SHALL remain at 2.5.2 while the project supports Java 8 because the public CVE fix line requires Java 11. Their vulnerability statuses MUST remain mitigated or deferred rather than fixed, and their use MUST be limited to trusted test/development scenarios.

#### Scenario: HSQLDB documentation audit
- **WHEN** the managed security baseline is published
- **THEN** no document claims that HSQLDB 2.5.2 contains the CVE-2022-41853 fix

#### Scenario: Derby artifact audit
- **WHEN** the managed security baseline is published
- **THEN** no document or BOM entry claims that an unpublished Derby 10.14 security artifact fixes CVE-2022-46337

### Requirement: Vulnerability status MUST reflect evidence and scope
Each upgraded or constrained component SHALL have CVE documentation that records affected versions, fix or mitigation evidence, project scope, Java compatibility, and final status. A version bump alone MUST NOT imply a fixed status when the advisory has no confirmed fix mapping.

#### Scenario: Undertow fixes strict-parser request smuggling CVEs
- **WHEN** Undertow 2.2.40.Final is managed
- **THEN** CVE-2026-28367, CVE-2026-28368, and CVE-2026-28369 are recorded as fixed by the included strict HTTP parser change

#### Scenario: Undertow multipart GET CVE remains affected
- **WHEN** official data continues to list Undertow 2.2.40.Final as affected by CVE-2026-3260 and the release diff contains no corresponding fix
- **THEN** the project records the status as deferred rather than fixed and documents required request/body/disk mitigations

### Requirement: Managed security baseline MUST pass targeted and project verification
The change SHALL validate BOM generation and run relevant tests for JDBC/databases, Hazelcast, RabbitMQ, LDAP, Mail, Undertow, and Tomcat, followed by the project's standard test gate.

#### Scenario: Upgrade batch is complete
- **WHEN** all target versions and documents are updated
- **THEN** BOM checks, targeted module tests, and the standard project gate complete without unresolved failures caused by the upgrade
