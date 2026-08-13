## MODIFIED Requirements

### Requirement: Boot BOM imports the NES Spring Data BOM
The Spring Boot NES dependency BOM SHALL import the Spring Data release-train BOM using the published NES BOM coordinate, not the upstream coordinate. For this change the managed version SHALL be `2021.2.18-nes.patch.2-SNAPSHOT`.

#### Scenario: Spring Data BOM is imported as the patch.2 NES GAV
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** it imports `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.2-SNAPSHOT`
- **AND** it does not import `org.springframework.data:spring-data-bom`

### Requirement: Only forked Spring Data modules are rewritten to NES coordinates
The build SHALL rewrite exactly the forked Spring Data modules — commons, keyvalue, redis, and elasticsearch — to NES coordinates during Gradle dependency resolution, and SHALL NOT rewrite any other Spring Data module. The Elasticsearch fork SHALL use `4.4.18-nes.patch.2-SNAPSHOT`; the other existing fork lines SHALL remain unchanged unless separately approved.

#### Scenario: Redis declaration is transparently substituted
- **WHEN** any dependency (direct or transitive) requests `org.springframework.data:spring-data-redis`
- **THEN** Gradle dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:2.7.18-nes.patch.1-SNAPSHOT`

#### Scenario: Elasticsearch declaration uses the patch.2 NES line
- **WHEN** any dependency requests `org.springframework.data:spring-data-elasticsearch`
- **THEN** dependency resolution uses `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.2-SNAPSHOT`
- **AND** it does not resolve the official Spring Data Elasticsearch artifact

#### Scenario: Unforked Spring Data module keeps official coordinates
- **WHEN** a dependency requests an unforked module such as `spring-data-jpa`, `spring-data-mongodb`, `spring-data-rest`, `spring-data-neo4j`, or `spring-data-r2dbc`
- **THEN** dependency resolution keeps the official coordinate and official version
- **AND** no non-existent NES coordinate is synthesized

### Requirement: Spring Data fork boundary is documented consistently
NES GAV mapping documentation SHALL describe the Spring Data fork boundary accurately: BOM, commons, keyvalue, redis, and elasticsearch are forked; all other Spring Data modules remain official. The BOM and Elasticsearch entries SHALL identify the patch.2 SNAPSHOT line.

#### Scenario: GAV mapping documents the Spring Data boundary
- **WHEN** maintainers read the NES GAV mapping documentation
- **THEN** Spring Data BOM, commons, keyvalue, redis, and elasticsearch appear with their NES coordinates and versions, including BOM `2021.2.18-nes.patch.2-SNAPSHOT` and Elasticsearch `4.4.18-nes.patch.2-SNAPSHOT`
- **AND** the documentation states that other `spring-data-*` modules keep official coordinates resolved via the private/central mirror
