## Why

`add-makefile-test-target` 完成后，`make test` 在 `spring-boot` 主模块的 `web.embedded.{tomcat,jetty,undertow}.*ServletWebServerFactoryTests` 整组（约 369 条用例）持续失败。stack trace 指向 `DirtiesUrlFactoriesExtension` 通过反射访问 `java.net.URLStreamHandlerFactory`，被 Java 17 JPMS 拒绝（`InaccessibleObjectException`）。这一组失败属于 D 类"环境/JPMS"，无法通过修改测试断言消除 —— 必须给执行该模块测试的 JVM 传 `--add-opens=java.base/java.net=ALL-UNNAMED`。

## What Changes

- 修改 `spring-boot-project/spring-boot/build.gradle`：为 `tasks.named('test')` 增加 `jvmArgs '--add-opens=java.base/java.net=ALL-UNNAMED'`（精确位置和写法在 design 阶段确认）。
- 验证：`make test` 后 spring-boot 主模块的 `*ServletWebServerFactoryTests` 整组从失败转为通过；其它模块行为不变。
- 更新 `make-test-target` capability 的 spec：在"已知失败分类"中删除 D 类条目，对应残留数字下调约 369 条。
- 更新归档变更里的 `EXECUTION_NOTES.md` 引用或在新变更里补充对比表（实施阶段决定）。

## Capabilities

### New Capabilities
<!-- 无 -->

### Modified Capabilities
- `make-test-target`：D 类失败被消除后，"承诺范围"与"已知失败分类"段落需要同步更新。

## Impact

- 受影响文件：`spring-boot-project/spring-boot/build.gradle`。
- 不影响 fork 其它源码、Makefile、其它模块的 build 脚本。
- 风险：`--add-opens` 是 JVM 启动参数，可能影响 `test` 任务的子进程行为；按上游同类型修复经验风险较低。
