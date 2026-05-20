## Why

`add-makefile-test-target` 完成后，`make test` 在 `:spring-boot-project:spring-boot-tools:spring-boot-gradle-plugin:test` 持续报约 961 条失败，几乎全部集中在 `org.springframework.boot.gradle.docs.*DocumentationTests`（GettingStarted / IntegratingWithActuator / ManagingDependencies / Packaging 等）。stack trace 指向 `java.util.zip.ZipException at ZipFile.java:1637`，根因是这些测试通过 Gradle Tooling API 启动子构建时，构建环境未预置可用的 Gradle distribution。该问题属于 G 类"gradle-plugin DocumentationTests 环境性失败"，单条修测试无效，必须从测试任务的运行配置或测试类层面解决。

## What Changes

候选实现路径（design 阶段二选一或综合）：
- **路径 A**：在 `spring-boot-tools/spring-boot-gradle-plugin/build.gradle` 为 `test` 任务追加 `systemProperty 'gradleDistributionPath', file("$gradle.gradleHomeDir")` 之类，让 Tooling API 能找到 distribution。
- **路径 B**：在该模块 `build.gradle` 的 `test` 任务配置中 `exclude '**/docs/*DocumentationTests*'`，把整组文档测试从 `make test` 范围中剔除（保留 `intTest` 中跑，本变更不动 intTest）。
- 更新 `make-test-target` capability 的 spec：G 类条目从"已知失败"中移除，残留数字下调 961 条。

## Capabilities

### New Capabilities
<!-- 无 -->

### Modified Capabilities
- `make-test-target`：G 类失败消除后，"承诺范围"与"已知失败分类"段落需要同步更新。

## Impact

- 受影响文件：`spring-boot-project/spring-boot-tools/spring-boot-gradle-plugin/build.gradle`。
- 不影响其它模块、Makefile 或 fork 源码。
- 风险：若选路径 B（排除测试类），DocumentationTests 在 `make test` 中失去覆盖；若选路径 A（配置 distribution），需确认 CI/本地环境下 `gradle.gradleHomeDir` 可用。
