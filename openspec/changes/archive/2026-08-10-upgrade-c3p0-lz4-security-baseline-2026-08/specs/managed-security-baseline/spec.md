## MODIFIED Requirements

### Requirement: Managed vulnerable components MUST use Java 8 compatible security versions
The dependency management BOM SHALL manage PostgreSQL JDBC 42.7.13, H2 2.2.220, Hazelcast 5.2.5, RabbitMQ Java Client 5.18.0, Spring LDAP 2.4.4, Sun/Jakarta Mail 1.6.8, Undertow 2.2.40.Final, Tomcat 9.0.120, Netty 4.1.136.Final, c3p0 0.14.0, and `at.yawk.lz4:lz4-java` 1.11.1 unless validation proves a target incompatible and the design is updated before completion. The repository Gradle build SHALL substitute legacy `org.lz4:lz4-java` requests with `at.yawk.lz4:lz4-java:1.11.1`. Derby SHALL remain at 10.14.2.0 because no Java 8 security-fix artifact is published to Maven Central.

#### Scenario: Generated Maven BOM
- **WHEN** the Spring Boot dependency-management POM is generated
- **THEN** every listed BOM-managed component resolves to the target version with no stale managed version

#### Scenario: Gradle dependency resolution
- **WHEN** a relevant Spring Boot module resolves its compile or test runtime classpath
- **THEN** it contains a single version of each upgraded component and that version matches the managed target

#### Scenario: Reactor Netty consumer resolves Netty
- **WHEN** WebFlux, WebClient, Actuator, or RSocket resolves Netty through the NES Reactor Netty fork
- **THEN** all Netty BOM-managed modules resolve to 4.1.136.Final with no 4.1.135.Final or older duplicate

#### Scenario: c3p0 resolves its secure mchange dependency
- **WHEN** the Spring Boot c3p0 integration resolves its runtime or test runtime classpath
- **THEN** c3p0 resolves to 0.14.0 and mchange-commons-java resolves to 0.6.0 with no older duplicate

#### Scenario: Gradle lz4 coordinate convergence
- **WHEN** Kafka and Elasticsearch dependencies are resolved together by the repository Gradle build
- **THEN** the graph contains `at.yawk.lz4:lz4-java:1.11.1` and contains no resolved `org.lz4:lz4-java` implementation

#### Scenario: Maven consumers receive the secure active fork version
- **WHEN** a Maven consumer imports the generated Spring Boot dependency-management POM and resolves Kafka Client
- **THEN** `at.yawk.lz4:lz4-java` resolves to 1.11.1
- **AND** documentation states that a separate exclusion is required for any Elasticsearch path that still declares `org.lz4:lz4-java`

#### Scenario: Updated baseline uses a distinct development version
- **WHEN** Spring Boot artifacts containing this security baseline are generated during development
- **THEN** their project version is `2.7.18-nes.patch.2-SNAPSHOT`
- **AND** independently versioned NES dependency forks retain their existing versions

### Requirement: Vulnerability status MUST reflect evidence and scope
Each upgraded or constrained component SHALL have CVE documentation that records affected versions, fix or mitigation evidence, project scope, Java compatibility, and final status. A version bump alone MUST NOT imply a fixed status when the advisory has no confirmed fix mapping.

#### Scenario: Undertow fixes strict-parser request smuggling CVEs
- **WHEN** Undertow 2.2.40.Final is managed
- **THEN** CVE-2026-28367, CVE-2026-28368, and CVE-2026-28369 are recorded as fixed by the included strict HTTP parser change

#### Scenario: Undertow multipart GET CVE remains affected
- **WHEN** official data continues to list Undertow 2.2.40.Final as affected by CVE-2026-3260 and the release diff contains no corresponding fix
- **THEN** the project records the status as deferred rather than fixed and documents required request/body/disk mitigations

#### Scenario: c3p0 and mchange CVEs use resolved artifact evidence
- **WHEN** CVE-2026-27727, CVE-2026-27830, and CVE-2026-55223 are marked fixed
- **THEN** the documents cite c3p0 0.14.0 and mchange-commons-java 0.6.0 resolution evidence
- **AND** no document claims that removing the Quartz dependency path removed all c3p0 or mchange exposure

#### Scenario: lz4 native XXHash CVE records its conditions
- **WHEN** CVE-2026-59949 is recorded in the vulnerability ledger
- **THEN** the document states that attacker influence over the array reference, offset, or length and use of JNI-backed XXHash are required
- **AND** the fixed status is based on resolution to lz4-java 1.11.1

#### Scenario: Vulnerability totals are rebuilt
- **WHEN** the vulnerability report is updated for this change
- **THEN** every status total is recalculated from the final report rows rather than incremented from the 2026-07-22 totals

### Requirement: Managed security baseline MUST pass targeted and project verification
The change SHALL validate dependency-management generation and run relevant tests for JDBC/databases, Hazelcast, RabbitMQ, LDAP, Mail, Undertow, Tomcat, c3p0, Hibernate c3p0 integration, and lz4 resolution, followed by the project's standard test gate.

#### Scenario: Upgrade batch is complete
- **WHEN** all target versions and documents are updated
- **THEN** BOM checks, targeted module tests, Java 8 verification, and the standard project gate complete without unresolved failures caused by the upgrade

#### Scenario: c3p0 supported integration remains functional
- **WHEN** c3p0 0.14.0 is used by Spring Boot's `DataSourceBuilder` and Hibernate 5.6 integration
- **THEN** supported data-source creation, configuration, connection acquisition, and shutdown tests pass

#### Scenario: lz4 resolution remains conflict-free
- **WHEN** representative Kafka and Elasticsearch classpaths and smoke tests run
- **THEN** they use lz4-java 1.11.1 without duplicate capability or linkage failures
