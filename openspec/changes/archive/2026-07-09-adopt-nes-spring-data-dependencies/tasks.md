## 1. 依赖解析改动

- [x] 1.1 `spring-boot-project/spring-boot-dependencies/build.gradle`：将 `library("Spring Data Bom", "2021.2.18-nes.patch.1-SNAPSHOT")` 的 import 组由 `group("org.springframework.data") { imports = ["spring-data-bom"] }` 改为 `group("cn.bjca.footstone.bpring.data") { imports = ["bjca-footstone-bpring-data-bom"] }`，版本不变，加注释
- [x] 1.2 根 `build.gradle`：在 `resolutionStrategy.eachDependency` 规则四（logback）之后新增规则五，仅重写 `org.springframework.data:spring-data-{commons,keyvalue}` 为 NES 坐标 `2.7.18-nes.patch.1-SNAPSHOT`
- [x] 1.3 更新规则组头部注释，补 spring-data 到现有映射组清单

## 2. CVE 文档

- [x] 2.1 新建 `doc/CVE/CVE-2026-41711.md`（commons PropertyPath 栈溢出 DoS）
- [x] 2.2 新建 `doc/CVE/CVE-2026-41716.md`（commons TypeDiscoverer 负缓存 OOM DoS）
- [x] 2.3 新建 `doc/CVE/CVE-2026-41721.md`（commons MapDataBinder SpEL 集合自增 DoS）
- [x] 2.4 更新 `doc/CVE/CVE-2026-41719.md`：状态 免疫 → 已修复（fork backport）+ 未使用（双保险）

## 3. 台账登记

- [x] 3.1 `doc/REQUIREMENTS.md`：追加 [需求-034]
- [x] 3.2 `doc/COMPONENTS_UPGRADE_HISTORY.md`：追加 Spring Data BOM 去特征化行
- [x] 3.3 `doc/VULNERABILITY_REPORT.md`：补 4 个 CVE 状态行 + 更新计数（已修复 46→50、免疫 4→3、合计 56→59）+ 头部日期/坐标说明
- [x] 3.4 `doc/NES_GAV_MAPPING.md`：新增 Spring Data GAV 映射章节
- [x] 3.5 `doc/GAV_MAPPING.md`：补规则五说明，兑现原「如需新增 spring-data」TODO

## 4. 验证

- [x] 4.0 Gradle 配置阶段离线自检：`./gradlew :spring-boot-project:spring-boot-dependencies:help --offline` EXIT=0，证明 `build.gradle` 规则五与 `spring-boot-dependencies/build.gradle` 的 fork BOM import DSL 语法正确、脚本可加载、bomr 接受新坐标
- [x] 4.0b 静态一致性核对：`replaceFirst(/^spring-/, "${forkArtifactPrefix}-")` 推导得 `bjca-footstone-bpring-data-commons`，与 fork `spring-data-bom/bom/pom.xml` 及 fork 仓库实际制品坐标一致；fork commons `PropertyPath.java:427-433` 的 `depth` 计数器修复（CVE-2026-41711）已核实存在
- [x] 4.1 `make clean test`（Tier A：spring-boot + spring-boot-test + Kafka smoke）BUILD SUCCESSFUL in 15m 20s，零失败（2026-07-09，私服可达 + fork data SNAPSHOT 已 deploy）
- [x] 4.2 `make clean build-thin` BUILD SUCCESSFUL in 11m 10s；`checkRuntimeClasspathForProhibitedDependencies` 通过（无禁止依赖违规）
- [x] 4.3 `:spring-boot:dependencies` 确认：`spring-data-commons:2.7.18 → bjca-footstone-bpring-data-commons:2.7.18-nes.patch.1-SNAPSHOT`、`spring-data-keyvalue → bjca-...-data-keyvalue`、fork BOM `bjca-footstone-bpring-data-bom` 导入；所有 `org.springframework:spring-core` 经规则一重写为 fork core（无官方漏网、无双份 commons）；`spring-data-redis/r2dbc/relational` 保持官方坐标未被误改
- [x] 4.4 无 SSL flaky 失败（Tier A 一次通过）

> 注：任务 4.1–4.4 已在内网私服环境（`192.168.131.36:8088`，fork data SNAPSHOT 已 deploy）实测通过（2026-07-09），全部 BUILD SUCCESSFUL。

## 5. 归档

- [x] 5.1 归档本 change，spec 增量 sync 到 `openspec/specs/nes-spring-data-dependencies/`（2026-07-09 完成，`openspec validate spec/nes-spring-data-dependencies --strict` 通过）
