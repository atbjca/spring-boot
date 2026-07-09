## ADDED Requirements

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
