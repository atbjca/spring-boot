## Why

`make clean build`（等价于 `make build`，其依赖已含 `clean`）当前在 Checkstyle 阶段失败，阻塞本地编译打包与发布流水线。失败来自近期 Tomcat / Reactor 相关改动引入的 import 顺序与 Javadoc 风格违规，需尽快清掉以便恢复可构建状态。

## What Changes

- 修正 `TomcatReactiveWebServerFactoryTests` 的 import 顺序与分组（`SpringImportOrder`）
- 修正 `TomcatServletWebServerFactory` 中 `LoaderHidingWebResourceSet` 的 Javadoc 首句句号（`JavadocStyle`）
- 不改运行时行为、API 或依赖版本

## Capabilities

### New Capabilities

- `make-build-checkstyle`: 保证 `make build` 路径上 spring-boot 模块的 Checkstyle（main/test）可通过，恢复 clean build 绿灯

### Modified Capabilities

- （无）本次仅修复既有代码风格违规，不改变既有 capability 的需求语义

## Impact

- 受影响文件：
  - `spring-boot-project/spring-boot/src/test/java/.../TomcatReactiveWebServerFactoryTests.java`
  - `spring-boot-project/spring-boot/src/main/java/.../TomcatServletWebServerFactory.java`
- 验证：`make build`（或至少 `:spring-boot-project:spring-boot:checkstyleMain` / `checkstyleTest`）应通过
- 无 API / 依赖 / 行为变更
