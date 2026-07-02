## MODIFIED Requirements

### Requirement: A 类生态组件排除官方 Spring 传递依赖

对 `spring-boot-dependencies/build.gradle` 中尚未 fork 的 A 类 Spring 生态库，MUST 在每个 managed module 上声明 `exclude group: "org.springframework", module: "*"`，使下游通过 Boot BOM 引入时不传递官方 `org.springframework:*` 坐标。

覆盖范围从 Phase C 的 5 个组件（GraphQL / HATEOAS / Kafka / LDAP / Retry）扩展到 9 个，新增：

| 组件 | groupId | 模块数 | 备注 |
|------|---------|--------|------|
| Spring AMQP | `org.springframework.amqp` | 5 | 全部排除 |
| Spring Batch | `org.springframework.batch` | 4 | 全部排除 |
| Spring WS | `org.springframework.ws` | 5 | `spring-ws-security` 额外排除 `org.springframework.security` |
| Spring RESTDocs | `org.springframework.restdocs` | 4 | `spring-restdocs-asciidoctor` 不排除（无 Spring 依赖） |

上述组件 MUST 从 `bom()` import 改为显式 `modules = [...]` 列表以支持 per-module exclusion。

#### Scenario: spring-amqp managed dependency 含 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.amqp:spring-amqp` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`

#### Scenario: spring-batch-core managed dependency 含 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.batch:spring-batch-core` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`

#### Scenario: spring-ws-security 含双重 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.ws:spring-ws-security` 的 dependencyManagement 条目包含 exclusion `org.springframework:*` 和 `org.springframework.security:*`

#### Scenario: spring-restdocs-asciidoctor 无 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.restdocs:spring-restdocs-asciidoctor` 的 dependencyManagement 条目不包含 exclusion
