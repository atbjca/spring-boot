## Why

兄弟项目 spring-boot-2.7（`2.7.x-bjca-patch`）已通过两个已归档 change 完成 Spring Data / Kafka 的 fork 坐标对接（`adopt-nes-spring-data-dependencies`、`align-nes-spring-kafka-artifactid`）。本项目 spring-boot-3.5（`3.5.x-bjca-patch`）需要对齐同一套方案，但覆盖面更广。

以下 6 个参考仓库已在 fork 侧完成本体安全维护 + GAV 去特征化并发布私服，**原始官方坐标在私服中已不存在**：

- **spring-data-bom**（`2025.0.x-bjca-patch`）：BOM 自身坐标改为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2025.0.13-nes.patch.1-SNAPSHOT`；内部将 **commons / keyvalue / redis / elasticsearch 四个模块**切至 NES 制品，其余 `spring-data-*`（jpa/mongodb/neo4j/cassandra/couchbase 等）保持官方坐标 + 官方版本。
- **spring-data-commons**（`3.5.x-bjca-patch`）→ `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:3.5.13-nes.patch.1-SNAPSHOT`
- **spring-data-keyvalue**（`3.5.x-bjca-patch`）→ `...:bjca-footstone-bpring-data-keyvalue:3.5.13-nes.patch.1-SNAPSHOT`
- **spring-data-redis**（`3.5.x-bjca-patch`）→ `...:bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1-SNAPSHOT`
- **spring-data-elasticsearch**（`5.5.x-bjca-patch`）→ `...:bjca-footstone-bpring-data-elasticsearch:5.5.13-nes.patch.1-SNAPSHOT`（**独立版本线 5.5.x，非 data 主线 3.5.x**）
- **spring-kafka**（`3.3.x-bjca-patch`）→ `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka{,-test}:3.3.16-nes.patch.1-SNAPSHOT`（groupId + artifactId + version 均改）

本项目当前状态：Spring Data / Kafka 仍走"官方坐标 + A 类 SCA 排除"的过渡写法（见 `fork-ecosystem-sca-excludes` spec）；根 `build.gradle` 的 `resolutionStrategy.eachDependency` **只有 framework / security 两条规则，没有任何 data / kafka 规则**。若不更新，构建到 Spring Data / Kafka 解析会因私服缺失官方坐标而失败。

## What Changes

完全对标 2.7 的**"fork BOM import 管版本 + resolutionStrategy 全局重写坐标"**组合方案，差异仅在覆盖面（4 模块 vs 2 模块）与 ES 版本线：

- **层一（BOM import 坐标）**：`spring-boot-dependencies/build.gradle` 的 `library("Spring Data Bom", ...)` import 组由 `org.springframework.data` / `spring-data-bom` 改为 `cn.bjca.footstone.bpring.data` / `bjca-footstone-bpring-data-bom`，版本 `2025.0.13` 不变。
- **层二（子模块坐标映射）**：根 `build.gradle` 的 `resolutionStrategy.eachDependency` 在 security 规则之后**新增两条规则**：
  - **Kafka 规则**：`org.springframework.kafka:spring-kafka*` → `${forkArtifactPrefix}-` 前缀替换 → `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka{,-test}:3.3.16-nes.patch.1-SNAPSHOT`（与 framework/security 规则同构）。
  - **Data 规则**：`org.springframework.data:spring-data-{commons,keyvalue,redis,elasticsearch}` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-*`。commons/keyvalue/redis 用 `3.5.13-nes.patch.1-SNAPSHOT`；**elasticsearch 单列 `5.5.13-nes.patch.1-SNAPSHOT`**。其余 `spring-data-*` 保持官方坐标。该规则兼堵未 fork 模块经传递依赖回拉官方 commons 的链路。
- **BOM 库块调整**：
  - Spring Kafka 库块（`library("Spring Kafka", ...)`）group 改 `cn.bjca.footstone.bpring.kafka`、版本改 `3.3.16-nes.patch.1-SNAPSHOT`、modules key 由 `spring-kafka{,-test}` 改名为 `bjca-footstone-bpring-kafka{,-test}`，**保留 `exclude group: "org.springframework", module: "*"`**（kafka fork POM 内部仍以官方坐标传递 Spring Framework，作依赖图层双保险）。
  - `library("Elasticsearch Client", ...)` 的 `alignWith { version { from ... } }` 对齐来源由 `org.springframework.data:spring-data-elasticsearch` 改到 fork ES 坐标（5.5.x 版本线由 fork BOM 托管）。
  - **删除 Spring Data Commons / KeyValue / Redis 三个独立 library 块**：这四个 data 模块已 fork（内部依赖已 fork 化，不再传递官方坐标），改由 fork data-bom 统一纳管，不再需要 A 类 exclude。与 2.7 最终成品一致。
- **starter 源码不改**：3 个 starter（`spring-boot-starter-data-elasticsearch` / `-data-redis` / `-data-redis-reactive`）中的 `api("org.springframework.data:...")` **原样保留**，由 resolutionStrategy 在解析期透明重写（路线②）。

不改动任何 Java 源码；不 fork jpa/mongodb 等其余 data 模块；不触碰任何参考仓库；不触碰 buildSrc / gradle-plugin 的构建期锁定依赖。

## Capabilities

### New Capabilities
- `nes-spring-data-kafka-dependencies`: 约束 Spring Boot NES BOM 以 fork 坐标管理 Spring Data BOM 与 Spring Kafka，并在构建期将 commons/keyvalue/redis/elasticsearch/kafka 的源码及传递声明透明重写为 NES 制品；同时约束"仅这四个 data 模块 + kafka 去特征化、其余 data 模块保持官方坐标"的边界，以及 ES 独立 5.5.x 版本线的处理。

### Modified Capabilities
- `fork-ecosystem-sca-excludes`: Spring Data commons/keyvalue/redis 已 fork（内部依赖 fork 化、不再传递官方坐标），从"未 fork A 类组件"覆盖范围中**移除**，改由 fork data-bom 纳管、不再声明 exclude；Spring Kafka 虽 fork 但 fork POM 内部仍以官方坐标传递 Spring Framework，作为特例**保留** exclude，且受治理 modules key 与 group 更名为 fork 坐标。

## Impact

- **依赖解析**：`build.gradle`（新增 kafka + data 两条规则）、`spring-boot-dependencies/build.gradle`（Data BOM import 坐标、Kafka modules key、Elasticsearch Client alignWith 来源）
- **starter**：无（路线②，源码不动）
- **上游依赖**：6 个 fork 仓库的 `-SNAPSHOT` 制品需已 deploy 到私服
- **验证**：`make clean test` + `make clean build-thin`；`:spring-boot:dependencies` 确认 commons/keyvalue/redis/elasticsearch/kafka 均解析到 NES 制品、无官方/fork 双份、无官方 `org.springframework(.data)?:*` 漏网、ES 解析到 5.5.x fork 版本；未 fork 的 data 模块（jpa/mongodb 等）保持官方坐标。离线/沙盒环境私服不可达时，构建验证在具备内网的环境补跑。
