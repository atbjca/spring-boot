## Why

Phase A 已完成 Boot 层 GAV rebranding，但构建与运行时仍解析官方 `org.springframework:*` / `org.springframework.security:*` 坐标。Framework 6.2 社区支持已于 2026-06-30 结束，SCA 仍扫描到官方 Spring 传递依赖。需在 Boot 3.5.15 fork 中接入已发布的 Framework 6.2.19 / Security 6.5.11 NES fork 制品，完成兼容链闭环。

## What Changes

- `gradle.properties` 增加 `springFrameworkVersion=6.2.19-nes.patch.1-SNAPSHOT`、`springSecurityVersion=6.5.11-nes.patch.1-SNAPSHOT`。
- 根 `build.gradle` 添加 `resolutionStrategy.eachDependency` 规则（参考 2.7 fork），透明映射 Framework / Security 坐标。
- `spring-boot-dependencies/build.gradle` BOM 中 Framework / Security 条目改为 fork groupId + BOM import。
- `buildSrc/build.gradle` 切换为 fork Framework BOM 与模块坐标（buildSrc 独立构建不受根 resolutionStrategy 影响）。
- 更新 `doc/NES_GAV_MAPPING.md`、`doc/REQUIREMENTS.md` 记录 Phase B 兼容链。
- **前提**：Framework / Security fork 制品已发布到 Nexus（由独立仓库构建，本 change 仅消费）。

### Non-goals

- 不在本仓库 fork Framework / Security 源码（独立仓库负责）。
- 不 fork Logback（仍用官方 1.5.34）。
- 不处理 Spring Data / Session / GraphQL 等 A 类生态组件 fork。
- 不修改 Java 包名（`org.springframework.*` 保持不变）。

## Capabilities

### New Capabilities

- `fork-framework-gav-mapping`: Framework 6.2.x fork 坐标映射、BOM 引用、buildSrc 依赖切换。
- `fork-security-gav-mapping`: Security 6.5.x fork 坐标映射、BOM 引用、Authorization Server 等特殊模块处理。

### Modified Capabilities

- `fork-gav-config`: Phase A「第三方保持官方坐标」扩展为 Framework / Security 使用 NES fork 版本。

## Impact

- **构建脚本**：根 `build.gradle`、`gradle.properties`、`buildSrc/build.gradle`、`spring-boot-dependencies/build.gradle`。
- **依赖解析**：所有子模块 `build.gradle` 零修改，通过 resolutionStrategy 透明替换。
- **SCA**：`org.springframework:*` / `org.springframework.security:*` 传递依赖坐标规避生效。
- **前提依赖**：Nexus 上须存在 `cn.bjca.footstone.bpring:*` 与 `cn.bjca.footstone.bpring.security:*` 制品。
