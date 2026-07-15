## 1. 依赖解析改动（层一 + 层二）

- [x] 1.1 `spring-boot-project/spring-boot-dependencies/build.gradle`：`library("Spring Data Bom", ...)` 版本改 `2025.0.13-nes.patch.1-SNAPSHOT`、import 组由 `group("org.springframework.data") { bom("spring-data-bom") }` 改为 `group("cn.bjca.footstone.bpring.data") { bom("bjca-footstone-bpring-data-bom") }`，加注释说明 fork 来源
- [x] 1.2 根 `build.gradle`：在 `resolutionStrategy.eachDependency` 的 security 规则之后新增 **Kafka 规则**：`org.springframework.kafka:spring-kafka*` → `${forkArtifactPrefix}-` 前缀替换 → `cn.bjca.footstone.bpring.kafka:*:3.3.16-nes.patch.1-SNAPSHOT`
- [x] 1.3 根 `build.gradle`：新增 **Data 规则**：`org.springframework.data:spring-data-{commons,keyvalue,redis,elasticsearch}` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-*`；commons/keyvalue/redis 用 `3.5.13-nes.patch.1-SNAPSHOT`，**elasticsearch 单列 `5.5.13-nes.patch.1-SNAPSHOT`**（三元表达式按 artifact 分支给版本）；其余 `spring-data-*` 不匹配、保持官方
- [x] 1.4 更新 resolutionStrategy 规则注释，补 data / kafka 映射说明

## 2. BOM 库块调整

- [x] 2.1 `library("Spring Kafka", ...)`：版本改 `3.3.16-nes.patch.1-SNAPSHOT`、group 改 `cn.bjca.footstone.bpring.kafka`、modules key 改名为 `bjca-footstone-bpring-kafka` / `-kafka-test`，**保留 `exclude group: "org.springframework", module: "*"`**
- [x] 2.2 `library("Elasticsearch Client", "8.18.8")`：`alignWith { version { from ... } }` 的 `from` 由 `org.springframework.data:spring-data-elasticsearch` 改到 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch`，`managedBy "Spring Data Bom"` 保持
- [x] 2.3 **删除** Spring Data Commons / KeyValue / Redis 三个独立 library 块（四模块已 fork、内部不传递官方坐标，改由 fork data-bom 纳管，无需 A 类 exclude；与 2.7 一致）

## 3. starter（确认不改）

- [x] 3.1 确认 `spring-boot-starter-data-elasticsearch` / `-data-redis` / `-data-redis-reactive` 的 `api("org.springframework.data:...")` 保持官方坐标不动（路线②，由 resolutionStrategy 透明重写）

## 4. 验证

- [x] 4.1 Gradle 配置阶段离线自检：`./gradlew :spring-boot-project:spring-boot-dependencies:help --offline` **BUILD SUCCESSFUL**（规则与 fork BOM import DSL 语法正确、bomr 接受新坐标）
- [x] 4.2 静态一致性核对：`replaceFirst` 推导的 artifactId 与 fork `spring-data-bom/bom/pom.xml` 4 条 managed 条目、kafka fork 制品坐标逐一比对一致
- [ ] 4.3 `make clean test`（Tier A）+ `make clean build-thin` + `checkRuntimeClasspathForProhibitedDependencies`（需内网私服可达，离线环境待补跑）
- [x] 4.4 `:dependencies` 实测（本地缓存命中，`--offline`）确认：
  - data-redis starter：`spring-data-redis → bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1`，传递 keyvalue/commons 均 fork 坐标，`bjca-footstone-bpring-data-bom:2025.0.13-nes.patch.1` 纳管生效
  - data-elasticsearch starter：**`spring-data-elasticsearch → bjca-footstone-bpring-data-elasticsearch:5.5.13-nes.patch.1`（5.5.x 版本线正确）**，其 commons 依赖仍 3.5.13（版本线正确分叉），BOM constraint 显示 ES 5.5.13 (c)
  - 传递官方 `org.springframework:spring-core/web/context` 经规则一重写为 `bjca-footstone-bpring-*:6.2.19-nes.patch.1`，无官方漏网
  - 生成 BOM POM 核对：data-bom import = fork 坐标、`spring-kafka.version=3.3.16-nes.patch.1`、kafka managed 条目 = `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka{,-test}` + exclude、**无残留官方 spring-data-commons/keyvalue/redis 独立管理条目**

## 5. 台账 / 文档（按项目惯例，若适用）

- [ ] 5.1 `doc/NES_GAV_MAPPING.md` / `doc/GAV_MAPPING.md`：新增/补充 Spring Data（4 模块）+ Kafka 的 GAV 映射与规则说明
- [ ] 5.2 若涉及 CVE 修复纳入，按项目四件套惯例更新 `doc/REQUIREMENTS.md`、`COMPONENTS_UPGRADE_HISTORY.md`、`VULNERABILITY_REPORT.md`（本 change 以坐标对接为主，CVE 台账视 fork 侧实际修复内容补登）

## 6. 归档

- [ ] 6.1 归档本 change，spec 增量 sync 到 `openspec/specs/`；`openspec validate --strict` 通过
