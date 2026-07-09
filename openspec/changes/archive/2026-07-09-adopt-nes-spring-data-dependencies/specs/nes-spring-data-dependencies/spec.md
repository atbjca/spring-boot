## ADDED Requirements

### Requirement: Boot BOM imports the NES Spring Data BOM
The Spring Boot NES dependency BOM SHALL import the Spring Data release-train BOM using the published NES BOM coordinate, not the upstream coordinate.

#### Scenario: Spring Data BOM is imported as NES GAV
- **WHEN** the Spring Boot NES dependency BOM is generated
- **THEN** it imports `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.1-SNAPSHOT`
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

### Requirement: Only commons and keyvalue are treated as forked Spring Data modules
The build SHALL NOT rewrite Spring Data modules other than commons and keyvalue to NES coordinates, because only those two are published as NES artifacts.

#### Scenario: Unforked Spring Data module keeps official coordinates
- **WHEN** a dependency requests `org.springframework.data:spring-data-redis` (or jpa, mongodb, rest, neo4j, etc.)
- **THEN** dependency resolution keeps the official `org.springframework.data` coordinate and official version
- **AND** does not attempt to resolve a non-existent NES coordinate for that module.

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
NES GAV mapping documentation SHALL describe the Spring Data fork boundary accurately: BOM, commons, and keyvalue are forked; all other Spring Data modules remain official.

#### Scenario: GAV mapping documents the Spring Data boundary
- **WHEN** maintainers read the NES GAV mapping documentation
- **THEN** Spring Data BOM, commons, and keyvalue appear with their NES coordinates and versions
- **AND** the documentation states that other `spring-data-*` modules keep official coordinates resolved via the private/central mirror.
