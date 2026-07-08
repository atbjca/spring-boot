## MODIFIED Requirements

### Requirement: Makefile 暴露 `test` 目标

根目录 `Makefile` SHALL 提供名为 `test` 的目标，作为本仓库日常测试入口。该目标 MUST 被声明为 `.PHONY`，并 MUST 先执行本地 Gradle 分发包准备流程。

#### Scenario: 在干净工作树中调用 `make test`
- **WHEN** 开发者在仓库根目录下执行 `make test`
- **THEN** Make 调用 `./gradlew -Dorg.gradle.caching=false` 并显式调度 Tier A 任务
- **AND** 不触发 `clean / format / build / install / deploy` 等其它 Make 目标

#### Scenario: `test` 目标与其它目标并存
- **WHEN** 调用 `make help`
- **THEN** 输出文案中包含 `make test` 一行说明
- **AND** 既有 `clean / format / build / build-thin / install / deploy / stop / tree / projects` 条目的措辞和顺序保持不变

### Requirement: Tier A 默认覆盖核心模块与 NES Kafka smoke

`make test` MUST 显式调度以下 Gradle 测试任务：

1. `:spring-boot-project:spring-boot:test`
2. `:spring-boot-project:spring-boot-test:test`
3. `:spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test`

`make test` MUST NOT 调度 `spring-boot-system-tests:*` 子树下的任何 `test` 任务。

#### Scenario: Kafka smoke 被日常门禁覆盖
- **WHEN** 开发者执行 `make test`
- **THEN** Gradle 调度 `:spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test`
- **AND** `SampleKafkaApplicationTests.testVanillaExchange` 实际执行并通过

#### Scenario: 核心模块仍被覆盖
- **WHEN** `make test` 执行
- **THEN** 调用过程中调度 `:spring-boot-project:spring-boot:test`
- **AND** 调用过程中调度 `:spring-boot-project:spring-boot-test:test`

### Requirement: Makefile 内自描述

`Makefile` 中 `test` 目标的紧邻注释 MUST 说明：
- 当前目标的范围为 `spring-boot`、`spring-boot-test` 和 Kafka smoke；
- 当前承诺的语义为 Tier A 全绿门禁；
- Kafka smoke 使用 NES `spring-kafka-test` 对 fork Kafka 3.9.2 的 EmbeddedKafka 兼容能力，不需要外部 Kafka 服务。

#### Scenario: 阅读 Makefile 即可理解 Kafka smoke 覆盖
- **WHEN** 任意贡献者在不查阅 design.md 的情况下阅读 `Makefile`
- **THEN** 该贡献者能从 `test` 目标周围注释中获知 Kafka smoke 已纳入 `make test`
- **AND** 注释中不再声明 `spring-kafka-test 2.9.x` 与 fork Kafka 3.9.2 不兼容

### Requirement: smoke-test-kafka 恢复执行

`spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test` 的 `SampleKafkaApplicationTests` MUST 不再通过 `@Disabled` 整类跳过。该测试 MUST 使用 EmbeddedKafka 验证示例应用能够完成 Kafka 消息发送和消费。

#### Scenario: smoke-test-kafka 通过 EmbeddedKafka 验证收发
- **WHEN** 执行 `./gradlew :spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test`
- **THEN** `SampleKafkaApplicationTests.testVanillaExchange` 执行
- **AND** 消费者收到 `A simple test message`

### Requirement: test-feedback 不排除 Kafka smoke

`make test-feedback` MUST NOT 使用 `-x :spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test` 排除 Kafka smoke 测试。

#### Scenario: test-feedback 覆盖 Kafka smoke
- **WHEN** 执行 `make -n test-feedback`
- **THEN** 展开的命令中不包含 `-x :spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test`
