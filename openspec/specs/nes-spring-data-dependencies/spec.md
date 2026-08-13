# nes-spring-data-dependencies Specification

## Purpose
TBD - created by archiving change adopt-nes-spring-data-dependencies. Update Purpose after archive.
## Requirements
### Requirement: Boot BOM imports the NES Spring Data BOM
The Spring Boot NES dependency BOM SHALL import the Spring Data release-train BOM using the published NES BOM coordinate, not the upstream coordinate. The managed version SHALL be `2021.2.18-nes.patch.2-SNAPSHOT`.

#### Scenario: Spring Data BOM is imported as the patch.2 NES GAV
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** it imports `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.2-SNAPSHOT`
- **AND** it does not import `org.springframework.data:spring-data-bom`.

### Requirement: Build resolves Spring Data commons and keyvalue to NES modules
The Spring Boot build SHALL resolve source-level `org.springframework.data:spring-data-commons` and `org.springframework.data:spring-data-keyvalue` declarations to the corresponding NES artifacts during Gradle dependency resolution.

#### Scenario: Commons declaration is transparently substituted
- **WHEN** any dependency (direct or transitive) requests `org.springframework.data:spring-data-commons`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:2.7.18-nes.patch.1-SNAPSHOT`.

#### Scenario: KeyValue declaration is transparently substituted
- **WHEN** a dependency requests `org.springframework.data:spring-data-keyvalue`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:2.7.18-nes.patch.1-SNAPSHOT`.

#### Scenario: Transitive official commons from an unforked module is redirected
- **WHEN** an unforked module such as `org.springframework.data:spring-data-redis` transitively pulls `org.springframework.data:spring-data-commons`
- **THEN** the resolved commons artifact is the NES module, not the official `org.springframework.data:spring-data-commons:2.7.18`.

### Requirement: Spring Data commons/keyvalue CVEs are documented as fixed
The remediation ledger SHALL record that Spring Data Commons CVE-2026-41711 / 41716 / 41721 and Spring Data KeyValue CVE-2026-41719 are fixed via the NES fork artifacts consumed by this project.

#### Scenario: Commons DoS CVEs are recorded as fixed
- **WHEN** a maintainer reads `doc/VULNERABILITY_REPORT.md` and `doc/CVE/`
- **THEN** CVE-2026-41711, CVE-2026-41716, CVE-2026-41721 each have a dedicated document
- **AND** they are listed with status fixed, attributed to the `spring-data-commons-2.7` NES fork.

#### Scenario: KeyValue CVE is upgraded from immune to fixed
- **WHEN** a maintainer reads the CVE-2026-41719 document
- **THEN** its status is fixed via the `spring-data-keyvalue-2.7` NES fork, with the prior "unused module" reasoning retained as defense-in-depth
- **AND** the vulnerability report counts reflect the move (fixed +1, immune −1).

### Requirement: Spring Data fork boundary is documented consistently
NES GAV mapping documentation SHALL describe the Spring Data fork boundary accurately: BOM, commons, keyvalue, redis, and elasticsearch are forked; all other Spring Data modules remain official. The BOM and Elasticsearch entries SHALL identify the patch.2 SNAPSHOT line.

#### Scenario: GAV mapping documents the Spring Data boundary
- **WHEN** maintainers read the NES GAV mapping documentation
- **THEN** Spring Data BOM, commons, keyvalue, redis, and elasticsearch appear with their NES coordinates and versions, including BOM `2021.2.18-nes.patch.2-SNAPSHOT`, redis `2.7.18-nes.patch.1-SNAPSHOT`, and elasticsearch `4.4.18-nes.patch.2-SNAPSHOT`
- **AND** the documentation states that other `spring-data-*` modules keep official coordinates resolved via the private/central mirror.

### Requirement: Only forked Spring Data modules are rewritten to NES coordinates
The build SHALL rewrite exactly the forked Spring Data modules — commons, keyvalue, redis, and elasticsearch — to NES coordinates during Gradle dependency resolution, and SHALL NOT rewrite any other Spring Data module, because only these four are published as NES artifacts. The Elasticsearch fork SHALL use `4.4.18-nes.patch.2-SNAPSHOT`; the other existing fork lines SHALL remain unchanged unless separately approved.

#### Scenario: Redis declaration is transparently substituted
- **WHEN** any dependency (direct or transitive) requests `org.springframework.data:spring-data-redis`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:2.7.18-nes.patch.1-SNAPSHOT`.

#### Scenario: Elasticsearch declaration uses the patch.2 NES line
- **WHEN** any dependency requests `org.springframework.data:spring-data-elasticsearch`
- **THEN** dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.2-SNAPSHOT`
- **AND** it does not resolve the official Spring Data Elasticsearch artifact
- **AND** the elasticsearch version line is hardcoded independently of the `2.7.18-nes.patch.1-SNAPSHOT` line used by commons/keyvalue/redis.

#### Scenario: Unforked Spring Data module keeps official coordinates
- **WHEN** a dependency requests an unforked `org.springframework.data` module such as `spring-data-jpa`, `spring-data-mongodb`, `spring-data-rest`, `spring-data-neo4j`, or `spring-data-r2dbc`
- **THEN** dependency resolution keeps the official `org.springframework.data` coordinate and official version
- **AND** does not attempt to resolve a non-existent NES coordinate for that module.

### Requirement: Redis and Elasticsearch transitive-dependency CVEs are documented as immune-or-fixed
The remediation ledger SHALL record that the CVEs remediated inside the `spring-data-redis-2.7` and `spring-data-elasticsearch-2.7` NES forks are, from this project's perspective, already immune or fixed because this project's Spring Boot BOM manages the affected transitive dependencies at versions above the fix lines; adopting the redis/elasticsearch forks is therefore coordinate-alignment, not remediation of a live exposure.

#### Scenario: Redis fork transitive CVEs are recorded as immune-or-fixed
- **WHEN** a maintainer reads `doc/VULNERABILITY_REPORT.md` and `doc/CVE/`
- **THEN** the redis-fork transitive CVEs (Kotlin CVE-2020-29582, Jackson CVE-2023-35116, commons-beanutils CVE-2025-48734, and the Netty batch) are each documented
- **AND** each is judged against this project's managed versions (Kotlin 1.9.22, Jackson 2.21.5, Netty 4.1.135.Final) and marked immune or fixed (defense-in-depth).

#### Scenario: Elasticsearch fork transitive CVEs are recorded as immune-or-fixed
- **WHEN** a maintainer reads the elasticsearch CVE documents
- **THEN** the elasticsearch-fork transitive CVEs (SnakeYAML CVE-2022-1471, Elasticsearch CVE-2023-46673, Jackson batch, Netty batch) are each documented
- **AND** each is judged against this project's managed versions (SnakeYAML 2.5, Elasticsearch 7.17.29) and marked immune or fixed.

#### Scenario: Vulnerability report does not accumulate aggregate counts
- **WHEN** the vulnerability report is updated for this change
- **THEN** per-CVE status rows are added
- **AND** the aggregate/statistics counters are not incremented (per maintenance convention).

