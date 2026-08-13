# adopt-nes-elasticsearch-client-stack evidence

Runtime evidence files live under `build/elasticsearch-adoption/evidence/` (not committed). This file records the commands, results, and the closed producer-POM LZ4 gate.

## Producer LZ4 boundary (tasks 5.3 / 5.4)

Inspected sibling producer source on 2026-08-13 (task 5.3, then still open):

- `/Volumes/LIBIAO_HY/dev/GitHub/nes/elasticsearch-7.17/libs/lz4/build.gradle`
- Direct API dependency was `api 'org.lz4:lz4-java:1.8.0'`
- No `at.yawk.lz4:lz4-java` edge existed in the then-published producer POM

Boot-side mitigation already in this change:

- BOM exclusions of `org.lz4:lz4-java` on `bjca-footstone-blasticsearch`, `bjca-footstone-blasticsearch-lz4`, and HLRC
- BOM management of `at.yawk.lz4:lz4-java:1.11.1`
- `spring-boot-starter-data-elasticsearch` explicitly depends on `at.yawk.lz4:lz4-java`

Producer follow-up `replace-lz4-java-with-at-yawk-1-11-1` (elasticsearch-7.17, archived 2026-08-13) replaced `libs/lz4` with `at.yawk.lz4:lz4-java:1.11.1` and deployed SNAPSHOT unique `7.17.29-nes.patch.1-20260813.135413-2`.

Direct-consumer proof (task 5.4 closed, Java 8 / Maven 3.8.2, no Boot BOM, no starter, `--update-snapshots`):

```bash
mvn -f tests/elasticsearch-adoption/consumers/direct-hlrc/pom.xml -U dependency:tree
mvn -f tests/elasticsearch-adoption/consumers/direct-sde/pom.xml -U dependency:tree
```

| Consumer | Direct GAV | LZ4 result |
|---|---|---|
| `direct-hlrc` | NES HLRC `7.17.29-nes.patch.1-SNAPSHOT` | `bjca-footstone-blasticsearch-lz4` → `at.yawk.lz4:lz4-java:1.11.1`; `org.lz4` count 0 |
| `direct-sde` | NES SDE `4.4.18-nes.patch.2-SNAPSHOT` | same transitive path; `org.lz4` count 0 |

**Full-adoption gate is closed.** Direct SDE/HLRC consumers receive the replacement from the producer POM. Boot BOM exclusion/starter explicit dependency remain defense in depth.

## Environment

- Boot focused tests / isolated publication: JDK 11.0.30-tem
- Independent consumers: Amazon Corretto 8.0.472 (`java.specification.version = 1.8`)
- Gradle wrapper 7.6.3 from the Boot tree (`./gradlew -p <consumer>`, not a consumer-owned wrapper)
- Maven 3.8.2
- Isolated candidate repository: `build/elasticsearch-adoption/repository`
- Isolated Gradle home: `build/elasticsearch-adoption/gradle-home` (seeded with the local 7.6.3 dist; no Boot `resolutionStrategy`)
- Isolated Maven local: `build/elasticsearch-adoption/maven-local`

## 6. Focused verification

### 6.1 Elasticsearch auto-configuration / actuator / SDE / starter tests

Command (JDK 11):

```bash
./gradlew -Dorg.gradle.caching=false \
  :spring-boot-project:spring-boot-autoconfigure:test \
  --tests org.springframework.boot.autoconfigure.elasticsearch.ElasticsearchRestClientAutoConfigurationTests \
  --tests org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchDataAutoConfigurationTests \
  --tests org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchRepositoriesAutoConfigurationTests \
  --tests org.springframework.boot.autoconfigure.data.elasticsearch.ReactiveElasticsearchRestClientAutoConfigurationTests \
  --tests org.springframework.boot.autoconfigure.data.elasticsearch.ReactiveElasticsearchRepositoriesAutoConfigurationTests \
  --tests org.springframework.boot.autoconfigure.jsonb.JsonbAutoConfigurationTests \
  --tests org.springframework.boot.autoconfigure.jsonb.JsonbAutoConfigurationWithNoProviderTests \
  :spring-boot-project:spring-boot-actuator:test \
  --tests org.springframework.boot.actuate.elasticsearch.ElasticsearchRestClientHealthIndicatorTests \
  --tests org.springframework.boot.actuate.elasticsearch.ElasticsearchReactiveHealthIndicatorTests \
  :spring-boot-project:spring-boot-actuator-autoconfigure:test \
  --tests org.springframework.boot.actuate.autoconfigure.elasticsearch.ElasticSearchRestHealthContributorAutoConfigurationTests \
  --tests org.springframework.boot.actuate.autoconfigure.elasticsearch.ElasticsearchReactiveHealthContributorAutoConfigurationTests \
  :spring-boot-project:spring-boot-test:test \
  --tests org.springframework.boot.test.json.JsonbTesterTests
```

Result: `BUILD SUCCESSFUL in 4m 56s`.

Testcontainers follow-up:

```bash
./gradlew -Dorg.gradle.caching=false \
  :spring-boot-project:spring-boot-autoconfigure:test \
  --tests org.springframework.boot.autoconfigure.elasticsearch.ElasticsearchRestClientAutoConfigurationIntegrationTests \
  --tests org.springframework.boot.autoconfigure.data.elasticsearch.ReactiveElasticsearchRestClientAutoConfigurationIntegrationTests \
  :spring-boot-project:spring-boot-test-autoconfigure:test \
  --tests org.springframework.boot.test.autoconfigure.data.elasticsearch.DataElasticsearchTestIntegrationTests \
  --tests org.springframework.boot.test.autoconfigure.data.elasticsearch.DataElasticsearchTestPropertiesIntegrationTests \
  --tests org.springframework.boot.test.autoconfigure.data.elasticsearch.DataElasticsearchTestWithIncludeFilterIntegrationTests \
  --tests org.springframework.boot.test.autoconfigure.data.elasticsearch.DataElasticsearchTestReactiveIntegrationTests
```

Result: `BUILD SUCCESSFUL in 19s`.

### 6.2 JSON-B / Johnzon and JSON-P provider tests

Covered by the same focused invocation as 6.1 (`JsonbAutoConfigurationTests`, `JsonbAutoConfigurationWithNoProviderTests`, `JsonbTesterTests`). Result: passed with the `javax.json:javax.json-api` declarations. Starter runtime ServiceLoader scan (`graph-scan.txt`): one `jakarta.json.spi.JsonProvider` from NES Barsson (`org.eclipse.parsson.JsonProviderImpl` class name retained inside Barsson; **not** the `org.eclipse.parsson` coordinate); zero `javax.json` providers on the Elasticsearch starter graph (Johnzon is not on that starter).

### 6.3 Resolved graphs

Starter `runtimeClasspath` (`starter-runtime-artifacts.txt`, `starter-runtime-dependencies.txt`, `graph-scan.txt`):

- Present: NES 16-module Elasticsearch closure, NES Java API Client, Barsson `1.0.5-nes.patch.1-SNAPSHOT`, `jakarta.json-api:2.0.2`, SDE `4.4.18-nes.patch.2-SNAPSHOT`, `at.yawk.lz4:lz4-java:1.11.1`
- Absent: `org.elasticsearch:`, `co.elastic.clients:`, `org.lz4:lz4-java`, `org.eclipse.parsson:`, `transport-netty4-client`, SDE patch.1
- `forbidden=[]`, `duplicate_es_classes=0`

`org.lz4:lz4-java:1.8.0 -> at.yawk.lz4:lz4-java:1.11.1` on the starter graph.

### 6.4 Class major 52

- Root classes of adopted production JARs: all major ≤ 52 (`class-major-root.txt`, no FAIL)
- Multi-release entries under `META-INF/versions/9|11` report 53/55 (`class-major.txt`). Java 8 loads the root classes, so this is expected MRJAR layout, not a Java 8 failure.

## 7. Independent consumer verification

Isolated publication of Boot BOM, core, autoconfigure, starter, logging, and Elasticsearch starter used unique SNAPSHOT identity `20260813.130423-1`.

Fixtures: `tests/elasticsearch-adoption/consumers/{maven,gradle,gradle-dm}` sharing `PublishedBootElasticsearchSmoke`. The Gradle DM fixture `settings.gradle` uses NES `maven-public` for plugin resolution because `plugins.gradle.org` times out on this network.

### 7.1 Maven BOM consumer

- `dependency:tree` → `maven-dependency-tree.txt` (`BUILD SUCCESS`)
- `dependency:build-classpath` + `compile` + Java 8 smoke → `maven-classpath.txt`, `maven-smoke.txt`
- Smoke: `elasticsearch.package=org.elasticsearch.client.RestClientBuilder`, `javax.json.providers=0`, `jakarta.json.providers=1`

Resolved unique NES Elasticsearch timestamp from Nexus: `7.17.29-nes.patch.1-20260813.033415-1`.

### 7.2 Gradle `io.spring.dependency-management` consumer

Boot `./gradlew -p tests/elasticsearch-adoption/consumers/gradle-dm` with isolated `GRADLE_USER_HOME`, `--refresh-dependencies`, Java 8:

- `dependencies --configuration runtimeClasspath` → `gradle-dm-dependency-tree.txt`
- `writeRuntimeArtifacts` → `gradle-dm-runtime-artifacts.txt`
- `run` → `gradle-dm-smoke.txt`

Smoke matches Maven: RestClientBuilder package preserved; 0 javax / 1 jakarta JSON-P provider.

### 7.3 Native Gradle `platform(...)` consumer

Same wrapper/Java 8/isolation pattern against `tests/elasticsearch-adoption/consumers/gradle`:

- `gradle-platform-dependency-tree.txt`
- `gradle-platform-runtime-artifacts.txt`
- `gradle-platform-smoke.txt`

Smoke matches Maven and Gradle DM.

### 7.4 Cross-fixture summary

Recorded in `consumer-graph-summary.txt` plus the files above.

| Check | Maven | Gradle DM | Gradle platform |
|---|---|---|---|
| NES ES 16-module + Java Client | yes | yes | yes |
| Barsson `1.0.5-nes.patch.1-SNAPSHOT` | yes | yes | yes |
| `jakarta.json-api:2.0.2` | yes | yes | yes |
| SDE `4.4.18-nes.patch.2-SNAPSHOT` | yes | yes | yes |
| `at.yawk.lz4:lz4-java:1.11.1` | yes | yes | yes |
| `org.lz4:lz4-java` / official ES / `co.elastic.clients` / Parsson GAV / transport | absent | absent | absent |
| SDE patch.1 | absent | absent | absent |
| Java 8 smoke RestClientBuilder package | `org.elasticsearch.client.RestClientBuilder` | same | same |
| JSON-P providers (javax / jakarta) | 0 / 1 | 0 / 1 | 0 / 1 |
| Boot candidate SNAPSHOT | `20260813.130423-1` | same isolated repo | same isolated repo |
| NES ES unique SNAPSHOT | `7.17.29-nes.patch.1-20260813.033415-1` | SNAPSHOT from Nexus via isolated caches | same |

None of the three consumers used the Boot root `resolutionStrategy`. Direct SDE/HLRC consumers that skip the Boot Elasticsearch starter are covered by `consumers/direct-hlrc` and `consumers/direct-sde` (task 5.4 closed; producer unique `7.17.29-nes.patch.1-20260813.135413-2`).

## Review notes (task 9.1)

Diff is limited to Elasticsearch client closure, JSON-P dual runtime, Spring Data patch.2, LZ4 starter/BOM handling, contract tests, consumer fixtures, and documentation. Unforked Spring Data modules were not rewritten. No broad `org.elasticsearch` / `co.elastic.clients` group substitution was added.

Formal Boot RELEASE remains blocked while Elasticsearch, Barsson, Spring Data BOM, and SDE coordinates are SNAPSHOT (`component-release`).
