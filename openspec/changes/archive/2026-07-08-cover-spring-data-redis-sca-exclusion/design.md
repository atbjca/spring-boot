## Context

Spring Data 在 3.5 当前通过 `spring-data-bom` import 管理全量模块。该方式可以保留上游 Spring Data BOM 的版本集合，但不能直接给 `spring-data-redis` 等单个 managed dependency 添加 per-module exclusion。

已确认 `spring-data-redis:3.5.13` 直接依赖 `org.springframework:spring-tx`、`spring-oxm`、`spring-aop`、`spring-context-support`；同时它依赖的 `spring-data-keyvalue` 和 `spring-data-commons` 也继续传递多个 `org.springframework:*`。因此只处理 Redis starter 或 Redis driver 不能解决泄露，治理点必须在 Spring Data managed dependency 层。

BomPlugin 会基于显式 `modules` 给匹配 managed dependency 添加 `<exclusions>`。本变更保留 Spring Data BOM import，同时用独立 library 管理 Redis 泄露链上的模块；独立 library 使用模块真实版本，避免把 release train 版本误用为模块版本。

## Goals / Non-Goals

**Goals:**
- 阻断 `spring-data-redis` 链路向下游 Maven 消费者传递官方 `org.springframework:*` 坐标。
- 保留 `spring-data-bom` import，避免一次性手工维护 Spring Data 全量模块版本。
- 为 BOM import 与独立 module libraries 共存的用法增加验证，避免生成 POM 时遗漏 import 或 module exclusion。
- 更新 OpenSpec 和维护文档，说明 Spring Data Redis 已覆盖、Spring Data 其它模块仍需独立评估。

**Non-Goals:**
- 不 fork Spring Data。
- 不一次性处理 Spring Data Cassandra、MongoDB、JPA、REST、LDAP 等其它模块。
- 不处理 Spring Integration、Session、Pulsar 的 BOM import 泄露面。
- 不改变 Redis driver（Jedis / Lettuce）版本。

## Decisions

### Decision 1: 保留 `spring-data-bom` import，并用独立 library 覆盖 Redis 链路模块

方案是保留 `Spring Data Bom` 的 `bom("spring-data-bom")`，同时新增独立 library 显式管理：
- `spring-data-commons`
- `spring-data-keyvalue`
- `spring-data-redis`

理由：全量替换 Spring Data BOM 为显式 modules 会扩大维护面，也容易遗漏未使用或版本不同步的模块。本次实际问题是 Redis 链路泄露，最小闭环应覆盖 Redis 直接模块及其 Spring Data 中间依赖。独立 library 必须使用模块真实版本 `3.5.13`，不能使用 release train BOM 版本 `2025.0.13`。

替代方案：把 Spring Data BOM 全量转换为 modules。该方案 SCA 覆盖更彻底，但影响面大，需要逐个核对 2025.0.13 BOM 的全部模块和版本，不适合本次 Redis 定点修复。

### Decision 2: 对三个 Redis 链路模块统一排除 `org.springframework:*`

`spring-data-redis` 直接排除可以阻断其 POM 中的直接 Spring Framework 依赖；`spring-data-keyvalue` 和 `spring-data-commons` 也必须排除，否则其它路径仍可能把 Spring Framework 坐标带入 dependencyManagement 消费链。

### Decision 3: 增加 BomPlugin 组合覆盖测试

现有测试分别覆盖 `bom()` import 和 module exclusion。新增测试验证生成 POM 可以同时包含 imported BOM 和显式 module，并且显式 module 带 exclusion。

## Risks / Trade-offs

- [Risk] 误用 release train BOM 版本作为模块版本会解析到不存在的 `spring-data-redis:2025.0.13`。→ Mitigation：Redis 链路模块使用独立 library 和真实模块版本 `3.5.13`，并通过 `make build-thin` 验证。
- [Risk] 只覆盖 Redis 链路后，Spring Data 其它模块仍可能泄露官方 Spring 依赖。→ Mitigation：文档明确剩余待评估范围，避免误判为 Spring Data 全量完成。
- [Risk] Spring Data 升级时 Redis 链路模块版本随 BOM 变化，显式 modules 的 exclusion 仍存在但需确认模块名未变化。→ Mitigation：在维护文档中记录升级时需要核对 Spring Data BOM。
- [Risk] 下游若直接引入未覆盖的 Spring Data 模块，仍可能看到官方 Spring 坐标。→ Mitigation：本 change 只承诺 Redis 链路；其它模块应通过后续 OpenSpec change 单独处理。
