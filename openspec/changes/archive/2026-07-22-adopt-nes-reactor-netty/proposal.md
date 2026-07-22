## Why

Spring Boot 2.7 NES 当前仍通过官方 Reactor BOM 和 `spring-boot-starter-reactor-netty` 发布 `io.projectreactor.netty:reactor-netty-*`，无法消费已部署到 Nexus 的 Reactor Netty NES fork，也使 Netty 停留在 `4.1.135.Final`。同时，现有漏洞总览把仍未在 Reactor Netty 1.0.48 fork 中闭环的 `CVE-2025-22227` 标为“已修复”，需要在引入 fork 时一并纠正依赖边界、发布语义和安全台账。

## What Changes

- 将 Spring Boot 仓库内对官方 `io.projectreactor.netty:reactor-netty-*` 的解析透明映射到 `cn.bjca.footstone.beactor.netty:bjca-footstone-beactor-netty-*:1.0.48-nes.patch.1-SNAPSHOT`。
- 让 `spring-boot-starter-reactor-netty` 发布的 Maven POM 直接依赖 NES `bjca-footstone-beactor-netty-http`，避免下游 Maven 消费者重新拉回官方坐标。
- 在 Spring Boot BOM 中显式管理 Reactor Netty NES 模块；继续保留官方 Reactor BOM 管理 `reactor-core` 等未 fork 组件。
- 将 Netty BOM 从 `4.1.135.Final` 对齐到 Reactor Netty fork 已验证的 `4.1.136.Final`。
- 按 TDD 增加坐标映射、生成 POM、依赖图、WebFlux/WebClient、HTTP/2 默认设置及重定向安全语义验证。
- 修正 `CVE-2025-22227` 的错误闭环状态并同步登记 `CVE-2026-41715`；仅在源码补丁、回归测试和 Nexus 制品验证全部通过后将两者标记为已修复。
- 同步需求、组件升级历史、GAV 映射、安全台账、测试说明、User Manual 与 Quick Start。
- **BREAKING**：NES 版 `spring-boot-starter-reactor-netty` 的发布 POM 将从官方 Reactor Netty GAV 切换为内部 NES GAV；未配置 NES Nexus 的外部消费者将无法解析该依赖。

## Capabilities

### New Capabilities

- `nes-reactor-netty-dependencies`: 规定 Reactor Netty NES 坐标映射、BOM 管理、starter 发布语义、Netty 版本对齐及消费者验证要求。
- `reactor-netty-security-baseline`: 规定 Reactor Netty/Netty 漏洞状态判定、重定向凭据安全回归和安全文档同步要求。

### Modified Capabilities

- `managed-security-baseline`: 将 Spring Boot 管理的 Netty 安全基线从 `4.1.135.Final` 提升至 `4.1.136.Final`，并要求依赖解析与文档保持一致。

## Impact

- 构建与依赖管理：根 `build.gradle`、`gradle.properties`、`spring-boot-dependencies` 及其生成的 BOM/POM。
- 发布产物：`spring-boot-starter-reactor-netty` 及经它间接使用 Reactor Netty 的 WebFlux、RSocket 和 WebClient 消费链。
- 运行时：Reactor Netty HTTP 客户端/服务端、Netty HTTP/1.1、HTTP/2、DNS、native transport 等传递依赖统一升级至 `4.1.136.Final`。
- 测试：构建逻辑测试、生成 POM 断言、依赖图断言、WebFlux/WebClient/Actuator/RSocket 回归及独立 Maven/Gradle 消费者验证。
- 安全：不会因“采用 fork”自动宣布 `CVE-2025-22227`、`CVE-2026-41715` 已修复；实际补丁、测试和制品均闭环后才能变更状态。
- 运维：下游必须可访问 NES Nexus；回滚时需同时恢复 starter POM、坐标映射、BOM 管理项和 Netty 版本。
- 交付文档：`doc/REQUIREMENTS.md`、`COMPONENTS_UPGRADE_HISTORY.md`、`VULNERABILITY_REPORT.md`、`doc/CVE/`、GAV 映射、`USER_MANUAL.md`、`QUICK_START.md` 和测试文档。
