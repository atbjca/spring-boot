## MODIFIED Requirements

### Requirement: 不发布的显式 include 模块排除

以下 4 个显式 `include` 的模块 MUST 从 `settings.gradle` 中移除（注释或删除）：

- `spring-boot-project:spring-boot-docs`
- `spring-boot-project:spring-boot-tools:spring-boot-cli`
- `spring-boot-project:spring-boot-tools:spring-boot-antlib`
- `spring-boot-project:spring-boot-tools:spring-boot-configuration-metadata-changelog-generator`

`spring-boot-project:spring-boot-tools:spring-boot-properties-migrator` MUST remain included so the fork can publish the properties migrator artifact to Nexus.

#### Scenario: CLI 不参与构建
- **WHEN** 执行 `./gradlew projects`
- **THEN** 输出中不包含 `spring-boot-cli` 相关项目

#### Scenario: Properties migrator 参与构建
- **WHEN** 执行 `./gradlew projects`
- **THEN** 输出中包含 `spring-boot-project:spring-boot-tools:spring-boot-properties-migrator`
