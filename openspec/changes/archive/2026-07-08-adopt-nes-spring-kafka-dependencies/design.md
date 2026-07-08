## Context

当前 Spring Boot 2.7 NES 仓库已经将 Kafka 客户端升级到 `3.9.2`，并将 Spring Kafka 基线升级到 `2.9.13`。但 `spring-boot-dependencies` 仍通过官方坐标管理 `org.springframework.kafka:spring-kafka` 和 `org.springframework.kafka:spring-kafka-test`，文档也仍把 Spring Kafka 描述为未 fork 的 A 类组件。

参考仓库 `/Users/anan/Documents/GitHub/nes/spring-kafka-2.9` 已定义 NES Spring Kafka 坐标：

```
GroupId:    cn.bjca.footstone.bpring.kafka
Version:    2.9.13-nes.patch.1-SNAPSHOT
Artifacts:  spring-kafka
            spring-kafka-test
            spring-kafka-docs
```

该参考仓库文档提到 `bjca-footstone-bpring-kafka-bom` 以及 `bjca-footstone-bpring-kafka*` artifactId，但私服验证结果显示已发布产物实际为 `cn.bjca.footstone.bpring.kafka:spring-kafka` 和 `cn.bjca.footstone.bpring.kafka:spring-kafka-test`。源码 `settings.gradle` 未包含 `spring-kafka-bom` 模块，本 change 不能以 Kafka BOM 为前提。

当前工作区已有与本 change 无关的未提交修改，包括 Kafka smoke test 历史处置。实现前需要确认分支状态，避免混入本 change。

## Goals / Non-Goals

**Goals:**

- 让 Spring Boot NES BOM 直接管理 NES Spring Kafka 主模块和测试模块。
- 让当前仓库 Gradle 构建解析官方 Spring Kafka 声明时透明使用 NES Spring Kafka 坐标。
- 清理文档中“Spring Kafka 未 fork”“需要使用官方坐标并手工补充 Spring Framework fork 依赖”的过期描述。
- 明确不依赖不存在或未验证的 `bjca-footstone-bpring-kafka-bom`。
- 保持 Java 源码 package/import 不变。

**Non-Goals:**

- 不创建 Spring Kafka BOM。
- 不修改 `/Users/anan/Documents/GitHub/nes/spring-kafka-2.9` 参考仓库。
- 不恢复 `spring-boot-smoke-test-kafka` 中已知受 EmbeddedKafka 兼容性影响的测试。
- 不升级 Kafka 客户端版本；当前仍使用 `3.9.2`。
- 不引入新的第三方库或新的设计模式。

## Decisions

### 1. Boot BOM 直接管理 NES Spring Kafka 模块

将 `spring-boot-project/spring-boot-dependencies/build.gradle` 中的 Spring Kafka library 从官方 group 和 artifact 切换为 NES group 和 artifact。

候选方案：

| 方案 | 结论 | 原因 |
|------|------|------|
| 导入 `bjca-footstone-bpring-kafka-bom` | 不采用 | 参考仓库未发现实际 BOM 模块或发布产物 |
| 继续管理官方 `org.springframework.kafka` 坐标 | 不采用 | 下游仍会拿到官方 GAV，违背 NES 依赖链目标 |
| Boot BOM 直接管理 NES Kafka 模块 | 采用 | 与 Boot BOM 版本管理中心职责一致，且只依赖已确认的模块坐标 |

### 2. 新增构建期 Spring Kafka 坐标替换规则

根 `build.gradle` 已通过 `resolutionStrategy.eachDependency` 透明替换 Spring Framework、Spring Security、Logback。Spring Kafka 应新增一条同类规则：

```
org.springframework.kafka:spring-kafka
  -> cn.bjca.footstone.bpring.kafka:spring-kafka:2.9.13-nes.patch.1-SNAPSHOT

org.springframework.kafka:spring-kafka-test
  -> cn.bjca.footstone.bpring.kafka:spring-kafka-test:2.9.13-nes.patch.1-SNAPSHOT
```

该规则只覆盖已确认存在的两个模块，不覆盖 `spring-kafka-docs`，因为 Boot 构建通常不需要将应用依赖声明透明替换到 docs 模块。

### 3. 先验证 NES Spring Kafka POM，再决定 exclude 策略

当前 BOM 对官方 Spring Kafka 模块配置了 `exclude group: "org.springframework", module: "*"`，原因是未 fork 组件会传递回官方 Spring Framework 坐标。私服与参考仓库生成 POM 的验证结果显示，NES Spring Kafka POM 仍传递官方 Spring Framework 坐标：

```
org.springframework:spring-context:5.3.29
org.springframework:spring-messaging:5.3.29
org.springframework:spring-tx:5.3.29
org.springframework:spring-test:5.3.29
```

因此 BOM 管理条目必须保留等价 exclude，避免下游 classpath 混入官方 Spring Framework。

### 4. 文档同步以消费者视角为准

`doc/NES_GAV_MAPPING.md` 是下游消费者视角的主文档，应优先更新：

- Spring Kafka 加入 NES fork 组件列表。
- Spring Kafka 使用示例改为 NES GAV。
- 移除 Spring Kafka 在 A 类未 fork 组件中的描述。
- 明确不要求导入 Kafka BOM。

维护者视角的 `doc/GAV 构建机制说明.md` 需要补充 Spring Kafka 映射规则，避免后续维护者误以为只有 Framework/Security/Logback 需要自动替换。

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| NES Spring Kafka artifactId 与文档不一致 | 以私服实际发布产物为准，使用 `spring-kafka` / `spring-kafka-test` |
| NES Spring Kafka POM 仍传递官方 Spring Framework | BOM 管理条目继续保留 `exclude org.springframework:*` |
| `spring-kafka-test` 2.9.x 与 Kafka 3.9.2 EmbeddedKafka 兼容性仍存在 | 不恢复已 disabled 的 smoke test，仅验证编译与非 embedded 依赖解析 |
| 工作区存在无关未提交修改 | 实现前确认 `git status`，必要时提示备份或单独处理 |
| 文档中存在多个 GAV 入口，容易漏改 | 使用 `rg "spring-kafka|Spring Kafka|bjca-footstone-bpring-kafka"` 全量搜索并逐项核对 |

## Migration Plan

1. 确认工作区状态和目标分支，避免混入既有未提交补丁。
2. 验证 `cn.bjca.footstone.bpring.kafka:spring-kafka:2.9.13-nes.patch.1-SNAPSHOT` 和 `spring-kafka-test` 是否可从 Nexus 解析。
3. 检查 NES Spring Kafka POM 中的 Spring Framework 传递依赖坐标。
4. 按 TDD 流程补充或调整 BOM/构建映射相关测试。
5. 修改根 `build.gradle` 的 Spring Kafka 解析规则。
6. 修改 `spring-boot-dependencies/build.gradle` 的 Spring Kafka BOM 管理条目。
7. 更新 GAV、需求、漏洞、快速入门和用户手册类文档。
8. 执行 targeted verification：BOM 生成/检查、相关 buildSrc 测试、Kafka autoconfigure 编译或测试。

Rollback 策略：恢复本 change 涉及的 BOM 和 `resolutionStrategy` 修改，并恢复文档中 Spring Kafka 官方坐标说明；不触碰已有 Kafka smoke test 历史处置。
