## Why

`make test-feedback` 跑 `spring-boot-smoke-tests` 子树时，`spring-boot-smoke-test-kafka` 报 1 条失败：`SampleKafkaApplicationTests.testVanillaExchange()`，根因是测试启动外部 Kafka broker 而环境未配置。此外，`spring-boot-gradle-plugin:test` 的 `BuildInfoDslIntegrationTests` 有 2 条失败（Gradle 7.6.3 相关），与 proposal 原估计的 5 个 smoke-test 不符，说明 data-jpa/flyway/hibernate52/test 在当前配置下未触发失败（可能在 settings.gradle ignoredSmokeTests 中已排除，或测试本身可稳定通过）。

本变更目标：决定 smoke-test-kafka 的去留（排除或修复），并同步更新 S 类在 `make-test-target` spec 中的描述。

## What Changes

- **调查结论（已更新）：** 原 proposal 高估范围，实际 smoke-test 失败仅 `spring-boot-smoke-test-kafka` 1 条。
- **决策：** 排除 `spring-boot-smoke-test-kafka`（`testVanillaExchange` 需真实 Kafka，外围环境不具备；修复路径引入 embedded-kafka 与 BOM 策略冲突风险大）。
- **BuildInfoDslIntegrationTests 2 条失败** 根因待单独调查（Gradle 7.6.3 兼容性），不列入本变更范围。
- 更新 `make-test-target` capability spec：将 `spring-boot-smoke-test-kafka` 纳入显式排除清单，S 类说明同步更新。

## Capabilities

### New Capabilities
<!-- 无 -->

### Modified Capabilities
- `make-test-target`：`spring-boot-smoke-test-kafka` 加入显式排除清单，S 类失败条目同步更新。

## Impact

- 受影响文件：
  - 排除路径：根 `Makefile`（test-feedback 的 -x 清单追加 `:spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test`）
- 不影响 smoke-test-data-jpa/flyway/hibernate52（当前状态：通过）
- 风险：排除后 kafka 功能本身失去 CI 覆盖；后续若引入 embedded-kafka 可重新纳入。
