## Why

`spring-boot-project/spring-boot-dependencies/build.gradle:1822` 的 `library("Spring Data Bom", ...)` 通过 `group("org.springframework.data") { imports = ["spring-data-bom"] }` 导入 Spring Data BOM。[需求-017] 曾将其**版本**对齐至 fork 版本体系 `2021.2.18-nes.patch.1-SNAPSHOT`，但当时 fork 侧尚未做坐标去特征化，故 import 坐标仍是官方 `org.springframework.data:spring-data-bom`，且当时明确「跳过 spring-data-bom」。

此后 fork 侧三仓库完成本体 CVE 修复 + GAV 去特征化并发布私服：

- **spring-data-bom**（分支 `2021.2.x-bjca-patch`）：BOM 自身坐标改为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom`；内部仅将 commons/keyvalue 切至 NES 制品，其余 `spring-data-*` 保持官方坐标 + 官方 `2.7.18`；并删除 commons/keyvalue 上对 spring-core/beans/context/tx 的 `exclusions`。
- **spring-data-commons-2.7**：backport 修复 CVE-2026-41711 / 41716 / 41721（本体 DoS）+ 去特征化。
- **spring-data-keyvalue-2.7**：backport 修复 CVE-2026-41719（SpEL 排序注入）+ 去特征化。

原始 `org.springframework.data:spring-data-bom:...-nes.patch.1-SNAPSHOT` 坐标在私服中已不存在。本项目若不更新，构建到 Spring Data 解析会失败；且 commons/keyvalue 四个已修复 CVE 尚未纳入本项目四件套台账。

## What Changes

- **层一（BOM import 坐标）**：`spring-boot-dependencies/build.gradle` 中 Spring Data BOM 的 import 组由 `org.springframework.data` / `spring-data-bom` 改为 `cn.bjca.footstone.bpring.data` / `bjca-footstone-bpring-data-bom`；版本 `2021.2.18-nes.patch.1-SNAPSHOT` 不变。
- **层二（子模块坐标映射）**：根 `build.gradle` 的 `resolutionStrategy.eachDependency` 新增**规则五**，仅将 `org.springframework.data:spring-data-{commons,keyvalue}` 重写为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-{commons,keyvalue}:2.7.18-nes.patch.1-SNAPSHOT`。其余 `spring-data-*`（redis/jpa/mongodb/rest 等）保持官方坐标，由私服/mavenCentral 代理解析。规则五兼堵 redis 等官方模块经传递依赖回拉官方 commons 的链路。
- **四件套台账**：新建 `doc/CVE/CVE-2026-41711/41716/41721.md`，更新 `CVE-2026-41719.md`（免疫 → 已修复+双保险）；`REQUIREMENTS.md` 追加 [需求-034]；`COMPONENTS_UPGRADE_HISTORY.md`、`VULNERABILITY_REPORT.md`（计数 46→50、免疫 4→3、合计 56→59）、`NES_GAV_MAPPING.md`、`GAV_MAPPING.md` 同步。

不改动任何 Java 源码；不 fork redis/jpa 等模块；不触碰 buildSrc / gradle-plugin 的构建期锁定依赖。

## Capabilities

### New Capabilities
- `nes-spring-data-dependencies`: 约束 Spring Boot NES BOM 以 fork 坐标管理 Spring Data BOM，并在构建期将 commons/keyvalue 源码声明透明重写为 NES 制品；同时约束「仅 commons/keyvalue 去特征化、其余模块保持官方坐标」的边界，以及 fork 状态文档一致性。

### Modified Capabilities
<!-- 无 -->

## Impact

- **依赖解析**：`build.gradle`（新增规则五）、`spring-boot-dependencies/build.gradle`（BOM import 坐标）
- **文档/台账**：`doc/REQUIREMENTS.md`、`doc/COMPONENTS_UPGRADE_HISTORY.md`、`doc/VULNERABILITY_REPORT.md`、`doc/NES_GAV_MAPPING.md`、`doc/GAV_MAPPING.md`、`doc/CVE/CVE-2026-41711|41716|41721|41719.md`
- **上游依赖**：需 fork `spring-data-bom` / `spring-data-commons` / `spring-data-keyvalue` 的 `-SNAPSHOT` 制品已 deploy 到私服 `192.168.131.36:8088`
- **验证**：`make clean test`（Tier A）+ `make clean build-thin`；`:spring-boot:dependencies` 确认无官方/fork 双份 `spring-data-commons`、无官方 `spring-core` 漏网。离线/沙盒环境私服不可达时，构建验证在具备内网的环境补跑
