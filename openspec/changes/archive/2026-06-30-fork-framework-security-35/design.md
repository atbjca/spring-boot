## Context

Phase A（`bootstrap-boot-3515-nes-fork`，已归档）在 `3.5.x-bjca-patch` 上完成 Boot GAV rebranding，`make build-thin` 与 `make test` 已验证。当前 `springFrameworkVersion=6.2.19`、`spring-boot-dependencies` BOM 仍引用官方 Framework / Security。

参考实现：`origin/2.7.x-bjca-patch` 的 `resolutionStrategy.eachDependency` + BOM fork 条目 + `buildSrc` 坐标切换。2.7 版本参数：`springFrameworkVersion=5.3.39-nes.patch.1-SNAPSHOT`、`springSecurityVersion=5.8.16-nes.patch.1-SNAPSHOT`。

Framework / Security 源码 fork 在**独立仓库**完成并发布到 Nexus；本 change 仅让 Boot fork **消费**这些制品。

## Goals / Non-Goals

**Goals:**
- Boot 构建解析 Framework / Security 为 fork GAV，子模块 `build.gradle` 零修改。
- BOM 管理的 Framework / Security 版本与 `gradle.properties` 一致。
- `buildSrc` 独立编译使用 fork Framework 坐标。
- SCA 扫描 Boot 传递依赖时不再出现官方 `org.springframework` / `org.springframework.security` groupId。
- 更新 GAV 映射文档。

**Non-Goals:**
- Framework / Security 源码 fork 与 CVE 修复（独立仓库 change）。
- Logback / Spring Data / Session 等生态组件 fork。
- A 类组件 `exclude org.springframework` 规则（随各生态 fork 逐步添加）。

## Decisions

### Decision 1：Framework groupId 映射为 `${forkGroupIdBase}`，Security 为 `${forkGroupIdBase}.security`

与 2.7 一致：
- `org.springframework:spring-xxx` → `${forkGroupIdBase}:${forkArtifactPrefix}-xxx:${springFrameworkVersion}`
- `org.springframework.security:spring-security-xxx` → `${forkGroupIdBase}.security:${forkArtifactPrefix}-security-xxx:${springSecurityVersion}`

artifactId 替换规则：`spring-` → `${forkArtifactPrefix}-`，`spring-security-` → `${forkArtifactPrefix}-security-`。

### Decision 2：BOM 使用 imports 而非逐模块列举

`spring-boot-dependencies` 中 Framework / Security 条目改为：
```groovy
group(forkGroupIdBase) { imports = [forkArtifactPrefix + "-framework-bom"] }
group(forkGroupIdBase + ".security") { imports = [forkArtifactPrefix + "-security-bom"] }
```
字符串拼接避免 GString 类型转换问题（3.5 BOM DSL 要求 `java.lang.String`）。

### Decision 3：buildSrc 必须直接声明 fork 坐标

buildSrc 先于主项目编译，根 `resolutionStrategy` 不作用于 buildSrc。参考 2.7：
```groovy
implementation(platform("${forkGroupIdBase}:${forkArtifactPrefix}-framework-bom:${springFrameworkVersion}"))
implementation("${forkGroupIdBase}:${forkArtifactPrefix}-context")
```

### Decision 4：Nexus content filter 扩展

Phase A 的 `includeGroupByRegex('cn\\.bjca\\.footstone\\.bpring(\\..+)?')` 已覆盖 `.security` 子包，无需额外仓库配置。

### Decision 5：前置条件 — Framework / Security fork 制品须先发布

实施本 change 前，须在 Nexus 验证以下制品可达：
- `cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1-SNAPSHOT`
- `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-bom:6.5.11-nes.patch.1-SNAPSHOT`

若制品不存在，先完成 Framework / Security 独立仓库 fork，或临时 `mavenLocal()` 安装。

## Risks / Trade-offs

- **[制品未就绪]** → 构建失败。缓解：实施前检查 Nexus，文档标注前置步骤。
- **[Configuration Cache]** → 新增 resolutionStrategy 规则需验证兼容性（Phase A 已启用 STABLE_CONFIGURATION_CACHE）。
- **[A 类生态组件]** → Spring Data / GraphQL 等仍传递官方 Spring 坐标。缓解：文档标注，后续独立 change 处理。
- **[版本漂移]** → Framework / Security fork 独立发版。缓解：`gradle.properties` 单点管理版本号。

## Migration Plan

1. 确认 Nexus 上 Framework / Security fork SNAPSHOT 制品存在。
2. 更新 `gradle.properties` 版本参数。
3. 添加 `resolutionStrategy.eachDependency` 规则。
4. 更新 `spring-boot-dependencies` BOM 条目。
5. 切换 `buildSrc/build.gradle` 依赖坐标。
6. `make build-thin` 验证编译。
7. `make test` 验证核心测试。
8. 更新 `doc/NES_GAV_MAPPING.md`。

## Open Questions

- Framework / Security 独立仓库是否已有 `6.2.x-bjca-patch` / `6.5.x-bjca-patch` 分支？
- Authorization Server（`spring-security-oauth2-authorization-server`）是否纳入 Security fork BOM？
- 是否在本 change 同步添加 A 类组件的 `exclude org.springframework` 规则？
