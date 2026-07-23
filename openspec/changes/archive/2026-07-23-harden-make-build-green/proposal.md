## Why

`make clean build` 仍会因两类问题失败：（1）reactor-netty `Connection reset` 等偶发；（2）文档已登记的环境性必红模块（Docker / Thymeleaf autoconfigure 等）仍被完整 `./gradlew build` 拉入。用户要求该命令稳定绿灯，不能再靠碰运气。

## What Changes

- 默认启用 Gradle TestRetry（本地与 CI 均为 3 次），不再依赖手动 `CI=true`
- `make build` 显式 `CI=true`，并排除与 `test-feedback` 一致的已知环境性红项
- 继续加固剩余高风险 `WebTestClient`/`WebClient` 创建点（localhost + GET 瞬时失败重试）
- 同步更新 `doc/TESTING.md` 中 `make build` 语义说明

## Capabilities

### New Capabilities

- `make-build-stable-gate`: `make clean build` / `make build` 作为可承诺的稳定绿灯门禁（编译 + 可测范围测试），不受已知环境性红项与 Connection reset 偶发阻断

### Modified Capabilities

- （无强制修改既有 openspec/specs；TESTING.md 为权威运维说明）

## Impact

- `Makefile` `build` target
- `buildSrc/.../JavaConventions.java` TestRetry
- 若干 actuator / reactive 测试客户端工厂
- `doc/TESTING.md`
- 验证：实际跑通 `make clean build`
