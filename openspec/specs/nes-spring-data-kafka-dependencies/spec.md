## Purpose

Ensure Spring Boot NES dependency management and Gradle dependency resolution use the published NES Spring Data and Spring Kafka coordinates where fork artifacts exist, while preserving official coordinates for unforked Spring Data modules.

## Requirements

### Requirement: Boot BOM imports the NES Spring Data BOM
The Spring Boot NES dependency BOM SHALL import the Spring Data release-train BOM using the published NES BOM coordinate, not the upstream coordinate.

#### Scenario: Spring Data BOM is imported as NES GAV
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** it imports `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2025.0.13-nes.patch.1-SNAPSHOT`
- **AND** it does not import `org.springframework.data:spring-data-bom`.

### Requirement: Build resolves forked Spring Data modules to NES artifacts
The Spring Boot build SHALL resolve source-level and transitive `org.springframework.data:spring-data-{commons,keyvalue,redis,elasticsearch}` declarations to the corresponding NES artifacts during Gradle dependency resolution, without editing any starter or source declaration.

#### Scenario: Commons declaration is transparently substituted
- **WHEN** any dependency (direct or transitive) requests `org.springframework.data:spring-data-commons`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:3.5.13-nes.patch.1-SNAPSHOT`.

#### Scenario: KeyValue declaration is transparently substituted
- **WHEN** a dependency requests `org.springframework.data:spring-data-keyvalue`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:3.5.13-nes.patch.1-SNAPSHOT`.

#### Scenario: Redis declaration is transparently substituted
- **WHEN** a dependency requests `org.springframework.data:spring-data-redis` (including via the data-redis starters)
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1-SNAPSHOT`.

#### Scenario: Transitive official commons from an unforked module is redirected
- **WHEN** any module transitively pulls `org.springframework.data:spring-data-commons`
- **THEN** the resolved commons artifact is the NES module, not the official `org.springframework.data:spring-data-commons`.

### Requirement: Elasticsearch module resolves on its own 5.5.x version line
The build SHALL resolve `org.springframework.data:spring-data-elasticsearch` to the NES Elasticsearch artifact on the independent 5.5.x version line, distinct from the 3.5.x line used by commons/keyvalue/redis.

#### Scenario: Elasticsearch declaration substituted on 5.5.x line
- **WHEN** a dependency requests `org.springframework.data:spring-data-elasticsearch`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:5.5.13-nes.patch.1-SNAPSHOT`
- **AND** the resolved version is NOT `3.5.13-nes.patch.1-SNAPSHOT`.

#### Scenario: Elasticsearch Client version aligns with the NES ES coordinate
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** the `Elasticsearch Client` library aligns its version from the NES Elasticsearch coordinate managed by the NES Spring Data BOM, not from `org.springframework.data:spring-data-elasticsearch`.

### Requirement: Build resolves Spring Kafka to NES artifacts
The Spring Boot build SHALL resolve `org.springframework.kafka:spring-kafka` and `spring-kafka-test` to the NES Kafka artifacts (changed groupId, artifactId, and version) during Gradle dependency resolution.

#### Scenario: Kafka declaration is transparently substituted
- **WHEN** a dependency requests `org.springframework.kafka:spring-kafka`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka:3.3.16-nes.patch.1-SNAPSHOT`.

#### Scenario: Kafka test artifact is transparently substituted
- **WHEN** a dependency requests `org.springframework.kafka:spring-kafka-test`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-test:3.3.16-nes.patch.1-SNAPSHOT`.

### Requirement: Only forked Spring Data modules are rewritten
The build SHALL NOT rewrite Spring Data modules other than commons, keyvalue, redis, and elasticsearch to NES coordinates, because only those are published as NES artifacts.

#### Scenario: Unforked Spring Data module keeps official coordinates
- **WHEN** a dependency requests `org.springframework.data:spring-data-jpa` (or mongodb, neo4j, cassandra, couchbase, r2dbc, relational, rest, envers, etc.)
- **THEN** the resolved artifact keeps its official `org.springframework.data` coordinate and official version.

### Requirement: Starter sources remain on official coordinates
The Spring Data starters SHALL keep their official `org.springframework.data:*` `api(...)` declarations unchanged; coordinate rewriting is performed only by Gradle resolution strategy.

#### Scenario: Redis starter source is unchanged
- **WHEN** `spring-boot-starter-data-redis/build.gradle` is inspected
- **THEN** it still declares `api("org.springframework.data:spring-data-redis")`
- **AND** the resolved artifact at build time is the NES redis module.
