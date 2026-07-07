## MODIFIED Requirements

### Requirement: Makefile 基础目标

根目录 MUST 提供 `Makefile`，包含以下 `.PHONY` 目标：

| 目标 | 行为 |
|------|------|
| `help` | 显示中文帮助信息 |
| `setup-gradle` | 调用 `./scripts/setup-gradle-local.sh`，将本地 Gradle 发行包安装到 wrapper 缓存 |
| `clean` | `./gradlew clean` |
| `format` | `./gradlew format` |
| `build-thin` | `./gradlew assemble -x test -x intTest -x checkstyleMain -x checkstyleTest` |
| `install` | `./gradlew publishToMavenLocal -x test` |
| `deploy` | `./gradlew publish -x test` |
| `stop` | `./gradlew --stop` |
| `test` | Phase 1 核心模块测试（spring-boot + spring-boot-test） |
| `test-gate` | Tier B 全绿模块测试（Phase 1 + 摸底后确认的模块） |

The repository MUST track `scripts/setup-gradle-local.sh` because `Makefile` targets depend on it.

#### Scenario: make help 显示目标列表
- **WHEN** 执行 `make help`
- **THEN** 输出包含 `setup-gradle`、`build-thin`、`install`、`deploy`、`test-gate` 的中文说明

#### Scenario: setup-gradle helper 存在
- **WHEN** 从 clean checkout 检查仓库文件
- **THEN** `scripts/setup-gradle-local.sh` 存在
- **AND** `Makefile` 的 `setup-gradle` 目标调用该脚本

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
