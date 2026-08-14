# nes-spring-retry-dependencies Specification

## Purpose
Ensure Spring Boot NES manages, resolves, publishes, verifies, and documents NES Spring Retry as the sole Retry implementation while preserving Java 8 compatibility and the current excluded-project and release boundaries.

## Requirements
### Requirement: Boot BOM manages only the NES Spring Retry module
The Spring Boot NES dependency BOM SHALL manage `cn.bjca.footstone.bpring.retry:bjca-footstone-bpring-retry:1.3.4-nes.patch.1-SNAPSHOT` and MUST NOT manage `org.springframework.retry:spring-retry`.

#### Scenario: Generated BOM contains the NES Retry GAV
- **WHEN** the Spring Boot NES dependency-management POM is generated
- **THEN** dependency management contains `cn.bjca.footstone.bpring.retry:bjca-footstone-bpring-retry:1.3.4-nes.patch.1-SNAPSHOT`
- **AND** dependency management does not contain `org.springframework.retry:spring-retry`.

#### Scenario: Official Retry declarations are an explicit migration break
- **WHEN** a downstream consumer previously declared `org.springframework.retry:spring-retry` without a version
- **THEN** migration documentation requires the consumer to declare `cn.bjca.footstone.bpring.retry:bjca-footstone-bpring-retry` instead
- **AND** Java source imports remain `org.springframework.retry.*`.

### Requirement: Gradle resolves the official Retry main module to NES Retry
The Boot Gradle build SHALL precisely substitute requests for `org.springframework.retry:spring-retry` with the managed NES Retry module and MUST NOT rewrite the entire `org.springframework.retry` group.

#### Scenario: Official Retry main module is requested
- **WHEN** a project or transitive dependency requests `org.springframework.retry:spring-retry`
- **THEN** Gradle selects `cn.bjca.footstone.bpring.retry:bjca-footstone-bpring-retry:1.3.4-nes.patch.1-SNAPSHOT`.

#### Scenario: Another artifact in the official Retry group is requested
- **WHEN** dependency resolution encounters an artifact in `org.springframework.retry` whose artifactId is not `spring-retry`
- **THEN** the NES Retry substitution rule does not rewrite that artifact.

### Requirement: Published dependency metadata prevents official Retry leakage
The Boot BOM and active Starter publications SHALL exclude the known official Retry transitive paths and SHALL provide NES Retry wherever the Starter contract requires Retry at runtime.

#### Scenario: BOM-managed ecosystem components are consumed together
- **WHEN** a Maven consumer imports the generated Boot BOM and uses Spring AMQP, Spring Batch Infrastructure, and Spring Integration Core
- **THEN** their managed metadata excludes `org.springframework.retry:spring-retry`
- **AND** the resulting dependency graph contains no official Retry artifact.

#### Scenario: Batch Starter POM is generated
- **WHEN** `spring-boot-starter-batch` is published
- **THEN** its `spring-batch-core` dependency excludes `org.springframework.retry:spring-retry`
- **AND** it declares `cn.bjca.footstone.bpring.retry:bjca-footstone-bpring-retry` as a compile dependency managed by the Boot BOM.

#### Scenario: Kafka, Batch, AMQP, and Integration are resolved together
- **WHEN** a representative Maven consumer imports the generated Boot BOM and declares Kafka, Batch, AMQP, and Integration dependencies
- **THEN** exactly one Spring Retry implementation is selected
- **AND** that implementation is NES Retry patch.1 SNAPSHOT.

### Requirement: Official Spring Retry is prohibited on Boot classpaths
Every checked Boot Java classpath SHALL reject the exact official `org.springframework.retry:spring-retry` artifact while allowing the NES Retry artifact and unrelated artifacts not covered by the exact prohibition.

#### Scenario: Official Retry is present
- **WHEN** a checked compile or runtime classpath resolves `org.springframework.retry:spring-retry`
- **THEN** the prohibited dependency check fails and identifies the official GAV.

#### Scenario: NES Retry is present
- **WHEN** a checked compile or runtime classpath resolves `cn.bjca.footstone.bpring.retry:bjca-footstone-bpring-retry`
- **THEN** the prohibited dependency check passes for that artifact.

#### Scenario: Unknown official-group artifact is present
- **WHEN** a checked classpath resolves an artifact in `org.springframework.retry` whose artifactId is not `spring-retry`
- **THEN** that artifact is not rejected by the Spring Retry-specific prohibition.

### Requirement: NES Retry mitigation evidence is behavior-based and auditable
Boot validation SHALL demonstrate the fixed LRU capacity behavior, record the resolved timestamped SNAPSHOT, and classify CVE-2026-41710 as mitigated until an approved NES Retry RELEASE exists.

#### Scenario: Recently used cache entry is retained at capacity
- **WHEN** a `MapRetryContextCache` with capacity 2 receives A, B, access to A, and then C
- **THEN** inserting C does not throw `RetryCacheCapacityExceededException`
- **AND** A and C remain in the cache
- **AND** B is evicted.

#### Scenario: Retry SNAPSHOT evidence is recorded
- **WHEN** maintainers validate the Retry dependency after refreshing changing modules
- **THEN** dependency evidence identifies timestamp `20260810.073226-2` or a later artifact with equivalent verified behavior
- **AND** the selected artifact remains compatible with Java 8.

#### Scenario: Vulnerability status is published before Retry RELEASE
- **WHEN** the managed Retry coordinate still ends in `-SNAPSHOT`
- **THEN** CVE-2026-41710 is documented as “已缓解” rather than “已修复”
- **AND** documentation warns that stale caches must refresh the changing module.

### Requirement: Retry adoption does not expand excluded project scope or release scope
The change MUST preserve the current project inclusion set and MUST NOT publish a Boot, Kafka, or Retry RELEASE while internal dependencies remain SNAPSHOTs.

#### Scenario: Project settings are reviewed
- **WHEN** the change is complete
- **THEN** excluded AMQP and Integration Starters and the Boot CLI remain excluded
- **AND** no excluded project is re-enabled solely for Retry adoption.

#### Scenario: Release readiness is evaluated
- **WHEN** Boot metadata still references Kafka patch.2 SNAPSHOT or Retry patch.1 SNAPSHOT
- **THEN** the existing component release gate blocks a Boot RELEASE.
