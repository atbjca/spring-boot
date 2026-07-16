## MODIFIED Requirements

### Requirement: Phase B 第三方依赖使用 fork 坐标
Phase B 中 `springFrameworkVersion` MUST 更新为 `6.2.19-nes.patch.1-SNAPSHOT`，Security BOM 版本 MUST 更新为 `6.5.11-nes.patch.1-SNAPSHOT`（通过 `springSecurityVersion` 参数）。Logback MUST 保持官方 `ch.qos.logback` 坐标（1.5.38），不替换为 bogback fork。

#### Scenario: Framework 依赖解析为 fork GAV
- **WHEN** 任意子模块声明 `org.springframework:spring-context`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring:bjca-footstone-bpring-context:6.2.19-nes.patch.1-SNAPSHOT`
- **AND** 不保留 `org.springframework:spring-context:6.2.19`

#### Scenario: Security 依赖解析为 fork GAV
- **WHEN** 任意子模块声明 `org.springframework.security:spring-security-core`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-core:6.5.11-nes.patch.1-SNAPSHOT`

#### Scenario: Logback 依赖保持官方且使用修复版本
- **WHEN** BOM 中声明 Logback library
- **THEN** groupId 为 `ch.qos.logback`
- **AND** 版本为 `1.5.38`
