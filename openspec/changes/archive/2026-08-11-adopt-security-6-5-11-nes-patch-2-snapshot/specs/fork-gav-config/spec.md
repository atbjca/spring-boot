## MODIFIED Requirements

### Requirement: NES 版本号格式

`gradle.properties` MUST 定义以下版本参数：

| 参数 | 值 |
|------|-----|
| `version` | `3.5.15-nes.patch.2-SNAPSHOT` |
| `springBootVersion` | `3.5.15` |
| `springFrameworkVersion` | `6.2.19-nes.patch.1` |
| `springSecurityVersion` | `6.5.11-nes.patch.2-SNAPSHOT` |
| `springAuthorizationServerVersion` | `1.5.8-nes.patch.1` |
| `forkArtifactPrefix` | `bjca-footstone-bpring` |
| `forkGroupIdBase` | `cn.bjca.footstone.bpring` |

开发版本号 MUST 遵循 `{官方基线版本}-nes.patch.{N}-SNAPSHOT` 格式。Boot 与内部 fork 组件 MAY 独立递增 NES patch 序号，但每个组件的版本必须来自其单一根属性；`springBootVersion` MUST 保持官方基线版本，不包含 NES 后缀。

#### Scenario: gradle.properties 包含完整 fork 参数
- **WHEN** 读取根目录 `gradle.properties`
- **THEN** `version` 等于 `3.5.15-nes.patch.2-SNAPSHOT`
- **AND** `springBootVersion` 等于 `3.5.15`
- **AND** `springSecurityVersion` 等于 `6.5.11-nes.patch.2-SNAPSHOT`
- **AND** `forkArtifactPrefix` 与 `forkGroupIdBase` 均已定义
- **AND** Framework 与 Authorization Server 版本保持现有 RELEASE 值

#### Scenario: SpringBootVersion 返回官方基线
- **WHEN** 构建并运行 `SpringBootVersion.getVersion()`
- **THEN** 返回值等于 `3.5.15`（不含 `-nes.patch` 后缀）

### Requirement: Phase B 第三方依赖使用 fork 坐标

Phase B 中 `springFrameworkVersion` MUST 保持 `6.2.19-nes.patch.1`，Security BOM 版本 MUST 使用 `6.5.11-nes.patch.2-SNAPSHOT`（通过 `springSecurityVersion` 参数），Authorization Server MUST 保持 `1.5.8-nes.patch.1`。采用 Security patch.2 snapshot MUST NOT change or invent versions for other internal fork dependencies。Logback MUST 保持官方 `ch.qos.logback` 坐标（1.5.38），不替换为 bogback fork。

#### Scenario: Framework 依赖解析为既有 fork GAV
- **WHEN** 任意子模块声明 `org.springframework:spring-context`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring:bjca-footstone-bpring-context:6.2.19-nes.patch.1`

#### Scenario: Security 依赖解析为 patch.2 snapshot fork GAV
- **WHEN** 任意子模块声明 `org.springframework.security:spring-security-core`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-core:6.5.11-nes.patch.2-SNAPSHOT`
- **AND** 不回退到 `org.springframework.security` 或 `6.5.11-nes.patch.1`

#### Scenario: Logback 依赖保持官方且使用修复版本
- **WHEN** BOM 中声明 Logback library
- **THEN** groupId 为 `ch.qos.logback`
- **AND** 版本为 `1.5.38`
