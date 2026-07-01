## Why

`add-makefile-test-target` 完成后，`make test` 在 `:spring-boot-project:spring-boot-tools:spring-boot-gradle-plugin:test` 持续报约 961 条失败，几乎全部集中在 `org.springframework.boot.gradle.docs.*DocumentationTests`。stack trace 指向 `java.util.zip.ZipException at ZipFile.java:1637`，根因是这些测试通过 Gradle Tooling API 启动子构建时，**构建进程找不到本地 Gradle distribution**，转而从 Tencent mirror 下载（默认 fallback），在隔离网络环境下下载失败或超时。

`GradleBuild` 使用 `GradleDistributionLocator` 解析 Gradle distribution，支持通过 `NES_GRADLE_DISTRIBUTIONS_DIR` / `nes.gradle.distributions.dir` 指定本地查找目录，也支持 `NES_GRADLE_DISTRIBUTIONS_MIRROR` 指定下载镜像。当前 `~/.gradle/gradle.properties` 未配置这些，且 `GradleDistributionLocator` 的 fallback 默认路径是 `~/dev`（对 NES fork 而言不够明显）。

## What Changes

通过两个层次固化配置，确保 DocumentationTests 在任何环境下都能找到本地 Gradle distribution：

1. **修改 `GradleDistributionLocator` 默认 fallback** — 将 hardcoded `~/dev` 改为 `~/.gradle/gradle-distributions`，放在 `.gradle` 目录下更符合约定。
2. **在 `~/.gradle/gradle.properties` 配置** — 添加 `systemProp.nes.gradle.distributions.dir=~/dev`，确保 Gradle 进程启动时即有配置，不依赖环境变量。
3. **更新 `make-test-target` capability spec** — 将 G 类"gradle-plugin DocumentationTests"条目从"已知失败"中移除。

## Capabilities

### New Capabilities
<!-- 无 -->

### Modified Capabilities
- `make-test-target`：G 类 gradle-plugin DocumentationTests 失败已消除，"已知失败分类"段落同步更新。

## Impact

- 受影响文件：
  - `spring-boot-project/spring-boot-tools/spring-boot-gradle-test-support/src/main/java/.../GradleDistributionLocator.java`（改默认 fallback）
  - `~/.gradle/gradle.properties`（用户侧配置，需用户确保已添加）
- 不影响其它模块、Makefile 或 fork 源码。
- 风险：用户首次运行前需确保 `~/.gradle/gradle.properties` 已包含配置，否则 fallback 到 `~/.gradle/gradle-distributions`（新默认），该目录需存在或有解压好的 Gradle。
