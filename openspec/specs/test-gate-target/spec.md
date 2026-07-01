## ADDED Requirements

### Requirement: test-gate 目标定义

`make test-gate` MUST 运行 Tier B 全部全绿模块的测试（Phase 1 模块 + 摸底后确认全绿的模块），跳过 checkstyle。

#### Scenario: test-gate 包含 Phase 1 模块
- **WHEN** 执行 `make test-gate`
- **THEN** 测试范围包含 `:spring-boot-project:spring-boot:test` 和 `:spring-boot-project:spring-boot-test:test`

#### Scenario: test-gate 包含 Tier B 全绿模块
- **WHEN** 执行 `make test-gate`
- **THEN** 测试范围包含摸底后确认全绿的 Tier B 模块
- **AND** 不包含摸底后仍有失败的模块

#### Scenario: test-gate BUILD SUCCESSFUL
- **WHEN** 执行 `make test-gate`
- **THEN** BUILD SUCCESSFUL，0 failures
