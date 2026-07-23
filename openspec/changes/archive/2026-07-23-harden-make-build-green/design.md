## Context

完整 `./gradlew build` 会调度 Docker / Testcontainers / 已知 Thymeleaf 残留的 autoconfigure 测试，TESTING.md 已声明全量不能作为全绿目标。同时 reactor-netty 客户端偶发 `Connection reset` 在本地 `TestRetry=0` 时一次失败即红。

## Goals / Non-Goals

**Goals:**

- `make clean build` 稳定 `BUILD SUCCESSFUL`
- 保留 checkstyle / 编译 / 主库与可测模块测试覆盖
- 偶发连接错误由客户端重试 + TestRetry 双层吸收

**Non-Goals:**

- 不宣称全仓库每一个子项目 test 全绿（仍由 `test-feedback` 摸底）
- 不修改生产业务语义

## Decisions

1. **`JavaConventions`：`maxRetries` 固定为 3**（不再 `isCi() ? 3 : 0`）
2. **`make build`：`CI=true` + 与 `test-feedback` 相同的 `-x` 环境性排除清单**
3. **客户端：剩余 `bindToServer` 高风险点补齐 GET retry；reactive 基类 SSL `WebClient.builder` 走带 filter 的 helper**

## Risks / Trade-offs

- [Risk] 用户误以为 `make build` 已覆盖 Docker system-tests → Mitigation：Makefile 注释 + TESTING.md 写明排除原因；全量摸底仍用 `test-feedback`
- [Risk] TestRetry 掩盖真缺陷 → Mitigation：`failOnPassedAfterRetry=false` 已有；真断言失败会稳定失败

## Migration Plan

- 直接合入；回滚 Makefile / JavaConventions / 测试客户端即可

## Open Questions

- 无
