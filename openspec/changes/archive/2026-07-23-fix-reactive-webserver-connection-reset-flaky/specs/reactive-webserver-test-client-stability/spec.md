## ADDED Requirements

### Requirement: Reactive web server factory test client resists Connection reset on GET

`AbstractReactiveWebServerFactoryTests` 创建的 `WebClient` MUST 对 GET 在瞬时连接失败时有限重试，且 MUST 使用 `localhost` 作为 base URL 主机。

#### Scenario: Compression GET recovers from Connection reset

- **WHEN** Jetty10（或其它共用基类的）压缩相关 GET 首次因 `Connection reset` 失败
- **THEN** 客户端 SHALL 自动重试并完成既有压缩断言

#### Scenario: Client targets localhost

- **WHEN** `getWebClient` 为随机端口构建 base URL
- **THEN** URL SHALL 为 `http://localhost:<port>`
