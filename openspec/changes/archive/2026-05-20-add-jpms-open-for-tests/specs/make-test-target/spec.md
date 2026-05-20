## ADDED Requirements

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

## MODIFIED Requirements

### Requirement: Makefile 内自描述

`Makefile` 中 `test` 目标的紧邻注释 MUST 说明：
- 当前目标的范围（三个子树）；
- 7 条 `-x` 排除项各自的单行原因；
- 当前承诺的语义（"完整反馈面优先"，非"全绿"）；
- 已知失败模块的归类提示（gradle-plugin DocumentationTests / E 类未定位 / smoke-tests 外部依赖）。

#### Scenario: 阅读 Makefile 即可理解取舍
- **WHEN** 任意贡献者在不查阅 design.md 的情况下阅读 `Makefile`
- **THEN** 该贡献者能从 `test` 目标周围注释中获知范围、排除项与"已知红"清单的存在
- **AND** 注释中不再提及"D 类 JPMS"（该类失败已在 `add-jpms-open-for-tests` 中通过 `--add-opens=java.base/java.net=ALL-UNNAMED` 修复）
