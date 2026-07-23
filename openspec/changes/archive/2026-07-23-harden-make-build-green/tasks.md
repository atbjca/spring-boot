## 1. Build gate

- [x] 1.1 `JavaConventions` 将 TestRetry `maxRetries` 固定为 3
- [x] 1.2 `Makefile` `build` 加 `CI=true`，并加入与 `test-feedback` 一致的 `-x` 排除清单与注释
- [x] 1.3 更新 `doc/TESTING.md` 说明 `make build` 稳定绿灯语义
- [x] 1.4 更新 `ConventionsPluginTests`：本地亦期望 `maxRetries: 3`

## 2. Client hardening

- [x] 2.1 reactive 基类 SSL/`WebClient.builder` 路径复用带 GET retry 的 builder helper
- [x] 2.2 为 actuator 侧剩余 `bindToServer` 高风险工厂补齐 GET retry

## 3. Verify

- [x] 3.1 执行 `make clean build` 直至 `BUILD SUCCESSFUL`（先 `make stop` 清 daemon；EXIT:0）
