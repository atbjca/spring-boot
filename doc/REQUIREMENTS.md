# NES Fork 需求记录

## [需求-001] Bootstrap 3.5.15 NES Fork Phase A

| 字段 | 内容 |
|------|------|
| 状态 | 已完成 |
| 基线 | Spring Boot 3.5.15（commit `5bafd0a6bf1`） |
| Fork 版本 | `3.5.15-nes.patch.1` |
| 范围 | Boot 层 GAV rebranding、Nexus 发布链路、Makefile 工具链 |
| 非目标 | Framework 6.2.x / Security 6.5.x / Logback fork（Phase B） |

### 验收标准

- 所有 Boot 模块发布坐标为 `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-*`
- `SpringBootVersion.getVersion()` 返回 `3.5.15`
- `make build-thin` 编译通过
- `make install` 本地仓库 GAV 正确

### Nexus 配置

在 `~/.gradle/gradle.properties` 中配置（勿提交凭据）：

```properties
nexusPublicUrl=http://host/repository/maven-public/
nexusReleaseUrl=http://host/repository/releases/
nexusSnapshotUrl=http://host/repository/snapshots/
nexusUsername=your-user
nexusPassword=your-password
```

## [需求-007] 3.5.15 NES Patch 2 Snapshot 开发版本

| 字段 | 内容 |
|------|------|
| 状态 | 当前开发版本 |
| 上一不可变版本 | `3.5.15-nes.patch.1` |
| 当前 Fork 版本 | `3.5.15-nes.patch.2-SNAPSHOT` |
| 官方运行时基线 | `3.5.15` |
| 范围 | Boot fork 开发版本推进、生成 GAV 与当前状态文档同步 |
| 非目标 | 内部依赖升级、RELEASE、Nexus 发布、Git tag |

### 验收标准

- 根 `gradle.properties` 是 Boot fork 版本的唯一来源，`version=3.5.15-nes.patch.2-SNAPSHOT`，不得增加模块级版本覆盖。
- `springBootVersion` 保持 `3.5.15`；Framework、Security、Authorization Server、Spring Data 与 Kafka 等内部 fork 依赖版本保持不变。
- 根项目、代表性 Boot 子项目及生成的 Maven/BOM 元数据必须使用 `3.5.15-nes.patch.2-SNAPSHOT` 和既有 fork groupId/artifactId。
- 必须通过版本属性、生成 POM、`SpringBootVersionTests` 与 clean `make build-thin` 验证。
- 本需求不得执行 publish/deploy、修改 Nexus 内容、创建 release commit 或 `v3.5.15-nes.patch.2` tag。
- `3.5.15-nes.patch.1` 的归档 OpenSpec、发布规范、日期化测试记录与 Git tag 保持不可变。

## [需求-004] 2026-07-16 依赖安全修复

| 组件 | 要求版本 | 说明 |
|------|----------|------|
| Jackson Databind/BOM | 2.21.5 | 修复 2026-54512 至 54518、2026-59888/59889 |
| Logback | 1.5.38 | 保持官方 `ch.qos.logback` 坐标，修复 CVE-2026-13006 |
| Tomcat | 10.1.57 | 修复 CVE-2026-59083 |
| Undertow | 2.3.26.Final | 修复 2026-28367/28368/28369，保持 2.3.x 兼容线 |

验收要求：

- 生成 BOM 必须显示上述版本。
- 必须执行 clean `make build-thin` 和 `make test` 并记录结果。
- 必须同步 `doc/VULNERABILITY_REPORT.md` 与 `doc/CVE/` 明细。
- Log4j2 2.24.3 本轮不升级；默认运行时使用 Logback，并记录风险接受边界和复核触发条件。

## [需求-008] 集成 Spring Security 6.5.11 NES Patch 2 Snapshot

| 字段 | 内容 |
|------|------|
| 状态 | 当前开发基线 |
| Security 上一不可变版本 | `6.5.11-nes.patch.1` |
| Security 当前版本 | `6.5.11-nes.patch.2-SNAPSHOT` |
| Security 官方运行时基线 | `6.5.11` |
| Boot 当前版本 | `3.5.15-nes.patch.2-SNAPSHOT` |
| 范围 | Security snapshot 消费、fork GAV/BOM 解析及 Boot 兼容性验证 |
| 非目标 | Security/Boot 发布、Nexus 写入、RELEASE、Git tag、其他依赖升级 |

### 验收标准

- 根 `springSecurityVersion` 是 Boot 构建中 Security 版本的唯一来源，值为 `6.5.11-nes.patch.2-SNAPSHOT`；不得增加模块级 Security 版本覆盖。
- Security core、config、web、OAuth2、test 与 BOM 必须解析到 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-*:6.5.11-nes.patch.2-SNAPSHOT`，不得选择官方或 patch.1 制品。
- Boot、Framework、Authorization Server、Spring Data、Kafka、ActiveMQ、Artemis 等其他版本保持不变。
- 必须验证生成 BOM、代表性依赖图、Security 定向测试、clean `make build-thin` 与 `make test`。
- 本需求只消费已存在的 Security snapshot，不得执行 publish/deploy、修改 Nexus 内容或创建 release/tag。

## [需求-005] 2026-07-29 Netty / PostgreSQL JDBC 安全修复

| 组件 | 要求版本 | 说明 |
|------|----------|------|
| Netty | 4.1.136.Final | 修复 CVE-2026-59901 及 4.1.136 公告整批安全项；保持 4.1.x，禁止 4.2.x |
| PostgreSQL JDBC | 42.7.13 | 修复 CVE-2026-54291（固定于 42.7.12+） |

验收要求：

- 生成 BOM 必须显示 Netty `4.1.136.Final` 与 PostgreSQL JDBC `42.7.13`。
- 必须执行 clean `make build-thin` 和 `make test` 并记录结果。
- 必须同步 `doc/VULNERABILITY_REPORT.md` 与 `doc/CVE/` 明细（含 Netty 批次与 CVE-2026-54291）。
- Tomcat CVE-2026-66299（examples-only）记为免疫；本轮不升 Tomcat。
- 发布 / Nexus redeploy 不在本需求范围内。

## [需求-012] HttpCore5 CVE-2026-54399 安全升级与 Parsson CVE 追认

| 字段 | 内容 |
|------|------|
| 状态 | 已完成；HttpCore5/Parsson 分类、定向验证、clean thin build 与核心测试均通过 |
| HttpCore5 原版本 | `org.apache.httpcomponents.core5:{httpcore5,httpcore5-h2,httpcore5-reactive}:5.3.6` |
| HttpCore5 当前管理版本 | `5.4.3` |
| HttpCore5 最低稳定修复版本 | `5.4.3`（CVE-2026-54399） |
| Parsson 当前管理版本 | `org.eclipse.parsson:parsson:1.1.9` |
| Parsson 最低修复版本 | `1.1.8`（CVE-2026-9563） |
| 范围 | BOM 单点升级、HttpClient5/响应式 HTTP 兼容验证、Parsson 既有证据追认、CVE/VEX/总览同步 |
| 非目标 | HttpCore5 5.5 beta、HttpClient5 独立升级、Parsson/Yasson/Jakarta JSON 版本变更、发布/Nexus/tag、Log4j2 移植 |

### 验收标准

- `spring-boot-dependencies` 必须通过单一 `HttpCore5` library 管理 `httpcore5`、`httpcore5-h2` 和 `httpcore5-reactive` 5.4.3，不得增加模块级版本、`resolutionStrategy` 或消费模块覆盖。
- 生成 BOM、resolved BOM 与代表性依赖图必须只选择 HttpCore5 5.4.3；不得保留 CVE-2026-54399 受影响的 5.4.2 及更早版本或 5.5-beta1 及更早预览版本。
- HttpClient5 保持 5.5.2；必须验证同步和响应式 HttpComponents builder、CLI、buildpack platform 及可用 smoke/integration 消费路径。
- CVE-2026-54399 只有在定向测试、clean `make build-thin` 和核心 `make test` 成功后才能从“验证中”改为“已修复”。
- Parsson 保持 1.1.9；Yasson 3.0.4 的 1.1.7 请求和 Elasticsearch Java client 的 1.0.5 请求继续统一解析到 1.1.9。CVE-2026-9563 在 1.1.8 修复，因此当前版本可依据审计截止后进入或更新的权威 advisory 数据追认为已修复。
- 必须保留历史事实：Parsson 1.1.9 原升级发生时 OSV 未返回该 CVE，属于主动维护；本轮只是根据后续 advisory 追认安全状态，不得虚构当时的 CVE 驱动或测试目的。
- Parsson 1.1.8 起默认限制 `15,000,000` 次 parser character-consumption，1.1.9 保留该限制；超大 JSON 下游可评估 `org.eclipse.parsson.maxParsingLimit`，本项目不得全局弱化该默认值。
- 必须同步漏洞总览、两份独立 CVE 明细、VEX、GAV 映射和 OpenSpec；不得修改 release 版本或执行发布。
- 实际验证结果：`make clean build-thin` 为 `BUILD SUCCESSFUL in 1m 56s`（828 actionable tasks）；`make test` 为 `BUILD SUCCESSFUL in 10m 11s`（42 actionable tasks：9 executed、2 cached、31 up-to-date）。定向测试和必需门禁均无相关失败，最终风险复核不要求额外执行 `make test-gate`。

## [需求-013] Log4j2 2.25.5 七项 CVE 修复与 Boot 3.5 兼容迁移

| 字段 | 内容 |
|------|------|
| 状态 | 已完成；BOM、源码兼容、focused/smoke、clean thin build、核心测试与 `make test-gate` 均通过 |
| 原版本 | `org.apache.logging.log4j:log4j-bom:2.24.3` |
| 当前版本 | `org.apache.logging.log4j:log4j-bom:2.25.5` |
| 修复范围 | CVE-2025-68161、CVE-2026-34477、CVE-2026-34478、CVE-2026-34479、CVE-2026-34480、CVE-2026-34481、CVE-2026-49844 |
| 默认 logging GAV | `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-logging`（保持 Logback） |
| 可选 Log4j2 GAV | `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-log4j2` |
| 非目标 | 默认日志切换、Log4j2 2.26/3.x、release 版本变更、发布/Nexus/tag |

### 验收标准

- `spring-boot-dependencies` 必须只通过单一 `Log4j2` library 导入 `log4j-bom:2.25.5`，不得增加模块级版本或 prerelease 覆盖。七项 CVE 涉及及代表性运行时模块必须为 2.25.5；必须保留上游 BOM 有意选择的 `log4j-flume-ng:2.23.1`，不得为了数字统一强制覆盖。
- 默认发布 starter 必须继续依赖 `logback-classic:1.5.38`、`log4j-to-slf4j:2.25.5` 和 `jul-to-slf4j:2.0.18`；只有可选 Log4j2 starter 引入 `log4j-core`、`log4j-slf4j2-impl` 与 `log4j-jul:2.25.5`。
- Log4j `PluginProcessor` 所需 builder setter 必须精确改为 public；`GraalVmProcessor` 必须使用 `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot` 生成元数据，不得全局关闭 `-Werror` 或 annotation processing。
- ECS、GELF、Logstash、Extractor 和 custom formatter 必须使用受支持的 `Throwable` API，并保持结构化错误字段与 custom `StackTracePrinter` 行为。
- `%wEx`、`%xwEx` 及其六个 alias 必须覆盖 short/full/extended、separator、cause、无异常与 CRLF/LF 归一化；CVE-2026-49844 必须直接验证 `NaN`、`Infinity`、`-Infinity` 输出为 JSON 字符串。
- 实际验证结果：focused Log4j2 tests 与三个 smoke 模块通过；`make clean build-thin` assemble 为 `BUILD SUCCESSFUL in 3m 13s`（828 actionable tasks：780 executed、35 from cache、13 up-to-date）；`make test` 为 `BUILD SUCCESSFUL in 7m 35s`（42 actionable tasks：9 executed、2 from cache、31 up-to-date）。包级 Log4j2 重跑曾 1/174 失败（`getLoggerConfigurationsShouldReturnAllLoggers`，临时 Nested logger 未挂在测试 `LoggerContext` 上），已按上游 `7d343204016` 稳定化；随后单方法、整类和 174 项包级测试通过。首次 `make test-gate` 因 Codex HTTP 429 在 autoconfigure 测试中被取消，不计为通过；重跑为 `BUILD SUCCESSFUL in 16m 6s`（114 actionable tasks：15 executed、6 from cache、93 up-to-date）。
- 七项独立 CVE、漏洞总览、VEX、GAV 映射、升级评估和 OpenSpec 必须一致报告为已修复；不得修改 `3.5.15-nes.patch.2-SNAPSHOT` 或执行制品发布。

## [需求-009] 显式管理 Parsson 1.1.9

| 字段 | 内容 |
|------|------|
| 状态 | 当前依赖基线；后续 advisory 已确认 1.1.9 修复 CVE-2026-9563 |
| 组件 | Eclipse Parsson（Jakarta JSON-P provider） |
| 上一传递版本 | `1.1.7`（Yasson 3.0.4）/ `1.0.5`（Elasticsearch Java client） |
| 当前管理版本 | `org.eclipse.parsson:parsson:1.1.9` |
| 范围 | Boot BOM 显式版本管理、JSON-B 解析与兼容性验证 |
| 非目标 | Yasson 3.0.5/groupId 迁移、Jakarta JSON API 升级、发布/Nexus/tag |

### 验收标准

- `spring-boot-dependencies` 必须通过单一 `Parsson` library 管理 `org.eclipse.parsson:parsson:1.1.9`，不得在 starter、测试模块或 resolutionStrategy 增加第二个版本源。
- 生成 BOM 必须包含 `parsson.version=1.1.9` 和对应 managed dependency。
- Yasson 保持 `org.eclipse:yasson:3.0.4`；其 Parsson 1.1.7 请求及 Elasticsearch Java client 的 1.0.5 请求在代表性 runtime graph 中必须统一选择 1.1.9。
- Jakarta JSON API 保持 2.1.3，Jakarta JSON Bind API 保持 3.0.2；其他 fork 与第三方依赖版本保持不变。
- 必须运行 JSON-B 定向测试、clean `make build-thin` 与 `make test`，并如实记录任何无关测试波动。
- OSV 对 Parsson 1.1.7 与 1.0.5 的查询在原 2026-08-11 升级审计中均未返回漏洞，因此当时准确记录为主动维护。审计截止后进入或更新的 CVE-2026-9563 权威数据明确影响 1.1.8 之前的 Maven Central artifacts，并由 1.1.8 修复；当前 1.1.9 据此追认为已修复，但不得改写原升级时间线、断言 CVE 的首次发布日期或虚构测试目的。
- Parsson 1.1.8 起新增默认 `15,000,000` 次字符解析操作上限，1.1.9 延续该行为；处理超大 JSON 的下游必须评估并按需配置 `org.eclipse.parsson.maxParsingLimit`，本项目不得擅自设置全局覆盖值。

## [需求-006] 2026-08-06 ActiveMQ Classic / Artemis 安全修复

| 组件 | 要求版本 | 兼容边界 |
|------|----------|----------|
| ActiveMQ Classic | 6.2.8 | 保持 6.2.x 维护线；未经独立兼容性评估不得升级到 6.3.x |
| ActiveMQ Artemis | 2.54.0 | 使用权威 `org.apache.artemis:artemis-bom`；现有 `org.apache.activemq:artemis-*` 消费坐标暂时保留，由 2.54.0 BOM 的兼容条目统一管理 |

验收要求：

- ActiveMQ 与 Artemis 的生产依赖版本只能由 `spring-boot-dependencies` 中对应 BOM library 声明拥有，不得在 starter、模块或测试中增加第二个版本覆盖。
- 生成 dependency-management POM 和 resolved BOM 必须显示 ActiveMQ `6.2.8`、`org.apache.artemis:artemis-bom:2.54.0`，并确认新旧 Artemis groupId 下的模块均解析为 `2.54.0`、无模块级版本漂移。
- 必须运行 ActiveMQ/Artemis starter、JMS 自动配置、连接工厂、客户端与 embedded broker/server 的定向测试；协议覆盖按项目已有 Core、OpenWire、STOMP 测试能力执行，未覆盖的授权负向场景必须如实记录。
- 可用的 Docker/Testcontainers/Compose 测试必须执行；若 Docker daemon 等环境前提缺失，必须记录准确的跳过原因和非容器补偿证据，不得将跳过记为通过。
- 必须执行 `make clean build-thin`、`make test`，并在定向失败或最终风险复核要求时执行 `make test-gate`；全部必需门禁成功后，相关 CVE 才能记为已修复。
- 必须同步 `doc/VULNERABILITY_REPORT.md`、15 份 `doc/CVE/` 明细、`doc/NES_GAV_MAPPING.md` 与对应 OpenSpec 证据，审计截止不得早于 2026-08-06。
- Fork/release 版本、发布配置与 Nexus 部署不在本需求范围内。

## [需求-010] LZ4 Java CVE-2026-59949 安全升级

| 字段 | 内容 |
|------|------|
| 状态 | 已完成；定向验证、clean thin build、核心测试和 Tier B 门禁均通过 |
| 上一解析版本 | `at.yawk.lz4:lz4-java:1.10.1`（由 Kafka clients 3.9.2 传递引入） |
| 当前管理版本 | `at.yawk.lz4:lz4-java:1.11.2` |
| 最低修复版本 | `1.11.1` |
| 范围 | Boot BOM 显式版本管理、Kafka/LZ4/XXHash 兼容性验证、CVE 文档 |
| 非目标 | Kafka/Spring Kafka 升级、归档 `org.lz4` 坐标恢复、恶意 JNI 崩溃载荷执行、发布/Nexus/tag |

### 验收标准

- `spring-boot-dependencies` 必须通过单一 `LZ4 Java` library 管理 `at.yawk.lz4:lz4-java:1.11.2`，不得增加模块级版本或 resolutionStrategy 覆盖。
- 生成 BOM 必须包含 `lz4-java.version=1.11.2` 和对应 managed dependency。
- Kafka clients 3.9.2 的 1.10.1 传递请求必须统一解析到 1.11.2；Kafka 3.9.2 与 Spring Kafka `3.3.16-nes.patch.1` 保持不变。
- 解析图不得选择 `at.yawk.lz4:lz4-java:1.10.1`、`org.lz4:lz4-java` 或 `net.jpountz.lz4:lz4` 旧制品。
- 必须验证有效的 LZ4 压缩/解压、XXHash、Kafka producer/consumer、Streams 配置和 auto-configuration 路径；不得在主测试 JVM 中执行会触发 native 崩溃的非法数组范围载荷。
- CVE 状态只有在父 OpenSpec change 的 clean build 和核心测试门禁通过后才能从“验证中”改为“已修复”。`make clean build-thin` 已成功；首次父变更 `make test` 的环境性 `SIGKILL 9` 中断已在资源恢复后重跑，用户于 2026-08-13 确认 `make test` 和 `make test-gate` 均成功完成。

## [需求-011] 2026-08-11 剩余 BOM CVE 处理与全量审计

| 字段 | 内容 |
|------|------|
| 状态 | 已完成；依赖修改、定向验证、完整 OSV 审计和全部项目门禁均通过 |
| 审计截止 | 2026-08-11 |
| 范围 | Derby 延期、Commons Lang、QueryDSL、OpenTelemetry、LZ4 修复，Undertow/Infinispan/Spring Integration 分类，Log4j2 台账，以及完整 resolved-BOM 审计 |
| 非目标 | Java 基线升级、自建 Derby 制品、QueryDSL 6.x、Kafka/Spring Kafka 升级、Log4j2 2.25.x 移植、发布/Nexus/tag |

| 组件 / finding | 要求状态 |
|------|----------|
| Apache Derby / CVE-2022-46337 | 保留 `10.16.1.1` 并明确延期；LDAP authentication 是触发边界；发布可消费的 Java 17 修复或 Java 基线升级时重评 |
| Commons Lang3 / CVE-2025-48924 | `3.18.0` |
| QueryDSL / CVE-2024-49203 | 从 `com.querydsl:5.1.0` 迁移到 `io.github.openfeign.querydsl:5.6.1`；Java 包仍为 `com.querydsl.*` |
| OpenTelemetry / CVE-2026-45292 | `1.62.0`；parent-only OkHttp/MockWebServer 测试库对齐 `5.3.2`，不得加入发布 BOM |
| LZ4 Java / CVE-2026-59949 | `at.yawk.lz4:lz4-java:1.11.2` |
| Undertow / CVE-2026-3260 | 保留 2.3.26.Final；按 2026-07-07 CNA REJECTED 状态记为不适用并保留旧 GHSA |
| Infinispan / CVE-2025-5731 | 15.2.6.Final 超出 CNA `<15.2.5` 受影响范围；CLI 不在默认 cache runtime |
| Spring Integration / CVE-2026-40987 | 6.5.10 新于 6.5.9 OSS 修复边界；当前扫描关联记为版本误报 |
| Log4j2 | 本需求当时将 2.24.3 的七个 finding 明确延期；后续 [需求-013] 已完成 2.25.5 兼容移植并转为已修复，默认运行时仍保持 Logback |

### 验收标准

- Derby、Commons Lang3、OpenTelemetry、QueryDSL 和 LZ4 Java 的生产版本只能由 `spring-boot-dependencies` 对应 library/BOM 声明拥有，不得增加模块级版本或通用 resolutionStrategy 覆盖。
- 生成 dependency-management POM 和 resolved BOM 必须显示 Derby 10.16.1.1、Commons Lang3 3.18.0、OpenTelemetry 1.62.0、OpenFeign QueryDSL 5.6.1、LZ4 Java 1.11.2；不得保留 `com.querydsl` 5.1.0 管理项。
- QueryDSL 下游必须迁移 Maven groupId；本项目源码和公共 API 不得把 Java import 从 `com.querydsl.*` 改名。
- Derby 10.16.1.2 的必要 Central 制品缺失、10.17.1.0 class-file major 63 与 Java 17 major 61 不兼容的证据必须保留；不得将该 finding 写成已修复。
- 完整 resolved-BOM 审计必须覆盖直接管理和 imported BOM 展开的每个 Maven 坐标，应用 NES-to-upstream alias，并对所有命中给出 VEX 分类；失败、过期、截断或数量不一致不得报告为 clean。
- 2026-08-11 最终审计证据必须记录 1560 个输入坐标、1547 个 distinct 坐标、13 个重复来源、0 个 malformed 坐标、9 个 normalized findings、0 个未分类项，以及 `complete-with-known-risk` 状态。
- 必须保留 Commons Lang、QueryDSL/GraphQL、OpenTelemetry baggage/exporter、Kafka/LZ4、Derby、Undertow 和 Infinispan 的定向验证证据；`make clean build-thin` 必须成功。
- `make test` 和 `make test-gate` 必须成功完成。首次 `make test` 的 `SIGKILL 9` 仅记录为环境中断；用户于 2026-08-13 确认资源恢复后的 `make test` 和 `make test-gate` 均成功完成，Commons Lang、QueryDSL、OpenTelemetry 和 LZ4 状态更新为“已修复”。
- 必须同步漏洞总览、各 CVE 明细、Log4j2 评估、GAV 映射、机器可读 alias/VEX 和 OpenSpec 实施证据；不得修改 fork/release 版本、发布配置或 Nexus 内容。

## [需求-002] Framework / Security GAV 映射 Phase B

| 字段 | 内容 |
|------|------|
| 状态 | 已完成 |
| 基线 | Phase A 完成后的 `3.5.x-bjca-patch` |
| Framework 版本 | `6.2.19-nes.patch.1` |
| Security 版本 | `6.5.11-nes.patch.1` |
| Authorization Server 版本 | `1.5.8-nes.patch.1` |
| 范围 | `resolutionStrategy` 映射、BOM 条目、buildSrc 坐标切换、ClassPathExclusions fork 适配 |
| 前提 | Framework / Security fork 制品已发布到 Nexus |

### 验收标准

- 构建解析 `org.springframework:*` / `org.springframework.security:*` 为 fork GAV
- `make build-thin` 编译通过
- `make test` 核心模块全绿
- BOM POM 中 Framework / Security managed deps 使用 fork groupId

## [需求-003] A 类生态 SCA 排除 Phase C

| 字段 | 内容 |
|------|------|
| 状态 | 已完成 |
| 基线 | Phase B 完成后的 `3.5.x-bjca-patch` |
| 范围 | BOM 中对 GraphQL / HATEOAS / LDAP / Retry / AMQP / Batch / RESTDocs 添加 `exclude org.springframework`；Kafka 使用 fork 坐标并保留 exclusion；Spring Data commons/keyvalue/redis/elasticsearch 使用 fork BOM + fork 制品 |
| 非目标 | Spring Data 其它未 fork 模块 / Integration / Session BOM import 条目、Logback fork；Spring WS 保持上游 BOM import |

### 验收标准

- 生成的 BOM POM 中上述 A 类模块含 `org.springframework:*` exclusion
- Spring Data BOM 使用 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom`，Redis/KeyValue/Commons/Elasticsearch 解析到 fork 坐标
- Spring WS 保持 `spring-ws-bom` import，不展开 modules 解析 OpenSAML
- `make build-thin` / `make test` 全绿
