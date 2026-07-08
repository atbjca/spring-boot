## Why

Spring Boot 2.7 NES BOM 当前仍管理官方 `org.springframework.kafka:spring-kafka` 坐标，导致下游即使引入 NES Boot BOM，Kafka 依赖仍可能回到官方 GAV。参考 `spring-kafka-2.9` NES 维护分支后，需要让 Boot BOM 直接管理已发布的 NES Spring Kafka 模块，保持下游依赖链与 NES GAV 体系一致。

## What Changes

- 将 Spring Boot dependency BOM 中的 Spring Kafka 管理坐标从官方 GAV 切换为 NES GAV：
  - `org.springframework.kafka:spring-kafka:2.9.13` → `cn.bjca.footstone.bpring.kafka:spring-kafka:2.9.13-nes.patch.1-SNAPSHOT`
  - `org.springframework.kafka:spring-kafka-test:2.9.13` → `cn.bjca.footstone.bpring.kafka:spring-kafka-test:2.9.13-nes.patch.1-SNAPSHOT`
- 增加或调整构建期透明替换规则，使当前仓库源码中声明的 `org.springframework.kafka:*` 可解析到 NES Spring Kafka 模块。
- 不引入 `bjca-footstone-bpring-kafka-bom`，因为参考仓库中未发现对应 `spring-kafka-bom` 模块或本地发布产物。
- 更新 GAV、需求、漏洞和下游使用文档，移除 Spring Kafka 仍是“未 fork 组件”的过期描述。
- 验证结果显示 NES Spring Kafka POM 仍传递官方 `org.springframework:*`，因此继续排除官方 Spring Framework 传递依赖。

## Capabilities

### New Capabilities

- `nes-spring-kafka-dependencies`: 约束 Spring Boot NES BOM 和本仓库构建解析必须使用 NES Spring Kafka 坐标。

### Modified Capabilities

（无）

## Impact

- `spring-boot-project/spring-boot-dependencies/build.gradle`：Spring Kafka library 坐标、版本、模块列表及排除规则。
- 根 `build.gradle`：可能新增 `org.springframework.kafka` 到 NES Spring Kafka 的 `resolutionStrategy.eachDependency` 映射。
- 文档：`doc/GAV 构建机制说明.md`、`doc/NES_GAV_MAPPING.md`、`doc/GAV_MAPPING.md`、`doc/REQUIREMENTS.md`、`doc/VULNERABILITY_REPORT.md`，以及快速入门/用户手册类文档。
- 测试与验证：BOM 生成、依赖解析、Kafka 相关自动配置编译测试；不恢复已知受 Kafka 3.9.2 与 `spring-kafka-test` 2.9.x embedded broker 兼容性影响的 smoke test。
- 下游影响：依赖 NES Boot BOM 的项目应改用 NES Spring Kafka GAV；Java package/import 仍保持 `org.springframework.kafka.*` 不变。
