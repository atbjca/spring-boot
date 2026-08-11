## MODIFIED Requirements

### Requirement: Security 依赖透明映射

根 `build.gradle` 的 `resolutionStrategy.eachDependency` MUST 包含规则：当 `requested.group == 'org.springframework.security'` 且 `requested.name.startsWith('spring-security-')` 时，将依赖替换为 `${forkGroupIdBase}.security:${forkArtifactPrefix}-security-<module>:${springSecurityVersion}`。`springSecurityVersion` MUST 为 `6.5.11-nes.patch.2-SNAPSHOT`，并作为所有 Security 模块的单一版本源。

#### Scenario: spring-security-core 解析为 patch.2 snapshot fork 坐标
- **WHEN** 任意子模块声明 `org.springframework.security:spring-security-core`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-core:6.5.11-nes.patch.2-SNAPSHOT`
- **AND** 不存在同一图中的 patch.1 或官方 Security core 回退

#### Scenario: spring-security-bom 解析为 patch.2 snapshot fork BOM
- **WHEN** 构建脚本引用 `org.springframework.security:spring-security-bom`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-bom:6.5.11-nes.patch.2-SNAPSHOT`

### Requirement: Security BOM 条目使用 fork 坐标

`spring-boot-dependencies/build.gradle` 中 Spring Security library 条目 MUST 使用 `group(forkGroupIdBase + ".security")` 并通过 `bom()` 引入 `${forkArtifactPrefix}-security-bom`。该 BOM 及其 managed Security modules MUST 使用根 `springSecurityVersion` 的 `6.5.11-nes.patch.2-SNAPSHOT`。

#### Scenario: BOM 中 Security GAV 使用 patch.2 snapshot
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** Security BOM 和相关 managed dependency 的 groupId 为 `cn.bjca.footstone.bpring.security`
- **AND** artifactId 使用 `bjca-footstone-bpring-security-*` 命名
- **AND** version 为 `6.5.11-nes.patch.2-SNAPSHOT`
