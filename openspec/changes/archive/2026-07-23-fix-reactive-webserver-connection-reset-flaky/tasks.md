## 1. Harden getWebClient

- [x] 1.1 `getWebClient` 使用 `http://localhost:<port>`，移除 `InetSocketAddress` 通配主机
- [x] 1.2 为 GET 增加 `retry(10)` filter，并补充 `HttpMethod` import

## 2. Verify

- [x] 2.1 复跑 `Jetty10ReactiveWebServerFactoryTests.noCompressionForResponseWithInvalidContentType`
- [x] 2.2 复跑 `Jetty10ReactiveWebServerFactoryTests` 整类（或压缩相关用例）确认通过
