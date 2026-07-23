## 1. Harden WebTestClient in base class

- [x] 1.1 将 `AbstractWebEndpointIntegrationTests.load()` 的 base URL 改为 `http://localhost:<port><endpointPath>`
- [x] 1.2 为 `WebTestClient` 增加与 `WebEndpointTestInvocationContextProvider` 一致的 GET `retry(10)` filter（需补 `HttpMethod` import）

## 2. Verify

- [x] 2.1 运行 `:spring-boot-project:spring-boot-actuator:test --tests '*WebFluxEndpointIntegrationTests*'`，确认通过
- [x] 2.2 单独复跑 `principalIsNullWhenRequestHasNoPrincipal`，确认通过
