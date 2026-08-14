## 1. Version Sources and Gradle Resolution

- [x] 1.1 Add `springRetryNesVersion` and `springKafkaNesVersion` to `gradle.properties` with comments describing their BOM, substitution, Starter, and SNAPSHOT roles.
- [x] 1.2 Update the root Kafka substitution to use `springKafkaNesVersion` and add an exact `org.springframework.retry:spring-retry` to NES Retry substitution using `springRetryNesVersion`.
- [x] 1.3 Extend `ForkDependencySubstitutionTests` to verify both version properties, Kafka patch.2 mapping, exact Retry mapping, and the absence of a whole-group Retry rewrite.

## 2. Boot BOM and Published Metadata

- [x] 2.1 Change the Boot BOM Spring Kafka library to the patch.2 version property while preserving the existing NES artifactIds and Spring Framework exclusions.
- [x] 2.2 Replace the official Spring Retry library with the NES Retry GAV and version property so the generated BOM no longer manages `org.springframework.retry:spring-retry`.
- [x] 2.3 Add exact official Retry exclusions to `spring-amqp`, `spring-batch-infrastructure`, and `spring-integration-core`, without changing unrelated module exclusions.
- [x] 2.4 Extend BOM/build contract tests to assert the NES Retry management entry, Kafka patch.2 entries, exact ecosystem exclusions, and absence of official Retry management.
- [x] 2.5 Generate and inspect the dependency-management POM, recording that Kafka patch.2 and NES Retry are managed and that the required official Retry exclusions are published.

## 3. Batch Starter and Classpath Uniqueness

- [x] 3.1 Update `spring-boot-starter-batch` to exclude official Retry from `spring-batch-core` and add the BOM-managed NES Retry as an `api` dependency.
- [x] 3.2 Extend `CheckClasspathForProhibitedDependencies` to prohibit exactly `org.springframework.retry:spring-retry`.
- [x] 3.3 Add unit tests proving official Retry is prohibited, NES Retry is allowed, and another artifact in `org.springframework.retry` is not broadly prohibited.
- [x] 3.4 Run the Batch Starter conflict, unnecessary-exclusion, unconstrained-direct-dependency, and POM generation checks; verify the generated POM contains both the official Retry exclusion and direct NES Retry dependency.

## 4. Retry and Kafka Behavioral Verification

- [x] 4.1 Add a Java 8-compatible `MapRetryContextCache` regression test for capacity 2 that accesses A before inserting C and verifies no capacity exception, retention of A/C, and eviction of B.
- [x] 4.2 Refresh changing modules and capture dependency insight proving Retry resolves to timestamp `20260810.073226-2` or a later behaviorally equivalent Java 8 artifact with no official Retry selected.
- [x] 4.3 Capture dependency insight proving Kafka main/test resolve only to patch.2 timestamp `20260814.020248-2` or a later equivalent Java 8 artifact, while Spring Data Commons remains on the existing NES coordinate.
- [x] 4.4 Run targeted Kafka auto-configuration and `SpringKafkaHeaderSecurityTests`, Rabbit auto-configuration tests, the Retry LRU regression, and the EmbeddedKafka smoke test.

## 5. Published Consumer Verification

- [x] 5.1 Add or extend a repository-owned Maven consumer fixture that imports the generated Boot BOM and simultaneously declares NES Kafka, Spring Batch, Spring AMQP, and Spring Integration dependencies.
- [x] 5.2 Verify the Maven consumer dependency tree contains exactly NES Retry patch.1 SNAPSHOT, Kafka patch.2, and NES Spring Data Commons, with no `org.springframework.retry:spring-retry` or duplicate Retry classes.
- [x] 5.3 Add an equivalent Gradle dependency-resolution assertion where needed to prove the exact substitution path and checked Boot classpaths contain no official Retry.
- [x] 5.4 Record the existing unrelated `bomrCheck` Elasticsearch/LZ4 baseline failures separately, while requiring all Retry-specific exclusion, generated-POM, and consumer gates to pass.

## 6. Security and Consumer Documentation

- [x] 6.1 Add `doc/CVE/CVE-2026-41710.md` and update the vulnerability report with NES Retry GAV, LRU evidence, timestamped SNAPSHOT, stale-cache guidance, and status “已缓解”.
- [x] 6.2 Update CVE-2026-41731 evidence from Kafka patch.1 to patch.2 timestamped SNAPSHOT without weakening the exact trusted-package migration guidance.
- [x] 6.3 Update `doc/NES_GAV_MAPPING.md`, `doc/USER_MANUAL.md`, and related version summaries for Kafka patch.2 and NES Retry, including the official-GAV migration break and unchanged Java imports.
- [x] 6.4 Correct `doc/QUICK_START.md` to use `bjca-footstone-bpring-kafka` and `bjca-footstone-bpring-kafka-test`, add the NES Retry declaration where appropriate, and retain the warning that no Kafka BOM exists.
- [x] 6.5 Verify documentation does not claim CVE-2026-41710 is fixed, does not recommend the official Retry GAV, and does not re-enable or document excluded projects as active.

## 7. Final Change Verification

- [x] 7.1 Run buildSrc tests covering substitution, BOM contracts, and prohibited dependencies, followed by the targeted module checks defined above.
- [x] 7.2 Review `settings.gradle` and the final diff to confirm AMQP/Integration Starters and Boot CLI remain excluded and no files in the read-only `spring-kafka-2.9` repository changed.
- [x] 7.3 Run OpenSpec validation, record all commands and timestamped dependency evidence, and leave the change active for implementation review without publishing a RELEASE.
