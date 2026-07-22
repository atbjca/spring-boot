## ADDED Requirements

### Requirement: Reactor Netty official coordinates SHALL resolve to NES artifacts
Spring Boot 的构建 SHALL 将受支持的官方 `io.projectreactor.netty:reactor-netty-*` 请求映射到版本单点管理的 NES Reactor Netty 制品。映射 MUST 使用明确模块白名单，MUST NOT 泛化到 incubator QUIC 或未知模块。

#### Scenario: Supported official module is requested
- **WHEN** 任一子项目请求 `reactor-netty`、`reactor-netty-core`、`reactor-netty-http` 或 `reactor-netty-http-brave`
- **THEN** 解析结果 MUST 使用 `cn.bjca.footstone.beactor.netty:bjca-footstone-beactor-netty-*` 和配置的 NES 版本

#### Scenario: Unknown Reactor Netty module is requested
- **WHEN** 请求不在受支持白名单内的 Reactor Netty 或 incubator 模块
- **THEN** 构建 MUST NOT 自动构造或替换为未经验证的 NES 坐标

### Requirement: Spring Boot BOM SHALL explicitly manage NES Reactor Netty modules
`spring-boot-dependencies` SHALL 显式管理四个受支持的 NES Reactor Netty 模块为 `1.0.48-nes.patch.1-SNAPSHOT` 或后续经独立 change 批准的版本。官方 Reactor BOM SHALL 继续管理 Reactor Core 等未 fork 组件，且 MUST NOT 被错误视为 NES Reactor Netty BOM。

#### Scenario: Dependency-management POM is generated
- **WHEN** 生成 Spring Boot dependency-management Maven POM
- **THEN** POM MUST 包含四个 NES Reactor Netty managed dependencies，且版本一致

#### Scenario: Reactor Core is resolved
- **WHEN** 下游解析 `io.projectreactor:reactor-core`
- **THEN** 它 SHALL 继续由既有官方 Reactor BOM 基线管理，不得被改写到 Reactor Netty NES group

### Requirement: Reactor Netty starter publication SHALL expose NES coordinates
NES `spring-boot-starter-reactor-netty` 的发布元数据 SHALL 直接声明 NES `bjca-footstone-beactor-netty-http`，不得依赖仅在 Spring Boot 仓库内部生效的 Gradle resolutionStrategy。

#### Scenario: Starter Maven POM is generated
- **WHEN** 生成 `spring-boot-starter-reactor-netty` 的 Maven POM
- **THEN** 其 HTTP 引擎依赖 MUST 是 `cn.bjca.footstone.beactor.netty:bjca-footstone-beactor-netty-http`
- **AND** POM MUST NOT 声明 `io.projectreactor.netty:reactor-netty-http`

#### Scenario: Independent Maven consumer resolves the starter
- **WHEN** 配置 NES Nexus 的独立 Maven 项目消费已发布或本地暂存的 NES starter/BOM
- **THEN** 依赖树 MUST 只包含 NES Reactor Netty 模块，不得回拉同名官方模块

### Requirement: Netty SHALL align with the producer-tested baseline
Spring Boot dependency management SHALL 将全部 `io.netty:*` 核心模块统一管理为 `4.1.136.Final`，与 Reactor Netty NES fork 已验证组合保持一致，并保持 Java 8 兼容。

#### Scenario: Runtime dependency graph is resolved
- **WHEN** 解析 WebFlux、WebClient 或 RSocket 相关 runtime classpath
- **THEN** 所有受 Netty BOM 管理的核心模块 MUST 选定 `4.1.136.Final`，不得出现 `4.1.135.Final` 或更旧版本并存

#### Scenario: Java compatibility is audited
- **WHEN** 接受 Reactor Netty NES 和 Netty 4.1.136 制品
- **THEN** 关键 class 的 bytecode major MUST 不高于 Java 8 的 52，或具备等价的官方构建证据

### Requirement: Adoption SHALL preserve supported reactive integration paths
采用 NES Reactor Netty 后，Spring Boot 的 WebFlux、WebClient、Actuator 和 RSocket 相关装配与基本运行行为 SHALL 保持兼容。HTTP/2 用户设置语义 SHALL 不因 Netty 4.1.136 默认值而退化。

#### Scenario: Reactive integration tests run
- **WHEN** 执行受影响模块的针对性测试和项目标准测试门禁
- **THEN** WebFlux/WebClient/Actuator/RSocket 相关测试 MUST 无由坐标替换或 Netty 升级引起的失败

#### Scenario: HTTP2 max streams is explicitly configured
- **WHEN** 应用通过 Reactor Netty 配置显式设置 HTTP/2 `maxConcurrentStreams`
- **THEN** 有效设置 MUST 保留用户值语义，不得被 Netty 新默认值静默压低为 100

### Requirement: Consumer documentation SHALL describe NES repository and rollback requirements
User Manual 和 Quick Start SHALL 提供 NES Nexus、BOM/starter、直接 GAV、SNAPSHOT 更新、Java 8、已知安全状态及回滚说明。示例 MUST 与实际生成的 BOM/POM 一致。

#### Scenario: New consumer follows Quick Start
- **WHEN** 用户仅按 Quick Start 配置仓库并引入 NES Spring Boot BOM/starter
- **THEN** 项目 SHALL 能解析 NES Reactor Netty 与 Netty 4.1.136，且无需复制 Spring Boot 仓库内部的 resolutionStrategy

#### Scenario: Consumer cannot access NES Nexus
- **WHEN** 用户环境无法访问 NES Nexus
- **THEN** 文档 MUST 明确说明解析失败影响及恢复官方坐标的回滚路径
