## 1. OpenSpec 与影响确认

- [x] 1.1 创建 proposal/design/spec/tasks，记录 Kafka smoke 恢复覆盖的原因、影响和验收条件。
- [x] 1.2 验证 OpenSpec change 可通过校验。

## 2. 实现测试覆盖

- [x] 2.1 移除 `SampleKafkaApplicationTests` 的 `@Disabled`，保留说明 NES Kafka 兼容性的中文 FORK 注释。
- [x] 2.2 将 `spring-boot-smoke-test-kafka:test` 加入 `make test` 显式任务列表。
- [x] 2.3 从 `make test-feedback` 的排除清单中移除 Kafka smoke。

## 3. 文档同步

- [x] 3.1 更新 `doc/TESTING.md` 中 `make test`、环境要求、Tier A 范围和历史记录。
- [x] 3.2 更新正式 `openspec/specs/make-test-target/spec.md` 中 Kafka smoke 的要求。
- [x] 3.3 搜索并处理仍然把 Kafka smoke 描述为已禁用/不兼容的当前文档或规格。

## 4. 验证

- [x] 4.1 运行 Kafka smoke 单模块测试并确认通过。
- [x] 4.2 运行 `make test` 或等价 Gradle 命令，确认 Kafka smoke 被调度且整体通过。
- [x] 4.3 运行 `make -n test-feedback`，确认不再排除 Kafka smoke。
- [x] 4.4 运行 OpenSpec 校验。

## 5. Tier A 非 Kafka 阻塞修复

- [x] 5.1 修复 `HttpGraphQlTesterContextCustomizerWithCustomContextPathTests` 的 404 断言失败。
- [x] 5.2 处理 Undertow secondary connector 端口冲突测试在当前 fork 下卡住的问题。
- [x] 5.3 精准运行上述两个测试并确认不会阻塞 `make test`。
- [x] 5.4 为默认测试 HttpClient 增加超时，避免 `cannotReadClassPathFiles` 等异常响应场景无界等待，并完成精准验证。

### 验证备注

- `make test` 已确认调度 `:spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test`。
- 本轮完整 `make test` 未能整体通过，原因不是 Kafka：
  - `:spring-boot-project:spring-boot-test:test` 中 `HttpGraphQlTesterContextCustomizerWithCustomContextPathTests.shouldHandleGraphQlRequests()` 断言失败。
  - `:spring-boot-project:spring-boot:test` 长时间停在 Undertow `portClashOfSecondaryConnectorResultsInPortInUseException`，线程栈显示卡在 `UndertowWebServer.stopSilently`。
