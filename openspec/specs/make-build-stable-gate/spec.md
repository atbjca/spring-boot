# make-build-stable-gate Specification

## Purpose
`make build` / `make clean build` 作为可承诺的稳定绿灯门禁：全量编译打包与 checkstyle，测试范围为 Tier A。

## Requirements

### Requirement: make build is a stable green gate

`make build`（及 `make clean build`）MUST 在本机无 Docker/外部依赖的标准环境下稳定以成功结束。

#### Scenario: Connection reset does not fail the gate

- **WHEN** Tier A 测试因瞬时 `Connection reset` / 同类 reactor-netty 连接错误失败
- **THEN** Gradle TestRetry SHALL 自动重试该用例（最多 3 次），且高风险 Web 客户端 SHALL 对瞬时连接失败做有限次重试

#### Scenario: Build compiles without running full-suite tests

- **WHEN** 开发者执行 `make build`
- **THEN** Phase 1 SHALL 执行全仓库 `build` 但排除 `test` / `intTest` / `documentationTest` / asciidoctor 文档任务
- **AND** Phase 2 SHALL 复用 `make test`（Tier A：spring-boot + spring-boot-test + Kafka smoke）
