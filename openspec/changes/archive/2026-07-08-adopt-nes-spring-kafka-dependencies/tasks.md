## 1. Preflight and dependency verification

- [x] 1.1 Confirm `git status --short` and record unrelated dirty files before implementation.
- [x] 1.2 Verify `~/dev/gradle-7.6.3-bin.zip` or installed Gradle 7.6.3 is available for the current wrapper.
- [x] 1.3 Verify `cn.bjca.footstone.bpring.kafka:spring-kafka:2.9.13-nes.patch.1-SNAPSHOT` resolves from local Maven/Nexus.
- [x] 1.4 Verify `cn.bjca.footstone.bpring.kafka:spring-kafka-test:2.9.13-nes.patch.1-SNAPSHOT` resolves from local Maven/Nexus.
- [x] 1.5 Inspect the resolved NES Spring Kafka POMs and decide whether `exclude group: "org.springframework", module: "*"` must remain.

## 2. Tests first

- [x] 2.1 Add or update buildSrc/BOM tests that assert Spring Kafka dependency management emits NES groupId, artifactId, and version.
- [x] 2.2 Add or update dependency substitution test coverage for `org.springframework.kafka:spring-kafka`.
- [x] 2.3 Add or update dependency substitution test coverage for `org.springframework.kafka:spring-kafka-test`.
- [x] 2.4 Run the new or updated tests and confirm they fail before implementation for the expected reason.

## 3. Build implementation

- [x] 3.1 Update root `build.gradle` with a Spring Kafka NES dependency substitution rule for the two confirmed modules.
- [x] 3.2 Update `spring-boot-project/spring-boot-dependencies/build.gradle` to manage NES Spring Kafka coordinates.
- [x] 3.3 Apply the POM verification decision by removing or retaining Spring Framework exclusions on the NES Kafka BOM entries.
- [x] 3.4 Keep existing Kafka 3.9.2 and `spring-kafka-test` EmbeddedKafka smoke-test disabled behavior unchanged.

## 4. Documentation updates

- [x] 4.1 Update `doc/GAV 构建机制说明.md` with the Spring Kafka NES mapping rule and maintenance notes.
- [x] 4.2 Update `doc/NES_GAV_MAPPING.md` so Spring Kafka is documented as a NES fork component.
- [x] 4.3 Update `doc/GAV_MAPPING.md` with the Spring Kafka NES coordinates if it remains the comprehensive mapping entry point.
- [x] 4.4 Update `doc/REQUIREMENTS.md` to record the Spring Kafka NES GAV adoption and impact analysis.
- [x] 4.5 Update `doc/VULNERABILITY_REPORT.md` to reflect Spring Kafka NES dependency status without changing unrelated CVE states.
- [x] 4.6 Add or update Quick Start and User Manual documentation for consuming NES Spring Kafka through the Boot BOM.
- [x] 4.7 Search all docs for `bjca-footstone-bpring-kafka-bom` and remove any instruction that assumes the non-existent Kafka BOM.

## 5. Verification

- [x] 5.1 Run the targeted buildSrc/BOM tests added or updated in this change.
- [x] 5.2 Run a dependency management or generated BOM verification task and confirm the generated BOM contains NES Spring Kafka coordinates.
- [x] 5.3 Run a targeted Kafka autoconfigure compile/test task that does not depend on EmbeddedKafka broker startup.
- [x] 5.4 Run `openspec status --change adopt-nes-spring-kafka-dependencies` and confirm artifacts are complete.
- [x] 5.5 Summarize verification results, skipped tests, and remaining Kafka EmbeddedKafka compatibility risk.
