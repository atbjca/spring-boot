## Context

Boot 当前在根 Gradle 构建中透明替换 Spring Framework、Security、Kafka 和部分 Data 坐标，但 Spring Retry 仍由 BOM 管理为官方 `org.springframework.retry:spring-retry:1.3.4`。真实依赖解析表明，官方 Retry 会由 Spring AMQP、Spring Batch、Spring Integration 和 Kafka patch.1 进入 Boot classpath。

Spring Kafka NES `2.9.13-nes.patch.2-SNAPSHOT` 已直接依赖 `cn.bjca.footstone.bpring.retry:bjca-footstone-bpring-retry:1.3.4-nes.patch.1-SNAPSHOT`，并继续携带 Spring Data Commons patch.1 optional 依赖。Kafka 发布 POM 不传递 Spring Data BOM，因此 Boot 无需为 Kafka 新增 Data BOM 导入；现有 Spring Data Commons 全局替换已覆盖该 optional 坐标。

NES Retry SNAPSHOT 已回移 CVE-2026-41710 涉及的有状态缓存 LRU/容量行为，但正式 RELEASE 尚未发布。当前可审计的 Nexus 时间戳为 `20260810.073226-2`；Kafka patch.2 为 `20260814.020248-2`。两者都是可变 SNAPSHOT，发布和安全状态必须反映这一边界。

Gradle 能把官方坐标透明替换为 NES 坐标，但 Maven 不提供等价的 GAV substitution。Boot 因此必须同时处理仓内 Gradle 解析和发布给 Maven 消费者的 BOM/Starter 元数据。

## Goals / Non-Goals

**Goals:**

- Boot 构建、测试和代表性下游 classpath 只保留一个 Spring Retry 实现，即 NES Retry patch.1 SNAPSHOT。
- Kafka 主模块和测试模块统一升级到 NES patch.2 SNAPSHOT，同时保留 Kafka Clients 3.9.2、CVE-2026-41731 行为和现有自动配置兼容性。
- Boot BOM、Batch Starter POM 和消费者文档使用真实已发布的 NES GAV，并明确官方 Retry GAV 的迁移断点。
- 用可执行回归测试和解析证据验证 Retry LRU 缓解、SNAPSHOT 身份和官方 Retry 不泄漏。
- 保持 Java 8 兼容以及 `org.springframework.retry.*`、`org.springframework.kafka.*` Java 包/API 不变。

**Non-Goals:**

- 不修改只读的 `spring-kafka-2.9` 仓，也不重新构建或发布 Kafka、Retry 制品。
- 不升级到 Spring Retry 2.x，不改变 Boot Retry/Kafka/AMQP 业务 API。
- 不发布 Boot RELEASE；内部 SNAPSHOT 未清零时继续由 component release 门禁阻断发布。
- 不重新启用被 `settings.gradle` 排除的 AMQP Starter、Integration Starter、Boot CLI 或其他项目。
- 不引入或假设不存在的 Kafka BOM，也不新增 Kafka 对 Spring Data BOM 的下游要求。

## Decisions

### 1. 使用两个独立版本属性作为单一版本源

在 `gradle.properties` 定义：

```properties
springRetryNesVersion=1.3.4-nes.patch.1-SNAPSHOT
springKafkaNesVersion=2.9.13-nes.patch.2-SNAPSHOT
```

根 substitution、Boot BOM、Starter 和验证均引用这些属性，避免 Kafka/Retry 版本在多个文件中硬编码漂移。

**Alternative considered:** 继续在根构建和 BOM 中分别硬编码版本。该方式延续当前 Kafka 做法，但会增加 SNAPSHOT 升级时的遗漏风险。

### 2. Gradle 仅精确替换官方 Spring Retry 主模块

新增规则只匹配：

```text
org.springframework.retry:spring-retry
```

并替换为：

```text
cn.bjca.footstone.bpring.retry:bjca-footstone-bpring-retry:${springRetryNesVersion}
```

不使用 `requested.group.startsWith` 或整个 `org.springframework.retry` group 重写，避免未来出现其他 artifact 时被错误映射。Kafka 规则继续只处理 `spring-kafka`/`spring-kafka-test`，但版本改为 `springKafkaNesVersion`。

**Alternative considered:** 只把 Kafka 升到 patch.2，依赖 Kafka POM 间接带入 NES Retry。该方案无法覆盖 AMQP、Batch、Integration 的官方 Retry 路径，也不能保证全仓唯一实现。

### 3. Boot BOM 只管理 NES Retry GAV

现有 `Spring Retry` library 从官方 group/artifact 改为 NES group/artifact。官方 `org.springframework.retry:spring-retry` 不再出现在生成的 dependency management 中。

这是有意的消费者迁移断点：Maven 的 dependency management 以 GAV 为键，管理 NES GAV 无法为官方 GAV补版本。消费者必须将依赖声明迁移到 NES GAV，但 Java import 不变。

**Alternative considered:** 同时管理官方和 NES 两套 GAV。该做法会让消费者继续声明易受影响的官方制品，并允许不同 GAV 的重复类同时进入 classpath，因此拒绝。

### 4. Maven 路径通过精确 BOM exclusions 阻断官方 Retry

对实际传递官方 Retry 的 managed dependencies 增加：

```text
org.springframework.amqp:spring-amqp
org.springframework.batch:spring-batch-infrastructure
org.springframework.integration:spring-integration-core
```

上的 `org.springframework.retry:spring-retry` exclusion。Kafka patch.2 已直接发布 NES Retry，因此无需从 Kafka 排除 NES Retry；Kafka 现有 Spring Framework exclusions 继续保留。

Boot 的 `CheckBom` 使用 detached configuration 查看上游原始依赖图，不继承根项目 substitution，能够正确认定上述官方 Retry exclusions 为必要。本 change 不修改 `CheckBom`。若未来将 substitution 安装到该 detached configuration，Gradle resolution result 仍保留 requested GAV，可在后续重构中据此修正校验，而不是增加 Retry 特例。

**Alternative considered:** 依靠 Gradle substitution 生成 Maven POM。Gradle resolution 规则不会自动表达成 Maven dependency management substitution，无法保护 Maven 消费者。

### 5. Batch Starter 显式发布 NES Retry

活跃的 `spring-boot-starter-batch` 从 `spring-batch-core` 排除官方 Retry，并增加无版本的 NES Retry `api` 依赖，由 Boot BOM constraint 管理版本。这样生成的 Starter POM同时表达：

- `spring-batch-core` 不得传递官方 Retry；
- 应直接引入 NES Retry。

AMQP 与 Integration Starter 当前未参与构建，不因本 change 重新启用；它们的 Maven消费者路径由 Boot BOM exclusions 覆盖。

**Alternative considered:** 仅在根 configuration 全局排除官方 Retry。全局排除不会完整进入发布 POM，且可能掩盖生产者元数据缺陷。

### 6. 用精确 classpath 禁止规则建立长期唯一性门禁

扩展 `CheckClasspathForProhibitedDependencies`，只把 `org.springframework.retry:spring-retry` 判定为 prohibited。测试必须证明：

- 官方 Retry 被禁止；
- NES Retry 被允许；
- 其他未知 `org.springframework.retry` artifact 不会被整组误禁。

Gradle 的版本冲突机制只比较相同 GAV，无法识别官方 Retry 与 NES Retry 中的重复类，因此该门禁是必要的第一道保护。Starter 的重复类检查继续作为发布路径的第二道保护。

### 7. 安全状态以行为和时间戳证据为准

新增 `MapRetryContextCache` 容量为 2 的 LRU 回归场景：依次写入 A、B，读取 A，再写入 C；必须不抛 `RetryCacheCapacityExceededException`，并保留 A/C、淘汰 B。

CVE-2026-41710 在 Retry RELEASE 前标记为“已缓解”。文档记录 Retry 时间戳 `20260810.073226-2`、可变 SNAPSHOT 缓存风险和刷新依赖要求。Kafka CVE-2026-41731 的既有行为测试继续运行，证据升级到 patch.2 时间戳 `20260814.020248-2`。

**Alternative considered:** 仅凭 `-SNAPSHOT` 版本字符串标记“已修复”。同一 SNAPSHOT 可被重新发布，无法构成稳定安全证据。

### 8. 发布消费者验证覆盖组合依赖图

除 Gradle dependency insight 和自动配置测试外，生成 Boot BOM/Batch Starter POM，并使用独立 Maven 消费者同时引入 Kafka、Batch、AMQP、Integration。验证最终依赖树：

- 只包含 NES Retry；
- 不包含官方 Retry；
- Kafka 为 patch.2；
- Spring Data Commons 继续解析为现有 NES 坐标；
- Java 8 编译/运行兼容。

文档同步修正 Quick Start 中错误的 `spring-kafka`/`spring-kafka-test` artifactId，并明确没有 Kafka BOM。

## Risks / Trade-offs

- **[SNAPSHOT 可变且可能命中旧缓存]** → 验证时刷新 changing modules，记录时间戳制品，并保持 CVE-2026-41710“已缓解”和 Boot RELEASE 阻断状态。
- **[消费者继续声明官方 Retry 时失去版本约束]** → 在迁移文档中将其标为 breaking change，给出 NES GAV 替换示例，并通过生成 BOM/POM 的独立 Maven 消费者验证。
- **[不同 GAV 含重复 `org.springframework.retry.*` 类，Gradle 不报告版本冲突]** → 增加官方 Retry 精确 prohibited 门禁，并保留 Starter duplicate-class 检查。
- **[BOM exclusion 只覆盖已知传递路径]** → 用组合 Maven 消费者和全仓 classpath 检查验证；未来新增官方 Retry 路径会被 prohibited 门禁捕获。
- **[Kafka patch.2 同时改变 Retry 和 optional Data Commons 元数据]** → 保留现有 Spring Data Commons 全局替换，分别验证 Kafka、Data Commons 和 Retry 的最终选中坐标，不引入 Kafka Data BOM 假设。
- **[仓库已有 `bomrCheck` 基线失败]** → 记录与本 change 无关的 Elasticsearch/LZ4 既有失败；本 change 新增的 Retry exclusions必须单独通过必要性检查和生成 POM/Maven消费者证据，不能用基线失败掩盖新增问题。

## Migration Plan

1. 增加 Kafka/Retry 版本属性和精确 Gradle substitution，更新静态构建契约测试。
2. 更新 Boot BOM 的 Kafka、Retry 管理和 AMQP/Batch/Integration exclusions。
3. 更新 Batch Starter 依赖与 classpath prohibited 门禁。
4. 增加 Retry LRU、安全证据、Kafka patch.2 回归和组合消费者验证。
5. 更新 GAV、Quick Start、用户手册、CVE 文档和漏洞汇总；保持 RELEASE 门禁阻断。
6. 若验证失败，回滚本 change 的 Boot 侧依赖和文档修改到 Kafka patch.1/官方 Retry 基线；不修改、删除或重新发布任何 Nexus 制品。
7. 后续在 NES Retry 发布 `1.3.4-nes.patch.1` RELEASE 后另建 change，切换不可变版本并重新评估 CVE-2026-41710 状态。

## Open Questions

无。当前版本、GAV、排除路径、验证证据和发布边界均已通过只读调查及临时消费者模型确认。
