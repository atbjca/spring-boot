## Why

`make build` 偶发失败于 `WebFluxEndpointIntegrationTests.principalIsNullWhenRequestHasNoPrincipal`：`WebClientRequestException: Connection reset`。这是 reactor-netty 客户端与短生命周期嵌入式服务器之间的连接竞态，不是业务缺陷，但会阻断本地完整构建。

## What Changes

- 在 `AbstractWebEndpointIntegrationTests` 创建 `WebTestClient` 时对齐同模块已验证的抗 flaky 模式（`WebEndpointTestInvocationContextProvider`）：对 GET 请求加有限次 `retry`，并将 base URL 固定为 `localhost`
- 不改生产代码、不改 Checkstyle 规则、不依赖 `CI=true` TestRetry 作为唯一手段

## Capabilities

### New Capabilities

- `web-endpoint-test-client-stability`: Web endpoint 集成测试客户端在面对 reactor-netty `Connection reset` 时具备稳定的 GET 重试与本机地址绑定，避免偶发失败阻断构建

### Modified Capabilities

- （无）

## Impact

- 受影响文件：`spring-boot-project/spring-boot-actuator/src/test/java/.../AbstractWebEndpointIntegrationTests.java`（及其子类：WebFlux / Servlet / Jersey 等共用基类测试）
- 验证：复跑 `WebFluxEndpointIntegrationTests`（至少含 `principalIsNullWhenRequestHasNoPrincipal`）与相关 actuator endpoint 集成测试应稳定通过
- 无 API / 依赖 / 运行时行为变更
