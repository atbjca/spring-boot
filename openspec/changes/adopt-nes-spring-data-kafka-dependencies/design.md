# Design: adopt-nes-spring-data-kafka-dependencies

## 背景与目标

本 change 把 spring-boot-3.5 的 Spring Data / Kafka 依赖从"官方坐标 + SCA 排除"过渡方案切换到"fork 坐标"正式方案，直接对标 spring-boot-2.7 已归档的两个 change。本文档只记录**与 2.7 的差异**和**需要决策/验证的点**；同构部分不赘述。

## 与 2.7 方案的差异（核心）

| 维度 | spring-boot-2.7（已完成） | spring-boot-3.5（本 change） |
|---|---|---|
| resolutionStrategy 起点 | 已有规则一~四，扩写"规则五" | **只有 framework/security 两条，从零新增 kafka + data 两条规则** |
| fork 的 data 模块 | commons、keyvalue（2 个） | commons、keyvalue、**redis、elasticsearch**（4 个） |
| data 版本线 | 单一 `2.7.18-nes.patch.1-SNAPSHOT` | commons/keyvalue/redis = `3.5.13-nes.patch.1`；**elasticsearch = `5.5.13-nes.patch.1`（独立线）** |
| redis/es starter | 未 fork，无需处理 | 已 fork，但 **starter 源码不动**，靠 resolutionStrategy 重写 |
| Elasticsearch Client alignWith | 未涉及 | `from` 来源需改到 fork ES 坐标 |
| Kafka | 已对齐 artifactId | 本项目首次对齐（同 2.7 最终形态） |

## 决策记录

### 决策 1：路线②（resolutionStrategy 透明重写），starter 源码不改
- **选项**：① 直接改 3 个 starter 的 `api("org.springframework.data:...")` 为 fork 坐标；② 保留官方坐标声明，靠根 `build.gradle` 的 `resolutionStrategy.eachDependency` 在解析期 `useTarget` 重写。
- **决策**：采用 ②，与 2.7 一致。
- **理由**：① 改动分散到多个 starter，且管不住传递依赖（如 redis 间接拉官方 commons）；② 改动集中在一处，且对直接声明与传递依赖统一生效。fork BOM 用 NES 坐标做 key，管不到"源码里写的官方坐标"，故必须靠 resolutionStrategy 兜底重写。

### 决策 2：ES 版本单列，不并入 data 主版本
- Spring Data Elasticsearch fork 走独立版本线 `5.5.x`（fork 制品 `5.5.13-nes.patch.1-SNAPSHOT`），data 主线是 `3.5.x`。
- **决策**：data 规则内对 elasticsearch **单独分支给版本**，不能用一个硬编码版本覆盖四模块。或者更干净的做法——`useTarget` 只重写 group+artifact、版本交由 fork BOM import 托管（避免版本硬编码分叉）。实现阶段二选一，优先"版本由 BOM 托管"，若 `useTarget` 语义要求显式版本则 es 单列。
- **风险**：若误把 es 套进 `3.5.13`，私服无此制品，解析失败。验证任务须显式核对 es 解析到 `5.5.x`。

### 决策 3：Data 删块（不带 exclude），仅 Kafka 保留 exclude
- 现状：3.5 的 dependencies 里有 3 个独立 Data 库块（Commons/KeyValue/Redis），各带 `exclude group: "org.springframework", module: "*"`；Kafka 块也带 exclude。
- **决策**：**删除 3 个独立 Data 块**，data 纯靠 fork BOM 纳管、不带 exclude；**仅 Kafka 保留 exclude**。与 2.7 最终成品完全一致。
- **理由（技术自洽，非历史惯性）**：
  - data commons/keyvalue/redis/elasticsearch 已 fork，其 fork POM **内部依赖直接用 fork 坐标**（如 commons import `bjca-footstone-bpring-framework-bom`、redis 用 `bjca-footstone-bpring-aop` 等），依赖图里根本不出现官方 `org.springframework:*` 节点 → 无需 exclude。
  - kafka fork POM **内部仍以官方坐标声明传递依赖**（实证 `spring-kafka-3.3/build.gradle:273-275`：`api 'org.springframework:spring-context/messaging/tx'`），图里会出现官方节点。虽然根 `build.gradle` 规则一会 `useTarget` 重写为 fork，但保留 exclude 在依赖图层面直接剪除，作为双保险。
  - 兜底逻辑：即便某 data 模块传递官方 `org.springframework:spring-*`，规则一（framework 全局重写）也会覆盖——这正是 2.7 能安全删除所有 data exclude 的原因。
- **注**：`fork-ecosystem-sca-excludes` spec 的语义是"**未 fork** 的 A 类组件"，data 四模块现已 fork，理应从该 spec 的覆盖范围**移除**（而非"改 fork 坐标保留 exclude"）；kafka 虽 fork 但仍漏官方坐标，作为特例保留在该 spec 内。

### 决策 4：Kafka artifactId 用前缀替换，与 framework/security 同构
- Kafka fork 改了 group + artifactId + version 三者。artifactId 用 `requested.name.replaceFirst(/^spring-/, "${forkArtifactPrefix}-")` 推导（`spring-kafka` → `bjca-footstone-bpring-kafka`，`spring-kafka-test` → `bjca-footstone-bpring-kafka-test`），与规则一/二同构。
- BOM 库块的 modules key 同步改名为 fork artifactId（否则 exclude 挂不到重写后的坐标）。

## resolutionStrategy 规则落点（示意）

```
build.gradle  resolutionStrategy.eachDependency  (现状 63-77 行)
  if  org.springframework:spring-*            → fork framework   （现有）
  else if org.springframework.security:...    → fork security    （现有）
  ──────────────── 本 change 新增 ────────────────
  else if org.springframework.kafka:spring-kafka*
            → cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka*:3.3.16-nes.patch.1-SNAPSHOT
  else if org.springframework.data:spring-data-{commons,keyvalue,redis,elasticsearch}
            → cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-*
              （commons/keyvalue/redis: 3.5.13-nes.patch.1；elasticsearch: 5.5.13-nes.patch.1）
              其余 spring-data-*（jpa/mongodb/neo4j/...）不匹配 → 保持官方
```

## 验证清单

- Gradle 配置阶段离线自检：`./gradlew :spring-boot-project:spring-boot-dependencies:help --offline` EXIT=0，证明规则与 fork BOM import DSL 语法正确、bomr 接受新坐标。
- 静态一致性核对：`replaceFirst` 推导的 artifactId 与 fork 仓库实际制品坐标、fork `spring-data-bom/bom/pom.xml` 的 4 条 managed 条目逐一比对。
- `make clean test`（Tier A）+ `make clean build-thin`；`checkRuntimeClasspathForProhibitedDependencies` 通过。
- `:spring-boot:dependencies` 实测确认：
  - commons/keyvalue/redis 解析到 `bjca-footstone-bpring-data-*:3.5.13-nes.patch.1-SNAPSHOT`
  - **elasticsearch 解析到 `5.5.13-nes.patch.1-SNAPSHOT`（版本线正确）**
  - kafka 解析到 `bjca-footstone-bpring-kafka{,-test}:3.3.16-nes.patch.1-SNAPSHOT`
  - 无官方 `org.springframework:*` / `org.springframework.data:*` / `org.springframework.kafka:*` 漏网
  - 无官方/fork 双份 commons
  - 未 fork 的 data 模块（jpa/mongodb/neo4j/cassandra/couchbase/r2dbc/relational/rest 等）**保持官方坐标未被误改**

## 非目标

- 不 fork jpa/mongodb/neo4j 等其余 Spring Data 模块。
- 不移除现有 exclude（属后续可选优化）。
- 不修改任何 Java 源码、starter 源码、参考仓库。
- 不改动 buildSrc / gradle-plugin 构建期锁定依赖。
