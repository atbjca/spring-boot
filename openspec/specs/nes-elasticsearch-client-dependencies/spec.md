# nes-elasticsearch-client-dependencies Specification

## Purpose
Spring Boot 2.7 NES 开发线管理已验证的 NES Elasticsearch 7.17 客户端闭包：16 个生产模块、NES Java API Client、Barsson、Jakarta JSON-P 2.0.2、LZ4 替换边界，以及独立 Maven/Gradle 消费者可解析的发布元数据。

## Requirements
### Requirement: Boot BOM manages the verified NES Elasticsearch client closure
The Boot dependency BOM SHALL manage the approved NES Elasticsearch client closure at the verified SNAPSHOT versions, including the 16 production Elasticsearch modules, the NES Java API Client, NES Barsson core, Jakarta JSON-P 2.0.2, and NES support artifacts required by those clients.

#### Scenario: Production client closure uses NES coordinates
- **WHEN** the generated Boot BOM is inspected
- **THEN** every production Elasticsearch module in the approved allowlist resolves to its `cn.bjca.footstone` NES coordinate
- **AND** the Java API Client, Barsson core, Jakarta JSON-P, and support artifacts resolve to their approved NES or Jakarta coordinates

### Requirement: Unsupported upstream Elasticsearch coordinates are not managed
The Boot BOM SHALL NOT manage upstream or unsupported coordinates for the Elasticsearch Transport Client, server/test distribution artifacts, or `co.elastic.clients:elasticsearch-java` when the corresponding NES client GAV is available.

#### Scenario: Forbidden coordinates are absent
- **WHEN** generated BOM, starter POM, and Gradle metadata are scanned
- **THEN** `org.elasticsearch.client:transport`, `org.elasticsearch.plugin:transport-netty4-client`, `org.elasticsearch.distribution.integ-test-zip:elasticsearch`, and `co.elastic.clients:elasticsearch-java` are absent from managed production dependencies

### Requirement: Boot Elasticsearch modules consume NES artifacts
Boot Elasticsearch auto-configuration, actuator, test-autoconfigure, test-support, documentation, and starter modules SHALL consume the managed NES Elasticsearch closure while retaining the original `org.elasticsearch.*` source package imports.

#### Scenario: Internal modules resolve the NES closure
- **WHEN** representative internal Elasticsearch modules are inspected or resolved
- **THEN** their runtime and test graphs use the approved NES artifacts
- **AND** source compatibility is preserved for existing `org.elasticsearch.*` imports

### Requirement: LZ4 replacement behavior is explicit
The Boot BOM SHALL exclude the old `org.lz4:lz4-java` edge where required and manage `at.yawk.lz4:lz4-java:1.11.1`; the Elasticsearch starter SHALL provide the replacement explicitly for starter consumers. Direct SDE/HLRC consumers MUST receive `at.yawk.lz4:lz4-java:1.11.1` transitively from the NES Elasticsearch producer POM without the Boot starter.

#### Scenario: Starter consumer receives only the replacement LZ4
- **WHEN** a consumer uses the Elasticsearch starter
- **THEN** the resolved graph contains `at.yawk.lz4:lz4-java:1.11.1`
- **AND** it does not contain `org.lz4:lz4-java`

#### Scenario: Direct consumer boundary is visible
- **WHEN** a consumer directly depends on NES SDE or HLRC without the starter and without Boot BOM LZ4 management
- **THEN** the resolved graph contains `at.yawk.lz4:lz4-java:1.11.1`
- **AND** it does not contain `org.lz4:lz4-java`

### Requirement: NES client artifacts remain Java 8 compatible
All adopted NES client artifacts used by Boot SHALL be compatible with Java 8 and SHALL have class major version 52 or lower.

#### Scenario: Client bytecode passes Java 8 gate
- **WHEN** the adopted client JARs are inspected
- **THEN** no production class has a major version greater than 52

### Requirement: Consumers can resolve the published metadata independently
The generated Maven BOM/POM and Gradle metadata SHALL support independent Maven consumers, Gradle consumers using the dependency-management plugin, and Gradle consumers using native `platform(...)` without relying on the Boot root build's substitution rules.

#### Scenario: Independent consumers resolve NES artifacts
- **WHEN** each representative consumer resolves the BOM and Elasticsearch starter/client graph
- **THEN** all expected NES coordinates and managed versions are selected
- **AND** no root-only substitution is required
