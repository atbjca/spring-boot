## ADDED Requirements

### Requirement: Nexus 仓库配置

根 `build.gradle` 和 `settings.gradle`（pluginManagement）MUST 配置 Nexus 私服仓库，优先级高于 `mavenCentral()`。仓库 URL 和 credentials MUST 通过 `gradle.properties` 参数化：

- `nexusPublicUrl`
- `nexusSnapshotUrl`
- `nexusReleaseUrl`
- `nexusUsername` / `nexusPassword`

credentials MUST NOT 以明文硬编码在版本控制的脚本中（可使用 `.gitignore` 的本地 `gradle.properties` 或环境变量）。

#### Scenario: 依赖解析优先私服
- **WHEN** Gradle 解析任意依赖
- **THEN** repositories 列表中 Nexus 排在 `mavenCentral()` 之前

#### Scenario: SNAPSHOT 发布到 snapshot 仓库
- **WHEN** 项目 version 以 `-SNAPSHOT` 结尾并执行 `publish`
- **THEN** 制品发布到 `nexusSnapshotUrl` 配置的仓库

### Requirement: Maven 发布配置

`subprojects` 块 MUST 为所有 deployable 子项目配置 `publishing.repositories.maven`，指向 Nexus（release 或 snapshot 按 version 后缀区分）。

#### Scenario: publishToMavenLocal 成功
- **WHEN** 执行 `./gradlew publishToMavenLocal -x test`
- **THEN** `~/.m2/repository/cn/bjca/footstone/bpring/boot/` 下出现 fork 命名的制品

#### Scenario: publish 到 Nexus
- **WHEN** 私服可达且 credentials 正确，执行 `./gradlew publish -x test`
- **THEN** Nexus 中出现 fork GAV 的 SNAPSHOT 制品
