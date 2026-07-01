## MODIFIED Requirements

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

#### Scenario: make help 显示 test-gate
- **WHEN** 执行 `make help`
- **THEN** 输出包含 `test-gate` 的中文说明

#### Scenario: make test-gate 全绿
- **WHEN** 执行 `make test-gate`
- **THEN** BUILD SUCCESSFUL
