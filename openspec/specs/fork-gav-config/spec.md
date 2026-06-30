## ADDED Requirements

### Requirement: NES 版本号格式

`gradle.properties` MUST 定义以下版本参数：

| 参数 | 值 |
|------|-----|
| `version` | `3.5.15-nes.patch.1-SNAPSHOT` |
| `springBootVersion` | `3.5.15` |
| `springFrameworkVersion` | `6.2.19-nes.patch.1-SNAPSHOT` |
| `springSecurityVersion` | `6.5.11-nes.patch.1-SNAPSHOT` |
| `springAuthorizationServerVersion` | `1.5.8-nes.patch.1-SNAPSHOT` |
| `forkArtifactPrefix` | `bjca-footstone-bpring` |
| `forkGroupIdBase` | `cn.bjca.footstone.bpring` |

版本号 MUST 遵循 `{官方基线版本}-nes.patch.{N}-SNAPSHOT` 格式。后续安全补丁递增 `N`。

#### Scenario: gradle.properties 包含完整 fork 参数
- **WHEN** 读取根目录 `gradle.properties`
- **THEN** `version` 等于 `3.5.15-nes.patch.1-SNAPSHOT`
- **AND** `springBootVersion` 等于 `3.5.15`
- **AND** `forkArtifactPrefix` 与 `forkGroupIdBase` 均已定义

#### Scenario: SpringBootVersion 返回官方基线
- **WHEN** 构建并运行 `SpringBootVersion.getVersion()`
- **THEN** 返回值等于 `3.5.15`（不含 `-nes.patch` 后缀）

### Requirement: Phase B 第三方依赖使用 fork 坐标

Phase B 中 `springFrameworkVersion` MUST 更新为 `6.2.19-nes.patch.1-SNAPSHOT`，Security BOM 版本 MUST 更新为 `6.5.11-nes.patch.1-SNAPSHOT`（通过 `springSecurityVersion` 参数）。Logback MUST 保持官方 `ch.qos.logback` 坐标（1.5.34），不替换为 bogback fork。

#### Scenario: Framework 依赖解析为 fork GAV
- **WHEN** 任意子模块声明 `org.springframework:spring-context`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring:bjca-footstone-bpring-context:6.2.19-nes.patch.1-SNAPSHOT`
- **AND** 不保留 `org.springframework:spring-context:6.2.19`

#### Scenario: Security 依赖解析为 fork GAV
- **WHEN** 任意子模块声明 `org.springframework.security:spring-security-core`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-core:6.5.11-nes.patch.1-SNAPSHOT`

#### Scenario: Logback 依赖保持官方
- **WHEN** BOM 中声明 Logback library
- **THEN** groupId 为 `ch.qos.logback`
- **AND** 版本为 `1.5.34`
