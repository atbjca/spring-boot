## Why

`settings.gradle` 仍为上游全量 include（55 个 starter、90+ smoke-test、CLI / Docs 等工具模块），`make build-thin` 编译了大量不发布的模块，浪费构建时间且增加维护噪音。`TESTING.md §8` 已定稿了保留/排除清单，但尚未落地到构建脚本。

## What Changes

- 在 `settings.gradle` 中添加 `ignoredStarters` 和 `ignoredSmokeTests` 排除集合（沿用 2.7 fork 的 `Set + eachDirMatch` 过滤模式）。
- 注释掉 5 个不发布的显式 include 模块：`spring-boot-cli`、`spring-boot-docs`、`spring-boot-antlib`、`spring-boot-configuration-metadata-changelog-generator`、`spring-boot-properties-migrator`。
- 排除 19 个不发布的 Starter（`TESTING.md §8.1` 清单）。
- 排除 28+ 个 Smoke-test（`TESTING.md §8.4` 继承 2.7 + 3.5 追加清单）。
- 验证裁剪后 `make build-thin` 和 `make test` 仍全绿。

### Non-goals

- 不修改任何模块的 `build.gradle` 源码。
- 不删除被排除模块的物理目录（仅不参与 Gradle 构建）。
- 不实施 Tier B 测试摸底（留下一个 change）。

## Capabilities

### New Capabilities

- `settings-module-trim`: settings.gradle 模块裁剪规则，定义 ignoredStarters / ignoredSmokeTests / 显式排除模块的完整清单与过滤机制。

### Modified Capabilities

- `fork-build-tooling`: `build-thin` 现在仅编译保留模块，构建时间显著缩短。

## Impact

- **构建脚本**：仅修改 `settings.gradle` 一个文件。
- **构建产物**：被排除的 starter 和 smoke-test 不再参与编译和发布。
- **`make build-thin`**：编译范围缩小，耗时减少。
- **`make test`**：不受影响（测试范围由 Makefile 中的 Gradle 任务路径控制，与 settings.gradle 无关）。
- **上游 rebase**：排除列表模式与上游 `eachDirMatch` 兼容，新增 starter/smoke-test 默认被 include，仅需评估是否加入排除列表。
