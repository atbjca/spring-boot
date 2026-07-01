## MODIFIED Requirements

### Requirement: build-thin 作为 fork 默认验证入口

`make build-thin` MUST 对裁剪后保留的模块执行 `./gradlew assemble`，跳过 test / intTest / 文档 / checkstyle。裁剪前已通过 `-x` 排除的 docs / cli / system-tests assemble 任务，裁剪后因模块不在 Gradle 项目树中，对应 `-x` 可保留（Gradle 会忽略不存在的任务路径）或移除。

#### Scenario: make build-thin 裁剪后全绿
- **WHEN** settings.gradle 排除不发布模块后执行 `make build-thin`
- **THEN** BUILD SUCCESSFUL
- **AND** 编译范围仅包含保留模块
