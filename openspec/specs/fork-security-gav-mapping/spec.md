## ADDED Requirements

### Requirement: Security 依赖透明映射

根 `build.gradle` 的 `resolutionStrategy.eachDependency` MUST 包含规则：当 `requested.group == 'org.springframework.security'` 且 `requested.name.startsWith('spring-security-')` 时，将依赖替换为 `${forkGroupIdBase}.security:${forkArtifactPrefix}-security-<module>:${springSecurityVersion}`。

#### Scenario: spring-security-core 解析为 fork 坐标
- **WHEN** 任意子模块声明 `org.springframework.security:spring-security-core`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-core:6.5.11-nes.patch.1-SNAPSHOT`

#### Scenario: spring-security-bom 解析为 fork BOM
- **WHEN** 构建脚本引用 `org.springframework.security:spring-security-bom`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-bom:6.5.11-nes.patch.1-SNAPSHOT`

### Requirement: Security BOM 条目使用 fork 坐标

`spring-boot-dependencies/build.gradle` 中 Spring Security library 条目 MUST 使用 `group(forkGroupIdBase + ".security")` 并通过 `bom()` 引入 `${forkArtifactPrefix}-security-bom`。

#### Scenario: BOM 中 Security groupId 为 fork
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** Security 相关 managed dependency 的 groupId 为 `cn.bjca.footstone.bpring.security`

### Requirement: Authorization Server 特殊处理

若 BOM 管理 `spring-security-oauth2-authorization-server`，MUST 使用 `${forkGroupIdBase}.security` groupId 及对应的 fork artifactId（`${forkArtifactPrefix}-security-oauth2-authorization-server`），版本独立管理。

#### Scenario: Authorization Server 使用 fork 坐标
- **WHEN** BOM 包含 Spring Authorization Server 条目
- **THEN** groupId 为 `cn.bjca.footstone.bpring.security`
- **AND** artifactId 以 `bjca-footstone-bpring-security-` 开头
