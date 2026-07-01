## ADDED Requirements

### Requirement: Makefile 基础目标

根目录 MUST 提供 `Makefile`，包含以下 `.PHONY` 目标：

| 目标 | 行为 |
|------|------|
| `help` | 显示中文帮助信息 |
| `clean` | `./gradlew clean` |
| `format` | `./gradlew format` |
| `build-thin` | `./gradlew assemble -x test -x intTest -x checkstyleMain -x checkstyleTest` |
| `install` | `./gradlew publishToMavenLocal -x test` |
| `deploy` | `./gradlew publish -x test` |
| `stop` | `./gradlew --stop` |
| `test` | Phase 1 核心模块测试（spring-boot + spring-boot-test） |
| `test-gate` | Tier B 全绿模块测试（Phase 1 + 摸底后确认的模块） |

#### Scenario: make help 显示目标列表
- **WHEN** 执行 `make help`
- **THEN** 输出包含 `build-thin`、`install`、`deploy`、`test-gate` 的中文说明

#### Scenario: make build-thin 跳过测试和文档
- **WHEN** 执行 `make build-thin`
- **THEN** Gradle 命令包含 `-x test` 且不含 `publish` 或 `publishToMavenLocal`

#### Scenario: make install 发布到本地仓库
- **WHEN** 执行 `make install`
- **THEN** 调用 `./gradlew publishToMavenLocal -x test`
- **AND** 不触发 `clean`（与 2.7 行为一致，避免不必要的全量清理）

#### Scenario: make test-gate 全绿
- **WHEN** 执行 `make test-gate`
- **THEN** BUILD SUCCESSFUL

### Requirement: build-thin 作为 fork 默认验证入口

`make build-thin` MUST 对裁剪后保留的模块执行 `./gradlew assemble`，跳过 test / intTest / 文档 / checkstyle。裁剪前已通过 `-x` 排除的 docs / cli / system-tests assemble 任务，裁剪后因模块不在 Gradle 项目树中，对应 `-x` 可保留（Gradle 会忽略不存在的任务路径）或移除。

#### Scenario: make build-thin 裁剪后全绿
- **WHEN** settings.gradle 排除不发布模块后执行 `make build-thin`
- **THEN** BUILD SUCCESSFUL
- **AND** 编译范围仅包含保留模块
