## 1. 前置状态与生产者证据

- [x] 1.1 复核当前分支、HEAD、tracked/untracked 状态和 active OpenSpec changes，记录并隔离所有不属于本 change 的用户文件，不执行清理、覆盖或顺带修改
- [x] 1.2 核对 Spring Security producer 的分支、HEAD 和 `5.8.16-nes.patch.2-SNAPSHOT` 版本，并确认 `5.8.16-nes.patch.2` RELEASE 与 `v5.8.16-nes.patch.2` tag 的实际状态；若发布状态已变化，先更新本 change 的设计与规格再继续
- [x] 1.3 使用禁用旧缓存的隔离解析环境强制刷新 patch.2-SNAPSHOT，记录实际 Nexus timestamp/build、代表性 BOM/POM/JAR SHA-256 和解析仓库，不把探索阶段 timestamp 当作固定版本
- [x] 1.4 汇总七项 CVE 的 producer 修复 commit、producer 回归 commit/命令、候选 artifact 身份和 Java 8 Maven/Gradle consumer 证据，形成可供 Boot 文档逐项引用的证据表
- [x] 1.5 保存 patch.1 与 patch.2 在测试适配前出现相同 12 个 OAuth2 和 2 个 SAML 唯一失败的对照证据，明确区分唯一失败数与重试后的执行失败数

## 2. TDD：建立版本、发布元数据与解析契约

- [x] 2.1 调研并选用仓库现有 buildSrc BOM/POM 测试、publication 测试或验证脚本模式，不引入新的测试框架、依赖管理插件或重复发布机制
- [x] 2.2 先增加 `springSecurityVersion` 单点驱动官方到 NES Security 映射的自动断言，并在 patch.1 基线上运行记录对 patch.2 目标的预期失败
- [x] 2.3 先增加生成 Boot dependency-management POM 的断言：必须 import patch.2-SNAPSHOT NES Security BOM、不得残留 patch.1 import 或新增第二份 Boot BOM；运行记录预期失败
- [x] 2.4 先增加 `spring-boot-starter-security` 和代表性 OAuth2 starter 的 Maven POM/Gradle Module Metadata 断言：必须使用 patch.2 NES GAV、不得使用官方 Security GAV 或 patch.1；运行记录预期失败
- [x] 2.5 先增加代表性 compile/runtime graph 断言：不得同时出现官方 Spring Security、NES patch.1 和 NES patch.2 实现；运行记录修改前结果
- [x] 2.6 复核新增验证的每个版本判断、坐标判断和禁止项均有可执行断言覆盖，并记录简单声明不适用算法覆盖率的理由

## 3. 采用 patch.2 并恢复 Spring Security 5.8 测试适配

- [x] 3.1 仅将 `gradle.properties` 的 `springSecurityVersion` 推进为 `5.8.16-nes.patch.2-SNAPSHOT`，保留现有根映射规则和现有 Security BOM import 结构
- [x] 3.2 重新生成 Boot BOM、代表性 starter POM 和 Gradle Module Metadata，运行 2.2—2.5 的断言并确认由红转绿，逐项确认无 patch.1 或官方 Security 残留
- [x] 3.3 仅移植 `bf2b381387c` 中 `OAuth2ResourceServerAutoConfigurationTests` 的有效改动，使用新包 `BearerTokenAuthenticationFilter` 并恢复 12 个被错误禁用的测试，不带入历史 OpenSpec 或无关文件
- [x] 3.4 仅移植 `541799f4147` 中 `Saml2RelyingPartyAutoConfigurationTests` 的有效改动，使用新包 `Saml2WebSsoAuthenticationFilter` 并保留解释类迁移原因的必要注释
- [x] 3.5 运行 OAuth2 resource-server 和 SAML2 目标测试类，确认 filter chain 断言检查实际安装的 Spring Security 5.8 filter实例且全部通过
- [x] 3.6 运行 servlet、reactive、OAuth2 client/resource server、SAML2、X.509 和通用 Security auto-configuration 的代表性 Boot 测试；任何新增失败必须定位，禁止通过 `@Disabled`、宽泛排除或降低断言隐藏

## 4. Bouncy Castle 组合图决策

- [x] 4.1 建立同时包含 SendGrid `4.9.3` 和 Security SAML/Crypto 的 Maven 与 Gradle 组合依赖图，证明当前 `bcprov-jdk15on:1.70` 与 `jdk18on:1.84` 的实际共存路径和重叠类风险
- [x] 4.2 评估最小 Java 8 兼容 SendGrid 小版本升级方案，检查其 POM 是否原生使用 `jdk18on`，并验证 API、SendGrid auto-configuration 和最小邮件客户端行为
- [x] 4.3 若不采用 SendGrid 升级，评估从 SendGrid 排除 `bcprov-jdk15on` 并显式使用 Security 已验证 `jdk18on:1.84` 的方案，分别运行 SendGrid 独立 smoke 与 SendGrid + SAML/Crypto 组合 smoke
- [x] 4.4 基于 4.2 和 4.3 的 Java 8、API、依赖图和行为证据选择且记录唯一处置：小版本升级、排除/替代，或明确的不收敛兼容边界；证据不足时不得声称收敛
- [x] 4.5 实施所选的最小构建/依赖管理调整；若选择兼容边界则保持构建图事实不变，并在自动检查中显式报告双 provider family 而不是静默放行
- [x] 4.6 为最终处置增加可重复的 Maven/Gradle 图断言和 Java 8 行为 smoke，确认结论同时覆盖 SendGrid 与 Security SAML/Crypto

## 5. 独立消费者与 Java 8 发布验证

- [x] 5.1 将 Boot dependency-management、Security starter、代表性 OAuth2 starter及其所需 Boot 模块发布到隔离的临时 Maven 仓库，确保验证不依赖用户 `~/.m2` 中的同版本旧制品
- [x] 5.2 创建或复用最小 Maven consumer，导入发布后的 Boot BOM并消费 Security starter、代表性 OAuth2/SAML 路径；consumer 不得复制 Boot 根构建的 `resolutionStrategy` 或源码 substitution
- [x] 5.3 创建或复用最小 Gradle consumer，从同一隔离仓库消费 Boot platform和相同 Security 路径；consumer 不得使用仓库内部坐标映射规则
- [x] 5.4 在真实 Java 8 上运行 Maven 和 Gradle consumers，执行 Security、OAuth2、SAML/OpenSAML 和 Bouncy Castle 代表性类加载/行为 smoke，确认无 class-version、linkage 或 provider 错误
- [x] 5.5 比较两个 consumer 的关键依赖树，确认只存在 patch.2-SNAPSHOT NES Security，Security/SAML/Crypto/BC 版本和 4.4 的处置结论一致，且无 patch.1 或官方 Security 实现
- [x] 5.6 检查代表性 Boot、Security、SAML 和 Crypto 主 artifact 的 class major 不高于 52，并保存 Java 8 runtime identity、解析树、命令、退出码、timestamp和 SHA-256 证据

## 6. 安全状态与范围化文档同步

- [x] 6.1 更新 `doc/REQUIREMENTS.md` 中当前 Spring Security 采用范围，移除“本次不处理 Security”的过期当前结论，并记录现有 BOM契约、Java 8、BC 决策和正式 RELEASE 门禁
- [x] 6.2 更新 `doc/COMPONENTS_UPGRADE_HISTORY.md`，登记 patch.1 RELEASE 到 patch.2-SNAPSHOT 开发候选的采用事实，同时保留 patch.1 不可变发布历史
- [x] 6.3 更新 `doc/NES_GAV_MAPPING.md` 与 `doc/GAV_MAPPING.md` 中表示当前开发基线的 Security 版本/GAV；逐项保留正式发布示例、回滚目标和历史上下文中的 patch.1
- [x] 6.4 更新 `doc/VULNERABILITY_REPORT.md`，为七项 CVE 登记 producer evidence、Boot 候选状态和 RELEASE 未完成边界，并从最终表格重新计算所有状态总数
- [x] 6.5 更新现有 `doc/CVE/CVE-2026-22732.md`，并为 `CVE-2026-22746`、`CVE-2026-40988`、`CVE-2026-41003`、`CVE-2026-41694`、`CVE-2026-41706`、`CVE-2026-47838` 创建独立记录，逐项包含受影响范围、修复线、producer commit/test、候选制品、Java 8 和最终状态
- [x] 6.6 按实际执行命令和结果更新 `doc/TESTING.md`，记录 patch.1 对照、patch.2 针对性测试、发布元数据、Maven/Gradle Java 8 consumers和 BC 结论；未执行或受环境阻塞的门禁不得写成通过
- [x] 6.7 审计 `doc/QUICK_START.md` 和 `doc/USER_MANUAL.md`；默认不修改 patch.1 RELEASE 示例，只有明确支持用户试用 patch.2-SNAPSHOT 时才补充 SNAPSHOT 仓库、刷新、非 RELEASE 状态、BC 边界和回滚说明
- [x] 6.8 全仓搜索七项 CVE、patch.1、patch.2、Security BOM和 BC family，消除当前事实冲突，同时确认 `openspec/changes/archive/**` 和历史发布证据未被改写

## 7. 完整门禁与交付复核

- [x] 7.1 运行全部新增版本、BOM/POM/Gradle metadata、依赖图和独立 consumer 自动检查，确认在最终实现上稳定通过
- [x] 7.2 重新运行受影响 Security auto-configuration 目标测试，确认 OAuth2 12 个和 SAML 2 个既有失败已闭合，其他 Security 集成无本 change 引入的未解决失败
- [x] 7.3 运行仓库稳定门禁 `make build`，记录环境、命令、退出码和任何与本 change 无关的既有问题，不把未通过门禁描述为成功
- [x] 7.4 执行 `openspec validate adopt-spring-security-patch-2-security-baseline --strict`，修复全部规格格式、场景或一致性错误
- [x] 7.5 复核生成的 RELEASE/SNAPSHOT 元数据、Git diff和 `git status`，确认只包含批准范围文件、无构建产物或用户工具目录，并确认正式 Boot RELEASE仍会被 Security patch.2-SNAPSHOT 阻断
- [x] 7.6 汇报实现文件、测试与 Java 8 证据、七项 CVE 状态、BC 最终处置、实际 SNAPSHOT身份、回滚路径及“Security patch.2 RELEASE/tag 完成前不得正式发布 Boot”的剩余门禁
