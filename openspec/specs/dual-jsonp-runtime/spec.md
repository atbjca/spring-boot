# dual-jsonp-runtime Specification

## Purpose
Boot 2.7 同时保留 Johnzon/`javax.json.*` 遗留 JSON-P 路径，以及 NES Elasticsearch Java Client 使用的 Jakarta JSON-P 2.0.2 与 NES Barsson/`jakarta.json.*` 路径，并保证各命名空间内 provider 唯一。

## Requirements
### Requirement: Legacy and NES JSON-P namespaces coexist without cross-resolution
The Boot runtime SHALL preserve the legacy `javax.json.*` API/provider path for Boot and Johnzon users while providing Jakarta JSON-P 2.0.2 and NES Barsson for the NES Elasticsearch client, without resolving two versions of the same JSON-P GA.

#### Scenario: Both JSON-P namespaces are available
- **WHEN** a representative Boot application uses Johnzon and the NES Elasticsearch Java client
- **THEN** `javax.json.*` classes resolve from the legacy API/provider path
- **AND** `jakarta.json.*` classes resolve from Jakarta JSON-P 2.0.2 and NES Barsson

#### Scenario: Same-GA conflict is rejected
- **WHEN** dependency resolution requests multiple versions of `jakarta.json:jakarta.json-api`
- **THEN** the graph converges on the approved 2.0.2 version
- **AND** the old 1.1.x Jakarta coordinate is not used as a second runtime

### Requirement: JSON-P providers are unique within each namespace
The runtime and verification suite SHALL detect duplicate JSON-P providers within either the `javax.json` or `jakarta.json` namespace and SHALL identify the provider selected for each namespace.

#### Scenario: Provider uniqueness is verified
- **WHEN** ServiceLoader metadata and provider classes are scanned
- **THEN** exactly one supported provider is selected for the legacy `javax.json` path
- **AND** exactly one supported provider is selected for the NES `jakarta.json` path

### Requirement: The dependency-check allowlist is precise
The prohibited-dependency check SHALL allow only the `javax.json` group needed by the legacy API and SHALL continue rejecting unrelated `javax.*` dependencies.

#### Scenario: Legacy JSON API passes the check
- **WHEN** `javax.json:javax.json-api` is present in an approved module
- **THEN** the classpath check permits it

#### Scenario: Broad javax dependency remains prohibited
- **WHEN** an unrelated `javax.*` group is introduced
- **THEN** the classpath check rejects it

### Requirement: Consumers receive an explicit coordinate migration rule
Documentation SHALL state that applications importing `javax.json.*` MUST use `javax.json:javax.json-api`, even if an older dependency used the coordinate `jakarta.json:jakarta.json-api:1.1.6`; applications using `jakarta.json.*` MUST use Jakarta JSON-P 2.0.2.

#### Scenario: Legacy import migration is documented
- **WHEN** a consumer declares the old Jakarta 1.1.x coordinate but imports `javax.json.*`
- **THEN** migration guidance directs the consumer to `javax.json:javax.json-api` without changing Java imports
