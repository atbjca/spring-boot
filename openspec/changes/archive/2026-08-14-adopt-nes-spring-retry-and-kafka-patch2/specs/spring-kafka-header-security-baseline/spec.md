## MODIFIED Requirements

### Requirement: Boot MUST consume a Spring Kafka artifact with the CVE-2026-41731 fix
The Boot fork SHALL manage the NES Spring Kafka patch.2 SNAPSHOT and MUST verify that the resolved artifact implements exact trusted-package matching and contains the internal backport from commit `c119b8f62` or equivalent behavior.

#### Scenario: Untrusted JDK subpackage header is received
- **WHEN** `DefaultKafkaHeaderMapper` receives a JSON type Header for `java.util.logging.FileHandler` while only the default trusted packages are configured
- **THEN** the Header value is returned as `NonTrustedHeaderType`
- **AND** the declared JDK subpackage type is not instantiated.

#### Scenario: Exact package behavior remains compatible
- **WHEN** the Header type belongs directly to an explicitly trusted package
- **THEN** the mapper continues to deserialize the Header according to its existing behavior.

#### Scenario: Explicit wildcard remains compatible
- **WHEN** a caller explicitly configures `addTrustedPackages("*")`
- **THEN** the mapper continues to allow all valid type packages.

### Requirement: SNAPSHOT fix evidence MUST identify the resolved artifact
Validation and maintained documentation SHALL record the internal fix commit, the verified Kafka patch.2 timestamped SNAPSHOT or stronger immutable artifact evidence, Java 8 compatibility, and the risk that an older cached artifact with the same `-SNAPSHOT` version may not represent the validated build.

#### Scenario: Dependency verification is performed
- **WHEN** maintainers validate the Boot Kafka dependency after refreshing changing modules
- **THEN** dependency insight identifies `2.9.13-nes.patch.2-SNAPSHOT:20260814.020248-2` or a later artifact with equivalent fixed behavior
- **AND** the resolved variant is compatible with Java 8
- **AND** only one NES version of the Spring Kafka main and test modules is selected.

#### Scenario: Mutable SNAPSHOT cache is documented
- **WHEN** CVE-2026-41731 evidence is updated for Kafka patch.2
- **THEN** the status is tied to the verified artifact evidence rather than the mutable version string alone
- **AND** documentation instructs stale build environments to refresh the dependency.

### Requirement: Spring Kafka security adoption MUST preserve existing Boot integration
The change SHALL preserve current Kafka auto-configuration, exact trusted-package behavior, Kafka Clients 3.9.2, EmbeddedKafka smoke behavior, and NES Spring Data Commons resolution while moving the managed Kafka version to patch.2.

#### Scenario: Boot verification completes
- **WHEN** the Kafka patch.2 adoption is validated
- **THEN** targeted Kafka auto-configuration tests, Header security tests, and the Kafka smoke test pass
- **AND** generated BOM and dependency resolution use the NES Spring Kafka patch.2 GAV and SNAPSHOT version
- **AND** Spring Data Commons continues to resolve to the existing NES coordinate rather than an official duplicate.
