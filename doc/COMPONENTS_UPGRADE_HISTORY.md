# 核心组件漏洞升级与维护记录表 (Upgrade History)

> 为保证项目长期安全与稳定，本表跟踪核心三方组件的安全版本升级历史。
> JDK 8 兼容性限制：无法越过 Spring Boot 2.7.x 的 BOM 禁止依赖规则进行激进跨主版本升级。

## 组件升级历史

| 升级日期 | 组件名称 | 升级前版本 | 升级后版本 | 修复漏洞 / 原因 | 兼容性说明 |
| :---: | :--- | :---: | :---: | :--- | :--- |
| 2026-07-02 | `org.jetbrains.kotlin:*` | 1.6.21 | **1.9.22** | 让 OkHttp 4.12 / jackson-module-kotlin 2.21 携带的 Kotlin metadata（1.8/1.9）能被 fork 构建接受；配套 jackson-module-kotlin 从 `strictly 2.16.2` 恢复由 jackson-bom 统一管理 | Kotlin `languageVersion`/`apiVersion` 维持在 `1.6`（Kotlin 1.9 编译器仍支持）；源码零改动 |
| 2026-07-02 | `org.xerial:sqlite-jdbc` | 3.36.0.3 | **3.41.2.2** | CVE-2023-32697 (CVSS 8.8) JDBC URL RCE | 测试依赖；Java 8 兼容 |
| 2026-07-02 | `net.minidev:json-smart` | 2.4.11 | **2.5.2** | CVE-2023-1370 (CVSS 7.5) 深层嵌套 JSON 栈溢出 DoS | 跨 minor 升级 |
| 2026-07-02 | `com.google.code.gson:gson` | 2.9.1 | **2.12.1** | CVE-2025-53864 嵌套 JSON DoS（缺少深度限制） | 跨 minor 升级；Java 8 兼容 |
| 2026-07-02 | `com.squareup.okhttp3:okhttp-bom` | 4.9.3 | **4.12.0** | CVE-2023-3635 (CVSS 7.5) Okio GzipSource DoS | 跨 minor 升级；Java 8 兼容 |
| 2026-07-02 | `org.apache.httpcomponents.client5:httpclient5` | 5.1.4 | **5.6.1** | CVE-2026-40542 (CVSS 6.9) SCRAM-SHA-256 认证验证缺失 | 跨 minor 升级；需配套 httpcore5 5.4 |
| 2026-07-02 | `org.apache.httpcomponents.core5:httpcore5` 等 | 5.1.5 | **5.4** | HttpClient5 5.6.1 传递依赖要求 httpcore5 5.4+（`Tokenizer.delimiters()` API 在 5.2+ 引入） | 跨 minor 升级 |
| 2026-07-02 | `io.projectreactor:reactor-bom` | 2020.0.38 | **2020.0.47** | CVE-2025-22227 (CVSS 6.1) Reactor Netty 重定向凭据泄漏 | 2020.0.x 最终版；含 reactor-netty-http 1.0.48 |
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

### Jackson 版本策略（当前 2.21.4）
- 项目已于 [需求-027] 将 Jackson 从 2.15.4 升级至 2.21.x，并于 [需求-031] 跟进至 **2.21.4**
- Jackson **2.16+** 的 BOM 会传递 `javax.xml.bind:jaxb-api`，已在 BOM 层 exclude + Gradle 全局 exclude 处理
- `jackson-module-kotlin` 随 `jacksonVersion=2.21.4` 由 jackson-bom 统一管理（fork Kotlin 基线已升至 1.9.22，满足 jackson-module-kotlin 2.17+ 的 Kotlin 1.7+ 要求）
- 小版本升级（2.21.1 → 2.21.4）为安全补丁，API 兼容，无需源码改动

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
