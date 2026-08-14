## MODIFIED Requirements

### Requirement: Boot BOM manages NES Spring Kafka modules
The Spring Boot NES dependency BOM SHALL manage Spring Kafka using the published NES patch.2 module coordinates.

#### Scenario: Spring Kafka main module is managed as NES GAV
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** dependency management contains `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka:2.9.13-nes.patch.2-SNAPSHOT`
- **AND** dependency management does not manage `org.springframework.kafka:spring-kafka` as the Spring Kafka main module.

#### Scenario: Spring Kafka test module is managed as NES GAV
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** dependency management contains `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-test:2.9.13-nes.patch.2-SNAPSHOT`
- **AND** dependency management does not manage `org.springframework.kafka:spring-kafka-test` as the Spring Kafka test module.

### Requirement: Build resolves Spring Kafka declarations to NES modules
The current Spring Boot build SHALL resolve source-level `org.springframework.kafka` dependency declarations to the corresponding NES Spring Kafka patch.2 artifacts during Gradle dependency resolution.

#### Scenario: Main module declaration is transparently substituted
- **WHEN** a project dependency requests `org.springframework.kafka:spring-kafka`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka:2.9.13-nes.patch.2-SNAPSHOT`.

#### Scenario: Test module declaration is transparently substituted
- **WHEN** a project dependency requests `org.springframework.kafka:spring-kafka-test`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-test:2.9.13-nes.patch.2-SNAPSHOT`.

### Requirement: Spring Kafka fork status is documented consistently
Spring Kafka SHALL be documented as a NES forked component using the actual published patch.2 groupId and artifactIds, not as an unforked component or as NES groupId combined with non-existent official-style artifactIds.

#### Scenario: NES GAV documentation is updated
- **WHEN** maintainers read the NES GAV mapping, Quick Start, or user manual
- **THEN** Spring Kafka appears with `cn.bjca.footstone.bpring.kafka`, `bjca-footstone-bpring-kafka`, `bjca-footstone-bpring-kafka-test`, and patch.2 SNAPSHOT where a version is shown
- **AND** examples do not use `spring-kafka` or `spring-kafka-test` under the NES groupId.

#### Scenario: Kafka BOM guidance remains accurate
- **WHEN** consumer documentation describes Spring Kafka dependency management
- **THEN** it instructs consumers to import the Spring Boot NES BOM and use the concrete Kafka modules
- **AND** it does not require `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-bom`.
