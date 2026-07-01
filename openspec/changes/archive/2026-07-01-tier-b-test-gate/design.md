## Context

Phase 1 测试基线已验证（6308 条全绿），settings.gradle 裁剪已完成。Tier B 目标模块（TESTING.md §5）均已在 Gradle 项目树中保留，可直接运行测试。2.7 fork 经验表明，autoconfigure 模块通常有最多的 fork 适配需求（Banner 文本、版本号断言、GAV 硬编码等）。

## Goals / Non-Goals

**Goals:**
- 逐个摸底 7 个 Tier B 候选模块，获取准确的用例数/失败数。
- 对 fork 适配类失败进行修复（如 Banner、GAV 断言）。
- 将全绿模块纳入 `make test-gate`，不全绿但可接受的标注为待改进。
- 更新 TESTING.md 实测数据。

**Non-goals:**
- 不修复需要 Docker / 外部服务的测试失败。
- 不修改 `src/main` 业务逻辑。

## Decisions

### Decision 1：摸底采用逐模块串行方式

每个模块单独跑 `./gradlew :<path>:test -x checkstyleMain -x checkstyleTest`，记录结果后再跑下一个。避免并行时内存不足或日志交叉。

### Decision 2：test-gate 只纳入全绿模块

摸底后仍有失败的模块不进 test-gate（留 Tier C），避免 merge 门槛包含 flaky 测试。如果某模块仅有少量 fork 适配失败且可修复，修复后再纳入。

### Decision 3：test-gate 包含 Phase 1 模块

`make test-gate` 是 `make test` 的超集，包含 Phase 1 的 spring-boot + spring-boot-test，加上 Tier B 新增模块。

## Risks / Trade-offs

- **[autoconfigure 模块测试量大]** → 可能耗时 1h+，需有心理预期。
- **[fork 适配修复可能引入回归]** → 每次修复后重跑该模块验证。
- **[部分模块可能全部失败]** → 记录后跳过，不阻塞其他模块。
