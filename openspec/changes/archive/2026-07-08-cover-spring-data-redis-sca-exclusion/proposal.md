## Why

Spring Data Redis 通过 `spring-data-redis`、`spring-data-keyvalue`、`spring-data-commons` 传递官方 `org.springframework:*` 依赖，导致下游通过 NES Spring Boot BOM 使用 Redis starter 时仍可能被 SCA 扫描到官方 Spring 坐标。

此前 OpenSpec 已将 Spring Data BOM import 标记为待后续评估；现在 Redis 泄露路径已确认，需要将 Spring Data Redis 相关模块纳入 BOM exclusion 覆盖。

## What Changes

- 将 Spring Data Redis 相关 managed dependency 从纯 `spring-data-bom` import 覆盖扩展为显式模块管理，并添加 `exclude group: "org.springframework", module: "*"`。
- 覆盖 Redis 泄露链上的核心 Spring Data 模块：
  - `spring-data-redis`
  - `spring-data-keyvalue`
  - `spring-data-commons`
- 保留 Spring Data 其余模块的后续评估空间，避免本次变更扩大到 Cassandra、MongoDB、JPA、REST 等未完成影响分析的模块。
- 更新维护文档，说明 Spring Data Redis 已从“待评估”升级为“已覆盖 Redis 泄露链”。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

- `fork-ecosystem-sca-excludes`: 扩展 A 类生态组件 SCA exclusion 范围，要求 Spring Data Redis 相关 managed dependency 排除官方 `org.springframework:*` 传递依赖。

## Impact

- **构建脚本**：修改 `spring-boot-project/spring-boot-dependencies/build.gradle` 的 Spring Data 管理方式。
- **BOM POM**：生成的 NES Boot dependencyManagement 中，Redis 相关 Spring Data 条目包含 `<exclusions>`。
- **下游消费者**：通过 NES Boot BOM 引入 `spring-boot-starter-data-redis` / reactive Redis starter 时，不再从 Spring Data Redis 链路传递官方 Spring Framework 坐标。
- **风险**：显式管理部分 Spring Data 模块会弱化 BOM import 自动覆盖能力；后续 Spring Data 升级时必须核对相关模块版本与模块列表。
