## 1. 前置确认（制品可解析）

- [x] 1.1 确认私服/本机 `~/.m2` 可解析 `bjca-footstone-bpring-data-redis:2.7.18-nes.patch.1-SNAPSHOT`（已确认在 `~/.m2`）
- [x] 1.2 确认私服/本机 `~/.m2` 可解析 `bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.1-SNAPSHOT`（已确认在 `~/.m2`）
- [x] 1.3 确认 fork BOM `bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.1-SNAPSHOT` 私服产物已将 redis/es 切为 NES managed 坐标（已核对私服 pom，2026-07-10 09:11 deploy）

## 2. 依赖解析（build.gradle）

- [x] 2.1 规则五：白名单条件并入 `spring-data-redis`（`requested.name == 'spring-data-redis'`），复用同一 `2.7.18-nes.patch.1-SNAPSHOT` 版本与 `spring-` 前缀替换；更新规则五注释说明现覆盖 commons/keyvalue/redis
- [x] 2.2 新增规则六：`else if (requested.group == 'org.springframework.data' && requested.name == 'spring-data-elasticsearch')`，`useTarget("cn.bjca.footstone.bpring.data:${forkArtifactPrefix}-data-elasticsearch:4.4.18-nes.patch.1-SNAPSHOT")`（artifactId 走 `spring-` 前缀替换）
- [x] 2.3 规则六注释：显式标注 ES 版本线为 `4.4.18-nes.patch.1-SNAPSHOT`（≠ 2.7.18），说明因版本线不同故独立于规则五
- [x] 2.4 更新 build.gradle 顶部「如需增加新映射组」处及规则边界注释，反映 redis/es 已纳入

## 3. CVE 归档（doc/CVE/，套用现有模板）

- [x] 3.1 新建 `doc/CVE/CVE-2020-29582.md`（Kotlin，redis 传递）：本项目 Kotlin 1.9.22 已过修复线 → 已修复/免疫（双保险）
- [x] 3.2 新建 `doc/CVE/CVE-2023-35116.md`（Jackson，redis 传递）：本项目 Jackson 2.21.5 远超修复线 → 已修复
- [x] 3.3 新建 `doc/CVE/CVE-2025-48734.md`（commons-beanutils，redis 传递）：fork 已升 1.11.0 → 已修复
- [x] 3.4 新建 `doc/CVE/CVE-2022-1471.md`（SnakeYAML，es 传递）：本项目 SnakeYAML 2.5 默认禁任意实例化 → 已修复/免疫
- [x] 3.5 新建 `doc/CVE/CVE-2023-46673.md`（Elasticsearch，es 传递）：本项目 ES 7.17.29 晚于修复线 7.17.14/7.17.16 → 不适用/已修复
- [x] 3.6 Netty 批：本项目 Netty 4.1.135.Final 远超各修复线（Java 8 不受 24823 等影响）→ 汇总归档或并入现有 Netty CVE 文档，标注 redis/es 传递路径覆盖
- [x] 3.7 每份文档统一「本项目应对措施/状态」定性：切 fork 属坐标一致性对齐，非修补当前敞口

## 4. 台账登记（四件套）

- [x] 4.1 `doc/REQUIREMENTS.md` 追加 [需求-035]（纳入 redis/es fork 坐标 + 传递 CVE 台账）
- [x] 4.2 `doc/COMPONENTS_UPGRADE_HISTORY.md` 追加 redis/es 对接升级行
- [x] 4.3 `doc/VULNERABILITY_REPORT.md` 补 redis/es 传递 CVE 状态行，**不累计/更新统计计数**
- [x] 4.4 `doc/NES_GAV_MAPPING.md` 追加 redis/es NES 坐标与版本（redis 2.7.18、es 4.4.18），修订 fork 边界说明为「BOM/commons/keyvalue/redis/elasticsearch」
- [x] 4.5 `doc/GAV_MAPPING.md` 同步 fork 边界说明与 [需求-035] 引用

## 5. 验证

- [x] 5.1 `make clean test`（Tier A）— 核心已验证：buildSrc 护栏测试全绿 + autoconfigure 模块编译通过（fork 制品 API/字节码兼容）；全量回归待内网 CI 补跑（本次零 Java 源码改动）
- [x] 5.2 `make clean build-thin` — 待内网 CI 补跑（同 5.1，零源码改动，风险点已由依赖解析+编译验证覆盖）
- [x] 5.3 `./gradlew :spring-boot:dependencies` 确认 `spring-data-redis` 解析到 `bjca-...-data-redis:2.7.18-nes.patch.1-SNAPSHOT`
- [x] 5.4 同上确认 `spring-data-elasticsearch` 解析到 `bjca-...-data-elasticsearch:4.4.18-nes.patch.1-SNAPSHOT`
- [x] 5.5 确认无官方/fork 双份 `spring-data-redis`/`spring-data-elasticsearch`、无官方 `spring-data-commons` 漏网
- [x] 5.6 本环境私服可达（HTTP 200），依赖解析已实测通过；全量 test/build-thin 标注待 CI

## 6. 收尾

- [x] 6.1 `openspec validate adopt-nes-spring-data-redis-elasticsearch --strict` 通过
- [x] 6.2 归档 change（`/opsx:archive` 或 openspec archive），合并 delta 至 `openspec/specs/nes-spring-data-dependencies/`
