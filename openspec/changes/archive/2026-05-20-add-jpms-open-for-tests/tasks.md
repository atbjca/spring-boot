## 1. 修改 spring-boot/build.gradle

- [x] 1.1 在 `spring-boot-project/spring-boot/build.gradle` 现有 `toolchain { ... }` 块（第 195-197 行）之后，追加一段新的 `tasks.named('test').configure { jvmArgs '--add-opens=java.base/java.net=ALL-UNNAMED' }`，并在上方附 `// FORK:` 注释说明绕过 `ToolchainPlugin` 仅在 `-PtoolchainVersion` 场景下激活 testJvmArgs 的限制
- [x] 1.2 保留原 `toolchain { testJvmArgs.add(...) }` 块不动

## 2. 修改 Makefile 注释

- [x] 2.1 删除 `Makefile` 中 `test` 目标紧邻注释块里"(D) JVM/JPMS 类（约 369 条）"的整段（约 3 行），并把剩余分类编号或表述调整成依然通顺（保留 G/E/S 三类）

## 3. 局部验证

- [x] 3.1 `make stop` 释放 Gradle daemon
- [x] 3.2 精准跑代表性失败用例：`./gradlew :spring-boot-project:spring-boot:test --tests 'org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactoryTests'` —— 期望 BUILD SUCCESSFUL
- [x] 3.3 同上方式跑 `JettyServletWebServerFactoryTests`、`UndertowServletWebServerFactoryTests` 各跑一次 —— 期望全部通过
- [x] 3.4 确认 `./gradlew :spring-boot-project:spring-boot:test --info` 的输出 JVM args 含 `--add-opens=java.base/java.net=ALL-UNNAMED`（已通过完整 make test + XML 报告间接验证）

## 4. 完整 make test 验证

- [x] 4.1 跑一次完整 `make test`，对照 `add-makefile-test-target` EXECUTION_NOTES 中"修复后"基线
- [x] 4.2 `spring-boot:test` 模块失败数从约 482 降至 **5**（减少 477 条 ≈ D 类 369 + 暴露关联 108）；其它模块行为不变
- [x] 4.3 把第 4.1 结果摘要追加进本变更目录的 `EXECUTION_NOTES.md`

## 5. 归档准备

- [x] 5.1 本变更完成后 `openspec archive add-jpms-open-for-tests`
- [x] 5.2 归档时确认主 specs `openspec/specs/make-test-target/spec.md` 自动应用 MODIFIED + ADDED delta
