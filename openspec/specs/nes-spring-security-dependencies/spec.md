# nes-spring-security-dependencies Specification

## Purpose
TBD - created by archiving change adopt-spring-security-patch-2-security-baseline. Update Purpose after archive.
## Requirements
### Requirement: Boot development SHALL select the Spring Security patch.2 candidate through existing integration points
Spring Boot 开发线 SHALL 将 `springSecurityVersion` 作为 Spring Security 唯一版本源，并将其设置为 `5.8.16-nes.patch.2-SNAPSHOT`。现有官方坐标到 NES 坐标的 Gradle 映射和现有 NES Security BOM import SHALL 继续由该属性驱动；本 change MUST NOT 创建第二份 Boot BOM、重复的模块版本清单或新的宽泛坐标映射。

#### Scenario: Official Spring Security module is requested in the Boot build
- **WHEN** 任一 Boot 子项目请求受支持的 `org.springframework.security:spring-security-*` 模块
- **THEN** Gradle 解析结果 MUST 使用 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-*` 和 `5.8.16-nes.patch.2-SNAPSHOT`
- **AND** 解析图 MUST NOT 同时包含 patch.1 或对应官方 Spring Security 实现

#### Scenario: Version source is audited
- **WHEN** 实现完成版本推进并搜索构建配置
- **THEN** Spring Security patch.2 开发版本 MUST 由 `springSecurityVersion` 单点提供
- **AND** starter、子项目或验证脚本 MUST NOT 引入未经说明的重复硬编码版本源

### Requirement: Boot publication metadata SHALL expose the NES Security patch.2 contract
生成的 Spring Boot dependency-management POM SHALL 导入 NES Spring Security BOM `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-bom:5.8.16-nes.patch.2-SNAPSHOT`。代表性 Security starter 的 Maven POM 和 Gradle Module Metadata SHALL 发布实际解析到的 NES Security GAV 和 patch.2 版本，MUST NOT 重新暴露官方 Security GAV或 patch.1 版本。

#### Scenario: Boot dependency-management POM is generated
- **WHEN** 生成 `spring-boot-dependencies` Maven POM
- **THEN** dependency management MUST 以 `pom`/`import` 形式包含 patch.2-SNAPSHOT NES Security BOM
- **AND** MUST NOT 包含 patch.1 Security BOM import 或新增的重复 Boot BOM

#### Scenario: Security starter metadata is generated
- **WHEN** 生成 `spring-boot-starter-security` 及代表性 OAuth2 starter 的 Maven POM和 Gradle Module Metadata
- **THEN** Security 依赖 MUST 使用 `cn.bjca.footstone.bpring.security` 下的 NES artifactId 和 patch.2-SNAPSHOT
- **AND** 元数据 MUST NOT 声明 `org.springframework.security:spring-security-*` 或 `5.8.16-nes.patch.1`

### Requirement: Independent Maven and Gradle consumers SHALL verify the published Boot contract
本 change SHALL 将所需 Boot BOM、starter 和依赖模块发布到隔离的临时 Maven 仓库，并使用最小 Maven 与 Gradle 消费者验证下游行为。消费者 MUST 仅依赖发布元数据，MUST NOT 复制 Boot 仓库内部的 `resolutionStrategy`、源码 substitution 或其他私有构建逻辑。

#### Scenario: Maven consumer imports the Boot BOM
- **WHEN** 独立 Maven 项目从隔离仓库导入 Boot dependency-management POM并消费 Security starter及代表性 OAuth2/SAML 路径
- **THEN** 依赖树 MUST 只解析 patch.2-SNAPSHOT NES Security 模块
- **AND** Security 相关类加载或最小运行 smoke MUST 成功

#### Scenario: Gradle consumer imports the Boot platform
- **WHEN** 独立 Gradle 项目从同一隔离仓库消费 Boot platform和 Security starter，且没有仓库内坐标映射规则
- **THEN** runtime graph MUST 只解析 patch.2-SNAPSHOT NES Security 模块
- **AND** 结果 MUST 与 Maven 消费者的关键 Security、SAML 和 Crypto 版本一致

#### Scenario: Snapshot identity is recorded
- **WHEN** 独立消费者解析 `5.8.16-nes.patch.2-SNAPSHOT`
- **THEN** 验证记录 MUST 包含实际 Nexus timestamp/build、代表性 POM/JAR SHA-256 和生产者 commit
- **AND** 缓存命中的旧 SNAPSHOT MUST NOT 被作为当前候选证据

### Requirement: Published Boot Security consumption SHALL preserve Java 8 compatibility
Boot 采用 patch.2 候选后 SHALL 保持项目 Java 8 基线。生产者的 Java 8 发布门禁 SHALL 作为 Security artifact 证据，Boot 的 Maven 和 Gradle 独立消费者 SHALL 在真实 Java 8 运行时执行代表性 Security、OAuth2、SAML/Crypto 类加载或行为 smoke。

#### Scenario: Java 8 Maven consumer runs
- **WHEN** Maven 消费者在 Java 8 上解析并运行 Boot Security 候选
- **THEN** smoke MUST 成功且不得出现 class version、linkage、provider 或反射加载错误

#### Scenario: Java 8 Gradle consumer runs
- **WHEN** Gradle 消费者在 Java 8 上解析并运行相同候选
- **THEN** smoke MUST 成功且关键解析版本 MUST 与 Maven 消费者一致

#### Scenario: Candidate bytecode is audited
- **WHEN** 检查代表性 Boot、Security、SAML 和 Crypto 主 artifact
- **THEN** Java 8 路径中的 class major MUST 不高于 52
- **AND** 任何 Java 11+ class 或仅 Java 11 可运行的传递模块 MUST 阻止候选验收

### Requirement: Mixed Bouncy Castle paths SHALL have an explicit verified disposition
同时启用 SendGrid 和 Security SAML/Crypto 的依赖图 SHALL 明确处置 `bcprov-jdk15on:1.70` 与 Security `jdk18on:1.84`。验收结论 MUST 是经验证的 Java 8 兼容升级、经验证的排除/替代，或明确记录的不收敛兼容边界；不同 artifactId 未触发版本冲突 MUST NOT 被当作安全收敛证据。

#### Scenario: A converged Bouncy Castle solution is selected
- **WHEN** 实现选择 SendGrid 升级或 `jdk15on` 排除/替代
- **THEN** Maven 和 Gradle 组合图 MUST 只保留经批准的 BC provider family
- **AND** SendGrid 自动配置、邮件客户端 smoke及 Security SAML/Crypto smoke MUST 在 Java 8 上通过

#### Scenario: Convergence cannot be proven safely
- **WHEN** 升级或排除方案无法同时满足 Java 8、SendGrid 和 Security 运行证据
- **THEN** 构建和文档 MUST 如实保留并说明双 provider family、重叠类风险、受支持边界和回滚方式
- **AND** 测试报告与发布说明 MUST NOT 声称 BC 图已经收敛

### Requirement: SNAPSHOT adoption SHALL remain separate from formal release
`5.8.16-nes.patch.2-SNAPSHOT` SHALL 仅作为 Boot 开发候选。任何正式 Boot RELEASE SHALL 等待 Nexus-verified 的 `5.8.16-nes.patch.2` Security RELEASE 和对应 `v5.8.16-nes.patch.2` tag，并通过现有内部 RELEASE-only metadata gate；timestamped SNAPSHOT、分支 HEAD 或本地制品 MUST NOT 替代该条件。

#### Scenario: Boot development build is generated
- **WHEN** Boot 仍处于开发验证阶段且 Security patch.2 RELEASE 尚不存在
- **THEN** 生成元数据 MAY 引用 patch.2-SNAPSHOT
- **AND** 文档 MUST 将其标识为开发候选而非正式发布

#### Scenario: Formal Boot release is prepared
- **WHEN** 准备生成不带 `-SNAPSHOT` 的 Boot RELEASE 元数据
- **THEN** Security `5.8.16-nes.patch.2` Nexus 制品和精确 tag MUST 已验证
- **AND** 任一内部 Security SNAPSHOT 残留 MUST 阻止发布

#### Scenario: Patch.1 history is reviewed
- **WHEN** 更新当前版本或消费文档
- **THEN** 已发布的 `5.8.16-nes.patch.1` 坐标、tag和历史示例 MUST 保持不可变且可追溯
