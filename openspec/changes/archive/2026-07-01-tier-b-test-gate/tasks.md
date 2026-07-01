## 1. 摸底：逐模块运行测试

- [x] 1.1 运行 `spring-boot-autoconfigure` 测试，记录用例数和失败数
- [x] 1.2 运行 `spring-boot-actuator` 测试，记录用例数和失败数
- [x] 1.3 运行 `spring-boot-actuator-autoconfigure` 测试，记录用例数和失败数
- [x] 1.4 运行 `spring-boot-test-autoconfigure` 测试，记录用例数和失败数
- [x] 1.5 运行 `spring-boot-maven-plugin` 测试（不含 dockerTest），记录用例数和失败数
- [x] 1.6 运行 `spring-boot-configuration-processor` 测试，记录用例数和失败数
- [x] 1.7 运行 `spring-boot-autoconfigure-processor` 测试，记录用例数和失败数

## 2. 修复 fork 适配失败

- [x] 2.1 分析各模块失败原因（fork 适配 / 环境性 / 真实 bug）
- [x] 2.2 修复 fork 适配类失败（Banner、GAV 断言、版本号硬编码等）
- [x] 2.3 重跑修复后的模块验证全绿

## 3. 实现 test-gate

- [x] 3.1 在 Makefile 中添加 `test-gate` 目标（纳入全绿模块）
- [x] 3.2 在 Makefile help 中添加 `test-gate` 说明
- [x] 3.3 `make test-gate` BUILD SUCCESSFUL

## 4. 更新文档

- [x] 4.1 更新 `doc/TESTING.md` §5 Tier B 模块状态（实测用例数/失败数）
- [x] 4.2 更新 `doc/TESTING.md` §6 Phase 1 → Tier B 实测范围
