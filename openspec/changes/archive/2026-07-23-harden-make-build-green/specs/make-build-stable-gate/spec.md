## ADDED Requirements

### Requirement: make build is a stable green gate

`make build`（及 `make clean build`）MUST 在本机无 Docker/外部依赖的标准环境下稳定以 `BUILD SUCCESSFUL` 结束。

#### Scenario: Connection reset does not fail the gate

- **WHEN** 某个测试因瞬时 `Connection reset` / 同类 reactor-netty 连接错误失败
- **THEN** Gradle TestRetry SHALL 自动重试该用例（最多 3 次），且高风险 Web 客户端 SHALL 对 GET 做有限次重试

#### Scenario: Known environmental failures are excluded

- **WHEN** 开发者执行 `make build`
- **THEN** 构建 SHALL 排除与 `make test-feedback` 文档化清单一致的环境性必红任务（Docker / Thymeleaf autoconfigure 测试等），不得因此失败
