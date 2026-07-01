## Context

`make test-feedback` 覆盖 smoke-tests 子树时，`spring-boot-smoke-test-kafka:test` 报 `SampleKafkaApplicationTests.testVanillaExchange()` 失败，原因是测试依赖外部 Kafka broker，NES fork 环境未配置。

## Goals / Non-Goals

**Goals:**
- `make test-feedback` 在 smoke-tests 子树不再因 kafka 测试失败阻断反馈

**Non-Goals:**
- 不修复 kafka 测试本身（引入 embedded-kafka 或配置真实 broker）
- 不影响 smoke-test-data-jpa/flyway/hibernate52（当前已通过）
- BuildInfoDslIntegrationTests Gradle 7.6.3 失败不列入本变更（需单独调查）

## Decisions

### 决策：排除 smoke-test-kafka

在 `Makefile` 的 test-feedback `-x` 清单中追加：
```
-x :spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test
```

**理由：**
- 最小代价，无需引入新依赖或修改测试代码
- `testVanillaExchange` 本身是集成测试，需要真实 Kafka，不适合在 `make test-feedback` Tier C 反馈中强制通过
- 后续若引入 embedded-kafka，可移除此排除

## Risks / Trade-offs

- [Risk] kafka 功能失去 CI 覆盖 → Mitigation：文档中注明，后续引入 embedded-kafka 后恢复
