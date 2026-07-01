## Context

`GradleDistributionLocator` 负责在 TestKit 运行子构建时解析 Gradle distribution。查找链：

1. `NES_GRADLE_DISTRIBUTIONS_DIR` env 或 `nes.gradle.distributions.dir` system property → 指定目录
2. fallback 默认值：`~/dev`（当前 hardcoded）
3. 若目录下无解压好的 Gradle，尝试从 `NES_GRADLE_DISTRIBUTIONS_MIRROR` 下载（默认腾讯镜像）

DocumentationTests 失败的根因：`make test` 进程未设 `NES_GRADLE_DISTRIBUTIONS_DIR`，且 `~/dev` 目录下有 Gradle 但 TestKit 请求的版本（如 7.2-all）只有 zip 没有解压，下载时网络不可达导致 ZipException。

## Goals / Non-Goals

**Goals:**
- DocumentationTests 在 `make test` 中稳定通过，消除 961 条 G 类失败
- 配置可追溯：后来人能看出 distribution 查找路径是刻意配置的

**Non-Goals:**
- 不改 GradleBuild 的查找逻辑核心
- 不引入新的 external dependency
- 不在 Makefile 里显式传 env var（避免 `make test` 语义膨胀）

## Decisions

### 决策 1：改 `GradleDistributionLocator` 默认 fallback

**现状：** `Paths.get(System.getProperty("user.home"), "dev")`

**改为：** `Paths.get(System.getProperty("user.home"), ".gradle", "gradle-distributions")`

**理由：**
- 放在 `.gradle/` 下符合 Gradle 社区约定，用户看到 `.gradle/gradle-distributions/` 能推断其作用
- 原 `~/dev` 过于通用，挪 gradle distributions 到 `.gradle/` 更内聚

### 决策 2：在 `~/.gradle/gradle.properties` 配置

添加：
```properties
systemProp.nes.gradle.distributions.dir=~/dev
```

**理由：**
- `systemProp.` 前缀使 Gradle 进程 JVM 一启动就有此 system property，被 `GradleDistributionLocator.resolveLocalDir()` 的 `System.getProperty()` 读取
- 无需改环境变量、shell profile，对 IDE 启动的 Gradle 进程也生效
- 用户侧配置，后续可迁移到项目级 `.gradle/gradle.properties`（如果需要）

## Risks / Trade-offs

- [Risk] 用户首次运行前 `~/.gradle/gradle-properties` 可能已有配置覆盖，或无权限修改 → Mitigation：在 TESTING.md 注明"首次运行前需确保配置"，并提供快速检查命令
- [Risk] `~/.gradle/gradle-distributions` 新目录默认不存在，fallback 到此时若无解压 Gradle 仍会尝试下载 → Mitigation：文档说明用户应将 Gradle distributions 放在 `NES_GRADLE_DISTRIBUTIONS_DIR` 指定目录（`~/dev`）中
