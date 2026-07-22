# reactor-netty-security-baseline Specification

## Purpose
TBD - created by archiving change adopt-nes-reactor-netty. Update Purpose after archive.
## Requirements
### Requirement: Reactor Netty vulnerability status SHALL follow patch evidence
Reactor Netty 本体 CVE 的状态 SHALL 由实际源码补丁、可执行回归测试和已发布制品共同决定。采用 NES GAV 或提高传递 Netty 版本 MUST NOT 自动把 Reactor Netty 本体漏洞标为已修复。

#### Scenario: Fork lacks redirect credential patch
- **WHEN** `1.0.48-nes.patch.1-SNAPSHOT` 尚未包含 `CVE-2025-22227` 或 `CVE-2026-41715` 的完整修复和回归测试
- **THEN** 对应漏洞 MUST 保持“修复中”或等价未闭环状态

#### Scenario: Future fork claims the vulnerabilities are fixed
- **WHEN** 后续 change 准备把任一重定向凭据漏洞改为“已修复”
- **THEN** change MUST 提供修复 commit、跨 origin/跨 scheme 重定向测试及重新发布制品的证据

### Requirement: Redirect credential assessment SHALL cover security boundaries
重定向凭据安全评估 SHALL 至少覆盖同 origin、跨 host/port、链式重定向以及 HTTPS 到 HTTP 协议降级边界，并分别考虑 `Authorization` 与 `Proxy-Authorization`。

#### Scenario: Cross-origin redirect is assessed
- **WHEN** HTTP 客户端携带敏感认证头跟随跨 host 或跨 port 重定向
- **THEN** 安全文档和修复测试 MUST 明确验证敏感头不会发送到不可信目标

#### Scenario: Scheme downgrade redirect is assessed
- **WHEN** HTTPS 请求被重定向到 HTTP
- **THEN** 安全文档和修复测试 MUST 明确验证认证凭据不会经明文降级连接泄露

### Requirement: Netty transitive CVEs SHALL be separated from Reactor Netty CVEs
漏洞台账 SHALL 将 `io.netty:*` 传递依赖漏洞与 `reactor-netty-http` 本体漏洞分开记录，并按各自的受影响版本和修复证据定性。

#### Scenario: Netty 4.1.136 is selected
- **WHEN** Spring Boot 的最终依赖图统一解析到 Netty `4.1.136.Final`
- **THEN** 仅修复线不高于 4.1.136 且有可靠映射证据的 Netty CVE SHALL 标记为已修复

#### Scenario: Reactor Netty remains at the 1.0.48 fork baseline
- **WHEN** Netty 已升级但 Reactor Netty 本体仍基于 1.0.48 且缺少重定向补丁
- **THEN** Netty CVE 的闭环 MUST NOT 改变重定向凭据 CVE 的未闭环状态

### Requirement: Security documentation SHALL stay internally consistent
`VULNERABILITY_REPORT.md`、独立 CVE 文档、需求文档和组件升级历史 SHALL 对 Reactor Netty 版本、Netty 版本、修复线和最终状态保持一致，不得同时出现“已修复”与“修复中”的冲突结论。

#### Scenario: Documentation audit is performed
- **WHEN** change 准备完成或归档
- **THEN** 自动搜索和人工复核 MUST 确认 `CVE-2025-22227`、`CVE-2026-41715` 以及 Netty 4.1.136 的状态在所有台账中一致

### Requirement: Security validation SHALL not normalize a known vulnerability
测试不得通过断言漏洞存在、永久禁用安全用例或忽略失败来制造绿色门禁。当前 fork 未修复的安全缺口 SHALL 通过台账、已知限制和后续独立 change 管理。

#### Scenario: Current fork demonstrates vulnerable behavior
- **WHEN** 探索性安全验证证明当前 fork 仍会泄露重定向凭据
- **THEN** 结果 MUST 作为风险证据记录，且 MUST NOT 以“预期泄露”为断言加入永久回归套件
