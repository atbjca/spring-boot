## Why

The 2026-07 vulnerability ledger predates newly published c3p0 and lz4-java advisories and incorrectly records the mchange-commons-java JNDI issue as fixed while the build still manages c3p0 0.9.5.5. The project needs a Java 8-compatible dependency update and evidence-backed ledger correction before the next NES release.

## What Changes

- Upgrade `com.mchange:c3p0` from 0.9.5.5 to 0.14.0 so its transitive `mchange-commons-java` resolves to 0.6.0.
- Close CVE-2026-27727, CVE-2026-27830, and CVE-2026-55223 with the c3p0 0.14.0 line rather than relying on the unrelated Quartz exclusion rationale.
- Manage `at.yawk.lz4:lz4-java:1.11.1` in the published dependency BOM and upgrade the repository-wide `org.lz4:lz4-java` substitution target from 1.10.1 to 1.11.1 for CVE-2026-59949.
- Document that Gradle dependency substitution is not encoded in a Maven BOM; Maven consumers combining Kafka and Elasticsearch MUST exclude the legacy `org.lz4:lz4-java` path rather than treating the managed fork version as coordinate replacement.
- Verify Java 8 bytecode, dependency resolution, c3p0 `DataSourceBuilder` behavior, Hibernate c3p0 integration compatibility, and representative Kafka/Elasticsearch lz4 resolution.
- Add the missing CVE records and recalculate the vulnerability report from the corrected statuses.
- Advance the Spring Boot fork development version from the released `2.7.18-nes.patch.1` coordinate to `2.7.18-nes.patch.2-SNAPSHOT` so the updated dependency baseline produces distinguishable artifacts.
- Keep ActiveMQ/Artemis, Spring LDAP/Kafka/Framework/Security, Infinispan, and Jetty remediation outside this change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `managed-security-baseline`: Extend the Java 8 managed-security contract to cover c3p0/mchange and the repository-wide lz4-java substitution, including compatibility evidence and accurate CVE accounting.

## Impact

- **Dependency management**: `spring-boot-project/spring-boot-parent/build.gradle`, `spring-boot-project/spring-boot-dependencies/build.gradle`, and the root `build.gradle` substitution rule.
- **Runtime compatibility**: Applications that explicitly select c3p0 receive a significantly newer implementation; removed legacy c3p0 APIs outside Spring Boot's supported integration surface may affect downstream custom configuration.
- **Build resolution**: Gradle Kafka and Elasticsearch dependency graphs converge on `at.yawk.lz4:lz4-java:1.11.1`; Maven consumers receive the secure fork version through dependency management plus explicit legacy-coordinate exclusion guidance.
- **Documentation**: CVE detail files, vulnerability totals, requirements, and component upgrade history require correction.
