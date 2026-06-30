## Why

Spring Boot 3.5 是 3.x 线的最终维护版本，Spring Framework 6.2 社区支持将于 2026-06-30 结束。企业需要在 SCA 合规前提下长期维护 Boot 3.5 应用，但当前 `3.5.x-bjca-patch` 分支仍是纯上游代码（`org.springframework.boot`），未建立 NES fork 体系。Spring Boot 2.7 fork（`2.7.x-bjca-patch`）已验证 GAV rebranding + 私服发布 playbook，现需将其移植到 3.5.15 基线。

## What Changes

- 将 `3.5.x-bjca-patch` 工作分支锚定到 **3.5.15 RELEASE** 对应 commit（`5bafd0a6bf1`），不修改 `origin/3.5.x`。
- 引入 NES 版本体系：`3.5.15-nes.patch.1-SNAPSHOT`，`springBootVersion=3.5.15`。
- 移植 2.7 fork 的 GAV 核心配置（`forkGroupIdBase`、`forkArtifactPrefix`）及 Boot 层 rebranding（`build.gradle`、`settings.gradle`、`buildSrc`）。
- 建立 Nexus 私服发布链路（`publish` / `publishToMavenLocal`）。
- 新增 `Makefile`（`build-thin`、`install`、`deploy` 等），参考 2.7 模式。
- **Phase A 范围**：Boot 自身 GAV rebranding；Framework / Security **暂用官方坐标**（`6.2.19` / `6.5.11`）；Logback **暂用官方 1.5.34**。
- 新增 `doc/REQUIREMENTS.md` 首条需求记录及 GAV 映射文档骨架。

### Non-goals（本 change 不做）

- 不 fork Spring Framework 6.2.x / Spring Security 6.5.x（留 Phase B）。
- 不 fork Logback 1.5.x（官方仍在活跃维护）。
- 不精简模块（CLI/Docs/smoke-tests 排除策略留后续 change）。
- 不实现 `make test` 及 JPMS `--add-opens`（留后续 change，参考 2.7 已归档方案）。
- 不修改 Java 包名（`org.springframework.*` 保持不变）。

## Capabilities

### New Capabilities

- `fork-gav-config`: NES 版本号规则、`gradle.properties` fork 参数、`springBootVersion` 运行时基线标识。
- `fork-gav-rebranding`: Boot 层 GAV 自动映射、`settings.gradle` 项目名替换、`buildSrc` 发布修复（`DeployedPlugin`、`BomPlugin` 等）。
- `nexus-publish-pipeline`: Nexus 仓库配置、Maven 发布、`make install` / `make deploy` 入口。
- `fork-build-tooling`: 根目录 `Makefile` 及 `build-thin` 瘦构建目标。

### Modified Capabilities

<!-- 无既有 spec -->

## Impact

- **构建脚本**：根 `build.gradle`、`settings.gradle`、`gradle.properties`、`buildSrc/` 多个 Java/Groovy 插件类。
- **发布产物**：所有 Boot 模块 GAV 从 `org.springframework.boot:spring-boot-*` 变为 `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-*`。
- **下游消费者**：需配置 Nexus 私服并更新 BOM / Parent POM 坐标。
- **SCA 影响**：Boot 坐标规避生效；Framework/Security 仍可能被 SCA 标记（Phase B 前已知局限）。
- **不影响**：Java 源码包名、Auto-Configuration 机制、`spring.factories` / `AutoConfiguration.imports` 路径。
