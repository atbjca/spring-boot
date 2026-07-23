## Context

`AbstractWebEndpointIntegrationTests.load()` 为每个用例启动短生命周期嵌入式服务器，并用 `WebTestClient.bindToServer()` 发请求。失败栈为 `reactor.netty` `Connection reset`，发生在 GET `exchange()`。同模块 `WebEndpointTestInvocationContextProvider` 已对 GET 使用 `retry(10)` 且固定 `http://localhost:`，而本基类尚未对齐。

## Goals / Non-Goals

**Goals:**

- 消除 `WebFluxEndpointIntegrationTests`（及共用基类的其它栈）因 `Connection reset` 导致的偶发失败
- 复用仓库内已验证的 WebTestClient 抗 flaky 模式，改动面最小

**Non-Goals:**

- 不修改 reactor-netty / Netty 版本或生产代码
- 不把 `make build` 默认改为 `CI=true`（那是兜底，不是根治该测试客户端）
- 不引入 `@RepeatedTest` / `@Disabled` 掩盖问题

## Decisions

1. **在基类 `load()` 为 GET 增加 `retry(10)` filter**
   - Rationale：与 `WebEndpointTestInvocationContextProvider#createWebTestClient` 一致；仅重试幂等 GET，避免写操作误重试。
   - Alternative：仅依赖 Gradle TestRetry（需 `CI=true`）— 本地 `make build` 仍会红；用户要求稳定消除。
   - Alternative：`HttpClient.keepAlive(false)` / `ConnectionProvider.newConnection()` — 更“根因”，但偏离同模块既有模式，且需额外 reactor-netty 测试依赖接线；优先对齐现有成功做法。

2. **base URL 使用 `localhost` + port，不再用 `InetSocketAddress(port).getHostString()`**
   - Rationale：仅端口构造的地址主机为 `0.0.0.0`，作客户端 URL 在部分 OS 上不稳定；同模块其它测试已用 `localhost`。
   - Alternative：`127.0.0.1` — 等价；选 `localhost` 与现有测试一致。

## Risks / Trade-offs

- [Risk] GET retry 可能掩盖真实服务端缺陷 → Mitigation：仅对连接层瞬时失败生效；断言仍校验 status/body；真实逻辑错误不会因 retry 变绿。
- [Risk] 增加最坏路径耗时 → Mitigation：仅失败才重试；正常路径无额外成本。
- [Risk] Servlet/Jersey 子类也走同一 `load()` → Mitigation：同类竞态同样受益；行为与 WebEndpoint 另一套 provider 对齐。

## Migration Plan

- 直接合入测试基类修改；无需数据迁移。
- 回滚：还原 `AbstractWebEndpointIntegrationTests` 即可。

## Open Questions

- 无。修复模式已由同模块现有代码确认。
