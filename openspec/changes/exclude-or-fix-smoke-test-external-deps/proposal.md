## Why

`add-makefile-test-target` 完成后，`make test` 因 spring-boot-smoke-tests 子树被纳入而新增 5 个失败模块（约 17 条用例），全部因外部组件缺失：
- `spring-boot-smoke-test-data-jpa`（H2 / JPA contextLoad 系列）
- `spring-boot-smoke-test-flyway`（数据库迁移）
- `spring-boot-smoke-test-hibernate52`（Hibernate context loading）
- `spring-boot-smoke-test-kafka`（缺 Kafka broker）
- `spring-boot-smoke-test-test`（SampleTestApplicationWebIntegrationTests）

这是 S 类残留。本变更目标：决定每个 smoke-test 的去留 —— 排除（最小代价）或为其配置内嵌组件（最大覆盖）。

## What Changes

- 调查每个失败 smoke-test 的根因（是否单纯外部依赖、是否可用 H2/embedded-kafka 替代）。
- 决策矩阵（design 阶段产出）：
  - 排除：在根 `Makefile` 的 `test` 目标 `-x` 清单中追加这些子项目。
  - 修复：在对应 smoke-test 的 `build.gradle` 或 `src/test/resources/application.properties` 中加入内嵌组件配置 / `@DisabledIf` 条件 / 测试断言放宽。
- 更新 `make-test-target` capability 的 spec：S 类条目从"已知失败"中移除或更新；若选择排除路径，同时在 spec 中列入"显式排除清单"。

## Capabilities

### New Capabilities
<!-- 无 -->

### Modified Capabilities
- `make-test-target`：根据决策结果更新"显式排除清单"或"已知失败分类"。

## Impact

- 受影响文件（视决策路径）：
  - 排除路径：根 `Makefile`。
  - 修复路径：上述 5 个 smoke-test 各自的 `build.gradle` 与 / 或测试资源。
- 不影响 fork 其它源码、其它模块或 capability。
- 风险：修复路径需引入 embedded-kafka 等依赖，可能与 fork 的 BOM 策略冲突，design 阶段评估。
