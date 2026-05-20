# Execution Notes — add-jpms-open-for-tests

## 关键修改

- `spring-boot-project/spring-boot/build.gradle`：在原 `toolchain { testJvmArgs.add(...) }` 块之后追加无条件生效的 `tasks.named('test').configure { jvmArgs '--add-opens=java.base/java.net=ALL-UNNAMED' }` 块（带 `// FORK:` 注释）。原 `toolchain {}` 块保留兼容 `-PtoolchainVersion` 场景。
- `Makefile`：删除 `test` 目标紧邻注释中"(D) JVM/JPMS 类（约 369 条）..."的整段（5 行），保留 G/E/S 三类。

## 根因回顾

实地调查 `buildSrc/org/springframework/boot/build/toolchain/ToolchainPlugin.java:42-48` 与 `ToolchainExtension.java:40-41`：
- `ToolchainExtension.javaVersion` **仅在通过 `-PtoolchainVersion=X` 显式传入时**才非 null。
- `ToolchainPlugin.configureToolchain` 第 45 行检查 `if (toolchainVersion != null)` 才会调用 `configureTestToolchain`，把 `testJvmArgs` 应用到 Test 任务。
- 默认 `./gradlew test` 不传该属性，于是原已写好的 `testJvmArgs.add("--add-opens=...")` 完全不生效。

## 局部验证

`./gradlew :spring-boot-project:spring-boot:test --tests` 精准跑 4 个测试类：

| 测试类 | 修复前 | 修复后 |
|---|---|---|
| `TomcatServletWebServerFactoryTests`（119 用例） | 全失败 | **全通过** |
| `JettyServletWebServerFactoryTests`（102 用例） | 全失败 | **全通过** |
| `Jetty10ServletWebServerFactoryTests`（100 用例） | 全失败 | **全通过** |
| `UndertowServletWebServerFactoryTests`（98 用例） | 全失败 | **全通过** |

> BUILD SUCCESSFUL in 4m 54s

## 完整 `make test` 对照（修复前 `make_test_run2.log` vs 修复后 `make_test_run3.log`）

- 耗时：16m 9s → **13m 18s**
- 失败 task 数：11 → 11（数字不变；个别 flaky 用例变化）
- 关键模块 `spring-boot:test`：

| 模块 | 修复前 | 修复后 | 差异 |
|---|---|---|---|
| `spring-boot:test` | 4257 / **482** / 22 | 4257 / **5** / 24 | **-477** ✓ |
| `gradle-plugin:test` | 1269 / 961 / 7 | 1269 / 961 / 7 | 0（G 类未处理） |
| `actuator-autoconfigure:test` | 1292 / 7 | 1292 / 8 | +1（flaky） |
| `actuator:test` | 1659 / 8 / 5 | 1659 / 8 / 5 | 0 |
| `spring-boot-test:test` | 873 / 2 / 1 | 873 / 2 / 1 | 0 |
| `devtools:test` | 329 / 2 / 1 | 329 / 2 / 1 | 0 |
| 5 个 smoke-tests | ~17 | ~17 | 0（S 类未处理） |

**477 条减少的来源**：D 类 ~369 条直接由 `--add-opens` 修复；额外 ~108 条之前被 D 类失败连带的中断 / 顺序敏感问题，本次跑得到正确执行。

## spring-boot:test 残留 5 条（全部 E 类）

转入 `investigate-e-class-test-failures` 处理：
- `org.springframework.boot.SpringApplicationNoWebTests > detectWebApplicationTypeToNone`
- `org.springframework.boot.json.BasicJsonParserTests > listWithRepeatedOpenArray`
- `org.springframework.boot.logging.LogbackAndLog4J2ExcludedLoggingSystemTests > whenLogbackAndLog4J2AreNotPresentJULIsTheLoggingSystem`
- `org.springframework.boot.logging.log4j2.SpringBootPropertySourceTests > allDefaultMethodsAreImplemented`
- `org.springframework.boot.web.embedded.tomcat.TldPatternsTests > tomcatSkipAlignsWithTomcatDefaults`

## 残留分类（更新版）

经本变更后 `make test` 失败画像：

- **G 类**：961 条（gradle-plugin DocumentationTests）—— `fix-gradle-plugin-doc-tests` change 处理。
- **S 类**：~17 条（5 个 smoke-tests 外部依赖）—— `exclude-or-fix-smoke-test-external-deps` change 处理。
- **E 类**：~30 条净未定位 —— `investigate-e-class-test-failures` change 处理。
- **D 类**：✅ 已消除。
