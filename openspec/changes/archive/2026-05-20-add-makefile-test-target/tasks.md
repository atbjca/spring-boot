## 1. 修改 Makefile

- [x] 1.1 在 `.PHONY` 行追加 `test`，保持其它目标顺序与措辞不变
- [x] 1.2 在 `help` 目标的 `@echo` 列表中新增一行 `make test`，措辞为"执行受控范围内的测试（含已知失败，详见 test 目标注释），耗时较长"
- [x] 1.3 在 `Makefile` 末尾追加 `test` 目标段落，包含：
  - 紧邻注释块说明三子树范围、7 条 `-x` 排除项原因、当前承诺（完整反馈面优先）、已知红的分类（D/G/E/S）、维护规则
  - 目标体：`./gradlew test --continue` + 7 个 `-x` 任务路径

## 2. 静态校验

- [x] 2.1 `make help` 输出包含新增 `make test` 行，且既有条目未被破坏
- [x] 2.2 `make -n test` 展开后命令含 `./gradlew test --continue` + 恰好 7 个 `-x` 排除项，无多无少
- [x] 2.3 `grep -n "test" Makefile` 确认 `.PHONY` 包含 `test` 且 `test:` 目标只声明一次

## 3. 修复 fork 责任范围内的 3 个测试文件

- [x] 3.1 `spring-boot/src/test/java/org/springframework/boot/BannerTests.java`：把 `testDefaultBanner` 与 `testDefaultBannerInLog` 中的 `:: Spring Boot ::` 断言改为 `:: Bpring Boot ::`，每处加 `// FORK:` 注释说明
- [x] 3.2 `spring-boot/src/test/java/org/springframework/boot/SpringBootVersionTests.java`：把 `isEqualTo(expectedVersion)` 改为 `assertThat(expectedVersion).startsWith(SpringBootVersion.getVersion())`，加 `// FORK:` 注释说明 gradle.properties 与 jar manifest 版本号不一致原因
- [x] 3.3 `spring-boot/src/test/java/org/springframework/boot/json/AbstractJsonParserTests.java`：把 `listWithRepeatedOpenArray` 中 `"too deeply nested"` 改为 `"nesting depth"`，加 `// FORK:` 注释说明 Jackson 升级文案变化

## 4. 实际执行验证

- [x] 4.1 `make stop` 释放 Gradle daemon，再执行一次完整 `make test`
- [x] 4.2 确认 3.1 / 3.2 / 3.3 涉及的 4 条用例不再出现在失败清单中
- [x] 4.3 确认 `compileTestJava` 失败未在调用中出现（autoconfigure 已被 `-x` 双保险）
- [x] 4.4 确认调用过程未触发任何 `:spring-boot-system-tests:*` 任务、未触发 2 个 Testcontainers integration-tests、未触发 buildpack-platform
- [x] 4.5 确认调用过程触发了 `:spring-boot-tests:spring-boot-smoke-tests:*` 至少一项与 `:spring-boot-tests:spring-boot-integration-tests:spring-boot-configuration-processor-tests` 与 `:spring-boot-server-tests`
- [x] 4.6 把"修复前 (6 模块 / 467 失败)"与"修复后"的差异写入 `openspec/changes/add-makefile-test-target/EXECUTION_NOTES.md`（仅本变更产物，不动其它文档）

## 5. 归档准备

- [x] 5.1 通知后续 `/opsx:archive`：本变更完成后归档至 `openspec/changes/archive/`
- [x] 5.2 在归档时记录尚未解决的失败分类（D / G / E / S），作为下一轮 change 的输入：
  - "启用 JPMS open"（修 D 类 ~369 条，需改 build.gradle）
  - "配 gradle distribution"（修 G 类 963 条，需改 build.gradle 或排除测试类）
  - "按模块逐一定位 E 类"（~130 条）
  - "smoke-tests 外部依赖排除细化"（cache/session-redis/mongo 等需要进一步 `-x`）
