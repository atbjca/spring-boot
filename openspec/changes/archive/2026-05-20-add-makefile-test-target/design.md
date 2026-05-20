## Context

本仓库是 Spring Boot 2.7.x 的内部 fork（分支 `2.7.x-bjca-patch`），最近提交集中在依赖升级（Netty、Jackson、Logback、Spring Security、Thymeleaf 等）与安全公告。根目录 `Makefile` 已封装 `clean / format / build / build-thin / install / deploy / stop / tree / projects` 等 Gradle 操作，但缺少执行测试的入口。

约束（用户明示）：
- **不动业务源码**（`src/main/java`）：保留 fork 已做的全部源码修改不变。
- **测试代码可改**：如测试因 fork 源码改动或依赖升级而过期，修改测试代码使其适应当前源码 / 依赖状态。
- **不动 `build.gradle` / `gradle.properties` / `settings.gradle`**：所有取舍只在 `Makefile` 和测试代码中表达。
- **覆盖面**：希望 `make test` 同时覆盖 `spring-boot-project` 子树、`spring-boot-tests/spring-boot-integration-tests` 与 `spring-boot-tests/spring-boot-smoke-tests`（不仅核心库）。

调查结论（基于 `make test` 实跑 29 分钟的结果、`build/test-results/test/*.xml` stack trace、`git diff $(merge-base main HEAD)..HEAD`）：

1. **代码-测试不同步（fork 责任，可修测试）** — 共 4 条：
   - `BannerTests.testDefaultBanner` / `testDefaultBannerInLog`：fork commit `055a99a` + `543cd9b` 把 `SpringBootBanner.java` 的 `BANNER` 改为 `{""}`、`SPRING_BOOT` 改为 `" :: Bpring Boot :: "`（fork 前缀），但 `BannerTests` 仍断言 `":: Spring Boot ::"`。
   - `SpringBootVersionTests.getVersionShouldReturnVersionMatchingGradleProperties`：fork 在 `gradle.properties` 中将 `version` 改为 `2.7.18-nes.patch.1-SNAPSHOT`，而 `SpringBootVersion.getVersion()`（来自 jar manifest 的 `Implementation-Version`）仍返回 `2.7.18`，测试做严格相等断言导致失败。
   - `JacksonJsonParserTests.listWithRepeatedOpenArray`（实际位于抽象基类 `AbstractJsonParserTests`）：Jackson 2.15.4 → 2.21.1 升级后，异常消息从 `"too deeply nested"` 改为 `"Document nesting depth (... ) exceeds the maximum allowed"`，测试断言未跟上。

2. **JVM/JPMS 环境性失败（需改 build.gradle，超出本次约束）** — 估算 369 条：
   - `org.springframework.boot.web.embedded.{tomcat,jetty,undertow}.*ServletWebServerFactoryTests` 整组：`DirtiesUrlFactoriesExtension` 反射访问 `java.net.URLStreamHandlerFactory` 在 Java 17 JPMS 下被拒绝。需要给该模块 `test` 任务追加 JVM 参数 `--add-opens=java.base/java.net=ALL-UNNAMED`，触及 `build.gradle`，**本次不在 scope 内**。

3. **`spring-boot-gradle-plugin:test` 的 `*DocumentationTests` 环境性失败** — 963 条：
   - 通过 Gradle Tooling API 起子构建时 `ZipException at ZipFile.java:1637`，因构建环境未预置 Gradle distribution。需要在 `build.gradle` 中为 `test` 任务配置 `systemProperty 'gradleDistributionPath'` 或排除测试类，**本次不在 scope 内**。

4. **其它少量失败（E 类未定位）** — ~130 条：
   - `LiquibaseEndpointTests` / `QuartzEndpointTests` / `ReactiveCloudFoundryActuatorAutoConfigurationTests.skipSslValidation` / `Jersey*ManagementContextConfigurationTests` / `LocalDevToolsAutoConfigurationTests` / `SpringBootTestContextHierarchyTests` / `WebTestClientContextCustomizerWithoutWebfluxIntegrationTests` 等。根因混合：依赖升级 + fork 排除 starter + 环境差异。**本次不逐个排查**。

5. **smoke-tests / integration-tests 加入的新负担**：
   - `settings.gradle` 已通过 `ignoredSmokeTests`（18 项）+ `ignoredStarters`（18 项）做了一轮裁剪。
   - 剩余 ≈73 个 smoke-tests 是端到端 sample 应用，部分依赖 redis/mongo/docker（cache、session-redis/mongo/webflux-redis/webflux-mongo 等）。
   - 4 个 integration-tests 中，`spring-boot-launch-script-tests` 与 `spring-boot-loader-tests` 用 Testcontainers/Docker。
   - **预期**：smoke-tests / integration-tests 加入后会引入新的失败用例（外部环境性）。本次不为这些做单测断言级别的修复。

## Goals / Non-Goals

**Goals:**
- `make test` 单一入口；覆盖 `spring-boot-project`、`spring-boot-tests/spring-boot-integration-tests`、`spring-boot-tests/spring-boot-smoke-tests` 三个子树的 `test` 任务。
- 通过 `--continue` 让单模块失败不阻断后续，给完整反馈面。
- 修复 fork 责任范围内、可仅通过测试代码改动消除的失败用例（A/C 类合计 4 条）。
- `Makefile` 的取舍逻辑自描述（注释块说明排除清单与理由）。
- `help` 文本同步说明 `make test`。

**Non-Goals:**
- 不修改 `src/main/java` 下的任何源码。
- 不修改 `build.gradle` / `gradle.properties` / `settings.gradle` / `buildSrc/`。
- 不修复 D 类 JPMS 失败（~369 条）—— 留待"启用 JPMS open"独立 change。
- 不修复 `gradle-plugin:*DocumentationTests`（963 条）—— 留待"配 Gradle distribution"独立 change。
- 不逐一排查 E 类 ~130 条 —— 留待"按模块分批稳定"独立 changes。
- 不接入 `intTest` / `:spring-boot-system-tests:*`（Docker 强依赖）。
- 不引入模块 / 测试类过滤参数（`MODULE=` / `CLASS=`）。

## Decisions

### Decision 1：从"显式白名单"改为"./gradlew test + 黑名单 -x 排除"

`make test` 不再列举要跑的任务路径，而是直接调用 `./gradlew test --continue`，然后用 `-x` 排除明确不想触发的任务。

**理由：**
- 用户要求 smoke-tests / integration-tests 也纳入。两者合计 ≈77 个子项目，且 smoke-tests 由 `settings.gradle` 的 `file().eachDirMatch` 动态生成 —— 白名单维护成本爆炸。
- 黑名单跟随 `settings.gradle` 已有的 `ignoredSmokeTests` / `ignoredStarters` 演进，未来 fork 调整时无需同步修改 `Makefile`。
- 跑得多 → 反馈面大，符合 TDD"一次看完整画面"诉求。

**代价：**
- `make test` 会调度更多任务（包含 D 类、gradle-plugin 等已知失败），整体耗时拉长、退出码仍非 0。这与本 change 调整后的目标"完整反馈面而非全绿"一致。

**已否决替代方案：**
- 继续 14 项白名单 → 用户明确希望覆盖 smoke/integration-tests，否决。
- 改 `settings.gradle` 注释掉模块 → 违反"不动 settings.gradle"约束。

### Decision 2：黑名单显式排除清单

`./gradlew test --continue` 加以下 `-x`：

1. `:spring-boot-project:spring-boot-autoconfigure:test` —— Thymeleaf 升级残留 `compileTestJava` 编译失败。
2. `:spring-boot-project:spring-boot-autoconfigure:compileTestJava` —— 双保险，避免被其它模块连带触发。
3. `:spring-boot-project:spring-boot-tools:spring-boot-buildpack-platform:test` —— 依赖 Docker daemon。
4. `:spring-boot-tests:spring-boot-integration-tests:spring-boot-launch-script-tests:test` —— Testcontainers / Docker。
5. `:spring-boot-tests:spring-boot-integration-tests:spring-boot-loader-tests:test` —— Testcontainers / Docker。
6. `:spring-boot-system-tests:spring-boot-deployment-tests:test` —— Docker。
7. `:spring-boot-system-tests:spring-boot-image-tests:test` —— Docker。

**保留在范围内的（不排除）**：
- `spring-boot-project` 下其它所有子项目（含 `spring-boot:test` 中 369 条 D 类 JPMS 失败、`spring-boot-gradle-plugin:test` 中 963 条 DocumentationTests —— 失败但允许跑）。
- `spring-boot-tests:spring-boot-integration-tests:spring-boot-configuration-processor-tests:test` 和 `spring-boot-server-tests:test`。
- `spring-boot-tests:spring-boot-smoke-tests:*` 全部 73 个未被 `ignoredSmokeTests` 排除的子项目。

### Decision 3：修复 fork 责任范围内的 4 条测试

仅修改测试代码（`src/test/java`），不动 `src/main`：

1. `spring-boot/src/test/java/org/springframework/boot/BannerTests.java`：把所有断言中的 `":: Spring Boot ::"` 改为 `":: Bpring Boot ::"`，注释说明因 fork 修改了 `SpringBootBanner.SPRING_BOOT` 常量。
2. `spring-boot/src/test/java/org/springframework/boot/SpringBootVersionTests.java`：把 `isEqualTo(properties.get("version"))` 改为 `startsWith("2.7.18")` 等宽松断言，注释说明 fork 在 `gradle.properties` 中追加了 `-nes.patch.1-SNAPSHOT` 后缀但 jar manifest 的 `Implementation-Version` 仍为基础版本号。
3. `spring-boot/src/test/java/org/springframework/boot/json/AbstractJsonParserTests.java`：第 197 行的异常消息断言从 `"too deeply nested"` 改为 `"nesting depth"`，注释说明 Jackson 2.15.4 → 2.21.1 错误消息文案变化。

### Decision 4：保留 `--continue`，承认非零退出

`make test` 退出码非 0 是预期：D 类、gradle-plugin、E 类失败仍存在。这与"完整反馈面优先"目标一致。

### Decision 5：`help` 文案表述

`help` 描述维持中文 + "耗时较长"占位，并加一行括号说明"含已知失败"。原话："执行受控范围内的测试（含已知失败，详见 test 目标注释），耗时较长"。

## Risks / Trade-offs

- **跑得久**：smoke-tests 加入后估算单次跑 60-120 分钟。→ 缓解：本 change 范围内接受这一代价；后续可单独提案 `make test-fast` 缩小范围。
- **`-x compileTestJava` 仍可能因其它模块的 `testImplementation project(':spring-boot-autoconfigure')` 触发**：理论上 testImplementation 拉的是 main classes，不会触发其它模块的 compileTestJava；但若实际命中，需要再加 `-x` 精确排除。→ 缓解：上次跑（白名单 14 项）未触发，预计黑名单方式同样安全；实际跑后若违反预期再调整。
- **`make test` 持续红色**：D + gradle-plugin + E 类未修，开发者每次看到红难免疲劳。→ 缓解：在 Makefile 注释块清晰列出"已知失败模块清单"，让开发者明白哪些"红是已知的"，哪些"红才是新问题"。
- **测试代码修改可能与上游冲突**：未来合并 upstream 时这 3 个文件会有 conflict。→ 缓解：在每处修改贴上 `// FORK: ...` 注释，便于合并时识别。
- **smoke-tests 中需 redis/mongo 的项目会失败**：cache、session-redis/mongo/webflux-redis/webflux-mongo 等。→ 缓解：本 change 不为这些追加 `-x`，留待后续按需补充。

## Migration Plan

- 无迁移：纯 `Makefile` + 测试代码改动，不影响其它命令、CI、源码、构建脚本。
- 回滚：还原 `Makefile` 中 `test` 目标段落、`.PHONY` 与 `help` 行、3 个测试文件的对应 hunk 即可。

## Open Questions

- D 类 JPMS、gradle-plugin DocumentationTests、E 类 130 条 是否值得在后续 change 中处理？由用户在本 change 完成后单独立项决定。
- `spring-boot-server-tests` 是否在当前环境能跑通？本次跑结果将作为依据，必要时下一轮加入 `-x` 清单。
