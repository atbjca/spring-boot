## Context

`AbstractReactiveWebServerFactoryTests.getWebClient` 被 Jetty/Tomcat/Netty/Undertow（含 Jetty10）压缩等用例共用。失败为 GET 上 `Connection reset`；基类此前用 `new InetSocketAddress(port).getHostString()`（常为 `0.0.0.0`）且无重试。已在 actuator `AbstractWebEndpointIntegrationTests` 验证 `localhost` + GET `retry(10)` 有效。

## Goals / Non-Goals

**Goals:**

- 稳定消除该类 reactive 工厂测试的 GET `Connection reset` 偶发失败
- 与 actuator 侧抗 flaky 模式保持一致

**Non-Goals:**

- 不改 Jetty/Netty 版本或生产工厂代码
- 不依赖仅 `CI=true` TestRetry

## Decisions

1. **在 `getWebClient(HttpClient, int)` 统一加 localhost + GET retry(10)**
   - Rationale：所有走该入口的用例（含 `prepareCompressionTest`）一并受益；与 `WebEndpointTestInvocationContextProvider` / 已修 actuator 基类一致。
   - Alternative：只给 `noCompressionForResponseWithInvalidContentType` 加重试 — 覆盖面不足。

## Risks / Trade-offs

- [Risk] GET retry 掩盖真实缺陷 → Mitigation：仅瞬时连接错误重试；断言仍校验压缩头/状态码。
- [Risk] 直接构造 `WebClient.builder()` 的 SSL 等路径未改 → Mitigation：那些路径多数已用 `https://localhost`；本次失败点走 `getWebClient`。

## Migration Plan

- 直接合入测试基类修改。回滚即还原该文件。

## Open Questions

- 无。
