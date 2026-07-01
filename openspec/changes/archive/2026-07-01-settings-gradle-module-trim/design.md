## Context

`settings.gradle` 当前为上游全量 include：55 个 starter（通过 `eachDirMatch` 动态扫描）、90+ 个 smoke-test（同上）、以及 CLI / Docs 等 5 个显式 include 的工具模块。`TESTING.md §8` 已定稿裁剪清单，2.7 fork 已验证 `ignoredStarters` / `ignoredSmokeTests` Set 过滤模式。

## Goals / Non-Goals

**Goals:**
- 在 `settings.gradle` 中落地 `TESTING.md §8` 定稿清单，排除不发布的 starter / smoke-test / 工具模块。
- 沿用 2.7 fork 的 `Set + eachDirMatch` 过滤模式，保持上游 rebase 友好。
- 裁剪后 `make build-thin` 和 `make test` 全绿。

**Non-goals:**
- 不删除被排除模块的物理目录。
- 不修改任何模块的 `build.gradle`。
- 不实施 Tier B 测试摸底。

## Decisions

### Decision 1：使用 Set 排除而非显式 include

沿用 2.7 模式：定义 `ignoredStarters` / `ignoredSmokeTests` 集合，在 `eachDirMatch` 回调中过滤。

- **替代方案**：改为显式逐行 include 保留的模块。
- **否决原因**：上游新增模块时需手动补行，rebase 更容易冲突；排除列表改动更小。

### Decision 2：不发布的显式模块直接注释

CLI / Docs / Antlib / Changelog-generator / Properties-migrator 是逐行 `include` 的，直接注释掉最简洁，保留原始行便于将来恢复。

### Decision 3：排除 system-tests 和部分 integration-tests

`spring-boot-deployment-tests` 和 `spring-boot-image-tests`（system-tests）依赖 Docker，已在 `make build-thin` 中通过 `-x` 排除 assemble，但仍参与 Gradle 配置阶段。从 settings 排除可减少配置耗时。

同理排除 `launch-script-tests`、`loader-tests`、`loader-classic-tests`、`sni-tests`（均需特殊环境）。保留 `configuration-processor-tests` 和 `server-tests`（Tier B/C 可能用到）。

## Risks / Trade-offs

- **[上游新增 starter/smoke-test 默认被 include]** → 可接受，新模块加入构建后若构建失败再评估是否排除。
- **[注释掉的 include 与上游 rebase 冲突]** → 冲突概率低（这些行很少被上游修改），冲突时手动解决即可。
