# 核心组件漏洞升级与维护记录表 (Upgrade History)

> 为保证项目长期安全与稳定，本表跟踪核心三方组件的安全版本升级历史。
> JDK 8 兼容性限制：无法越过 Spring Boot 2.7.x 的 BOM 禁止依赖规则进行激进跨主版本升级。

## 组件升级历史

| 升级日期 | 组件名称 | 升级前版本 | 升级后版本 | 修复漏洞 / 原因 | 兼容性说明 |
| :---: | :--- | :---: | :---: | :--- | :--- |
| 2026-02-25 | `org.springframework:spring-core` 等 | 5.3.31 | **5.3.39** | CVE-2024-22243 URI解析漏洞等 | Maven Central 公开的 5.3.x 最终版 |
| 2026-02-25 | `org.springframework.security:*` | 5.7.11 | **5.7.14** | 常规权限强化，跟随 Spring 5.3.x | Maven Central 公开的 5.7.x 最高版 |
| 2026-02-25 | `tomcat-embed-core` 等 | 9.0.83 | **9.0.115** | HTTP/2 DoS 等多项高危修复 | *需同步修复 `getAllowLinking()`/`setAllowLinking()` 新接口* |
| 2026-02-25 | `jackson-databind` 等 | 2.13.5 | **2.15.4** | 反序列化漏洞强化 | 2.16+ BOM 传递 javax 库触发 SB2.7 禁止规则，上限为 2.15.x |
| 2026-02-25 | `org.yaml:snakeyaml` | 1.30 | **2.5** | CVE-2022-1471 Constructor 反序列化 | 直接升至 2.x 主版本 |
| 2026-02-25 | `ch.qos.logback:logback-classic` | 1.2.12 | **1.2.13** | CVE-2023-22839 日志漏洞 | 1.2.x 绝版维护最终版 |
| 2026-02-26 | `org.apache.logging.log4j:*` | 2.17.2 | **2.25.3** | CVE-2025-68161 SSL域名验证修复 | 修复 2.x 全系高危漏洞，Java 8 最终版 |

---

## 技术决策说明

### Jackson 版本上限（2.15.4）
- Jackson **2.16+** 的 BOM 引入了 `javax.xml.bind:jaxb-api` 和 `javax.activation-api` 作为传递依赖
- Spring Boot 2.7 的 `spring-boot-autoconfigure` 模块明确禁止这两个库出现在编译 classpath
- 因此 Jackson 版本上限为 **2.15.4**（`2.15.x` 终版）

### Spring Framework 版本上限（5.3.39）
- 5.3.40 及以后为 Spring 商业支持专属版本，**未发布至 Maven Central**
- 5.3.39（2024-08-14 发布）为开源社区可使用的最终版

### Spring Security 版本上限（5.7.14）
- 5.7.15–5.7.17 未在 Maven Central 发布
- 5.7.14（2024-11-18 发布）为公开的最高版

### Tomcat 源码适配说明
- Tomcat 9.0.84+ 在 `WebResourceSet` 接口新增了 `getAllowLinking()` 和 `setAllowLinking(boolean)` 方法
- 已在 `TomcatServletWebServerFactory.java` 的内部类 `LoaderHidingWebResourceSet` 中实现这两个方法（委托给 delegate）

---

## 维护指南

1. **版本核实原则**：升级前在 [Maven Central](https://central.sonatype.com/) 确认版本可用性
2. **依赖禁止规则**：Spring Boot 2.7 的 `checkCompileClasspathForProhibitedDependencies` 会拦截 `javax.*` 等库
3. **跨主版本风险**：`SnakeYAML 1.x → 2.x` 等跨主版本升级需全量回归测试
