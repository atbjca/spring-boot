## Why

[需求-034] 对接 fork Spring Data 时，上游只 fork 了 BOM / commons / keyvalue 三项，redis、elasticsearch 保持官方坐标。此后 fork 侧完成了 redis、elasticsearch 两个模块的本体去特征化并发布私服，且 fork BOM（`bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.1`，2026-07-10 09:11 deploy）已将 redis / elasticsearch 两条 managed 依赖改为 NES 坐标。本项目当前 `build.gradle` 规则五仅重写 commons / keyvalue，未纳入 redis / elasticsearch——导致 BOM 编排层与本项目消费层出现漂移：源码声明的官方坐标 `spring-data-redis` / `spring-data-elasticsearch` 在 fork BOM 中已无对应 managed key（fork BOM 以 NES 坐标做 key），需在解析期补齐重写才能落到 NES 制品。

## What Changes

- **规则五扩容**：根 `build.gradle` 的 `resolutionStrategy` 规则五白名单并入 `spring-data-redis`（与 commons/keyvalue 同版本线 `2.7.18-nes.patch.1-SNAPSHOT`，走 `spring-` 前缀替换）。
- **新增规则六**：单独处理 `spring-data-elasticsearch`——版本线不同（`4.4.18-nes.patch.1-SNAPSHOT`，非 2.7.18），无法并入规则五，需独立 `else if` 硬编码其版本，artifactId 同样走 `spring-` 前缀替换为 `bjca-footstone-bpring-data-elasticsearch`。
- **fork 边界修订**：Spring Data fork 边界从「BOM/commons/keyvalue」扩为「BOM/commons/keyvalue/redis/elasticsearch」，其余 `spring-data-*`（jpa/mongodb/rest/neo4j/r2dbc/relational…）仍保持官方坐标。
- **四件套台账（[需求-035]）**：为 redis/es fork 所修的传递依赖 CVE 逐个建档并定性——本项目传递依赖版本全线高于修复线（Kotlin 1.9.22 / Jackson 2.21.5 / Netty 4.1.135 / SnakeYAML 2.5 / Elasticsearch 7.17.29），故定性为「已免疫 / 已修复（双保险）」，**切 fork 属坐标一致性对齐，非修补当前敞口**。`VULNERABILITY_REPORT.md` 按维护约定不再累计统计计数。
- **不改动**：任何 Java 源码；BOM import 坐标（[需求-034] 已切 fork BOM，今日新 deploy 自动生效）；buildSrc / gradle-plugin 构建期锁定依赖。

## Capabilities

### New Capabilities
<!-- 无 -->

### Modified Capabilities
- `nes-spring-data-dependencies`: 将 fork 模块边界从 commons/keyvalue 扩展到含 redis/elasticsearch；新增两者的解析重写需求（含 ES 独立版本线）；修订「仅 commons/keyvalue 为 fork 模块」的边界需求；补充 redis/es 传递依赖 CVE 的台账记录需求。

## Impact

- **依赖解析**：`build.gradle`（规则五并入 redis、新增规则六 elasticsearch）
- **文档/台账**：`doc/REQUIREMENTS.md`（[需求-035]）、`doc/COMPONENTS_UPGRADE_HISTORY.md`、`doc/VULNERABILITY_REPORT.md`（补状态行，不累计计数）、`doc/NES_GAV_MAPPING.md`、`doc/GAV_MAPPING.md`、`doc/CVE/`（redis/es 传递 CVE 建档：CVE-2020-29582 / CVE-2023-35116 / CVE-2025-48734 / CVE-2022-1471 / CVE-2023-46673 / Netty 批）
- **上游依赖**：fork `spring-data-redis`（`2.7.18-nes.patch.1-SNAPSHOT`）/ `spring-data-elasticsearch`（`4.4.18-nes.patch.1-SNAPSHOT`）及 fork BOM 已 deploy 到私服 `192.168.131.36:8088`（本机 `~/.m2` 已确认）
- **验证**：`make clean test` + `make clean build-thin`；`:spring-boot:dependencies` 确认 redis/es 解析到 NES 制品、无官方/fork 双份 `spring-data-redis`/`spring-data-elasticsearch`、无官方 `spring-data-commons` 漏网。离线/沙盒私服不可达时构建验证在内网补跑。
