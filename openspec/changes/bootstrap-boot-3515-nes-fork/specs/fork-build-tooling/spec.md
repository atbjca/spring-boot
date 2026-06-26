## ADDED Requirements

### Requirement: Makefile 基础目标

根目录 MUST 提供 `Makefile`，包含以下 `.PHONY` 目标：

| 目标 | 行为 |
|------|------|
| `help` | 显示中文帮助信息 |
| `clean` | `./gradlew clean` |
| `format` | `./gradlew format` |
| `build-thin` | `./gradlew build -x test -x intTest -x checkstyleMain -x checkstyleTest -x asciidoctor -x javadoc` |
| `install` | `./gradlew publishToMavenLocal -x test` |
| `deploy` | `./gradlew publish -x test` |
| `stop` | `./gradlew --stop` |

#### Scenario: make help 显示目标列表
- **WHEN** 执行 `make help`
- **THEN** 输出包含 `build-thin`、`install`、`deploy` 的中文说明

#### Scenario: make build-thin 跳过测试和文档
- **WHEN** 执行 `make build-thin`
- **THEN** Gradle 命令包含 `-x test` 且不含 `publish` 或 `publishToMavenLocal`

#### Scenario: make install 发布到本地仓库
- **WHEN** 执行 `make install`
- **THEN** 调用 `./gradlew publishToMavenLocal -x test`
- **AND** 不触发 `clean`（与 2.7 行为一致，避免不必要的全量清理）

### Requirement: build-thin 作为 fork 默认验证入口

`build-thin` MUST 作为 fork 日常编译验证的推荐入口，在 `help` 文案中标注大致耗时占位。

#### Scenario: build-thin 编译通过
- **WHEN** fork GAV 配置完成后执行 `make build-thin`
- **THEN** 构建以 `BUILD SUCCESSFUL` 结束（不要求测试通过）
