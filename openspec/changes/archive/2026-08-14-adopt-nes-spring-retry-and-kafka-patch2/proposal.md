## Why

Spring Boot NES 当前仍管理并可能从 Spring AMQP、Batch、Integration 和旧 Kafka patch.1 解析出官方 `org.springframework.retry:spring-retry:1.3.4`，而该版本受 CVE-2026-41710 影响。Spring Kafka NES patch.2 已优先采用包含回移缓解的 NES Spring Retry SNAPSHOT，因此 Boot 需要同步升级 Kafka 并统一整个构建和下游发布元数据中的 Retry 实现。

## What Changes

- 将 Spring Kafka NES 主模块和测试模块升级到 `2.9.13-nes.patch.2-SNAPSHOT`，继续验证 CVE-2026-41731 Header 反序列化修复与既有 Kafka 集成行为。
- 新增官方 Spring Retry 到 `cn.bjca.footstone.bpring.retry:bjca-footstone-bpring-retry:1.3.4-nes.patch.1-SNAPSHOT` 的精确构建替换，并由 Boot BOM 只管理 NES Retry GAV。
- 在 AMQP、Batch、Integration 和 Batch Starter 发布元数据中阻断官方 Retry 的传递引入；Batch Starter 显式提供受 Boot BOM 管理的 NES Retry。
- 增加 classpath 门禁，精确禁止 `org.springframework.retry:spring-retry`，同时允许 NES Retry 和其他未被明确禁止的 artifact。
- 增加 CVE-2026-41710 的证据、LRU 容量行为回归验证和 SNAPSHOT 缓存说明；在 NES Retry RELEASE 发布前将状态保持为“已缓解”，而非“已修复”。
- 更新 Spring Kafka/Retry GAV、Quick Start、用户手册和漏洞台账，修正不存在的 Kafka artifactId，并记录 Maven 消费者迁移方式。
- **BREAKING**：Boot BOM 不再为 `org.springframework.retry:spring-retry` 提供版本管理。直接声明该官方 GAV 的消费者必须改用 NES Retry GAV；Java import 仍保持 `org.springframework.retry.*`。
- 不发布 Spring Boot、Spring Kafka 或 Spring Retry RELEASE，不重新启用当前被排除的 AMQP、Integration Starter 或 Boot CLI。

## Capabilities

### New Capabilities

- `nes-spring-retry-dependencies`: 规定 Boot 对 NES Spring Retry 的 BOM 管理、Gradle 替换、传递依赖排除、Starter 发布、classpath 唯一性、安全状态和消费者迁移要求。

### Modified Capabilities

- `nes-spring-kafka-dependencies`: 将 Boot 管理和解析的 Spring Kafka NES 版本线从 patch.1 更新到 patch.2，并要求文档使用实际发布的 NES artifactId。
- `spring-kafka-header-security-baseline`: 将 CVE-2026-41731 的验证证据和集成基线迁移到 Kafka patch.2 SNAPSHOT，同时保留精确受信包匹配行为。

## Impact

- 构建和版本管理：`gradle.properties`、根 `build.gradle`、`spring-boot-dependencies` BOM 与相关 buildSrc 验证。
- Starter 和自动配置：活跃的 Batch Starter、Kafka/AMQP 自动配置 classpath；Java API 和 `org.springframework.retry.*` import 不变。
- 下游发布元数据：生成的 Boot BOM 和 Batch Starter POM，以及同时使用 Kafka、Batch、AMQP、Integration 的 Maven/Gradle 消费者。
- 安全与文档：CVE-2026-41710、CVE-2026-41731、漏洞汇总、NES GAV 映射、Quick Start 和用户手册。
- 外部依赖：只消费已发布的 Kafka patch.2 与 Retry patch.1 SNAPSHOT；`spring-kafka-2.9` 仓保持只读。
