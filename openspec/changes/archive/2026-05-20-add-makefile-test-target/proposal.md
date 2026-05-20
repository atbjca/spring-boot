## Why

当前 `Makefile` 暴露了 `clean / format / build / build-thin / install / deploy` 等常用 Gradle 封装目标，但没有任何执行单元测试的快捷入口。日常 TDD 循环只能手敲 `./gradlew test`，与 Makefile 整体风格不一致，也让"先跑测试再提交"的习惯缺少一个统一约定的入口。本次变更为 TDD 工作流补齐这一基础命令。

## What Changes

- 在根目录 `Makefile` 中新增 `test` 目标，封装 `./gradlew test`，覆盖工程内全部 Gradle 模块的单元测试。
- 在 `help` 目标的输出文案中新增对 `make test` 的一行说明，使其与现有目标保持同一风格（中文说明 + 大致耗时占位）。
- 将 `test` 加入 `.PHONY` 列表，避免与同名文件冲突。
- 不引入 `intTest` / `check` / 模块过滤 / 类过滤等更细粒度目标（参见 Non-goals）。

### Non-goals

- 不修复任何当前失败的单元测试；只提供执行入口。
- 不接入 `intTest`：当前注释已说明高级集成测试受限于 docker / 指定 IP 等环境前置条件，待环境就绪后再单独提案。
- 不改动 `build` / `build-thin` 等既有目标的语义或依赖关系。

## Capabilities

### New Capabilities

- `make-test-target`: Makefile 层面执行 Gradle 单元测试的统一入口及其帮助文案约定。

### Modified Capabilities

<!-- 无 -->

## Impact

- 受影响文件：根目录 `Makefile`。
- 不影响 Gradle 构建脚本、CI 配置、源代码或依赖关系。
- 对开发者工作流的影响：新增一个被推荐的 TDD 入口命令 `make test`；既有命令行为不变。
