# nes-spring-kafka-dependencies Specification

## Purpose
Ensure Spring Boot NES dependency management and build-time dependency resolution use the published Spring Kafka NES coordinates, while avoiding non-existent Kafka BOM assumptions and preventing official Spring Framework coordinates from leaking into downstream classpaths.

## Requirements
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

### Requirement: Reference docs resolve a reachable Spring Kafka version
The reference documentation build SHALL resolve the `spring-kafka-version` attribute to a reachable upstream baseline version, so the generated spring.io Spring Kafka documentation link is valid.

#### Scenario: Version attribute is the upstream baseline
- **WHEN** the docs build computes the `spring-kafka-version` attribute
- **THEN** its value is the official upstream baseline `2.9.13`
- **AND** it is neither `null` nor the fork-suffixed version `2.9.13-nes.patch.1-SNAPSHOT`.

#### Scenario: Generated documentation link is reachable
- **WHEN** the `spring-kafka-docs` link in `attributes.adoc` is rendered
- **THEN** it points to `https://docs.spring.io/spring-kafka/docs/2.9.13/reference/html/`
- **AND** it does not contain the literal segment `null`.
