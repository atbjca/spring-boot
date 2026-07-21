## Context

Spring Boot 2.7.18 的依赖管理仍服务 Java 8 下游。当前 BOM 对 PostgreSQL、Derby、H2、Hazelcast、RabbitMQ、Spring LDAP、Mail 等组件使用了已命中漏洞的版本；Tomcat 与 Undertow 也已有同版本线的新补丁。现有文档没有清楚区分 Derby 的 10.14 源码回移与 Maven Central 可用制品，把 Undertow 2.2.39 标成已修复，并把 HSQLDB 的不可升级约束与版本建议混在一起，需要与实际制品、字节码和公告重新对齐。

## Goals / Non-Goals

**Goals:**

- 将 Java 8 兼容且存在明确修复版本的托管组件抬升到安全版本。
- 对没有公开 Java 8 修复制品的 Derby、不能在 Java 8 下升级的 HSQLDB 保留版本并明确测试作用域和风险状态。
- 生成的 Maven BOM、Gradle 依赖解析和维护文档保持一致。
- 对跨小版本升级执行相关模块编译/测试和标准构建门禁。

**Non-Goals:**

- 不处理 Spring Kafka、Reactor Netty/Netty、ActiveMQ/Artemis、Spring Security。
- 不跨 Spring Boot 2.7 主线，不迁移到 Jakarta EE 9+。
- 不为 HSQLDB 反向移植上游 Java 11 修复。

## Decisions

### D1: 固定本批目标版本矩阵

| 组件 | 当前 | 目标 | 选择依据 |
|---|---:|---:|---|
| PostgreSQL JDBC | 42.3.8 | 42.7.13 | 覆盖 42.3.9/42.7.11 修复且保持 Java 8 |
| Derby | 10.14.2.0 | 保持 10.14.2.0 | 10.14 修复仅存在于源码分支；Central 无 Java 8 修复制品 |
| H2 | 2.1.214 | 2.2.220 | CVE 修复线；实测 class major 52 |
| Hazelcast | 5.1.7 | 5.2.5 | 两个权限校验 CVE 修复线；上游 `jdk.version=8` |
| RabbitMQ Client | 5.14.3 | 5.18.0 | 消息大小限制 DoS 修复；实测 class major 52 |
| Spring LDAP | 2.4.1 | 2.4.4 | 2.4.x 数据暴露修复线 |
| Sun/Jakarta Mail | 1.6.7 | 1.6.8 | 同 javax namespace 的 SMTP injection 修复 |
| Undertow | 2.2.39.Final | 2.2.40.Final | 修复 28367/28368/28369；3260 仍受影响 |
| Tomcat | 9.0.119 | 9.0.120 | Java 8 兼容 9.0.x 最新补丁 |

版本以 `spring-boot-dependencies/build.gradle` 为主，Tomcat 仍由 `gradle.properties` 的 `tomcatVersion` 单一来源管理。

### D2: Derby 与 HSQLDB 不升级，显式维持未修复状态

Derby 的公告说明 CVE-2022-46337 已回移至 10.14 源码分支，但 Maven Central 仅发布到 10.14.2.0；不存在可直接消费的 10.14.2.1/10.14.3.0 制品。本轮保持 10.14.2.0，只允许可信测试场景使用 LDAP 认证功能，未来如需生产使用必须先维护 Derby fork 或提升 Java 基线。

HSQLDB 2.7.4 实测为 class major 55（Java 11）；CVE-2022-41853 的公开修复线 2.7.1+ 不满足 Java 8。继续管理 2.5.2，但不得将其写为“版本已修复”。文档必须说明仅测试/开发数据库场景、不得处理不可信 SQL；未来放弃 Java 8 后再升级。

### D3: 文档状态不能从版本号推断

每条 CVE 分别依据受影响功能、修复版本和本项目作用域定性。实施核验确认 Undertow `2.2.40.Final` 包含 strict HTTP parser commit `60575f08f07b`，修复 CVE-2026-28367 / CVE-2026-28368 / CVE-2026-28369；但 GitHub Advisory/OSV 仍将 2.2.40 列入 CVE-2026-3260 影响范围，且 release diff 无 multipart GET 修复。因此 28367/28368/28369 标记已修复，3260 标记暂缓并要求下游拒绝 multipart GET、限制请求体和临时磁盘资源。

### D4: 分层验证

1. 生成并检查 `spring-boot-dependencies` POM，确认全部目标 GAV。
2. 运行受影响自动配置模块的编译/测试：JDBC/JPA、Hazelcast cache、Rabbit、LDAP、Mail、Undertow、Tomcat。
3. 执行项目标准 Tier A / `make test` 门禁；若外部服务类测试受环境阻塞，记录并保留可重复的 targeted 结果。

## Risks / Trade-offs

- **[Risk] PostgreSQL 42.3→42.7、H2 2.1→2.2 存在行为变化** → 跑 JDBC/JPA 自动配置与数据库初始化测试，文档记录跨 minor。
- **[Risk] Hazelcast 5.2 改变配置解析或序列化行为** → 跑 Hazelcast cache/session 相关测试并检查 classpath 无双版本。
- **[Risk] Undertow/Tomcat 补丁改变请求解析边界** → 跑两种服务器的 web server factory、HTTP/2/SSL/表单测试。
- **[Risk] Derby/HSQLDB 漏洞无法通过公开 Java 8 制品升级修复** → 保持测试作用域、禁止不可信输入并在总览维持缓解/暂缓状态。
- **[Trade-off] 选择最低明确安全版本而非所有组件最新主线** → 降低 Boot 2.7/Java 8 兼容风险，后续安全批次继续滚动。

## Migration Plan

1. 先更新版本与 BOM 期望，生成 POM并核对解析结果。
2. 按组件分组跑 targeted tests，必要时做最小兼容适配。
3. 同步 CVE、需求和升级历史文档，再跑标准全量门禁。
4. 回滚时恢复版本矩阵和文档状态；各组件版本为独立行，便于定位单项回退。

## Open Questions

（无；Undertow CVE 状态已在实施阶段完成证据核验。）
