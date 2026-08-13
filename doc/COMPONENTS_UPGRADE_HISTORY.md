# 核心组件漏洞升级与维护记录表 (Upgrade History)

> 为保证项目长期安全与稳定，本表跟踪核心三方组件的安全版本升级历史。
> JDK 8 兼容性限制：无法越过 Spring Boot 2.7.x 的 BOM 禁止依赖规则进行激进跨主版本升级。

## 组件升级历史

| 升级日期 | 组件名称 | 升级前版本 | 升级后版本 | 修复漏洞 / 原因 | 兼容性说明 |
| :---: | :--- | :---: | :---: | :--- | :--- |
| 2026-08-13 | NES Elasticsearch 客户端闭包 + Spring Data patch.2 | 官方 ES 7.17.29 / SDE patch.1 | **NES `7.17.29-nes.patch.1-SNAPSHOT` + Data BOM/SDE patch.2-SNAPSHOT** | 对齐已验证 NES 客户端闭包、Java API Client、Barsson、Jakarta JSON-P 2.0.2；停止管理 Transport Client / integ-test / 官方 elasticsearch-java；starter 显式 LZ4 替换（[需求-042]） | Java package 不变；内部依赖仍为 SNAPSHOT，正式 Boot RELEASE 保持阻断 |
| 2026-08-11 | Spring Security NES（Boot 开发候选） | `5.8.16-nes.patch.1` RELEASE | **`5.8.16-nes.patch.2-SNAPSHOT`** | Boot 开发线采用包含七项 2026 CVE backport 的 Security 候选；已验证实际 Nexus 制品 `5.8.16-nes.patch.2-20260811.065312-1`、现有 BOM/GAV 映射、Maven/Gradle Java 8 SAML/Crypto smoke和 SendGrid 4.10.1 BC 统一 | 仅为开发候选，不是 RELEASE；patch.1 制品、tag、用户示例和回滚目标保持不变；正式 Boot 发布仍等待 Security patch.2 RELEASE/tag及剩余发布门禁 |
| 2026-08-10 | Spring Boot NES fork 开发版本 | `2.7.18-nes.patch.1` | **`2.7.18-nes.patch.2-SNAPSHOT`** | 为 c3p0 / mchange / lz4-java 安全基线生成独立、可审计的开发制品，避免复用已发布 RELEASE 坐标 | 仅递增 Boot 制品版本；Spring Framework、Security、Data、Kafka、Reactor Netty 等独立 fork 版本保持不变 |
| 2026-08-06 | `com.mchange:c3p0` / `mchange-commons-java` | 0.9.5.5 / 旧传递版本 | **0.14.0 / 0.6.0** | CVE-2026-27727、CVE-2026-27830、CVE-2026-55223；纠正“Quartz exclude 已移除全部暴露”的旧台账结论 | class major 51；Boot DataSourceBuilder、H2 池生命周期及 Hibernate 5.6 provider 验证通过；直接使用已移除 c3p0 旧 API 的下游需迁移 |
| 2026-08-06 | `at.yawk.lz4:lz4-java` | 1.10.1 | **1.11.1** | CVE-2026-59949 JNI XXHash 无效数组范围导致 JVM 崩溃/越界读取；发布 BOM 管理活跃 fork，Gradle 将旧 `org.lz4` 坐标替换到新版本 | class major 51；Java/JNI 压缩和 XXHash 冒烟通过；Maven 同时使用 Kafka/Elasticsearch 时须排除 Elasticsearch 的旧 `org.lz4` 路径 |
| 2026-07-22 | `io.projectreactor.netty:reactor-netty-*` → Reactor Netty NES | 官方 1.0.48 | **`cn.bjca.footstone.beactor.netty:bjca-footstone-beactor-netty-*:1.0.48-nes.patch.1-SNAPSHOT`** | 统一 NES GAV；starter POM 直接发布 NES HTTP 坐标；commit `da3c7cf2` 修复 CVE-2025-22227/41715，Nexus HTTP 制品 `20260722.053243-4` 已验证安全字节码（[需求-039]） | Java package 不变；关键 class major 52；源码、测试与制品证据闭环 |
| 2026-07-22 | `io.netty:netty-bom` 等 | 4.1.135.Final | **4.1.136.Final** | 与 Reactor Netty NES 已验证组合对齐，覆盖修复线不高于 4.1.136 的 Netty 漏洞 | Java 8 兼容；HTTP/2 `maxStreams` 回归覆盖 |
| 2026-07-22 | Spring Kafka NES `DefaultKafkaHeaderMapper` | `2.9.13-nes.patch.1-SNAPSHOT` 旧时间戳制品 | **版本字符串不变；验证 `20260721.054238-2`** | fork commit `c119b8f62` 回移 CVE-2026-41731，受信包由父包前缀匹配收紧为精确包名匹配 | Java 8 variant；Boot 消费端行为回归覆盖；旧 SNAPSHOT 缓存需刷新（[需求-038]） |
| 2026-07-21 | Spring Boot `ApplicationTemp` / Actuator `EndpointRequest` | 2.7.18 原始实现 | **NES Java 8 backport** | CVE-2026-40973 临时目录接管、CVE-2025-22235 `/null/**` 安全匹配器 | 公开 API/GAV 不变；servlet/reactive 回归测试覆盖（[需求-036]） |
| 2026-07-21 | `org.postgresql:postgresql` | 42.3.8 | **42.7.13** | CVE-2024-1597 SQL 注入、CVE-2026-42198 SCRAM PBKDF2 CPU DoS | Java 8 兼容；跨 minor，执行 JDBC/JPA 回归（[需求-037]） |
| 2026-07-21 | `com.h2database:h2` | 2.1.214 | **2.2.220** | CVE-2022-45868 Web Console 管理密码命令行泄露 | class major 52，Java 8 兼容 |
| 2026-07-21 | `com.hazelcast:hazelcast` | 5.1.7 | **5.2.5** | CVE-2023-45859 / CVE-2023-45860 权限校验缺失 | 5.2.x Java 8 编译目标；执行 cache/session 回归 |
| 2026-07-21 | `com.rabbitmq:amqp-client` | 5.14.3 | **5.18.0** | CVE-2023-46120 超大消息 OOM DoS | class major 52，Java 8 兼容 |
| 2026-07-21 | `org.springframework.ldap:*` | 2.4.1 | **2.4.4** | CVE-2024-38829 locale 大小写转换导致数据暴露 | 保持 Spring Framework 5 / Javax 体系 |
| 2026-07-21 | `com.sun.mail:jakarta.mail` | 1.6.7 | **1.6.8** | CVE-2025-7962 SMTP 注入 | 保持 javax.mail namespace，兼容 Boot 2.7 |
| 2026-07-21 | `io.undertow:*` | 2.2.39.Final | **2.2.40.Final** | strict HTTP parser 修复 CVE-2026-28367/28368/28369；纠正 CVE-2026-3260 状态，2.2.40 仍在公告影响范围 | Java 8 兼容；3260 仍需拒绝 multipart GET 等缓解 |
| 2026-07-21 | `org.apache.tomcat.embed:*` | 9.0.119 | **9.0.120** | 跟进 Java 8 兼容的 9.0.x 最新补丁线 | 同主版本补丁升级 |
| 2026-07-21 | `org.apache.derby:*` / `org.hsqldb:hsqldb` | 10.14.2.0 / 2.5.2 | **保持不变** | Derby 无公开 Java 8 修复制品；HSQLDB 修复线需 Java 11，纠正台账而不伪报升级 | 仅可信测试/开发场景，维持暂缓/缓解状态 |
| 2026-07-10 | `org.springframework.data:spring-data-redis` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis` | `2.7.18`（官方坐标） | `2.7.18-nes.patch.1-SNAPSHOT`（**fork 坐标**） | redis 完成坐标去特征化；fork BOM 将 redis managed 依赖切 NES 制品；配套 resolutionStrategy 规则五并入 redis。所修传递依赖 CVE（Kotlin CVE-2020-29582 / Jackson CVE-2023-35116 / commons-beanutils CVE-2025-48734 / Netty 批）本项目 BOM 版本已高于修复线，属坐标一致性对齐（[需求-035]） | 包名/JPMS 模块名不变，Java 8 兼容 |
| 2026-07-10 | `org.springframework.data:spring-data-elasticsearch` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch` | `4.4.18`（官方坐标） | `4.4.18-nes.patch.1-SNAPSHOT`（**fork 坐标**，ES 4.4.x 版本线） | elasticsearch 完成坐标去特征化；fork BOM 将 es managed 依赖切 NES 制品；配套 resolutionStrategy 新增规则六（独立 4.4.x 版本线）。所修传递依赖 CVE（SnakeYAML CVE-2022-1471 / Elasticsearch CVE-2023-46673 / Netty 批）本项目 BOM 版本已高于修复线，属坐标一致性对齐（[需求-035]） | 包名/JPMS 模块名不变，Java 8 兼容 |
| 2026-07-09 | `org.springframework.data:spring-data-bom` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom` | `2021.2.18-nes.patch.1-SNAPSHOT`（官方坐标） | `2021.2.18-nes.patch.1-SNAPSHOT`（**fork 坐标**） | fork BOM 完成坐标去特征化；commons/keyvalue 切 NES 制品并 backport CVE-2026-41711/41716/41721（commons DoS）、CVE-2026-41719（keyvalue SpEL 注入）；配套 resolutionStrategy 规则五重写 commons/keyvalue | 包名/JPMS 模块名不变，Java 8 兼容；其余 spring-data-* 保持官方坐标由私服代理解析 |
| 2026-07-08 | `com.fasterxml.jackson.core:jackson-databind` 等 | 2.21.4 | **2.21.5** | CVE-2026-54515（大小写不敏感绑定重开 `@JsonIgnoreProperties` 忽略字段，mass-assignment）— 该 CVE 未随 2.21.4 修复，backport 至 2.21.5 | 2.21.x 同 minor 线安全补丁，API 兼容，Java 8 兼容 |
| 2026-07-02 | `org.jetbrains.kotlin:*` | 1.6.21 | **1.9.22** | 让 OkHttp 4.12 / jackson-module-kotlin 2.21 携带的 Kotlin metadata（1.8/1.9）能被 fork 构建接受；配套 jackson-module-kotlin 从 `strictly 2.16.2` 恢复由 jackson-bom 统一管理 | Kotlin `languageVersion`/`apiVersion` 维持在 `1.6`（Kotlin 1.9 编译器仍支持）；源码零改动 |
| 2026-07-02 | `org.xerial:sqlite-jdbc` | 3.36.0.3 | **3.41.2.2** | CVE-2023-32697 (CVSS 8.8) JDBC URL RCE | 测试依赖；Java 8 兼容 |
| 2026-07-02 | `net.minidev:json-smart` | 2.4.11 | **2.5.2** | CVE-2023-1370 (CVSS 7.5) 深层嵌套 JSON 栈溢出 DoS | 跨 minor 升级 |
| 2026-07-02 | `com.google.code.gson:gson` | 2.9.1 | **2.12.1** | CVE-2025-53864 嵌套 JSON DoS（缺少深度限制） | 跨 minor 升级；Java 8 兼容 |
| 2026-07-02 | `com.squareup.okhttp3:okhttp-bom` | 4.9.3 | **4.12.0** | CVE-2023-3635 (CVSS 7.5) Okio GzipSource DoS | 跨 minor 升级；Java 8 兼容 |
| 2026-07-02 | `org.apache.httpcomponents.client5:httpclient5` | 5.1.4 | **5.6.1** | CVE-2026-40542 (CVSS 6.9) SCRAM-SHA-256 认证验证缺失 | 跨 minor 升级；需配套 httpcore5 5.4 |
| 2026-07-02 | `org.apache.httpcomponents.core5:httpcore5` 等 | 5.1.5 | **5.4** | HttpClient5 5.6.1 传递依赖要求 httpcore5 5.4+（`Tokenizer.delimiters()` API 在 5.2+ 引入） | 跨 minor 升级 |
| 2026-07-02 | `io.projectreactor:reactor-bom` | 2020.0.38 | **2020.0.47** | 跟进 2020.0.x 最终版；后续核实其 Reactor Netty 1.0.48 仍受 CVE-2025-22227 影响 | Reactor Core 继续由该 BOM 管理；Reactor Netty 于 [需求-039] 切 NES GAV |
| 2026-07-01 | `io.undertow:undertow-core` 等 | 2.2.31.Final | **2.2.39.Final** | CVE-2025-12543 (CVSS 9.6) Host header 验证绕过 | 同 2.2.x minor 线补丁，兼容 Java 8 |
| 2026-07-01 | `org.thymeleaf:thymeleaf` 等 | 3.1.2.RELEASE | **3.1.5.RELEASE** | CVE-2026-40477, CVE-2026-40478, CVE-2026-41901 (CVSS 9.0 ×3) SSTI 模板注入 | 同 3.1.x minor 线补丁 |
| 2026-07-01 | `org.apache.solr:solr-solrj` 等 | 8.11.2 | **8.11.4** | CVE-2024-45216 (CVSS 9.8) PKI 认证绕过 | 同 8.11.x minor 线补丁 |
| 2026-07-01 | `org.apache.logging.log4j:*` | 2.25.3 | **2.25.4** | CVE-2026-34478, CVE-2026-34480 (CVSS 7.5) CRLF 注入 + XmlLayout 字符转义 | 补丁版本，Java 8 兼容 |
| 2026-07-01 | `org.eclipse.jetty:jetty-bom` 等 | 9.4.57.v20241219 | **9.4.58.v20250814** | CVE-2025-5115 (CVSS 7.7) HTTP/2 资源耗尽 DoS | 9.4.x 最终安全发布（EOL 2026-01） |
| 2026-07-01 | `org.glassfish.jersey:jersey-bom` 等 | 2.35 | **2.46** | CVE-2025-12383 (CVSS 7.4-9.4) SSL 竞态条件安全配置失效 | 同 2.x 主版本线；3.0+ 使用 jakarta.* 命名空间 |
| 2026-06-30 | `org.liquibase:liquibase-core` 等 | 4.9.1 | **4.24.0** | 与 BOM 中 SnakeYAML 2.5 二进制不兼容 | Spring Boot 3.2 同款；支持 SnakeYAML 2.x，仍兼容 Java 8（5.0+ 需 Java 17） |
| 2026-06-25 | `com.fasterxml.jackson.core:jackson-databind` 等 | 2.21.1 | **2.21.4** | CVE-2026-54513, CVE-2026-54512, CVE-2026-54516 等 | PTV / @JsonView 安全修复；`jackson-module-kotlin` 后续（2026-07-02）随 Kotlin 抬升解除 strictly 约束 |
| 2026-06-25 | `tomcat-embed-core` 等 | 9.0.117 | **9.0.119** | CVE-2026-43515, CVE-2026-43512, CVE-2026-41293 等 | Tomcat 9.0.118 安全发布 + 9.0.119 最新稳定版 |
| 2026-06-25 | `io.netty:netty-bom` 等 | 4.1.132.Final | **4.1.135.Final** | CVE-2026-42580, CVE-2026-42581, CVE-2026-50020, CVE-2026-47691 等 | 4.1.133 + 4.1.135 两轮安全发布合并 |
| 2026-04-16 | `io.netty:netty-bom` 等 | 4.1.131.Final | **4.1.132.Final** | CVE-2026-33871, CVE-2026-33870 | HTTP/2 DoS 及请求走私修复 |
| 2026-04-16 | `tomcat-embed-core` 等 | 9.0.115 | **9.0.117** | CVE-2026-24880, CVE-2026-29146 等 | 完善 EncryptInterceptor 修复，Java 8 兼容 |
| 2026-02-25 | `org.springframework:spring-core` 等 | 5.3.31 | **5.3.39** | CVE-2024-22243 URI解析漏洞等 | Maven Central 公开的 5.3.x 最终版 |
| 2026-03-04 | `org.springframework.security:*` | 5.7.14 | **5.8.16** | 5.8.x 分支最终维稳版，CVE相关修复 | 通往 6.x 的桥接版本，Java 8 最终版 |
| 2026-02-25 | `tomcat-embed-core` 等 | 9.0.83 | **9.0.115** | HTTP/2 DoS 等多项高危修复 | *需同步修复 `getAllowLinking()`/`setAllowLinking()` 新接口* |
| 2026-02-25 | `jackson-databind` 等 | 2.13.5 | **2.15.4** | 反序列化漏洞强化 | 2.16+ BOM 传递 javax 库触发 SB2.7 禁止规则，上限为 2.15.x |
| 2026-02-25 | `org.yaml:snakeyaml` | 1.30 | **2.5** | CVE-2022-1471 Constructor 反序列化 | 直接升至 2.x 主版本 |
| 2026-02-25 | `ch.qos.logback:logback-classic` | 1.2.12 | **1.2.13** | CVE-2023-22839 日志漏洞 | 1.2.x 绝版维护最终版 |
| 2026-02-26 | `org.apache.logging.log4j:*` | 2.17.2 | **2.25.3** | CVE-2025-68161 SSL域名验证修复 | 修复 2.x 全系高危漏洞，Java 8 最终版 |

---

## 技术决策说明

### Jackson 版本策略（当前 2.21.5）
- 项目已于 [需求-027] 将 Jackson 从 2.15.4 升级至 2.21.x，于 [需求-031] 跟进至 2.21.4，并于 [需求-033] 升至 **2.21.5**（补 CVE-2026-54515）
- Jackson **2.16+** 的 BOM 会传递 `javax.xml.bind:jaxb-api`，已在 BOM 层 exclude + Gradle 全局 exclude 处理
- `jackson-module-kotlin` 随 `jacksonVersion=2.21.5` 由 jackson-bom 统一管理（fork Kotlin 基线已升至 1.9.22，满足 jackson-module-kotlin 2.17+ 的 Kotlin 1.7+ 要求）
- 小版本升级（2.21.1 → 2.21.4 → 2.21.5）均为安全补丁，API 兼容，无需源码改动

### Spring Framework 版本上限（5.3.39）
- 5.3.40 及以后为 Spring 商业支持专属版本，**未发布至 Maven Central**
- 5.3.39（2024-08-14 发布）为开源社区可使用的最终版

### Spring Security 版本上限（5.8.16）
- 5.8.16（2024-11-18 发布）为 5.8.x 分支在 Maven Central 公开的最高稳定版。
- 作为 6.0 的过渡版本，它保留了对 Java 8 的支持。

### Tomcat 源码适配说明
- Tomcat 9.0.84+ 在 `WebResourceSet` 接口新增了 `getAllowLinking()` 和 `setAllowLinking(boolean)` 方法
- 已在 `TomcatServletWebServerFactory.java` 的内部类 `LoaderHidingWebResourceSet` 中实现这两个方法（委托给 delegate）

---

## 维护指南

1. **版本核实原则**：升级前在 [Maven Central](https://central.sonatype.com/) 确认版本可用性
2. **依赖禁止规则**：Spring Boot 2.7 的 `checkCompileClasspathForProhibitedDependencies` 会拦截 `javax.*` 等库
3. **跨主版本风险**：`SnakeYAML 1.x → 2.x` 等跨主版本升级需全量回归测试
