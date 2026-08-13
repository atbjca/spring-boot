## Context

Spring Boot 2.7 NES 当前处于 `2.7.18-nes.patch.2-SNAPSHOT` 开发线，但 `gradle.properties` 仍将 Spring Security 固定为已发布且不可变的 `5.8.16-nes.patch.1`。根构建已经通过 `resolutionStrategy.eachDependency` 把官方 `org.springframework.security:spring-security-*` 请求映射到 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-*`，`spring-boot-dependencies` 也已经导入 NES Security BOM。Gradle 的 publication version mapping 会把代表性 Security starter 的发布 POM 写成实际解析到的 NES GAV。因此本 change 的核心是推进并验证现有契约，而不是再创建一份 Boot BOM、扩大坐标映射规则或逐模块维护 Security 版本。

Spring Security 维护分支已经推进到 `5.8.16-nes.patch.2-SNAPSHOT`，并完成七项 2026 CVE backport：`CVE-2026-22732`、`CVE-2026-22746`、`CVE-2026-40988`、`CVE-2026-41003`、`CVE-2026-41694`、`CVE-2026-41706`、`CVE-2026-47838`。生产者仓库保存了逐项修复 commit、针对性回归、发布候选 SHA-256、Maven/Gradle 独立消费者和真实 Java 8 运行证据。探索阶段 Boot 强制刷新 Nexus 后解析到的候选为 `5.8.16-nes.patch.2-20260811.065312-1`；该 timestamp 只是当前证据，实施时仍必须重新解析并记录实际选中的 SNAPSHOT，不得依赖缓存或把 timestamp 写成稳定版本号。

使用 patch.2-SNAPSHOT 运行 Boot Security 相关测试时，262 次执行中出现 56 次失败，去除四次重试后是 14 个唯一失败：12 个 OAuth2 resource-server 断言和 2 个 SAML 断言。patch.1 对照运行结果完全相同。根因是 Boot 测试仍引用 Spring Security 5.8 已迁移类的 deprecated 兼容 stub，而实际 filter chain 安装的是新包中的类；已知正确适配分别存在于提交 `bf2b381387c` 和 `541799f4147`。因此这些失败属于既有消费者测试适配缺口，不是 patch.2 的安全回移回归。

依赖图还有一个必须显式处置的边界：Security 的 SAML/Crypto 发布图使用 Java 8 兼容的 Bouncy Castle `jdk18on:1.84`，而 Boot 的 SendGrid `4.9.3` 路径传递引入 `bcprov-jdk15on:1.70`。两个 artifactId 可同时解析，但包含重叠包和类，不能仅因版本冲突解析器未报错就声称依赖图收敛。实现必须通过排除、Java 8 兼容升级或有证据的兼容边界作出明确结论。

`5.8.16-nes.patch.2` RELEASE 和 `v5.8.16-nes.patch.2` tag 当前尚不存在。Boot 开发线可以验证并消费 SNAPSHOT，但现有 `component-release` 规则要求正式 Boot RELEASE 的所有内部依赖均为已批准 RELEASE；本 change 不改变该发布门禁。

## Goals / Non-Goals

**Goals:**

- 将 Boot 开发线的 Spring Security 单点版本推进到 `5.8.16-nes.patch.2-SNAPSHOT`，并保证现有 Gradle 坐标映射、Boot BOM import、starter POM 和 Gradle Module Metadata 一致指向该候选。
- 使用隔离的 Maven/Gradle 消费者验证发布后的 Boot BOM/starter 契约；消费者不得复制 Boot 仓库内部的 `resolutionStrategy`。
- 在真实 Java 8 上验证代表性 Boot Security 消费路径，并复用生产者对 Security artifact、传递安全基线和七项 CVE 的完整 Java 8 证据。
- 恢复 OAuth2 resource-server 和 SAML 测试对 Spring Security 5.8 新 filter 类的正确检查，移除因错误类引用产生的禁用或假失败。
- 对 SendGrid `bcprov-jdk15on:1.70` 与 Security `jdk18on:1.84` 的组合给出可执行、可审计的处置结论。
- 只同步受本次采用事实影响的版本、GAV、升级历史、漏洞台账、CVE 和测试证据；明确区分“安全修复已进入候选”与“patch.2 已正式发布”。

**Non-Goals:**

- 不在 Boot 仓库重复实现或修改七项 Spring Security 漏洞修复，也不复制生产者完整测试矩阵。
- 不创建新的 Boot BOM、不另写一套 Security 模块清单、不重构现有 fork GAV 规则。
- 不在本 change 发布 Spring Security patch.2 RELEASE、创建 tag、部署正式 Boot 制品或绕过 RELEASE-only 门禁。
- 不把 patch.1 的正式发布示例、历史升级记录或归档证据改写成 patch.2。
- 不做与 Bouncy Castle 冲突处置无关的 SendGrid 或第三方依赖升级；如选择 SendGrid 升级，修改范围必须由 Java 8、API 和回归证据限定。
- 默认不把内部 SNAPSHOT 验证扩大为面向用户的试用承诺；`QUICK_START.md` 和 `USER_MANUAL.md` 仅在明确支持该场景时修改。

## Decisions

### D1：只推进 `springSecurityVersion`，复用现有映射和 BOM import

`gradle.properties` 中的 `springSecurityVersion` 继续作为唯一版本源。根构建现有 Security 映射和 `spring-boot-dependencies` 的 NES Security BOM import 使用该属性，无需新增 BOM、模块白名单或另一份版本常量。实现应先用自动断言固定这一关系，再把值从 patch.1 改为 patch.2-SNAPSHOT。

备选方案是在 starter 或各子项目中逐项改成 NES GAV并硬编码版本。该方案会扩大修改面、产生多版本源，并破坏当前“声明官方坐标、解析和发布为 NES 坐标”的统一机制，因此不采用。

### D2：以生成的发布元数据和独立消费者作为真实契约

仓库内 Gradle 依赖图只能证明内部解析规则生效，不能单独证明下游 Maven/Gradle 行为。验证必须覆盖：

1. 生成的 Boot dependency-management POM 导入 `bjca-footstone-bpring-security-bom` patch.2-SNAPSHOT，且不残留 patch.1 Security import。
2. `spring-boot-starter-security`、OAuth2 resource-server/client 等代表性发布 POM和 Gradle Module Metadata使用 NES Security GAV及 patch.2-SNAPSHOT，不重新暴露官方 Security GAV。
3. 将所需 Boot 产物发布到隔离的临时 Maven 仓库后，最小 Maven 和 Gradle 项目仅依靠发布元数据完成解析与 smoke；它们不得复制根构建的坐标替换规则。

备选方案是只检查 `dependencyInsight`。它速度更快，可作为早期反馈，但无法发现声明侧 POM、Gradle metadata 或独立仓库缺失问题，不能作为最终验收。

### D3：SNAPSHOT 必须绑定实际制品，正式发布必须等待 RELEASE

实施时强制刷新 `5.8.16-nes.patch.2-SNAPSHOT`，记录 Nexus 实际 timestamp/build、代表性 POM/JAR SHA-256 和生产者 commit。Boot 文档可以表述为“开发基线已采用并验证 patch.2-SNAPSHOT”，但不得称其为 RELEASE，也不得创建或引用不存在的 patch.2 tag。

正式 Boot RELEASE 前必须由独立 Security release change 生成并验证 `5.8.16-nes.patch.2`，确认 Nexus RELEASE 制品和 `v5.8.16-nes.patch.2` tag，再把 Boot 元数据从 SNAPSHOT 切到 RELEASE并执行现有内部 SNAPSHOT 扫描。将 timestamped SNAPSHOT 当作正式版本或仅凭分支 HEAD 放行均不接受。

### D4：生产者证明修复正确，Boot 证明集成了正确制品

七项 CVE 的补丁正确性、攻击边界和完整 Java 8 模块测试由 Spring Security producer evidence 负责。Boot 不复制这些源码级套件，而是为每项漏洞保留可追溯的 producer commit/test/artifact 引用，并验证：

- 最终发布元数据和运行时图确实选中 patch.2 候选；
- Security servlet、reactive、OAuth2、SAML、X.509 等受影响集成面完成针对性 Boot 回归；
- 代表性 consumer 在真实 Java 8 上加载并执行 Security/Boot smoke；
- CVE 文档区分“修复已进入并验证的候选”与“正式 RELEASE 尚未完成”。

备选方案是在 Boot 重建七套漏洞 PoC。它会重复生产者职责、增加长期维护分叉，且仍不能替代发布元数据验证，因此仅在 Boot 自身适配引入额外行为时增加相应集成测试。

### D5：精确恢复已有的 Spring Security 5.8 测试类迁移

OAuth2 测试必须使用 `org.springframework.security.oauth2.server.resource.web.authentication.BearerTokenAuthenticationFilter`，SAML 测试必须使用 `org.springframework.security.saml2.provider.service.web.authentication.Saml2WebSsoAuthenticationFilter`。实现仅移植 `bf2b381387c` 和 `541799f4147` 中相关测试文件的有效改动，不带入这些历史提交里的旧 OpenSpec 或其他无关文件。

patch.1 与 patch.2 对照失败相同，证明修复的是 Boot 测试观察方式。不得通过继续 `@Disabled`、断言旧 stub 或把 filter 缺失写成预期结果来获得绿色门禁。

### D6：Bouncy Castle 采用证据驱动的单独决策门禁

实现先建立同时包含 SendGrid 和 Security SAML/Crypto 的 Maven/Gradle 组合图及运行 smoke，再按以下顺序选择最小安全方案：

1. 若 Java 8 兼容的 SendGrid 小版本可原生使用 `jdk18on`，且 API、自动配置和邮件客户端 smoke 通过，可升级并统一到 Security 已验证的 BC 1.84 family。
2. 否则，仅当 SendGrid 在排除 `bcprov-jdk15on` 并使用显式 `jdk18on` 后独立和组合 smoke 均通过时，采用排除/替代方案。
3. 若两者都缺少充分证据，则保留现状但明确记录双 provider family、重叠类风险、受支持组合和回滚方式；此时任何依赖图或文档都不得声称 BC 已收敛。

直接依赖版本号比较不能解决不同 artifactId 的重复类问题；全局强制替换也可能破坏不含 SAML 的 SendGrid 用户。因此最终选择必须写入构建元数据、测试证据和文档，不能只停留在解释文字。

### D7：文档同步按事实影响面执行

必须同步当前 Security 开发版本/GAV、组件升级历史、七项 CVE 页面与漏洞总表、需求和实际测试证据。patch.1 RELEASE 示例和归档记录保持不变。若本 change 只建立内部候选验证，不承诺用户直接消费 SNAPSHOT，则不修改 `QUICK_START.md` 和 `USER_MANUAL.md`；只有明确增加试用支持时，才补充仓库配置、刷新策略、风险和回滚说明。

备选方案是全仓替换 patch.1 文本。该方案会篡改历史发布事实并把开发候选误写为正式版本，因此不采用。

### D8：验证顺序先发布契约，再集成回归，最后标准门禁

实现先增加能在 patch.1 基线上失败的版本、BOM/POM/metadata 和依赖图断言，再推进版本并观察转绿；随后修复两个测试类迁移，完成 Security 针对性测试、BC 决策、独立消费者和 Java 8 验证；最后执行仓库标准 build/test 门禁及严格 OpenSpec 校验。网络/私服故障必须与代码失败分开记录，未执行的门禁不得写成通过。

## Risks / Trade-offs

- [SNAPSHOT 缓存命中旧制品] → 强制刷新并记录 timestamp、SHA-256、生产者 commit；消费者使用隔离缓存/仓库。
- [Boot BOM 正确但 starter POM 仍嵌入 patch.1] → 对代表性 starter POM和 Gradle metadata逐项断言，不只检查 BOM property。
- [Maven 消费者无法复用 Gradle 映射] → 消费隔离发布仓库中的真实 Boot BOM/starter，禁止复制 `resolutionStrategy`。
- [把既有 14 个测试失败误判为 patch.2 回归] → 保留 patch.1 对照证据并应用已知类迁移；修复后在 patch.2 上重跑相同测试。
- [Boot 重复生产者安全测试仍遗漏错误制品] → 生产者负责漏洞算法，Boot 优先验证坐标、制品身份、Java 8 和集成路径。
- [BC `jdk15on` 与 `jdk18on` 重叠类导致类路径顺序风险] → 用组合消费者和行为 smoke 选择升级、替代或明确的不收敛边界。
- [SendGrid 升级扩大范围] → 只评估最小 Java 8 兼容版本，要求自动配置/API 回归；证据不足则不升级。
- [文档把候选写成 RELEASE] → 使用双层状态：修复候选已验证、正式发布待 Security release；全仓审计 patch.2/tag/RELEASE措辞。
- [正式 Boot release 携带内部 SNAPSHOT] → 复用 `component-release` 的 RELEASE-only metadata gate，Security patch.2 RELEASE/tag 未验证时禁止放行。
- [测试耗时或 Nexus 波动] → 快速元数据断言和针对性测试优先，标准门禁最后执行；保存命令、退出码和环境事实。

## Migration Plan

1. 复核分支、HEAD、tracked/untracked 状态和当前 active changes，隔离用户已有工作。
2. 强制刷新 Security patch.2-SNAPSHOT，记录实际 timestamp、POM/JAR hash、producer commit、七项 CVE evidence 和 Java 8 producer gate。
3. 先增加版本单点、Boot BOM import、starter POM/Gradle metadata 及依赖图断言，并在 patch.1 基线上记录预期失败。
4. 仅修改 `springSecurityVersion` 到 patch.2-SNAPSHOT，重新生成元数据并使发布契约断言转绿。
5. 移植两个已知测试类迁移，运行 OAuth2、SAML 及其他受影响 Security integration tests。
6. 建立 SendGrid + Security 组合消费者，选择并实现 BC 处置，记录最终图和行为证据。
7. 发布 Boot 候选到隔离本地仓库，在真实 Java 8 上运行 Maven/Gradle 独立消费者，再执行项目标准 build/test 门禁。
8. 按事实范围同步文档，运行严格 OpenSpec、版本冲突、生成元数据和 Git diff 审计。

回滚时将 `springSecurityVersion` 恢复为不可变的 `5.8.16-nes.patch.1`，撤销两个仅为 5.8 正确类路径服务的测试改动及本 change 选择的 BC 调整，重新生成 BOM/POM/metadata并用独立消费者确认 patch.1 恢复。文档随实际运行基线回滚，但保留本 change 的探索和失败证据；不得删除或覆盖任何已发布 patch.1 制品。

## Open Questions

- SendGrid 路径最终采用 Java 8 兼容小版本升级、`jdk15on` 排除/替代，还是明确的不收敛支持边界，必须由实施阶段的独立与组合 smoke 决定。
