## 1. Dependency management

- [x] 1.1 Change the managed c3p0 version in `spring-boot-project/spring-boot-parent/build.gradle` from 0.9.5.5 to 0.14.0 and confirm its declared mchange-commons-java dependency is 0.6.0.
- [x] 1.2 Add `at.yawk.lz4:lz4-java` 1.11.1 to the published dependency-management BOM without inventing an `org.lz4` 1.11.1 coordinate.
- [x] 1.3 Update the root Gradle substitution from `at.yawk.lz4:lz4-java:1.10.1` to 1.11.1 and preserve the existing capability-conflict behavior.
- [x] 1.4 Generate the Maven BOM and verify that c3p0, mchange-commons-java, and at.yawk lz4 versions are present and unambiguous.

## 2. Compatibility and resolution verification

- [x] 2.1 Verify c3p0 0.14.0 and mchange-commons-java 0.6.0 class major versions are usable on the Java 8 baseline.
- [x] 2.2 Run Spring Boot `DataSourceBuilder` c3p0 tests and a minimal c3p0 pooled connection lifecycle test; run the relevant Hibernate 5.6 c3p0 integration coverage.
- [x] 2.3 Resolve representative Kafka and Elasticsearch Gradle classpaths and confirm only `at.yawk.lz4:lz4-java:1.11.1` is present.
- [x] 2.4 Run lz4 Java/native XXHash and compression smoke coverage, including valid attacker-controlled contents and invalid range rejection where the native implementation is available.
- [x] 2.5 Verify a Maven consumer resolves Kafka's at.yawk lz4 dependency to 1.11.1 and document/test the required exclusion for Elasticsearch's legacy `org.lz4` path.

## 3. Vulnerability and migration documentation

- [x] 3.1 Add CVE documents for CVE-2026-27830, CVE-2026-55223, and CVE-2026-59949 with affected features, fixed versions, Java compatibility, and project scope.
- [x] 3.2 Correct CVE-2026-27727 documentation so it no longer claims a Quartz exclusion removes all c3p0 exposure; record the c3p0/mchange resolved-artifact evidence.
- [x] 3.3 Rebuild `doc/VULNERABILITY_REPORT.md` status rows and totals from the final CVE set, including the lz4 conditional-impact wording.
- [x] 3.4 Synchronize `doc/REQUIREMENTS.md`, `doc/COMPONENTS_UPGRADE_HISTORY.md`, and user migration guidance with the new versions and Maven lz4 exclusion requirement.

## 4. Project validation and handoff

- [x] 4.1 Run targeted module tests and Java 8 compilation after the dependency changes.
- [x] 4.2 Run the standard project build/security gates, recording unrelated environmental or pre-existing failures separately.
- [x] 4.3 Run strict OpenSpec validation for this change and review the final diff for unintended ActiveMQ, Artemis, Spring ecosystem, Infinispan, Jetty, or Security changes.
- [x] 4.4 Set the Spring Boot fork development version to `2.7.18-nes.patch.2-SNAPSHOT`, verify generated Boot metadata uses the new version, and keep independently versioned NES dependency forks unchanged.
