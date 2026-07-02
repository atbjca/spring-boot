## Context

Phase C 已对仍使用显式 `modules` 的 5 个组件（GraphQL / HATEOAS / Kafka / LDAP / Retry）添加了 A 类排除。但 AMQP / Batch / WS / RESTDocs 在 3.5 上游被改为 `bom()` import，`bom()` 不支持 per-module exclusion，导致 2.7 已有的排除丢失。

2.7 的模块列表与 3.5 BOM 中的模块列表比对后确认一致（RESTDocs 在 3.5 中去掉了 `spring-restdocs-restassured`），可直接参考 2.7 模式。

## Goals / Non-Goals

**Goals:**
- 恢复 2.7 fork 在 AMQP / Batch / WS / RESTDocs 上的 SCA 排除。
- 与 2.7 的 `[A 类排除]` 模式完全对齐。
- `make build-thin` 和 `make test-gate` 全绿。

**Non-goals:**
- 不处理 2.7 也没有 exclusion 的 bom() 组件（Data / Integration / Session）。
- 不处理 3.5 新增的 Pulsar。

## Decisions

### Decision 1：bom() 改回 modules 列表

`bom()` import 无法加 per-module exclusion，唯一方式是改回显式 `modules = [...]`。2.7 已验证此模式可行。缺点是上游版本升级时如果新增模块需要手动同步，但这些组件模块列表很稳定。

### Decision 2：保留 links{} 块

3.5 在 `library()` 定义中新增了 `links {}` 块（站点 / GitHub / Javadoc / 文档链接），2.7 没有。改回 `modules` 时保留 `links {}` 不变。

### Decision 3：RESTDocs asciidoctor 不加 exclusion

与 2.7 一致，`spring-restdocs-asciidoctor` 是 Asciidoctor 扩展，不传递 Spring Framework 依赖。

### Decision 4：WS security 额外排除 org.springframework.security

与 2.7 一致，`spring-ws-security` 传递依赖 `spring-security-core`，需额外 `exclude group: "org.springframework.security", module: "*"`。

## Risks / Trade-offs

- **[上游新增模块遗漏]** → 这些组件模块列表非常稳定，几乎不会新增。上游版本升级时对照 BOM POM 检查即可。
- **[BomPlugin 兼容性]** → Phase C 已验证 BomPlugin 支持 `exclude` 语法。
