## Context

`TomcatReactiveWebServerFactoryTests.sslWithValidAlias()` 通过 HTTPS 访问本地 Tomcat SSL 端点，偶发 `PrematureCloseException`。根因推测为 SSL 握手阶段与连接关闭的竞态条件，在高负载或 CI 环境偶发。本变更目标为此 flaky 测试建立稳定的 CI 通过率。

## Goals / Non-Goals

**Goals:**
- 消除 `sslWithValidAlias()` 的 flaky 行为在 `make test` 中导致的误导性失败
- 建立明确的 flaky 测试处置规范（@RepeatedTest 方式）

**Non-Goals:**
- 不修复 SSL 底层问题（上游 Tomcat/Netty 问题）
- 不改动 src/main 代码
- 不涉及其他模块的测试

## Decisions

### 方案：@RepeatedTest(10)

在 `sslWithValidAlias()` 测试方法上用 `@RepeatedTest(10)` 替代默认的 `@Test`。

**理由：**
- JUnit 5 原生支持，无需额外依赖
- 10 次重复在 CI 环境中能以高概率捕获真正的 SSL 握手问题
- 单次运行时间约 0.4s，10 次约 4s，开销可接受
- 若存在真实 SSL 问题，10 次重复会稳定失败，能有效区分 flaky vs 真实缺陷

**替代方案考虑：**
- `@Timeout(30)`：只限制单次运行时间，不解决 flaky
- `@DisabledIf`：完全跳过，无法积累关于该测试的 CI 数据
- 增大 `StepVerifier` timeout：效果有限，不解决连接被关闭的根因

## Risks / Trade-offs

- [Risk] 10 次重复会增加该测试的 CI 运行时间 → Mitigation：可接受（4s 级别），若超时压力明显可降至 5 次
- [Risk] 若 flaky 概率极低，10 次可能仍偶发 → Mitigation：若仍偶发，可考虑加 `@Retry` 或在 Makefile 层面配置重跑
