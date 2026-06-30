## Context

本仓库分支 `3.5.x-bjca-patch` 已 reset 到 3.5.15 基线（`5bafd0a6bf1`，`version=3.5.15-SNAPSHOT`）。关键依赖：Framework 6.2.19、Security 6.5.11、Netty 4.1.135、Jackson 2.21.4、Tomcat 10.1.55、Logback 1.5.34。

参考实现：`origin/2.7.x-bjca-patch`（31 项需求，GAV 改造自 [需求-018]）。3.5 与 2.7 差异：Java 17+ 基线、Jakarta EE（Tomcat 10.x）、`buildSrc` API 演进（`DeployedPlugin` 结构变化）、Configuration Cache 已启用、模块集不同。

用户决策（2026-06-25）：
1. 只读 `origin/3.5.x`，fork 改动仅在 `3.5.x-bjca-patch`。
2. Framework 6.2 fork 有计划但 Phase A 暂用官方坐标（EOL 2026-06-30）。
3. Logback 1.5.x 暂用官方（actively developed）。
4. 基线 3.5.15，fork 版本 `3.5.15-nes.patch.1-SNAPSHOT`。

## Goals / Non-Goals

**Goals:**
- Boot 层完整 GAV rebranding，发布到 Nexus 私服。
- 子模块 `build.gradle` 零修改（依赖 `resolutionStrategy` 透明替换 Boot 内部坐标）。
- `SpringBootVersion.getVersion()` 返回 `3.5.15`（非 `-nes.patch` 后缀）。
- 提供 `make build-thin` / `make install` / `make deploy` 开发者入口。
- 建立 `doc/REQUIREMENTS.md` 与 `doc/NES_GAV_MAPPING.md`（3.5 兼容链）。

**Non-Goals:**
- Framework / Security / Logback fork（Phase B）。
- 模块精简、Banner 定制、CVE 手动升级（上游 3.5.15 已含 Netty 4.1.135 / Jackson 2.21.4）。
- `make test`、JPMS、smoke-test 排除（独立 change）。
- A 类组件 `exclude org.springframework`（Phase B 随 Framework fork 一并处理）。

## Decisions

### Decision 1：基线 commit 选 5bafd0a6bf1（3.5.15 时代末点）

3.5.15 RELEASE tag 本地尚未 fetch 到；`5bafd0a6bf1` 是 `93edd167`（3.5.16-SNAPSHOT 起点）的前一个 commit，包含 3.5.15 全部依赖升级。首条 fork commit 将 `version` 改为 `3.5.15-nes.patch.1-SNAPSHOT`。

**替代方案（否决）**：锚定 `v3.5.15` tag — tag 可用后可用 `git reset --hard v3.5.15` 微调，功能等价。

### Decision 2：Phase A 仅映射 Boot 自身 GAV，Framework/Security 保留官方

`resolutionStrategy.eachDependency` Phase A 只处理 Boot 模块发布侧（`group = cn.bjca.footstone.bpring.boot`），**不**添加 2.7 的 Framework/Security 映射规则（因 fork 制品尚不存在）。

**理由**：避免构建解析指向不存在的 `6.2.19-nes.patch.1-SNAPSHOT`。
**代价**：SCA 仍扫描到 `org.springframework:*` 传递依赖。

### Decision 3：Logback 保持官方 `ch.qos.logback`

Boot 3.5.15 BOM 管理 Logback 1.5.34，官方 actively developed，无需 bogback fork。

### Decision 4：从 2.7 移植 buildSrc 发布修复

必须适配 3.5 上游 `DeployedPlugin`（比 2.7 精简，缺 artifactId 显式设置）：
- `DeployedPlugin.java`：添加 `forkArtifactPrefix` → artifactId 替换逻辑（同 2.7 方案 B）。
- `BomPlugin.java` / `MavenPluginPlugin.java`：BOM 与 Maven 插件 groupId 动态传播。
- `buildSrc/build.gradle`：buildSrc 独立构建单元，需直接声明 fork 坐标或读取 `gradle.properties`。

### Decision 5：settings.gradle 项目名动态替换

```groovy
rootProject.name="${forkArtifactPrefix}-boot-build"
rootProject.children.each { ... replace "spring-boot" with "${forkArtifactPrefix}-boot" }
```

目录名保持 `spring-boot-*`（物理路径不变），Gradle 项目名变为 `bjca-footstone-bpring-boot-*`。

### Decision 6：Nexus 仓库配置

参考 2.7 `build.gradle` + `gradle.properties`（`nexusPublicUrl`、`nexusSnapshotUrl`、`nexusReleaseUrl`、credentials）。credentials 通过 `gradle.properties` 或环境变量注入，**不**提交明文密码。

## Risks / Trade-offs

- **[Framework 6.2 EOL 2026-06-30]** → Phase B 必须在 EOL 后尽快启动 fork，否则无社区安全补丁。
- **[SCA 不完整]** → Phase A 仅 Boot 坐标规避；下游 SCA 仍可能因 Framework 坐标报 CVE。文档中明确标注。
- **[buildSrc API 差异]** → 3.5 `DeployedPlugin` 结构与 2.7 不同，不能直接 copy-paste，需逐文件适配。
- **[Configuration Cache]** → 新增 `resolutionStrategy` 规则需验证与 configuration cache 兼容性。
- **[3.5.15-SNAPSHOT vs RELEASE]** → 基线 commit 的 `gradle.properties` 仍为 `-SNAPSHOT` 后缀；fork 首 commit 统一改为 `-nes.patch.1-SNAPSHOT` 并设 `springBootVersion=3.5.15`。

## Migration Plan

1. Reset 分支到 3.5.15 基线（已完成）。
2. 按 tasks.md 顺序实施 GAV 配置 → buildSrc → 根 build.gradle → settings.gradle → BOM → 文档。
3. `make build-thin` 验证编译通过。
4. `make install` 验证本地 Maven 仓库 GAV 正确。
5. `make deploy` 验证 Nexus 发布（需私服可达）。
6. Phase B 独立 change：Framework 6.2.x + Security 6.5.x fork 及映射规则。

## Open Questions

- Nexus credentials 注入方式：沿用 2.7 的 `gradle.properties` 本地模板还是 CI 环境变量？
- 是否在 Phase A 同步删除/置空默认 Banner（2.7 做了，3.5 是否跟随）？
- `v3.5.15` tag fetch 到本地后是否 rebase 到 tag 精确点？
