## Why

Spring Kafka 已切换到 NES 版本，用户确认 NES `spring-kafka-test` 已兼容 fork Kafka 3.9.2 的 EmbeddedKafka 场景。仓库当前仍按旧结论跳过 `spring-boot-smoke-test-kafka`，导致 `make test` 无法覆盖 Kafka 基础收发回归。

## What Changes

- 恢复 `SampleKafkaApplicationTests.testVanillaExchange` 的执行，不再用 `@Disabled` 跳过 Kafka smoke 测试。
- 将 `spring-boot-smoke-test-kafka:test` 纳入 `make test` 的显式任务清单，作为 NES Kafka 兼容性的日常门禁。
- 从 `make test-feedback` 的 `-x` 排除清单中移除 Kafka smoke 测试。
- 更新测试策略文档和 OpenSpec 规格，替换“spring-kafka-test 2.9.x 与 Kafka 3.9.2 不兼容”的历史结论。

## Capabilities

### New Capabilities

### Modified Capabilities
- `make-test-target`: `make test` 必须覆盖 NES Kafka smoke 测试，`make test-feedback` 不得再排除 Kafka smoke 测试。

## Impact

- 受影响文件：`Makefile`、`doc/TESTING.md`、`openspec/specs/make-test-target/spec.md`、`spring-boot-smoke-test-kafka` 测试类。
- 运行影响：`make test` 会启动 EmbeddedKafka，耗时增加，但不依赖外部 Kafka 服务或 Docker。
- 风险点：若私服解析回非 NES `spring-kafka-test`，Kafka smoke 会重新暴露兼容性失败；这正是本变更希望纳入门禁的回归信号。
