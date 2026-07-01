## Why

`TomcatReactiveWebServerFactoryTests.sslWithValidAlias()` 在 `make test` 中偶发失败，错误为 `PrematureCloseException: Connection prematurely closed BEFORE response`。测试通过 HTTPS 访问本地启动的 Tomcat SSL 端点，偶尔在 SSL 握手或连接建立阶段被异常关闭。这是典型的 E 类 flaky 测试，不影响真实功能但影响 CI 稳定性。

## What Changes

- 调查 `sslWithValidAlias()` 的 flaky 根因（SSL 握手时序问题或连接关闭竞态）
- 确定修复方案：在测试类级别加 `@RepeatedTest(10)` 以在 CI 环境捕获不稳定，或调整 SSL 连接 timeout
- 更新 `make-test-target` capability spec：将此 flaky 条目从"未知失败"移入"已知 flaky 分类"，说明已用 `@RepeatedTest` 处置

## Capabilities

### New Capabilities
<!-- 无 -->

### Modified Capabilities
- `make-test-target`：E 类 flaky 条目 `sslWithValidAlias` 已定位并处置，"已知失败分类"段落更新

## Impact

- 受影响文件：`spring-boot-project/spring-boot/src/test/java/org/springframework/boot/web/embedded/tomcat/TomcatReactiveWebServerFactoryTests.java`
- 不影响其它模块、src/main 或 build 配置
- 风险：@RepeatedTest 会增加 CI 运行时间（约 10× 单测时间），但可接受
