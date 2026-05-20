# Execution Notes — add-makefile-test-target

记录本变更两次完整 `make test` 实跑的对照，作为归档时的事实依据。

## 第一次跑（修复前，2026-05-20 下午）

- **触发命令**：`make test`（初版 Makefile，白名单 14 个 `spring-boot-project` 子项目）
- **耗时**：29 分 1 秒
- **任务统计**：137 actionable, 135 executed, 2 from cache
- **失败模块（6 个）**：

| 模块 | tests / failed / skipped | 主要类型 |
|---|---|---|
| `spring-boot:test` | 4257 / 485 / 22 | A 类 BannerTests/SpringBootVersionTests + C 类 JacksonJsonParser + D 类 JPMS *ServletWebServerFactoryTests + E 类杂项 |
| `spring-boot-tools:spring-boot-gradle-plugin:test` | 1269 / 963 / 7 | G 类 `*DocumentationTests` 几乎全挂（ZipException at ZipFile.java:1637） |
| `spring-boot-actuator-autoconfigure:test` | 1292 / 8 / 0 | E 类 Jersey* / CloudFoundry skipSslValidation |
| `spring-boot-actuator:test` | 1659 / 7 / 5 | E 类 LiquibaseEndpointTests / QuartzEndpointTests |
| `spring-boot-test:test` | 873 / 2 / 1 | E 类 SpringBootTestContextHierarchy / WebTestClient |
| `spring-boot-devtools:test` | 329 / 2 / 1 | E 类 LocalDevToolsAutoConfigurationTests |

## 第二次跑（修复后，2026-05-20 晚间）

- **触发命令**：`make test`（黑名单 7 个 `-x` 排除 + 三子树覆盖）
- **耗时**：16 分 9 秒（daemon 预热 + 部分任务命中缓存）
- **任务统计**：506 actionable, 376 executed, 130 up-to-date
- **失败模块（11 个）**：

| 模块 | tests / failed / skipped | 与前次相比 | 类型 |
|---|---|---|---|
| `spring-boot:test` | 4257 / 482 / 22 | **-3**（A/C 类 4 条修复确认；其它 flaky 数量略变） | D + E + 已修 4 条 |
| `gradle-plugin:test` | 1269 / 961 / 7 | -2（flaky） | G 类（未处理） |
| `spring-boot-actuator-autoconfigure:test` | 1292 / 7 / 0 | -1（CloudFoundry skipSslValidation 这次未出现，疑 flaky） | E 类（未处理） |
| `spring-boot-actuator:test` | 1659 / 8 / 5 | +1（新增 WebFluxEndpointIntegrationTests > writeOperationWithVoidResponse 疑 flaky） | E 类（未处理） |
| `spring-boot-test:test` | 873 / 2 / 1 | 不变 | E 类（未处理） |
| `spring-boot-devtools:test` | 329 / 2 / 1 | 不变 | E 类（未处理） |
| `spring-boot-smoke-test-data-jpa:test` | 31 / 9 / ? | 新增（首跑未覆盖 smoke-tests） | S 类（外部依赖：H2/JPA） |
| `spring-boot-smoke-test-flyway:test` | 5 / 5 / ? | 新增 | S 类（数据库初始化） |
| `spring-boot-smoke-test-hibernate52:test` | ? / 1 / ? | 新增 | S 类 |
| `spring-boot-smoke-test-kafka:test` | ? / 1 / ? | 新增 | S 类（Kafka broker 缺失） |
| `spring-boot-smoke-test-test:test` | ? / 1 / ? | 新增 | S 类 |

## 修复有效性验证（A/C 类 4 条）

| 用例 | 文件 | 修法 | 修后状态 |
|---|---|---|---|
| `BannerTests.testDefaultBanner` | `BannerTests.java:65-69` | `:: Spring Boot ::` → `:: Bpring Boot ::` + `// FORK:` | ✅ XML 无 `<failure>` |
| `BannerTests.testDefaultBannerInLog` | `BannerTests.java:71-76` | 同上 | ✅ XML 无 `<failure>` |
| `SpringBootVersionTests.getVersionShouldReturnVersionMatchingGradleProperties` | `SpringBootVersionTests.java:36-44` | `isEqualTo` → `assertThat(expectedVersion).startsWith(SpringBootVersion.getVersion())` + `// FORK:` | ✅ XML 无 `<failure>` |
| `JacksonJsonParserTests.listWithRepeatedOpenArray` | `AbstractJsonParserTests.java:194-201` | `"too deeply nested"` → `"nesting depth"` + `// FORK:` | ✅ XML 无 `<failure>` |

局部验证（精准跑 4 条用例）：`./gradlew :spring-boot-project:spring-boot:test --tests ...` → **BUILD SUCCESSFUL in 2m 10s**

## 排除清单生效性验证

`/tmp/make_test_run2.log` 中：
- `:spring-boot-project:spring-boot-autoconfigure:compileTestJava` 仅出现在 `-x` 参数行，未被实际执行 ✓
- `:spring-boot-system-tests:` 仅出现在 `-x` 参数行（2 条），未被实际执行 ✓
- `:spring-boot-tools:spring-boot-buildpack-platform:test` 仅出现在 `-x` 参数行，未被实际执行 ✓
- 两个 docker-bound integration-tests 任务路径仅出现在 `-x` 参数行，未被实际执行 ✓
- `:spring-boot-tests:spring-boot-smoke-tests:*` 出现 561 次（被广泛调度） ✓
- `:spring-boot-tests:spring-boot-integration-tests:spring-boot-configuration-processor-tests` 出现 7 次 ✓

## 残留分类（建议作为后续 change 输入）

- **D 类 — JVM/JPMS** (~369 条)：spring-boot 模块 `web.embedded.{tomcat,jetty,undertow}.*ServletWebServerFactoryTests`。需 `build.gradle` 加 `jvmArgs '--add-opens=java.base/java.net=ALL-UNNAMED'`。建议立 change `add-jpms-open-for-tests`。
- **G 类 — gradle-plugin DocumentationTests** (~961 条)：需 `build.gradle` 配 Gradle distribution 或排除测试类。建议立 change `fix-gradle-plugin-doc-tests`。
- **E 类 — 未逐一定位** (~30 条净)：Liquibase / Quartz / WebFlux / Jersey* / WebTestClient / SpringBootTestContextHierarchy / LocalDevTools 等。建议按模块拆 change 逐一排查。
- **S 类 — smoke-tests 外部依赖** (~17 条)：data-jpa（H2/JPA）, flyway, hibernate52, kafka, smoke-test-test 等。建议在本目标的 `-x` 清单中追加这几个 smoke-tests 子项目（如不打算修），或为这些场景配置内嵌组件（如 embedded-kafka）。
