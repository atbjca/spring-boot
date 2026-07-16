## Purpose

定义未 fork 的 Spring 生态组件在 NES Spring Boot BOM 中的 SCA exclusion 策略，阻断它们向下游传递官方 Spring Framework / Security 坐标。

## Requirements

### Requirement: A 类生态组件排除官方 Spring 传递依赖

对 `spring-boot-dependencies/build.gradle` 中尚未 fork 的 A 类 Spring 生态库，MUST 在每个受治理的 managed module 上声明 `exclude group: "org.springframework", module: "*"`，使下游通过 Boot BOM 引入时不传递官方 `org.springframework:*` 坐标。

Spring Data commons/keyvalue/redis/elasticsearch 已在 fork 侧完成去特征化，其 fork POM 内部依赖已 fork 化、不再传递官方 `org.springframework:*` 坐标，因此从本 A 类覆盖范围移除，改由 fork `bjca-footstone-bpring-data-bom` 统一纳管。

Spring Kafka 虽已 fork（GAV 去特征化），但其 fork POM 内部仍以官方坐标声明传递依赖（`org.springframework:spring-context/messaging/tx`），故作为特例保留在本 A 类范围内：group 与 modules key 更名为 fork 坐标，`exclude group: "org.springframework", module: "*"` 保留，作为依赖图层面的双保险（与 root `resolutionStrategy` 规则一的坐标重写叠加）。

Spring Retry 保留在本 A 类覆盖范围内：`spring-retry` POM 声明了 optional `org.springframework:spring-context`，Gradle 解析传递 artifact set 时不会拉取 optional 依赖，但 SCA/治理仍按 POM 声明看到官方 Spring 坐标，因此 BOM dependencyManagement MUST 保留 `exclude group: "org.springframework", module: "*"`。`bomrCheck` 对该策略性 optional exclusion 设白名单。

Spring WS 从本 A 类覆盖范围移除：Spring WS 保持上游 `spring-ws-bom` import，避免显式 modules 触发 `spring-ws-security -> wss4j -> org.opensaml:*` 解析，而 OpenSAML 5.x 仅托管在 Shibboleth 仓库、本项目私服未代理。

覆盖范围：GraphQL / HATEOAS / LDAP / Retry（显式 modules，官方坐标）+ AMQP / Batch / RESTDocs（bom→modules 转换，官方坐标）+ Kafka（fork 坐标 `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka{,-test}`，保留 exclude）。

| 组件 | groupId | 模块数 | 备注 |
|------|---------|--------|------|
| Spring GraphQL | `org.springframework.graphql` | 2 | 全部排除 |
| Spring HATEOAS | `org.springframework.hateoas` | 1 | 排除 |
| Spring Kafka | `cn.bjca.footstone.bpring.kafka` | 2 | fork 坐标，key `bjca-footstone-bpring-kafka{,-test}`，保留排除 |
| Spring LDAP | `org.springframework.ldap` | 4 | 全部排除 |
| Spring Retry | `org.springframework.retry` | 1 | 排除 optional Spring 坐标 |
| Spring AMQP | `org.springframework.amqp` | 5 | 全部排除 |
| Spring Batch | `org.springframework.batch` | 4 | 全部排除 |
| Spring RESTDocs | `org.springframework.restdocs` | 4 | `spring-restdocs-asciidoctor` 不排除（无 Spring 依赖） |

AMQP / Batch / RESTDocs MUST 从 `bom()` import 改为显式 `modules = [...]` 列表以支持 per-module exclusion。Spring WS MUST use `bom("spring-ws-bom")` import and SHALL NOT expand to explicit modules unless the build also provides an OpenSAML/Shibboleth resolution strategy. Spring Data MUST 导入 fork `bjca-footstone-bpring-data-bom` 且不再声明 exclude（fork 模块内部已 fork 化）。

#### Scenario: spring-kafka managed dependency 含 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`
- **AND** `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-test` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`

#### Scenario: spring-amqp managed dependency 含 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.amqp:spring-amqp` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`

#### Scenario: spring-ws-bom 保持 BOM import
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** dependencyManagement imports `org.springframework.ws:spring-ws-bom`
- **AND** Spring WS is not expanded into per-module dependency management entries.

#### Scenario: spring-retry managed dependency 含 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.retry:spring-retry` 的 dependencyManagement 条目包含 `org.springframework:*` exclusion

#### Scenario: spring-restdocs-asciidoctor 无 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.restdocs:spring-restdocs-asciidoctor` 的 dependencyManagement 条目不包含 exclusion

#### Scenario: Spring Data 模块不再作为 A 类 exclude 治理
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** 不存在针对 `spring-data-commons` / `spring-data-keyvalue` / `spring-data-redis` 的独立 library 块与 `org.springframework:*` exclusion
- **AND** dependencyManagement 通过 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom` import 纳管这些模块

#### Scenario: 消费者仍解析 fork Framework
- **WHEN** 子模块声明 `org.springframework.kafka:spring-kafka` 且根 `resolutionStrategy` 已配置 Framework 映射
- **THEN** 解析结果为 fork Kafka 制品，且其传递的 Spring Framework 依赖为 fork 坐标
