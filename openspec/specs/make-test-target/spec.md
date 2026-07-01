# make-test-target Specification

## Purpose
TBD - created by archiving change add-makefile-test-target. Update Purpose after archive.
## Requirements
### Requirement: Makefile 暴露 `test` 目标

根目录 `Makefile` SHALL 提供名为 `test` 的目标，作为本仓库测试入口（含 TDD 工作流与完整反馈面）。该目标 MUST 被声明为 `.PHONY`，且不依赖任何其它 Make 目标。

#### Scenario: 在干净工作树中调用 `make test`
- **WHEN** 开发者在仓库根目录下执行 `make test`
- **THEN** Make 调用 `./gradlew test --continue` 并附加显式 `-x` 排除清单
- **AND** 不触发 `clean / format / build / install / deploy` 等其它 Make 目标

#### Scenario: `test` 目标与其它目标并存
- **WHEN** 调用 `make help`
- **THEN** 输出文案中包含 `make test` 一行说明
- **AND** 既有 `clean / format / build / build-thin / install / deploy / stop / tree / projects` 条目的措辞和顺序保持不变

### Requirement: 默认覆盖 `spring-boot-project` / `spring-boot-integration-tests` / `spring-boot-smoke-tests` 三子树

`make test` MUST 通过 `./gradlew test` 让 Gradle 自动调度全部被 `settings.gradle` 启用的子项目的 `test` 任务，覆盖：

- `spring-boot-project` 子树下所有未被显式排除的子项目；
- `spring-boot-tests:spring-boot-integration-tests:*` 中未被显式排除的子项目；
- `spring-boot-tests:spring-boot-smoke-tests:*` 中未被 `settings.gradle` 的 `ignoredSmokeTests` 排除、且未被本目标显式 `-x` 的子项目。

`make test` MUST NOT 调度 `spring-boot-system-tests:*` 子树下的任何 `test` 任务（Docker 强依赖）。

#### Scenario: smoke-tests 自动覆盖
- **WHEN** `settings.gradle` 启用了某个 `spring-boot-smoke-test-<name>` 子项目
- **AND** 该子项目未被本目标的 `-x` 清单显式排除
- **THEN** `make test` 实际执行时该子项目的 `:test` 任务被调度

#### Scenario: 跨子树覆盖
- **WHEN** `make test` 执行
- **THEN** 调用过程中至少出现一次 `:spring-boot-project:` 前缀的 `:test` 任务
- **AND** 至少出现一次 `:spring-boot-tests:spring-boot-smoke-tests:` 前缀的 `:test` 任务
- **AND** 至少出现一次 `:spring-boot-tests:spring-boot-integration-tests:` 前缀的 `:test` 任务

### Requirement: 显式排除清单及理由

`make test` 的 `-x` 排除清单 MUST 包含且仅包含以下任务路径（不多不少），且每条在 `Makefile` 注释中给出单行原因：

1. `:spring-boot-project:spring-boot-autoconfigure:test`
2. `:spring-boot-project:spring-boot-autoconfigure:compileTestJava`
3. `:spring-boot-project:spring-boot-tools:spring-boot-buildpack-platform:test`
4. `:spring-boot-tests:spring-boot-integration-tests:spring-boot-launch-script-tests:test`
5. `:spring-boot-tests:spring-boot-integration-tests:spring-boot-loader-tests:test`
6. `:spring-boot-system-tests:spring-boot-deployment-tests:test`
7. `:spring-boot-system-tests:spring-boot-image-tests:test`

#### Scenario: 排除清单完整
- **WHEN** `make -n test` 展开
- **THEN** 命令行中恰好出现以上 7 个任务路径前缀以 `-x ` 的形式

#### Scenario: 不出现意外排除
- **WHEN** `make -n test` 展开
- **THEN** 命令行中不出现任何不在上述清单中的 `-x :...` 排除项

### Requirement: 失败不阻断后续模块

`make test` MUST 通过向 `gradlew` 传递 `--continue` 让单个子项目的失败不影响其它子项目的 `test` 继续执行。整体退出码仍由 Gradle 决定。

#### Scenario: 某模块测试失败
- **WHEN** 任一被调度子项目的 `test` 任务失败
- **THEN** Gradle 继续执行剩余被调度子项目的 `test` 任务
- **AND** `make test` 整体以非 0 退出码结束

### Requirement: 修复 fork 责任范围内的测试代码

对以下 3 个测试文件 MUST 完成调整以适配 fork 当前的源码 / 依赖状态。所有调整只动测试代码，不动 `src/main/java` 下任何文件。每处改动 MUST 附 `// FORK:` 形式的注释说明原因。

#### Scenario: BannerTests 适配 fork 修改后的 SpringBootBanner
- **WHEN** `:spring-boot-project:spring-boot:test` 调度 `BannerTests.testDefaultBanner` 与 `testDefaultBannerInLog`
- **THEN** 两条用例均通过
- **AND** 测试断言中预期字符串包含 `:: Bpring Boot ::`（不再是 `:: Spring Boot ::`）

#### Scenario: SpringBootVersionTests 适配 fork 版本号策略
- **WHEN** `:spring-boot-project:spring-boot:test` 调度 `SpringBootVersionTests.getVersionShouldReturnVersionMatchingGradleProperties`
- **THEN** 该用例通过
- **AND** 断言形态为"前缀匹配"或等价宽松断言，能同时容纳 `2.7.18` 与 `2.7.18-nes.patch.1-SNAPSHOT` 两种取值

#### Scenario: JacksonJsonParserTests 适配 Jackson 2.21.1 错误消息文案
- **WHEN** `:spring-boot-project:spring-boot:test` 调度 `JacksonJsonParserTests.listWithRepeatedOpenArray`
- **THEN** 该用例通过
- **AND** `AbstractJsonParserTests` 中的异常消息断言不再依赖 `"too deeply nested"` 字面量

### Requirement: Makefile 内自描述

`Makefile` 中 `test` 目标的紧邻注释 MUST 说明：
- 当前目标的范围（三个子树）；
- 7 条 `-x` 排除项各自的单行原因；
- 当前承诺的语义（"完整反馈面优先"，非"全绿"）；
- 已知 flaky/E 类失败的归类说明（E 类未定位 / smoke-tests 外部依赖 / 已定位但偶发的 flaky 如 `TomcatReactiveWebServerFactoryTests.sslWithValidAlias`）。

#### Scenario: 阅读 Makefile 即可理解 E 类 flaky 现状
- **WHEN** 任意贡献者在不查阅 design.md 的情况下阅读 `Makefile`
- **THEN** 该贡献者能从 `test` 目标周围注释中获知范围、排除项与"已知红"清单的存在
- **AND** 注释中明确列出 `TomcatReactiveWebServerFactoryTests.sslWithValidAlias` 为已知偶发 flaky（已通过 `@RepeatedTest(10)` 处置）
- **AND** 注释中不再提及"D 类 JPMS"（该类失败已在 `add-jpms-open-for-tests` 中通过 `--add-opens=java.base/java.net=ALL-UNNAMED` 修复）
- **AND** 注释中不再将 gradle-plugin DocumentationTests 列为已知失败（已通过 `NES_GRADLE_DISTRIBUTIONS_DIR` 配置解决）
- **AND** 注释中列出 `spring-boot-smoke-test-kafka` 为 S 类——`testVanillaExchange` 因 fork Kafka 3.9.2 与 spring-kafka-test 2.9.x 不兼容已被 `@Disabled`，test-feedback 保持 -x 排除

### Requirement: smoke-test-kafka @Disabled 处置

`spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test` 的 `SampleKafkaApplicationTests` 已被 `@Disabled` 标注，原因是 fork Kafka 升级到 3.9.2 后 `EmbeddedKafkaBroker`（spring-kafka-test 2.9.x）无法启动（`NoClassDefFoundError: MockTime/KafkaMetricsGroup`）。`test-feedback` 保持 `-x` 排除。根因修复需 Spring Boot 3.x + spring-kafka 3.x。

#### Scenario: smoke-test-kafka 被 @Disabled 并保持排除
- **WHEN** `make test-feedback` 执行
- **AND** `spring-boot-smoke-test-kafka` 未被 `-x` 排除
- **THEN** `SampleKafkaApplicationTests.testVanillaExchange` 被跳过（`@Disabled`）
- **AND** `make test-feedback` 不因 kafka 而失败

### Requirement: spring-boot 模块 Test 任务获得 `--add-opens=java.base/java.net=ALL-UNNAMED`

`spring-boot-project/spring-boot/build.gradle` MUST 保证：通过 `./gradlew test`（不传 `-PtoolchainVersion`）调度的 `:spring-boot-project:spring-boot:test` 任务，其 JVM 启动参数中包含 `--add-opens=java.base/java.net=ALL-UNNAMED`。

#### Scenario: 默认 `./gradlew test` 启动 JVM 含 opens 参数
- **WHEN** 在 spring-boot-project/spring-boot 目录下执行 `./gradlew test --info` 或 `make test`
- **AND** 不传 `-PtoolchainVersion` 任何属性
- **THEN** Gradle Test Executor 进程的 JVM 命令行包含 `--add-opens=java.base/java.net=ALL-UNNAMED`
- **AND** `DirtiesUrlFactoriesExtension` 通过反射设置 `URL.factory` 字段时不再抛出 `InaccessibleObjectException`

#### Scenario: `*ServletWebServerFactoryTests` 整组通过
- **WHEN** `make test` 调度 `:spring-boot-project:spring-boot:test` 子项目
- **THEN** `org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactoryTests`、`TomcatReactiveWebServerFactoryTests`、`SslConnectorCustomizerTests`、`TomcatEmbeddedWebappClassLoaderTests`、`TldPatternsTests` 全部用例通过
- **AND** `org.springframework.boot.web.embedded.jetty.JettyServletWebServerFactoryTests`、`Jetty10ServletWebServerFactoryTests` 全部用例通过
- **AND** `org.springframework.boot.web.embedded.undertow.UndertowServletWebServerFactoryTests` 全部用例通过

#### Scenario: 兼容 `-PtoolchainVersion` 场景
- **WHEN** 执行 `./gradlew :spring-boot-project:spring-boot:test -PtoolchainVersion=17`
- **THEN** Test 任务 JVM 仍含 `--add-opens=java.base/java.net=ALL-UNNAMED`
- **AND** 不因 `--add-opens` 参数被重复添加而启动失败

