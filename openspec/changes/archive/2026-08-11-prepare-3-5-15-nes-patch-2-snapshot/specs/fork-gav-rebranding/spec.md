## MODIFIED Requirements

### Requirement: DeployedPlugin artifactId 显式设置

`buildSrc/.../DeployedPlugin.java` MUST 在创建 `MavenPublication` 后检查 `forkArtifactPrefix` 属性，若存在则将 `artifactId` 设为 `project.name.replace("spring-boot", forkArtifactPrefix + "-boot")`。所有生成的 Spring Boot fork publications MUST inherit the single root project version and MUST NOT declare a module-specific version override.

#### Scenario: 发布制品 artifactId 使用 fork 命名和当前 snapshot 版本
- **WHEN** 为 `:spring-boot-project:spring-boot-starter-web` 生成 Maven publication metadata
- **THEN** GAV 为 `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-web:3.5.15-nes.patch.2-SNAPSHOT`
- **AND** artifactId 不以 `spring-boot-` 开头
- **AND** version 来自根 `gradle.properties` 的单一 `version` 属性
