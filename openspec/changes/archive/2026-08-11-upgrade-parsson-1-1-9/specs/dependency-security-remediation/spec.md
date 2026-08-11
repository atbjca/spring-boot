## ADDED Requirements

### Requirement: Parsson JSON-P provider is explicitly managed

The project MUST manage `org.eclipse.parsson:parsson` at version 1.1.9 in the Spring Boot dependency BOM while preserving Yasson 3.0.4, Jakarta JSON API 2.1.3, and Jakarta JSON Bind API 3.0.2.

#### Scenario: Generated BOM manages Parsson 1.1.9

- **WHEN** the `spring-boot-dependencies` Maven POM is generated
- **THEN** it defines `parsson.version` as `1.1.9`
- **AND** dependency management contains `org.eclipse.parsson:parsson` using that property
- **AND** the Yasson and Jakarta JSON API versions remain unchanged

#### Scenario: Yasson transitive Parsson is upgraded consistently

- **WHEN** a representative JSON-B test runtime graph resolves `org.eclipse:yasson:3.0.4`
- **THEN** Yasson's transitive `org.eclipse.parsson:parsson:1.1.7` request resolves to `1.1.9`
- **AND** representative Elasticsearch Java client requests for Parsson 1.0.5 also resolve to 1.1.9
- **AND** the graph contains no selected Parsson 1.1.7 or alternate Parsson coordinate

### Requirement: Parsson maintenance rationale is evidence based

Project documentation MUST describe the Parsson 1.1.9 change as proactive compatible-line maintenance unless an authoritative advisory identifies an applicable vulnerability.

#### Scenario: Documentation does not invent a Parsson CVE

- **WHEN** the Parsson upgrade is documented
- **THEN** the current and previous resolved versions and the transitive Yasson path are recorded
- **AND** the documentation does not claim a CVE, affected range, or fixed vulnerability absent authoritative evidence
