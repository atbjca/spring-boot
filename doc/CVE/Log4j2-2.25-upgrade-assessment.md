# Log4j2 2.24.3 → 2.25.5 实施与兼容性评估

> **结论：已完成 Log4j2 2.25.5 的有界源码迁移。**
> 2026-07-02 的初次 clean build 证明该升级不能只改版本号；本次按后来上游
> 2.25.x 适配方案移植 processor、Throwable 和 converter 变更，并在
> 2026-08-13 通过定向测试、三个 Log4j2 smoke 模块、clean thin build 和核心测试。

## 关联 CVE

本评估覆盖以下 7 个仅能通过版本升级修复的 Log4j2 CVE：

| CVE | CVSS | 漏洞类型 | 修复版本 |
|-----|:----:|---------|:-------:|
| CVE-2025-68161 | - | Socket Appender 未执行 TLS 主机名验证（MITM） | 2.25.3 |
| CVE-2026-34477 | 5.9 | TLS 主机名验证不完整（MITM） | 2.25.4 |
| CVE-2026-34478 | 7.5 | Rfc5424Layout CRLF 日志注入 | 2.25.4 |
| CVE-2026-34479 | - | Log4j1XmlLayout 非法 XML 字符 | 2.25.4 |
| CVE-2026-34480 | 7.5 | XmlLayout 非法字符注入 | 2.25.4 |
| CVE-2026-34481 | - | JsonTemplateLayout 非有限浮点 JSON | 2.25.4 |
| CVE-2026-49844 | - | MapMessage 非有限浮点 JSON | 2.25.5 |

## 历史实测过程（2026-07-02，Java 17）

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

## 2026-08-13 实施内容

- Boot BOM 的单一 `Log4j2` library 从 2.24.3 升级到 `log4j-bom:2.25.5`，未增加模块级版本覆盖或预览版本。resolved BOM 中七个 CVE 涉及的 `log4j-core`、`log4j-api`、`log4j-1.2-api` 和 `log4j-layout-template-json` 均为 2.25.5。
- 上游 BOM 有意保留已停止跟随主版本发布的 `log4j-flume-ng:2.23.1`；项目不为数字统一强制覆盖该版本。其余 29 个代表性/运行时模块（含 BOM 自身）为 2.25.5。
- `GraalVmProcessor` 使用当前发布模块坐标 `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot`，生成 10 个反射元数据条目；`PluginProcessor` 生成 12 个插件。
- `SpringProfileArbiter.Builder` 与 `StructuredLogLayout.Builder` 仅将 processor 要求的 setter 改为 public，并使用精确 Checkstyle suppression。
- ECS、GELF、Logstash、Extractor 与 custom formatter 从弃用的 `getThrownProxy()` / `ThrowableProxy` 迁移到 `Throwable` API。
- `%wEx` 使用 `VariablesNotEmptyReplacementConverter` 组合，`%xwEx` 通过受支持的 `LogEventPatternConverter` delegate 实现；测试覆盖所有六个 alias、short/full/extended、separator、cause、无异常和 CRLF/LF 归一化。
- CVE-2026-49844 增加直接回归，确认 `MapMessage` 中 `NaN`、`Infinity`、`-Infinity` 以 JSON 字符串输出。

## Starter 与默认运行时

默认发布坐标 `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-logging` 仍依赖 Logback 1.5.38，并携带用于将 Log4j API 路由到 SLF4J 的 `log4j-to-slf4j:2.25.5`。它没有切换到 Log4j2 runtime。

只有显式选择 `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-log4j2` 时，才会引入 `log4j-core`、`log4j-slf4j2-impl` 和 `log4j-jul` 2.25.5。Gradle 多项目构建内部仍使用未加发布前缀的 component identity，因此 smoke test 的 `modules.replacedBy` 规则使用 `spring-boot-starter-logging` / `spring-boot-starter-log4j2`。

## 风险敞口评估

这些 CVE 的**可利用性**对默认项目配置较低——命中的是「版本区间」而非「默认攻击路径」：

| CVE | 触发条件 |
|-----|---------|
| CVE-2025-68161 | 需 Log4j2 TLS Socket Appender，且部署依赖主机名验证阻止 MITM |
| CVE-2026-34477 | 需 Socket/SMTP/Syslog appender + `<Ssl>` TLS 配置 |
| CVE-2026-34478 | 需 Rfc5424Layout（Syslog 布局） |
| CVE-2026-34480 | 需 XmlLayout |
| CVE-2026-34479 | 需 Log4j1XmlLayout bridge |
| CVE-2026-34481 | 需 JsonTemplateLayout 且依赖其 JSON 输出 |
| CVE-2026-49844 | 需 MapMessage JSON 序列化且包含非有限浮点值 |

典型 Spring Boot 应用默认使用 Logback；即使下游主动切换 Log4j2，未配置上述
appender/layout 时，**七项受影响路径均不会由默认配置触发**。扫描器只比对
版本号，不感知实际未配置上述 appender/layout，故属「扫描器满意度」升级而非紧急漏洞。

## 验证结果

- clean `spring-boot:compileJava`：`BUILD SUCCESSFUL in 2m 33s`，无 2.25.5 processor、`-Werror` 或 deprecation failure。
- focused Log4j2 单元测试：`BUILD SUCCESSFUL in 1m 23s`；新增 converter 18 项测试最终 `BUILD SUCCESSFUL in 26s`。
- ordinary Log4j2、Actuator Log4j2、structured logging Log4j2 smoke 模块：`BUILD SUCCESSFUL in 1m 31s`。
- `make clean build-thin`：clean `BUILD SUCCESSFUL in 12s`；assemble `BUILD SUCCESSFUL in 3m 13s`，828 actionable tasks（780 executed、35 from cache、13 up-to-date）。
- `make test`：`BUILD SUCCESSFUL in 7m 35s`，42 actionable tasks（9 executed、2 from cache、31 up-to-date）。
- 包级 Log4j2 重跑曾出现 1/174 失败：`Log4J2LoggingSystemTests#getLoggerConfigurationsShouldReturnAllLoggers`。2.25.5 下经 `LogManager` 创建的临时 Nested logger 可能在 `getLoggerConfigurations()` 前被回收。已按上游 `7d343204016` 改为通过 `TestLog4J2LoggingSystem#getLoggerContext()` 注册；随后单方法、整类 59 项和包级 174 项均通过。该 focused failure 触发了 `make test-gate`。
- 首次 `make test-gate` 在 Codex 会话因 HTTP 429 中断时于 `:spring-boot-autoconfigure:test` 被取消，不计为通过。重跑 `make test-gate`：`BUILD SUCCESSFUL in 16m 6s`，114 actionable tasks（15 executed、6 from cache、93 up-to-date）。

远程 Spring build cache 多次返回 HTTP 403，Gradle 随后禁用远程缓存并在本地成功完成构建；这不是测试失败。

## 最终决策

七项 finding 均改为已修复。修复依据是选中固定版本并完成兼容性迁移与验证，而不是默认 Logback 带来的低可达性。默认 Logback 和受影响 appender/layout 非默认启用仍作为纵深风险边界保留。后续升级 Log4j2 时必须继续验证 public plugin setter、GraalVM 坐标、structured exception schema、throwable converter option 传播和两个发布 starter 的依赖图。

## 参考

- [Apache Logging Security](https://logging.apache.org/security.html)
- [Log4j 2.25.x release notes](https://logging.apache.org/log4j/2.x/release-notes.html)
