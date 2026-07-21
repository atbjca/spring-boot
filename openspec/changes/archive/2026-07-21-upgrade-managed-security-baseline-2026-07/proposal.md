## Why

当前 Spring Boot 2.7.18 BOM 中多项 Java 8 兼容组件停留在已知漏洞版本，现有漏洞台账还包含 Derby、HSQLDB、Undertow 等过时或矛盾的修复结论。需要在不引入 Spring Kafka、Reactor Netty/Netty 变更的前提下，完成一轮可验证、可回滚的托管组件安全基线升级与文档纠偏。

## What Changes

- 升级 PostgreSQL JDBC `42.3.8` → `42.7.13`，覆盖 CVE-2024-1597 与 CVE-2026-42198。
- Derby 保持 `10.14.2.0`：Apache 仅把 CVE-2022-46337 修复回移到 10.14 源码分支，Maven Central 没有发布 10.14.3.0 或其他 Java 8 修复制品；继续限定测试作用域并保留暂缓状态。
- 升级 H2 `2.1.214` → `2.2.220`，覆盖 CVE-2022-45868，并保持 Java 8 字节码。
- 升级 Hazelcast `5.1.7` → `5.2.5`，覆盖 CVE-2023-45859 / CVE-2023-45860，并保持 Java 8 编译目标。
- 升级 RabbitMQ Java Client `5.14.3` → `5.18.0`，覆盖 CVE-2023-46120。
- 升级 Spring LDAP `2.4.1` → `2.4.4`，覆盖 CVE-2024-38829。
- 升级 Sun/Jakarta Mail `1.6.7` → `1.6.8`，覆盖 CVE-2025-7962。
- 升级 Undertow `2.2.39.Final` → `2.2.40.Final`，修复 CVE-2026-28367 / CVE-2026-28368 / CVE-2026-28369；CVE-2026-3260 经公告与 release diff 核实仍未修复，继续暂缓并要求入口缓解。
- 升级 Tomcat `9.0.119` → `9.0.120`，跟进 Java 8 兼容的最新 9.0.x 补丁线。
- HSQLDB 保持 `2.5.2`：其 CVE-2022-41853 修复线 2.7.x 为 Java 11 字节码，与本项目 Java 8 基线冲突；继续限定测试作用域并纠正文档，不伪报为已升级。
- 同步 BOM 生成校验、需求、CVE 单文档、漏洞总览和组件升级历史。
- **范围外**：Spring Kafka、Reactor Netty/Netty、ActiveMQ/Artemis、Spring Security 变更。

## Capabilities

### New Capabilities

- `managed-security-baseline`: 定义 Java 8 约束下托管依赖的安全版本选择、不可升级组件的缓解与台账、BOM 验证和文档同步要求。

### Modified Capabilities

（无）

## Impact

- **BOM**：`spring-boot-dependencies/build.gradle` 和 `gradle.properties` 中 8 个组件版本发生变化，Derby/HSQLDB 状态文档纠偏但版本不变。
- **构建/测试**：依赖管理 POM、版本属性、相关自动配置/集成测试可能受跨小版本行为变化影响。
- **文档**：新增或更新相关 CVE 文档、`VULNERABILITY_REPORT.md`、`REQUIREMENTS.md`、`COMPONENTS_UPGRADE_HISTORY.md`。
- **兼容性**：坚持 Java 8；不跨 Spring 主版本，不引入 Jakarta 命名空间迁移。
