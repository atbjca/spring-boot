## Why

`make build` / `:spring-boot:test` 偶发失败于 `Jetty10ReactiveWebServerFactoryTests.noCompressionForResponseWithInvalidContentType`：`WebClientRequestException` / `SocketException: Connection reset`。与此前 actuator WebFlux endpoint 同类：reactor-netty 客户端 + 短生命周期嵌入式服务器竞态，且基类 `getWebClient` 仍用 `0.0.0.0` 主机、无 GET 重试。

## What Changes

- 在 `AbstractReactiveWebServerFactoryTests.getWebClient` 对齐已验证模式：`localhost` + GET `retry(10)`
- 覆盖 Jetty / Jetty10 / Tomcat / Netty / Undertow 等共用该基类的压缩与 HTTP 客户端用例

## Capabilities

### New Capabilities

- `reactive-webserver-test-client-stability`: Reactive WebServer 工厂集成测试客户端对 GET 瞬时 `Connection reset` 具备有限重试，并固定本机地址

### Modified Capabilities

- （无）

## Impact

- 文件：`spring-boot-project/spring-boot/src/test/java/.../AbstractReactiveWebServerFactoryTests.java`
- 验证：`Jetty10ReactiveWebServerFactoryTests.noCompressionForResponseWithInvalidContentType` 及同基类压缩相关 GET 用例
- 无生产代码 / API 变更
