## Why

当前 `make test` 仅覆盖 `spring-boot` + `spring-boot-test` 两个核心模块（6308 条），作为 Phase 1 过渡门槛。`TESTING.md §5` 已定义 Tier B 目标模块（autoconfigure / actuator / maven-plugin 等 7 个），但尚未摸底实测，无法确定哪些能全绿、哪些需适配。需要逐个运行这些模块的测试，记录结果，将全绿模块纳入 `make test-gate` 作为正式 merge 门槛。

## What Changes

- 逐个运行 7 个 Tier B 候选模块的测试，记录用例数和失败情况。
- 分析失败原因（fork 适配 vs 环境性 vs 真实 bug），对可修复的 fork 适配问题进行修复。
- 在 Makefile 中实现 `make test-gate` 目标，纳入所有全绿模块。
- 更新 `doc/TESTING.md` §5 / §6 的实测数据。

### Non-goals

- 不追求 Tier C 范围（smoke-test / Docker 依赖项）。
- 不修复环境性失败（Docker / 外部中间件依赖的测试）。
- 不修改业务逻辑源码（`src/main`）来迁就测试。

## Capabilities

### New Capabilities

- `test-gate-target`: Makefile `test-gate` 目标定义，包含 Tier B 全绿模块列表。

### Modified Capabilities

- `fork-build-tooling`: Makefile 新增 `test-gate` 目标。

## Impact

- **Makefile**：新增 `test-gate` 目标。
- **测试源码**：可能需要小范围适配（Banner 文本、GAV 断言等 fork 相关硬编码）。
- **doc/TESTING.md**：更新实测数据和 Tier B 模块状态。
- **merge 门槛**：从 Phase 1（2 模块）升级到 Tier B（N 模块）。
