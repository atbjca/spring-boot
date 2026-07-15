## Context

[需求-034] 完成 fork Spring Data 首轮对接时，上游仅 fork 了 BOM/commons/keyvalue，redis/elasticsearch 保持官方坐标，故根 `build.gradle` 的 `resolutionStrategy` 规则五仅重写 commons/keyvalue（硬编码 `2.7.18-nes.patch.1-SNAPSHOT`）。此后 fork 侧完成 redis/elasticsearch 本体去特征化，fork BOM（`bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.1`，2026-07-10 09:11 deploy）已将两者的 managed 依赖切为 NES 坐标。制品已在私服 `192.168.131.36:8088` 与本机 `~/.m2`。

关键约束：本项目坚守 Spring Boot 2.7.x；fork BOM 以 NES 坐标做 dependencyManagement key，无法匹配源码/starter 中声明的官方坐标 `org.springframework.data:spring-data-{redis,elasticsearch}`，因此**必须**靠 `resolutionStrategy` 在解析期重写，BOM 切坐标不能替代该机制。

## Goals / Non-Goals

**Goals:**
- 让本项目对 `spring-data-redis` / `spring-data-elasticsearch` 的官方坐标声明透明解析到 NES 制品。
- fork 边界与 fork BOM 对齐（BOM/commons/keyvalue/redis/elasticsearch 五项）。
- 四件套台账登记 [需求-035]，redis/es 传递 CVE 逐个定性。

**Non-Goals:**
- 不 fork 其余 `spring-data-*`（jpa/mongodb/rest/neo4j/r2dbc/relational…）。
- 不改任何 Java 源码、不改 BOM import 坐标（[需求-034] 已切）、不动 buildSrc/gradle-plugin 构建期锁定依赖。
- 不升级 redis/es 打包的传递依赖（本项目 BOM 已管理更高版本）。

## Decisions

**决策一：redis 并入规则五，elasticsearch 单开规则六。**
redis 与 commons/keyvalue 同版本线 `2.7.18-nes.patch.1-SNAPSHOT`，可直接在规则五的 `requested.name in {commons,keyvalue}` 白名单追加 `spring-data-redis`，复用同一 `useTarget` 硬编码版本。elasticsearch 版本线是 `4.4.18-nes.patch.1-SNAPSHOT`（跟随 ES 4.4.x fork），与 2.7.18 不同，若并入规则五会解析到不存在的 `bjca-...-elasticsearch:2.7.18-...` 坐标而失败，故必须单独一条 `else if` 分支硬编码 ES 版本。两者 artifactId 均走 `spring-` → `${forkArtifactPrefix}-` 前缀替换，与规则三（Kafka）/现规则五同构。
- 备选：把版本号做成 per-artifact 映射表统一处理——否决，当前仅两种版本线，映射表反而降低可读性，与既有规则风格不一致。

**决策二：CVE 定性为「已免疫/已修复（双保险）」。**
redis/es fork 的 CVE 文档从其自身仓库视角撰写，基线版本旧（如 Jackson 2.13.5、Kotlin 1.6.21、Netty 4.1.65、SnakeYAML 1.33、ES 7.17.15）。本项目经 spring-boot BOM 统一管理，实际版本全线高于修复线（Jackson 2.21.5 / Kotlin 1.9.22 / Netty 4.1.135 / SnakeYAML 2.5 / ES 7.17.29），故这些 CVE 对本项目已免疫或已修复。切 fork 的价值是坐标一致性（堵官方坐标经传递回拉、与 fork 边界统一），非修补敞口——台账须如实这样写，避免读者误判为新引入的漏洞修复。

**决策三：`VULNERABILITY_REPORT.md` 不累计统计计数。**
按维护约定，本次只补 per-CVE 状态行，不再更新聚合计数（区别于 [需求-034] 曾更新 46→50 等计数）。

## Risks / Trade-offs

- [ES 版本线混淆：误把 ES 也写成 2.7.18] → 规则六独立分支 + 源码注释显式标注 `4.4.18-nes.patch.1-SNAPSHOT`；`:spring-boot:dependencies` 验证解析结果。
- [规则六遗漏、ES 仍走官方坐标 → fork BOM 无对应 managed key 致版本解析失败] → 验证阶段 grep `:spring-boot:dependencies` 确认 ES 落到 NES 制品、无官方坐标漏网。
- [离线/沙盒私服不可达 → 构建验证失败] → 制品已确认在本机 `~/.m2`；私服不可达时构建验证在内网补跑（与 [需求-034] 同惯例）。
- [传递依赖双份（官方+fork 经 redis/es 回拉 commons）] → 规则五对 commons 的重写本就兼堵此链路；验证确认无官方/fork 双份 `spring-data-commons`。

## Migration Plan

1. 改 `build.gradle`：规则五并入 redis、新增规则六 elasticsearch（含注释）。
2. 台账四件套：CVE 建档、REQUIREMENTS [需求-035]、COMPONENTS_UPGRADE_HISTORY、VULNERABILITY_REPORT（不累计计数）、NES_GAV_MAPPING、GAV_MAPPING。
3. 验证：`make clean test` + `make clean build-thin` + `:spring-boot:dependencies` 断言。
4. 回滚：还原 `build.gradle` 规则五/六即可回到官方坐标解析（BOM import 不变，不受影响）。

## Open Questions

<!-- 无 -->
