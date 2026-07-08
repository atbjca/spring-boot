## MODIFIED Requirements

### Requirement: A 类生态组件排除官方 Spring 传递依赖

对 `spring-boot-dependencies/build.gradle` 中尚未 fork 的 A 类 Spring 生态库，MUST 在每个受治理的 managed module 上声明 `exclude group: "org.springframework", module: "*"`，使下游通过 Boot BOM 引入时不传递官方 `org.springframework:*` 坐标。

覆盖范围 9 个组件 + Spring Data Redis 链路：GraphQL / HATEOAS / Kafka / LDAP / Retry（显式 modules）+ AMQP / Batch / WS / RESTDocs（bom→modules 转换）+ Spring Data Redis / KeyValue / Commons（保留 `spring-data-bom` import，并通过独立 library 显式覆盖 Redis 泄露链 modules）。

| 组件 | groupId | 模块数 | 备注 |
|------|---------|--------|------|
| Spring GraphQL | `org.springframework.graphql` | 2 | 全部排除 |
| Spring HATEOAS | `org.springframework.hateoas` | 1 | 排除 |
| Spring Kafka | `org.springframework.kafka` | 2 | 全部排除 |
| Spring LDAP | `org.springframework.ldap` | 4 | 全部排除 |
| Spring Retry | `org.springframework.retry` | 1 | 排除 |
| Spring AMQP | `org.springframework.amqp` | 5 | 全部排除 |
| Spring Batch | `org.springframework.batch` | 4 | 全部排除 |
| Spring WS | `org.springframework.ws` | 5 | `spring-ws-security` 额外排除 `org.springframework.security` |
| Spring RESTDocs | `org.springframework.restdocs` | 4 | `spring-restdocs-asciidoctor` 不排除（无 Spring 依赖） |
| Spring Data Redis 链路 | `org.springframework.data` | 3 | `spring-data-redis` / `spring-data-keyvalue` / `spring-data-commons` 排除 |

AMQP / Batch / WS / RESTDocs MUST 从 `bom()` import 改为显式 `modules = [...]` 列表以支持 per-module exclusion。Spring Data MUST 保留 `spring-data-bom` import，并额外通过独立 library 声明 Redis 泄露链上的显式 modules 及真实模块版本以支持 per-module exclusion。

#### Scenario: spring-kafka managed dependency 含 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.kafka:spring-kafka` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`

#### Scenario: spring-amqp managed dependency 含 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.amqp:spring-amqp` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`

#### Scenario: spring-ws-security 含双重 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.ws:spring-ws-security` 的 dependencyManagement 条目包含 exclusion `org.springframework:*` 和 `org.springframework.security:*`

#### Scenario: spring-restdocs-asciidoctor 无 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.restdocs:spring-restdocs-asciidoctor` 的 dependencyManagement 条目不包含 exclusion

#### Scenario: spring-data-redis managed dependency 含 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.data:spring-data-redis` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`

#### Scenario: Spring Data Redis 中间模块含 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.data:spring-data-keyvalue` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`
- **AND** `org.springframework.data:spring-data-commons` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`

#### Scenario: Spring Data BOM import 保留
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** dependencyManagement 仍包含 `org.springframework.data:spring-data-bom` import

#### Scenario: 消费者仍解析 fork Framework
- **WHEN** 子模块声明 `org.springframework.kafka:spring-kafka` 且根 `resolutionStrategy` 已配置 Framework 映射
- **THEN** 编译 classpath 中 spring-context 解析为 `cn.bjca.footstone.bpring:bjca-footstone-bpring-context`
