## Why

logback fork 已于 2026-06-25 正式发布 `1.2.13-nes.patch.1`（含全部 5 个 CVE 修复，含 CVE-2026-13006）。Spring Boot BOM 仍引用 `1.2.13-nes.patch.1-SNAPSHOT`，下游无法锁定稳定制品，安全审计也不理想。

## What Changes

- `spring-boot-dependencies/build.gradle`：Logback library 版本 `1.2.13-nes.patch.1-SNAPSHOT` → `1.2.13-nes.patch.1`
- `doc/NES_GAV_MAPPING.md`：第 7 章版本号同步
- `doc/REQUIREMENTS.md`：新增 [需求-032] 记录本次升级

无 Java 源码变更；GAV 坐标不变。

## Capabilities

### New Capabilities
<!-- 无 -->

### Modified Capabilities
<!-- 无 -->

## Impact

- 受影响文件：3 个（1 build.gradle + 2 doc）
- 风险：低（坐标不变，仅版本字符串）
- 验证：`make build` 或 logback 相关模块测试
