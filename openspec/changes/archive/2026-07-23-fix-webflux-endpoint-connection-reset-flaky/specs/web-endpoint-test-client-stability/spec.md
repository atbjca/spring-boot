## ADDED Requirements

### Requirement: Web endpoint integration test client resists Connection reset on GET

Web endpoint 集成测试基类创建的 `WebTestClient` MUST 对 GET 请求在发生瞬时连接失败（如 `Connection reset`）时进行有限次自动重试，且 MUST 使用 `localhost` 作为客户端访问地址。

#### Scenario: GET request recovers from transient Connection reset

- **WHEN** 嵌入式 Web endpoint 服务器已启动，且首次 GET 因 reactor-netty 瞬时 `Connection reset` 失败
- **THEN** 客户端 SHALL 自动重试该 GET，并在后续成功响应上完成既有 status/body 断言

#### Scenario: Client targets localhost

- **WHEN** 测试基类为当前随机端口构建 `WebTestClient` base URL
- **THEN** URL SHALL 使用 `http://localhost:<port>...`，而不是通配地址主机（如 `0.0.0.0`）

#### Scenario: Non-GET requests are not retried by the filter

- **WHEN** 测试通过该客户端发送非 GET 请求
- **THEN** 客户端 SHALL 不对该请求应用上述 GET 重试 filter
