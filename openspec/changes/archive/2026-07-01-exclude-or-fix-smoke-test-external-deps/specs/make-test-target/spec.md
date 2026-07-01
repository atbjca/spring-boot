# make-test-target Specification Delta

## MODIFIED Requirements

### Requirement: Makefile 内自描述

~~`make test` 的 `-x` 排除清单 MUST 包含且仅包含以下任务路径（不多少许），且每条在 `Makefile` 注释中给出单行原因~~

`Makefile` 中 `test` 目标的紧邻注释 MUST 说明：
- 当前目标的范围（三个子树）；
- 7 条 `-x` 排除项各自的单行原因；
- 当前承诺的语义（"完整反馈面优先"，非"全绿"）；
- 已知 flaky/E 类失败的归类说明（E 类未定位 / smoke-tests 外部依赖 / 已定位但偶发的 flaky 如 `TomcatReactiveWebServerFactoryTests.sslWithValidAlias`）。

~~已知 flaky/E 类失败的归类说明（E 类未定位 / smoke-tests 外部依赖 / 已定位但偶发的 flaky 如 `TomcatReactiveWebServerFactoryTests.sslWithValidAlias`）。~~

**说明：** gradle-plugin DocumentationTests 已通过 `NES_GRADLE_DISTRIBUTIONS_DIR` 配置解决，不再列入已知失败。

#### Scenario: 阅读 Makefile 即可理解 E 类 flaky 现状
- **WHEN** 任意贡献者在不查阅 design.md 的情况下阅读 `Makefile`
- **THEN** 该贡献者能从 `test` 目标周围注释中获知范围、排除项与"已知红"清单的存在
- **AND** 注释中明确列出 `TomcatReactiveWebServerFactoryTests.sslWithValidAlias` 为已知偶发 flaky（已通过 `@RepeatedTest(10)` 处置）
- **AND** 注释中不再提及"D 类 JPMS"（该类失败已在 `add-jpms-open-for-tests` 中通过 `--add-opens=java.base/java.net=ALL-UNNAMED` 修复）
- **AND** 注释中不再将 gradle-plugin DocumentationTests 列为已知失败（已通过 `NES_GRADLE_DISTRIBUTIONS_DIR` 配置解决）
- **AND** 注释中列出 `spring-boot-smoke-test-kafka` 为 S 类外部依赖排除（`testVanillaExchange` 需真实 Kafka broker）

~~注释中不再将 gradle-plugin DocumentationTests 列为已知失败（已通过 `NES_GRADLE_DISTRIBUTIONS_DIR` 配置解决）~~

### Requirement: smoke-test-kafka 显式排除

`spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test` MUST 在 `test-feedback` 的 `-x` 排除清单中，理由为"S 类：testVanillaExchange 需真实 Kafka broker，NES fork 环境未配置"。

#### Scenario: smoke-test-kafka 被显式排除
- **WHEN** `make test-feedback` 执行
- **AND** `spring-boot-smoke-test-kafka` 未从 `-x` 清单中移除
- **THEN** `SampleKafkaApplicationTests.testVanillaExchange()` 不会被调度
- **AND** `make test-feedback` 不会因 kafka broker 缺失而失败
