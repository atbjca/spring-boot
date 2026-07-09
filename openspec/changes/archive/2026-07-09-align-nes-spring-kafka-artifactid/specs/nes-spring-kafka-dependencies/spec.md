## MODIFIED Requirements

### Requirement: Boot BOM manages NES Spring Kafka modules
The Spring Boot NES dependency BOM SHALL manage Spring Kafka using the published NES module coordinates.

#### Scenario: Spring Kafka main module is managed as NES GAV
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** dependency management contains `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka:2.9.13-nes.patch.1-SNAPSHOT`
- **AND** dependency management does not manage `org.springframework.kafka:spring-kafka` as the Spring Kafka main module.

#### Scenario: Spring Kafka test module is managed as NES GAV
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** dependency management contains `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-test:2.9.13-nes.patch.1-SNAPSHOT`
- **AND** dependency management does not manage `org.springframework.kafka:spring-kafka-test` as the Spring Kafka test module.

### Requirement: Build resolves Spring Kafka declarations to NES modules
The current Spring Boot build SHALL resolve source-level `org.springframework.kafka` dependency declarations to the corresponding NES Spring Kafka artifacts during Gradle dependency resolution.

#### Scenario: Main module declaration is transparently substituted
- **WHEN** a project dependency requests `org.springframework.kafka:spring-kafka`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka:2.9.13-nes.patch.1-SNAPSHOT`.

#### Scenario: Test module declaration is transparently substituted
- **WHEN** a project dependency requests `org.springframework.kafka:spring-kafka-test`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-test:2.9.13-nes.patch.1-SNAPSHOT`.
