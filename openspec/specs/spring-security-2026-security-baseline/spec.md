# spring-security-2026-security-baseline Specification

## Purpose
TBD - created by archiving change adopt-spring-security-patch-2-security-baseline. Update Purpose after archive.
## Requirements
### Requirement: The seven 2026 Spring Security CVE dispositions SHALL be evidence-backed
Boot 的安全基线 SHALL 对 `CVE-2026-22732`、`CVE-2026-22746`、`CVE-2026-40988`、`CVE-2026-41003`、`CVE-2026-41694`、`CVE-2026-41706` 和 `CVE-2026-47838` 分别记录生产者修复 commit、针对性测试、已解析候选制品和 Java 8 证据。采用 NES GAV 或只修改版本字符串 MUST NOT 自动将漏洞标记为已修复。

#### Scenario: Producer and artifact evidence agree
- **WHEN** 某项 CVE 的生产者补丁、回归测试、patch.2 候选 POM/JAR身份和 Java 8 gate均可追溯且一致
- **THEN** Boot 文档 MAY 将该漏洞记录为“修复已进入并验证的 patch.2 候选”
- **AND** MUST 同时标明 Security patch.2 正式 RELEASE 是否已经完成

#### Scenario: Any evidence link is missing or mismatched
- **WHEN** 某项 CVE 缺少修复 commit、回归结果、候选制品身份或 Java 8 证据中的任一项
- **THEN** 该漏洞 MUST 保持未闭环、待验证或等价状态
- **AND** Boot 正式发布材料 MUST NOT 宣称该项已修复

#### Scenario: All seven records are audited
- **WHEN** 本 change 准备完成
- **THEN** 漏洞总表和七项独立 CVE 记录 MUST 一一对应且无遗漏
- **AND** 受影响版本、修复线、producer evidence和 Boot 最终状态 MUST 相互一致

### Requirement: Boot SHALL perform proportional integration regression for the Security candidate
Boot SHALL 验证 patch.2 候选在 servlet、reactive、OAuth2 resource server/client、SAML2、X.509 和通用 Security auto-configuration 相关路径的集成兼容性。Boot MAY 复用生产者的漏洞算法测试，但 MUST 运行能证明自身自动配置、filter chain观察、发布元数据和运行 classpath 正确的针对性回归。

#### Scenario: Affected Boot Security tests run
- **WHEN** patch.2 候选进入 Boot 测试图
- **THEN** 受影响的 Security auto-configuration、OAuth2、SAML2、reactive和 X.509 代表性测试 MUST 无由版本采用或 classpath 错配造成的失败

#### Scenario: Producer suite already proves the vulnerability behavior
- **WHEN** 某项漏洞的完整攻击边界和修复回归已由 Security producer gate覆盖
- **THEN** Boot MAY 引用该证据而不复制完整 PoC 套件
- **AND** Boot MUST 仍证明所消费制品和 producer evidence是同一候选

#### Scenario: A Boot-specific regression is discovered
- **WHEN** Security 修复改变了 Boot 自动配置、filter chain、属性绑定或启动行为
- **THEN** Boot MUST 增加对应的本仓库回归测试并在修复前观察失败
- **AND** producer 测试通过 MUST NOT 被用来忽略该消费者回归

### Requirement: Spring Security 5.8 filter package migrations SHALL be reflected in Boot tests
Boot 的 OAuth2 resource-server 和 SAML2 测试 SHALL 检查 Spring Security 5.8 实际安装的新包 filter 类，而不是 deprecated 兼容 stub。相关测试 MUST 保持启用，并 MUST 验证真实 `SecurityFilterChain` 中存在目标 filter。

#### Scenario: OAuth2 resource-server filter chain is inspected
- **WHEN** 测试检查 bearer token resource-server 自动配置
- **THEN** 它 MUST 使用 `org.springframework.security.oauth2.server.resource.web.authentication.BearerTokenAuthenticationFilter`
- **AND** 相关 12 个测试 MUST NOT 因旧包类匹配失败而被禁用或误报 filter 缺失

#### Scenario: SAML2 filter chain is inspected
- **WHEN** 测试检查 SAML2 relying-party 自动配置
- **THEN** 它 MUST 使用 `org.springframework.security.saml2.provider.service.web.authentication.Saml2WebSsoAuthenticationFilter`
- **AND** 相关 chain 测试 MUST 匹配实际安装的 filter实例

#### Scenario: Patch.1 control and patch.2 candidate fail identically before adaptation
- **WHEN** 对照证据显示两个版本因相同旧包 import 产生同一组失败
- **THEN** 该问题 SHALL 归类为既有 Boot 测试适配缺口而非 patch.2 安全回移回归
- **AND** 修复后 MUST 在 patch.2 候选上重跑并通过相同测试

### Requirement: Security verification SHALL not normalize vulnerable or unverified behavior
测试和文档 MUST NOT 通过永久禁用安全用例、断言漏洞存在、忽略失败或把未验证候选写成 RELEASE来制造绿色状态。任何未闭环风险 SHALL 以明确状态、限制和后续门禁管理。

#### Scenario: A security-related test fails after adoption
- **WHEN** 失败无法由已证明的旧类迁移、环境故障或其他既有基线解释
- **THEN** 候选验收 MUST 暂停并定位根因
- **AND** 失败 MUST NOT 通过新增 `@Disabled`、宽泛排除或降低断言来隐藏

#### Scenario: Formal release evidence is absent
- **WHEN** patch.2 RELEASE制品或 tag尚未完成
- **THEN** 安全状态 MUST 使用“候选已验证、正式发布待完成”或等价措辞
- **AND** MUST NOT 使用“patch.2 RELEASE 已发布”或等价结论

### Requirement: Affected Security documentation SHALL remain scoped and internally consistent
当前版本/GAV、组件升级历史、需求、安全总表、七项 CVE 页面和实际测试证据 SHALL 与最终解析图一致。patch.1 正式发布示例和归档证据 MUST 保留。面向用户的 Quick Start/User Manual 只有在明确支持 SNAPSHOT 试用消费时才 SHALL 更新。

#### Scenario: Mandatory factual documentation is synchronized
- **WHEN** Boot 已采用并验证 patch.2 候选
- **THEN** 当前 Security 版本/GAV、组件升级历史、需求、漏洞总表、七项 CVE 记录和测试证据 MUST 反映实际候选与验证结果
- **AND** 漏洞状态总数 MUST 从最终表格重新计算而非基于旧总数递增

#### Scenario: Historical patch.1 examples are audited
- **WHEN** 文档搜索到 `5.8.16-nes.patch.1`
- **THEN** 属于已发布版本、回滚目标或历史证据的引用 MUST 保留并标明上下文
- **AND** 只有错误表示当前开发基线的引用 SHALL 改为 patch.2-SNAPSHOT

#### Scenario: User-facing SNAPSHOT trial is not supported
- **WHEN** 本 change 仅建立内部构建和独立验证 fixture，不承诺用户直接试用 SNAPSHOT
- **THEN** `QUICK_START.md` 和 `USER_MANUAL.md` MUST NOT 因全仓替换而改写 patch.1 RELEASE 示例

#### Scenario: User-facing SNAPSHOT trial is explicitly supported
- **WHEN** 实施决定向用户提供 patch.2-SNAPSHOT 试用步骤
- **THEN** Quick Start/User Manual MUST 同时说明 SNAPSHOT 仓库、强制刷新、非 RELEASE 状态、Java 8 证据、已知 BC 边界和回滚到 patch.1 的方法
