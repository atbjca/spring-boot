## RENAMED Requirements

- FROM: `### Requirement: Only commons and keyvalue are treated as forked Spring Data modules`
- TO: `### Requirement: Only forked Spring Data modules are rewritten to NES coordinates`

## MODIFIED Requirements

### Requirement: Only forked Spring Data modules are rewritten to NES coordinates
The build SHALL rewrite exactly the forked Spring Data modules — commons, keyvalue, redis, and elasticsearch — to NES coordinates during Gradle dependency resolution, and SHALL NOT rewrite any other Spring Data module, because only these four are published as NES artifacts.

#### Scenario: Redis declaration is transparently substituted
- **WHEN** any dependency (direct or transitive) requests `org.springframework.data:spring-data-redis`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:2.7.18-nes.patch.1-SNAPSHOT`.

#### Scenario: Elasticsearch declaration is transparently substituted on its own version line
- **WHEN** any dependency requests `org.springframework.data:spring-data-elasticsearch`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.1-SNAPSHOT`
- **AND** the elasticsearch version line `4.4.18-nes.patch.1-SNAPSHOT` is hardcoded independently of the `2.7.18-nes.patch.1-SNAPSHOT` line used by commons/keyvalue/redis.

#### Scenario: Unforked Spring Data module keeps official coordinates
- **WHEN** a dependency requests an unforked `org.springframework.data` module such as `spring-data-jpa`, `spring-data-mongodb`, `spring-data-rest`, `spring-data-neo4j`, or `spring-data-r2dbc`
- **THEN** dependency resolution keeps the official `org.springframework.data` coordinate and official version
- **AND** does not attempt to resolve a non-existent NES coordinate for that module.

### Requirement: Spring Data fork boundary is documented consistently
NES GAV mapping documentation SHALL describe the Spring Data fork boundary accurately: BOM, commons, keyvalue, redis, and elasticsearch are forked; all other Spring Data modules remain official.

#### Scenario: GAV mapping documents the Spring Data boundary
- **WHEN** maintainers read the NES GAV mapping documentation
- **THEN** Spring Data BOM, commons, keyvalue, redis, and elasticsearch appear with their NES coordinates and versions (redis `2.7.18-nes.patch.1-SNAPSHOT`, elasticsearch `4.4.18-nes.patch.1-SNAPSHOT`)
- **AND** the documentation states that other `spring-data-*` modules keep official coordinates resolved via the private/central mirror.

## ADDED Requirements

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
