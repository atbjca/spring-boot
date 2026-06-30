## Why

Phase B 已将 Framework / Security 映射为 fork GAV，但 Spring Kafka、GraphQL 等 A 类生态组件仍通过 BOM 传递 `org.springframework:*` 官方坐标，SCA 扫描仍会命中。2.7 fork 在 `spring-boot-dependencies` 中对显式模块条目添加 `exclude group: org.springframework`，由 resolutionStrategy 提供 fork Framework。

## What Changes

- 在 `spring-boot-dependencies/build.gradle` 为 GraphQL / HATEOAS / Kafka / LDAP / Retry 模块添加 A 类传递依赖排除。
- 更新 `doc/NES_GAV_MAPPING.md` SCA 说明与 Phase C 记录。
- 在 `doc/REQUIREMENTS.md` 标记 Phase B 已完成，新增 [需求-003] Phase C。

### Non-goals

- 不 fork Spring Data / Integration / Session 等（仍用官方 BOM import）。
- 不 fork Logback（保持官方 1.5.34）。
- 不为 BOM import 型条目（Integration / Session / AMQP 等）改回显式模块清单。

## Capabilities

### New Capabilities

- `fork-ecosystem-sca-excludes`: A 类生态组件 BOM 传递依赖排除规则。

## Impact

- **BOM POM**：上述模块的 `<dependencyManagement>` 含 `<exclusions>`。
- **运行时**：消费者通过 Boot BOM + resolutionStrategy 获得 fork Framework，行为与 2.7 一致。
