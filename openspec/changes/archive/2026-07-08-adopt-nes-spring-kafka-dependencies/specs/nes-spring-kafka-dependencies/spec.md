## ADDED Requirements

### Requirement: Boot BOM manages NES Spring Kafka modules
The Spring Boot NES dependency BOM SHALL manage Spring Kafka using the published NES module coordinates.

#### Scenario: Spring Kafka main module is managed as NES GAV
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** dependency management contains `cn.bjca.footstone.bpring.kafka:spring-kafka:2.9.13-nes.patch.1-SNAPSHOT`
- **AND** dependency management does not manage `org.springframework.kafka:spring-kafka` as the Spring Kafka main module.

#### Scenario: Spring Kafka test module is managed as NES GAV
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** dependency management contains `cn.bjca.footstone.bpring.kafka:spring-kafka-test:2.9.13-nes.patch.1-SNAPSHOT`
- **AND** dependency management does not manage `org.springframework.kafka:spring-kafka-test` as the Spring Kafka test module.

### Requirement: Build resolves Spring Kafka declarations to NES modules
The current Spring Boot build SHALL resolve source-level `org.springframework.kafka` dependency declarations to the corresponding NES Spring Kafka artifacts during Gradle dependency resolution.

#### Scenario: Main module declaration is transparently substituted
- **WHEN** a project dependency requests `org.springframework.kafka:spring-kafka`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.kafka:spring-kafka:2.9.13-nes.patch.1-SNAPSHOT`.

#### Scenario: Test module declaration is transparently substituted
- **WHEN** a project dependency requests `org.springframework.kafka:spring-kafka-test`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.kafka:spring-kafka-test:2.9.13-nes.patch.1-SNAPSHOT`.

### Requirement: Kafka BOM is not assumed
The change SHALL NOT introduce dependency management or user documentation that requires `bjca-footstone-bpring-kafka-bom` unless the corresponding artifact is proven to exist in the maintained Spring Kafka NES build or repository.

#### Scenario: Documentation avoids non-existent Kafka BOM
- **WHEN** GAV mapping, quick start, or user manual documentation describes Spring Kafka usage
- **THEN** it references the concrete NES modules directly
- **AND** it does not instruct users to import `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-bom`.

### Requirement: Spring Kafka fork status is documented consistently
Spring Kafka SHALL be documented as a NES forked component, not as an unforked Spring ecosystem component that requires official `org.springframework.kafka` coordinates plus manual Spring Framework fork supplements.

#### Scenario: NES GAV documentation is updated
- **WHEN** maintainers read the NES GAV mapping documentation
- **THEN** Spring Kafka appears with its NES groupId, artifactIds, and version
- **AND** outdated guidance that recommends `org.springframework.kafka:spring-kafka` for NES Boot users is removed or replaced.
