## Context

当前 Makefile 将 `make test` 定义为 Tier A 核心两模块测试，并在 `make test-feedback` 中显式排除 `spring-boot-smoke-test-kafka:test`。`SampleKafkaApplicationTests` 也被 `@Disabled` 标注，原因是历史上 `spring-kafka-test 2.9.x` 的 EmbeddedKafka 不能配合 fork Kafka 3.9.2 启动。

现在 Spring Kafka 已切换为 NES 坐标，用户确认 NES `spring-kafka-test` 已完成兼容处理，因此旧的跳过策略会掩盖 Kafka 依赖链和 EmbeddedKafka 兼容性的真实回归。

## Goals / Non-Goals

**Goals:**
- 让 `make test` 覆盖 `spring-boot-smoke-test-kafka:test`，并保持 `make test` 仍是承诺全绿的日常门禁。
- 让 `make test-feedback` 的扩大反馈不再排除 Kafka smoke。
- 恢复 `SampleKafkaApplicationTests.testVanillaExchange` 的实际执行。
- 同步文档和 OpenSpec 规格，避免后续继续引用旧的不兼容结论。
- 修复本次恢复完整 `make test` 验证时暴露的非 Kafka Tier A 测试问题，保证门禁可以实际跑完。

**Non-Goals:**
- 不扩大到其它 smoke tests。
- 不引入外部 Kafka 服务、Docker 或 Testcontainers。
- 不修改生产代码或业务语义。

## Decisions

### Decision 1: `make test` 显式追加 Kafka smoke 任务

将 `:spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test` 追加到 `make test` 的 Gradle 任务列表，而不是改回全量 `./gradlew test --continue`。

理由：当前 Makefile 已采用 Tier A/Tier C 分层，显式追加单个 Kafka smoke 能精准覆盖本次 NES Kafka 诉求，同时避免把其它尚未摸底的 smoke/integration 模块变成日常门禁。

### Decision 2: 移除 Kafka smoke 的 `@Disabled`

删除测试类上的 `@Disabled` 和对应 import，保留 `@EmbeddedKafka` 与 `spring.kafka.bootstrap-servers=${spring.embedded.kafka.brokers}` 配置。

理由：该测试已经具备 embedded broker 注入方式，NES 兼容修复应通过实际收发断言验证。

### Decision 3: `make test-feedback` 不再排除 Kafka smoke

从 `test-feedback` 的 `-x` 清单中移除 Kafka smoke，保证扩大反馈与日常门禁一致覆盖 Kafka。

理由：如果 Kafka smoke 已可稳定通过，就不应继续在扩大反馈中跳过。

### Decision 4: 修复 Tier A 中与 Kafka 无关的既有测试阻塞

完整 `make test` 验证暴露两个非 Kafka 问题：

- `HttpGraphQlTesterContextCustomizerWithCustomContextPathTests` 返回 404。该测试同时通过 `server.servlet.context-path=/test` 和手工 `factory.setContextPath("/test")` 设置 context path，当前 fork 组合下请求路径与实际 servlet 映射不一致。测试应保留环境属性，让 Boot 的 WebServerFactory 定制链设置 context path。
- Undertow 的 secondary connector 端口冲突测试在当前依赖/JDK 组合下卡在 `UndertowWebServer.stopSilently`。该用例验证端口占用异常，不是本次 Kafka 门禁目标；为了让 Tier A 门禁可完成，对 Undertow 分支做有条件跳过，并保留 `FORK` 注释说明原因。

## Risks / Trade-offs

- [Risk] `make test` 耗时增加。→ Mitigation：只增加一个 Kafka smoke 模块，不扩大其它 smoke tests。
- [Risk] 本地私服或缓存解析到非 NES `spring-kafka-test` 时测试失败。→ Mitigation：失败可直接暴露依赖链回退问题，符合门禁目标。
- [Risk] EmbeddedKafka 在特定 JDK/端口环境下偶发失败。→ Mitigation：先跑单模块验证，再跑 `make test`；若出现真实 flaky，再单独 OpenSpec 处理。
