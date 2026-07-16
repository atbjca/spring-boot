# NES GAV 映射（Spring Boot 3.5 兼容链）

## Phase C（当前）

在 Phase B 基础上，对仍使用官方 groupId 的 A 类生态组件在 BOM 中排除传递的 `org.springframework:*`，Framework 由 `resolutionStrategy` 提供 fork 坐标。

| 组件 | 官方 groupId | Fork | BOM 排除 org.springframework |
|------|-------------|------|------------------------------|
| Spring GraphQL | `org.springframework.graphql` | 官方 | ✅ |
| Spring HATEOAS | `org.springframework.hateoas` | 官方 | ✅ |
| Spring Kafka | `cn.bjca.footstone.bpring.kafka` | fork `bjca-footstone-bpring-kafka{,-test}` | ✅ |
| Spring LDAP | `org.springframework.ldap` | 官方 | ✅ |
| Spring Retry | `org.springframework.retry` | 官方 | ✅ optional Spring 坐标也排除 |
| Spring AMQP | `org.springframework.amqp` | 官方 | ✅ bom→modules |
| Spring Batch | `org.springframework.batch` | 官方 | ✅ bom→modules |
| Spring WS | `org.springframework.ws` | 官方 BOM import | ❌ 保持 `spring-ws-bom`，避免 OpenSAML/Shibboleth 解析 |
| Spring RESTDocs | `org.springframework.restdocs` | 官方 | ✅ bom→modules |
| Spring Data commons/keyvalue/redis/elasticsearch | `cn.bjca.footstone.bpring.data` | fork `bjca-footstone-bpring-data-*` + fork BOM | ❌ fork POM 内部已 fork 化 |
| Spring Data 其它模块 / Integration / Session | 各官方 groupId | 官方 BOM import / 官方坐标 | ⏳ 待后续评估 |
| Spring Pulsar | `org.springframework.pulsar` | 官方 BOM import | ⏳ 待后续评估（3.5 新增） |

Logback 仍用官方 `ch.qos.logback:1.5.38`（不 fork bogback）。

## Phase B（已完成）

| 组件 | 官方坐标 | Fork 坐标 | 版本 |
|------|----------|-----------|------|
| Spring Boot | `org.springframework.boot:*` | `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-*` | `3.5.15-nes.patch.1-SNAPSHOT` |
| Spring Framework | `org.springframework:*` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-*` | `6.2.19-nes.patch.1-SNAPSHOT` |
| Spring Security | `org.springframework.security:*` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-*` | `6.5.11-nes.patch.1-SNAPSHOT` |
| Authorization Server | `org.springframework.security:spring-security-oauth2-authorization-server` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-authorization-server` | `1.5.8-nes.patch.1-SNAPSHOT` |
| Spring Data BOM | `org.springframework.data:spring-data-bom` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom` | `2025.0.13-nes.patch.1-SNAPSHOT` |
| Spring Data Commons | `org.springframework.data:spring-data-commons` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons` | `3.5.13-nes.patch.1-SNAPSHOT` |
| Spring Data KeyValue | `org.springframework.data:spring-data-keyvalue` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue` | `3.5.13-nes.patch.1-SNAPSHOT` |
| Spring Data Redis | `org.springframework.data:spring-data-redis` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis` | `3.5.13-nes.patch.1-SNAPSHOT` |
| Spring Data Elasticsearch | `org.springframework.data:spring-data-elasticsearch` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch` | `5.5.13-nes.patch.1-SNAPSHOT` |
| Spring Kafka | `org.springframework.kafka:spring-kafka` | `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka` | `3.3.16-nes.patch.1-SNAPSHOT` |
| Spring Kafka Test | `org.springframework.kafka:spring-kafka-test` | `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-test` | `3.3.16-nes.patch.1-SNAPSHOT` |
| Logback | `ch.qos.logback:*` | 官方 | `1.5.38` |

### Fork 参数

| 参数 | 值 |
|------|-----|
| `forkGroupIdBase` | `cn.bjca.footstone.bpring` |
| `forkArtifactPrefix` | `bjca-footstone-bpring` |
| `springBootVersion` | `3.5.15` |
| `springFrameworkVersion` | `6.2.19-nes.patch.1-SNAPSHOT` |
| `springSecurityVersion` | `6.5.11-nes.patch.1-SNAPSHOT` |
| `springAuthorizationServerVersion` | `1.5.8-nes.patch.1-SNAPSHOT` |

### 映射示例

| 官方 GAV | Fork GAV |
|----------|----------|
| `org.springframework:spring-context:6.2.19` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-context:6.2.19-nes.patch.1-SNAPSHOT` |
| `org.springframework.security:spring-security-core:6.5.11` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-core:6.5.11-nes.patch.1-SNAPSHOT` |
| `org.springframework.boot:spring-boot-starter-web:3.5.15` | `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-web:3.5.15-nes.patch.1-SNAPSHOT` |
| `org.springframework.data:spring-data-redis:3.5.13` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1-SNAPSHOT` |
| `org.springframework.kafka:spring-kafka:3.3.16` | `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka:3.3.16-nes.patch.1-SNAPSHOT` |

### SCA 规避说明

Phase B 完成后，显式声明的 `org.springframework:*` / `org.springframework.security:*` 由 `resolutionStrategy` 替换为 fork 坐标。Phase C 对 GraphQL / Kafka 等 A 类模块在 BOM 中排除传递的官方 Spring 依赖。Spring Data commons/keyvalue/redis/elasticsearch 已切换为 fork BOM + fork 制品，starter 源码仍保留官方 `api(...)` 声明，由 `resolutionStrategy` 在解析期重写到 fork GAV。

Spring Retry 的 POM 声明 optional `org.springframework:spring-context`。Gradle 传递解析不会拉取 optional 依赖，但 SCA/治理仍按 POM 声明看到官方 Spring 坐标，因此 BOM dependencyManagement 保留 `org.springframework:*` exclusion，并在 `bomrCheck` 中对白名单策略性 optional exclusion 放行。Spring WS 保持上游 `spring-ws-bom` import，避免展开 modules 后解析 `spring-ws-security -> wss4j -> org.opensaml:*` 并触发 Shibboleth 仓库依赖。

仍使用 BOM import、尚未添加 exclusion 的组件（Spring Data 其它模块、Integration、Session、Pulsar 等）可能仍被 SCA 扫描到官方 Spring 传递链，待后续 change 处理。

## Phase A（已完成）

见归档变更 `openspec/changes/archive/2026-06-30-bootstrap-boot-3515-nes-fork/`。
