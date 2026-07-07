## MODIFIED Requirements

### Requirement: Maven 发布配置

`subprojects` 块 MUST 为所有 deployable 子项目配置 `publishing.repositories.maven`，指向 Nexus（release 或 snapshot 按 version 后缀区分）。

When `spring-boot-project:spring-boot-tools:spring-boot-properties-migrator` is included in `settings.gradle`, it MUST publish using the fork coordinate `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-properties-migrator`.

#### Scenario: publishToMavenLocal 成功
- **WHEN** 执行 `./gradlew publishToMavenLocal -x test`
- **THEN** `~/.m2/repository/cn/bjca/footstone/bpring/boot/` 下出现 fork 命名的制品

#### Scenario: publish 到 Nexus
- **WHEN** 私服可达且 credentials 正确，执行 `./gradlew publish -x test`
- **THEN** Nexus 中出现 fork GAV 的 SNAPSHOT 制品

#### Scenario: Properties migrator 发布到 Nexus
- **WHEN** 私服可达且 credentials 正确，执行 `./gradlew :spring-boot-project:spring-boot-tools:spring-boot-properties-migrator:publishMavenPublicationToNexusRepository -x test`
- **THEN** Nexus 中出现 `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-properties-migrator` 的 SNAPSHOT 制品
