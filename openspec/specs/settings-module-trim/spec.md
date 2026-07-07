## Purpose

Define which Spring Boot modules participate in the trimmed fork build and which modules remain excluded.

## Requirements
### Requirement: Starter 排除列表

`settings.gradle` MUST 定义 `ignoredStarters` 集合，包含以下 19 个不发布的 starter：

| Starter | 排除原因 |
|---------|---------|
| `spring-boot-starter-activemq` | 消息精简 |
| `spring-boot-starter-amqp` | 消息精简 |
| `spring-boot-starter-artemis` | 消息精简 |
| `spring-boot-starter-pulsar` | 消息精简（3.5 新增） |
| `spring-boot-starter-pulsar-reactive` | 消息精简（3.5 新增） |
| `spring-boot-starter-data-cassandra` | 私服/精简 |
| `spring-boot-starter-data-cassandra-reactive` | 私服/精简 |
| `spring-boot-starter-data-couchbase` | 私服/精简 |
| `spring-boot-starter-data-couchbase-reactive` | 私服/精简 |
| `spring-boot-starter-data-neo4j` | 私服/精简 |
| `spring-boot-starter-data-r2dbc` | 精简 |
| `spring-boot-starter-data-rest` | 精简 |
| `spring-boot-starter-data-ldap` | 精简 |
| `spring-boot-starter-graphql` | 精简 |
| `spring-boot-starter-hateoas` | 精简 |
| `spring-boot-starter-integration` | 依赖链冲突 |
| `spring-boot-starter-jersey` | 精简 |
| `spring-boot-starter-jooq` | 精简 |
| `spring-boot-starter-rsocket` | 精简 |

`eachDirMatch` 回调 MUST 检查 `!ignoredStarters.contains(it.name)` 后才 include。

#### Scenario: 排除的 starter 不参与构建
- **WHEN** 执行 `./gradlew projects`
- **THEN** 输出中不包含上述 19 个 starter 的项目名

#### Scenario: 保留的 starter 正常参与构建
- **WHEN** 执行 `./gradlew projects`
- **THEN** 输出中包含 `bjca-footstone-bpring-boot-starter-web`、`bjca-footstone-bpring-boot-starter-kafka` 等保留 starter

### Requirement: Smoke-test 排除列表

`settings.gradle` MUST 定义 `ignoredSmokeTests` 集合，包含以下 smoke-test（继承 2.7 + 3.5 追加）：

**继承 2.7（18 个）**：`activemq`, `activemq-embedded`, `amqp`, `ant`, `cache`, `data-ldap`, `data-r2dbc`, `data-r2dbc-flyway`, `data-r2dbc-liquibase`, `data-rest`, `graphql`, `hateoas`, `integration`, `jersey`, `parent-context`, `rsocket`, `secure-jersey`, `artemis`

**3.5 追加**：`pulsar`, `data-cassandra`, `data-couchbase`, `data-mongo`, `data-redis`, `data-elasticsearch`, `session-redis`, `session-mongo`, `session-webflux-redis`, `session-webflux-mongo`

每个条目 MUST 使用完整目录名（`spring-boot-smoke-test-<name>`）。

#### Scenario: 排除的 smoke-test 不参与构建
- **WHEN** 执行 `./gradlew projects`
- **THEN** 输出中不包含上述 smoke-test 的项目名

### Requirement: 不发布的显式 include 模块排除

以下 4 个显式 `include` 的模块 MUST 从 `settings.gradle` 中移除（注释或删除）：

- `spring-boot-project:spring-boot-docs`
- `spring-boot-project:spring-boot-tools:spring-boot-cli`
- `spring-boot-project:spring-boot-tools:spring-boot-antlib`
- `spring-boot-project:spring-boot-tools:spring-boot-configuration-metadata-changelog-generator`

`spring-boot-project:spring-boot-tools:spring-boot-properties-migrator` MUST remain included so the fork can publish the properties migrator artifact to Nexus.

#### Scenario: CLI 不参与构建
- **WHEN** 执行 `./gradlew projects`
- **THEN** 输出中不包含 `spring-boot-cli` 相关项目

#### Scenario: Properties migrator 参与构建
- **WHEN** 执行 `./gradlew projects`
- **THEN** 输出中包含 `spring-boot-project:spring-boot-tools:spring-boot-properties-migrator`

### Requirement: system-tests 和特殊 integration-tests 排除

以下模块 MUST 从 `settings.gradle` 中移除：

- `spring-boot-system-tests:spring-boot-deployment-tests`
- `spring-boot-system-tests:spring-boot-image-tests`
- `spring-boot-tests:spring-boot-integration-tests:spring-boot-launch-script-tests`
- `spring-boot-tests:spring-boot-integration-tests:spring-boot-loader-classic-tests`
- `spring-boot-tests:spring-boot-integration-tests:spring-boot-loader-tests`
- `spring-boot-tests:spring-boot-integration-tests:spring-boot-sni-tests`

保留 `configuration-processor-tests` 和 `server-tests`。

#### Scenario: system-tests 不参与构建
- **WHEN** 执行 `./gradlew projects`
- **THEN** 输出中不包含 `deployment-tests` 和 `image-tests`
