# Log4j2 2.24.3 → 2.25.5+ 升级可行性评估

> **结论：暂缓升级，留在 2.24.3。**
> 2.25.x 对 Spring Boot 3.5 存在成片的破坏性变更，升级已从「改版本号」演变为
> 「替上游做 3.5 → 2.25 移植」。官方 Spring Boot 3.5.x 维护线至今仍停在 2.24.3，
> 与本评估结论一致。

## 关联 CVE

本评估覆盖以下 3 个仅能通过版本升级修复的 Log4j2 CVE：

| CVE | CVSS | 漏洞类型 | 修复版本 |
|-----|:----:|---------|:-------:|
| CVE-2026-34477 | 5.9 | TLS 主机名验证不完整（MITM） | 2.25.4 |
| CVE-2026-34478 | 7.5 | Rfc5424Layout CRLF 日志注入 | 2.25.4 |
| CVE-2026-34479 | - | Log4j1XmlLayout 非法 XML 字符 | 2.25.4 |
| CVE-2026-34480 | 7.5 | XmlLayout 非法字符注入 | 2.25.4 |
| CVE-2026-34481 | - | JsonTemplateLayout 非有限浮点 JSON | 2.25.4 |
| CVE-2026-49844 | - | MapMessage 非有限浮点 JSON | 2.25.5 |

## 实测过程（2026-07-02，Java 17）

将 `spring-boot-dependencies/build.gradle` 的 Log4j2 版本改为 2.25.4 后，
执行 **clean build**（`make clean` + `./gradlew :spring-boot-project:spring-boot:compileJava`）
逐层暴露出四层不兼容：

> ⚠️ 注意：增量构建（`make test-gate`）会命中 2.24.3 时的旧 class 缓存，
> **不会触发新校验、显示为通过**，具有误导性。依赖升级必须 clean 后验证。

### 第 1 层 — 版本号
`build.gradle` 改 1 行即可。轻松。

### 第 2 层 — `@PluginBuilderAttribute` 强制 public setter
2.25.0 起 `PluginProcessor` 强制要求 `@PluginBuilderAttribute` 字段必须有
public setter，否则**编译期报错**（旧版仅忽略）。命中 3 处：

- `SpringProfileArbiter.java` — `name`
- `StructuredLogLayout.java` — `format`、`charset`

缓解：字段加 `@SuppressWarnings("log4j.public.setter")`（编译器建议写法）。

### 第 3 层 — GraalVmProcessor 缺坐标 + `-Werror`
2.25.x 的 `GraalVmProcessor` 在缺少 `log4j.graalvm.groupId` /
`log4j.graalvm.artifactId` 选项时打印推荐性警告；而 fork 全局启用 `-Werror`
（`buildSrc/.../JavaConventions.java`），警告被升级为致命错误。

缓解：给 spring-boot 模块 `compileJava` 传入这两个注解处理器选项。

### 第 4 层 — 15 处 API 弃用（`[deprecation]` + `-Werror`）
2.25.x 弃用了一批 API，Spring Boot 3.5 的 log4j2 扩展代码仍在使用，配合
`-Werror -Xlint:deprecation` 全部成为致命错误：

| 被弃用的 API | 涉及文件 |
|---|---|
| `LogEvent.getThrownProxy()` | ECS / Graylog / Logstash Formatter、Extractor |
| `ThrowableProxy` 类 | ECS Formatter、Extractor |
| `ThrowablePatternConverter(String,String,String[],Configuration)` | Whitespace / ExtendedWhitespace PatternConverter |

这些是「真·弃用」，未来大版本会删除。正确修法是迁移到 2.25.x 新 API
（`LogEvent.getThrown()` 等），属于有语义风险的重构，需充分回归测试。

## 风险敞口评估

这些 CVE 的**可利用性**对默认项目配置较低——命中的是「版本区间」而非「默认攻击路径」：

| CVE | 触发条件 |
|-----|---------|
| CVE-2026-34477 | 需 Socket/SMTP/Syslog appender + `<Ssl>` TLS 配置 |
| CVE-2026-34478 | 需 Rfc5424Layout（Syslog 布局） |
| CVE-2026-34480 | 需 XmlLayout |
| CVE-2026-34479 | 需 Log4j1XmlLayout bridge |
| CVE-2026-34481 | 需 JsonTemplateLayout 且依赖其 JSON 输出 |
| CVE-2026-49844 | 需 MapMessage JSON 序列化且包含非有限浮点值 |

典型 Spring Boot 应用使用默认 PatternLayout，**三者均无法触发**。扫描器只比对
版本号，不感知实际未配置上述 appender/layout，故属「扫描器满意度」升级而非紧急漏洞。

## 决策

**暂缓升级。** 理由：
1. 升级需替上游做成片的破坏性变更适配（第 2~4 层），成本高、有语义风险；
2. 官方 Spring Boot 3.5.x 亦未跟进 2.25.x，独立 fork 移植维护负担大；
3. 默认使用 Logback；即使下游主动切换 Log4j2，也不默认启用上述 appender/layout，风险敞口窄。

**重新评估触发条件：**
- 官方 Spring Boot 3.5.x 跟进 2.25.x → 直接 rebase；
- 本项目确需启用 Socket/Syslog/Xml/Rfc5424 等受影响 appender/layout → 届时按第 2~4 层
  逐层适配并做完整 clean build + 回归。

## 参考

- [Apache Logging Security](https://logging.apache.org/security.html)
- [Log4j 2.25.x release notes](https://logging.apache.org/log4j/2.x/release-notes.html)
