# Verification Evidence

## Resolved SNAPSHOT identities

- NES Spring Retry: `1.3.4-nes.patch.1-SNAPSHOT:20260810.073226-2`, Java 8 variant.
- NES Spring Kafka main/test: `2.9.13-nes.patch.2-SNAPSHOT:20260814.020248-2`, Java 8 variants.
- NES Spring Data Commons remains `2.7.18-nes.patch.1`.
- No resolved verification graph selected `org.springframework.retry:spring-retry`.

## Published consumer verification

Command:

```bash
ROOT_DIR_OVERRIDE=/Volumes/LIBIAO_HY/dev/GitHub/nes/spring-boot-2.7 \
  GRADLE_BIN=./gradlew \
  ./scripts/verify-published-boot-spring-retry-consumers.sh all
```

Result: passed. The generated Boot BOM was published to the project repository, and the independent Maven and Gradle consumers selected:

- `cn.bjca.footstone.bpring.retry:bjca-footstone-bpring-retry:1.3.4-nes.patch.1-SNAPSHOT`
- `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka:2.9.13-nes.patch.2-SNAPSHOT`
- `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:2.7.18-nes.patch.1`

The Maven classpath scan found exactly one owner of `org/springframework/retry/RetryContext.class`, the NES Retry artifact. Both consumer graphs contained no official Spring Retry artifact.

## `bomrCheck` baseline

Command:

```bash
./gradlew --no-daemon :spring-boot-project:spring-boot-dependencies:bomrCheck
```

Result: expected baseline failure, unrelated to this change. The only reported items were existing Elasticsearch exclusions:

- `bjca-footstone-blasticsearch`: unnecessary `org.lz4:lz4-java` exclusion.
- `bjca-footstone-blasticsearch-lz4`: unnecessary `org.lz4:lz4-java` exclusion.
- `bjca-footstone-blasticsearch-rest-high-level-client`: unnecessary `org.lz4:lz4-java` exclusion.
- `bjca-footstone-blasticsearch-java`: unnecessary `commons-logging:commons-logging` exclusion.

No Spring Retry exclusion was reported. Retry-specific generated-POM checks and the Maven/Gradle consumer gates passed independently.

## Targeted behavioral verification

Command:

```bash
./gradlew --no-daemon :spring-boot-project:spring-boot-autoconfigure:test \
  --tests org.springframework.boot.autoconfigure.kafka.KafkaAutoConfigurationTests \
  --tests org.springframework.boot.autoconfigure.kafka.SpringKafkaHeaderSecurityTests \
  --tests org.springframework.boot.autoconfigure.kafka.KafkaAutoConfigurationIntegrationTests \
  --tests org.springframework.boot.autoconfigure.amqp.RabbitAutoConfigurationTests \
  --tests org.springframework.boot.autoconfigure.retry.SpringRetryCacheSecurityTests
```

Result: passed. This covers Kafka and Rabbit auto-configuration, exact Kafka Header trust behavior, the Retry LRU capacity regression, and EmbeddedKafka integration smoke behavior.

## Documentation checks

- Added `doc/CVE/CVE-2026-41710.md` with NES Retry GAV, LRU behavior, timestamp `20260810.073226-2`, Java 8, stale-cache guidance, consumer migration, and status `⚠️已缓解`.
- Updated CVE-2026-41731 to Kafka patch.2 timestamp `20260814.020248-2` while retaining exact trusted-package guidance and the warning against wildcard trust.
- Updated GAV mapping, user manual, Quick Start, build-mechanism notes, vulnerability summary, and component history.
- Documentation scans found no NES Kafka group paired with `spring-kafka`/`spring-kafka-test`, no Maven example declaring the official Retry GAV, and no claim that CVE-2026-41710 is fixed.
- AMQP/Integration Starters and Boot CLI remain documented as excluded where applicable; no excluded project was presented as active.

## Final build contracts

Command:

```bash
./gradlew --no-daemon -p buildSrc test \
  --tests org.springframework.boot.build.ForkDependencySubstitutionTests \
  --tests org.springframework.boot.build.classpath.CheckClasspathForProhibitedDependenciesTests
```

Result: passed. Together with the targeted behavioral command above, this covers substitution, BOM text contracts, exact prohibited dependencies, Kafka/Rabbit auto-configuration, Header security, Retry LRU, and EmbeddedKafka.

## Scope and repository audit

- `settings.gradle` has no diff.
- Boot CLI remains commented out.
- `spring-boot-starter-integration` and `spring-boot-starter-amqp` remain in `ignoredStarters`.
- The read-only `spring-kafka-2.9` repository has no tracked or staged diff. Its pre-existing untracked `.claude/`, `.codex/`, and `.cursor/` directories were not touched.
- `git diff --check` passed.
- No Boot, Kafka, or Retry RELEASE was published. The only publication was the generated Boot BOM to the repository-local verification directory.

## OpenSpec validation

Command:

```bash
openspec validate adopt-nes-spring-retry-and-kafka-patch2 \
  --type change --strict --no-interactive --json
```

Result: passed with one valid change and zero issues. The change remains active for implementation review.
