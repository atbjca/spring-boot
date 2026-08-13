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

## Messaging BOM 坐标兼容（2026-08-06）

| 组件 | BOM 坐标 | 模块消费策略 | 版本 |
|------|----------|--------------|------|
| ActiveMQ Classic | `org.apache.activemq` 下的模块清单 | 保持既有模块坐标，由单一 ActiveMQ library pin 管理 | `6.2.8` |
| ActiveMQ Artemis | `org.apache.artemis:artemis-bom` | 新 BOM 同时管理 `org.apache.artemis:artemis-*` 与兼容的 `org.apache.activemq:artemis-*` 模块；现有 starter/auto-config 的旧组模块坐标暂时保留 | `2.54.0` |

Artemis 2.54.0 的权威 BOM 已从 `org.apache.activemq:artemis-bom` 迁移到 `org.apache.artemis:artemis-bom`。旧组 BOM 在该版本只是 relocation POM，不能作为本项目 Gradle dependency management 的有效版本源。因此 BOM import 使用新 groupId，而模块消费者继续使用现有旧组坐标以缩小兼容性变更面；不得为这些模块声明单独版本。生成 BOM 复核确认新 BOM 对两个 groupId 各管理 39 个模块，全部解析为 2.54.0。

## 官方第三方 JSON 坐标（2026-08-11）

| 组件 | 官方坐标 | 管理策略 | 版本 |
|------|----------|----------|------|
| Eclipse Parsson | `org.eclipse.parsson:parsson` | Boot BOM 显式管理；覆盖 Yasson 3.0.4 的 1.1.7 与 Elasticsearch Java client 的 1.0.5 传递请求 | `1.1.9` |
| Eclipse Yasson | `org.eclipse:yasson` | 保持现有官方坐标；本轮不迁移到 3.0.5 的 `org.eclipse.yasson` 新 groupId | `3.0.4` |
| Jakarta JSON API | `jakarta.json:jakarta.json-api` | 官方坐标 | `2.1.3` |
| Jakarta JSON Bind API | `jakarta.json.bind:jakarta.json.bind-api` | 官方坐标 | `3.0.2` |

Parsson 不是 NES fork，不参与根 `resolutionStrategy` GAV 重写。版本仅由 `spring-boot-dependencies` 的 `Parsson` library 拥有，保证直接声明和 Yasson 传递路径统一解析为 1.1.9。

## 官方第三方 QueryDSL 坐标迁移（2026-08-11）

| 组件 | 原坐标 | 当前坐标 | 版本 | Java 包 |
|------|--------|----------|------|---------|
| QueryDSL BOM | `com.querydsl:querydsl-bom` | `io.github.openfeign.querydsl:querydsl-bom` | `5.6.1` | 不适用 |
| QueryDSL modules | `com.querydsl:querydsl-*` | `io.github.openfeign.querydsl:querydsl-*` | `5.6.1` | 仍为 `com.querydsl.*` |

原 `com.querydsl` 5.1.0 lineage 没有 CVE-2024-49203 修复版本，Boot BOM 和 `spring-boot-autoconfigure` 的可选 `querydsl-core` 消费坐标已一起迁移到 OpenFeign 维护 lineage。该变更不是 NES fork GAV 重写，不参与根 `resolutionStrategy` 或 `nes-upstream-aliases.json`；下游显式声明 `querydsl-jpa`、`querydsl-apt` 等模块时必须自行改用新 groupId，dependency management 无法把旧 groupId 自动 relocation 到新 groupId。

## 官方第三方压缩坐标（2026-08-11）

| 组件 | 当前坐标 | 引入路径 / 管理策略 | 版本 |
|------|----------|---------------------|------|
| LZ4 Java | `at.yawk.lz4:lz4-java` | Kafka clients 3.9.2 传递请求 1.10.1；Boot BOM 显式管理并统一覆盖 | `1.11.2` |

LZ4 Java 已从归档的 `org.lz4` 项目迁移到维护中的 `at.yawk.lz4` 坐标，但仍保留 `net.jpountz.*` Java 包和 `org.lz4.java` automatic module name。该组件不是 NES fork，不参与 GAV 重写；版本只由 `spring-boot-dependencies` 的 `LZ4 Java` library 拥有。`spring-rabbit-stream` 对旧 `org.lz4:lz4-java` 的 exclusion 不影响 Kafka 的 `at.yawk.lz4` 依赖路径。

## Phase B（已完成）

| 组件 | 官方坐标 | Fork 坐标 | 版本 |
|------|----------|-----------|------|
| Spring Boot | `org.springframework.boot:*` | `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-*` | `3.5.15-nes.patch.2-SNAPSHOT` |
| Spring Framework | `org.springframework:*` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-*` | `6.2.19-nes.patch.1` |
| Spring Security | `org.springframework.security:*` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-*` | `6.5.11-nes.patch.2-SNAPSHOT` |
| Authorization Server | `org.springframework.security:spring-security-oauth2-authorization-server` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-authorization-server` | `1.5.8-nes.patch.1` |
| Spring Data BOM | `org.springframework.data:spring-data-bom` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom` | `2025.0.13-nes.patch.1` |
| Spring Data Commons | `org.springframework.data:spring-data-commons` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons` | `3.5.13-nes.patch.1` |
| Spring Data KeyValue | `org.springframework.data:spring-data-keyvalue` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue` | `3.5.13-nes.patch.1` |
| Spring Data Redis | `org.springframework.data:spring-data-redis` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis` | `3.5.13-nes.patch.1` |
| Spring Data Elasticsearch | `org.springframework.data:spring-data-elasticsearch` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch` | `5.5.13-nes.patch.1` |
| Spring Kafka | `org.springframework.kafka:spring-kafka` | `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka` | `3.3.16-nes.patch.1` |
| Spring Kafka Test | `org.springframework.kafka:spring-kafka-test` | `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-test` | `3.3.16-nes.patch.1` |
| Logback | `ch.qos.logback:*` | 官方 | `1.5.38` |

### Fork 参数

| 参数 | 值 |
|------|-----|
| `forkGroupIdBase` | `cn.bjca.footstone.bpring` |
| `forkArtifactPrefix` | `bjca-footstone-bpring` |
| `springBootVersion` | `3.5.15` |
| `springFrameworkVersion` | `6.2.19-nes.patch.1` |
| `springSecurityVersion` | `6.5.11-nes.patch.2-SNAPSHOT` |
| `springAuthorizationServerVersion` | `1.5.8-nes.patch.1` |

### 映射示例

| 官方 GAV | Fork GAV |
|----------|----------|
| `org.springframework:spring-context:6.2.19` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-context:6.2.19-nes.patch.1` |
| `org.springframework.security:spring-security-core:6.5.11` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-core:6.5.11-nes.patch.2-SNAPSHOT` |
| `org.springframework.boot:spring-boot-starter-web:3.5.15` | `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-web:3.5.15-nes.patch.2-SNAPSHOT` |
| `org.springframework.data:spring-data-redis:3.5.13` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1` |
| `org.springframework.kafka:spring-kafka:3.3.16` | `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka:3.3.16-nes.patch.1` |

### 机器可读审计别名同步

`scripts/security-audit/nes-upstream-aliases.json` 只描述 NES 私有坐标到上游身份的映射，不复制 resolved BOM 中的版本。当前规则与本文件一致：

| Rule ID | 私有坐标模式 | 上游坐标模式 | 版本归一化 |
|---------|--------------|--------------|------------|
| `spring-boot-fork` | `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-*` | `org.springframework.boot:spring-boot-*` | 去除 `-nes.patch.N[-SNAPSHOT]` |
| `spring-framework-fork` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-*` | `org.springframework:spring-*` | 同上 |
| `spring-security-fork` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-*` | `org.springframework.security:spring-security-*` | 同上 |
| `spring-data-fork` | `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-*` | `org.springframework.data:spring-data-*` | 同上 |
| `spring-kafka-fork` | `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka*` | `org.springframework.kafka:spring-kafka*` | 同上 |

审计同时查询私有和归一化后的上游 PURL，并保留 rule ID 与 provenance。QueryDSL、Parsson 和 LZ4 Java 都是官方第三方坐标，不得添加为 NES alias；它们直接按当前 Maven PURL 查询。

### SCA 规避说明

Phase B 完成后，显式声明的 `org.springframework:*` / `org.springframework.security:*` 由 `resolutionStrategy` 替换为 fork 坐标。Phase C 对 GraphQL / Kafka 等 A 类模块在 BOM 中排除传递的官方 Spring 依赖。Spring Data commons/keyvalue/redis/elasticsearch 已切换为 fork BOM + fork 制品，starter 源码仍保留官方 `api(...)` 声明，由 `resolutionStrategy` 在解析期重写到 fork GAV。

Spring Retry 的 POM 声明 optional `org.springframework:spring-context`。Gradle 传递解析不会拉取 optional 依赖，但 SCA/治理仍按 POM 声明看到官方 Spring 坐标，因此 BOM dependencyManagement 保留 `org.springframework:*` exclusion，并在 `bomrCheck` 中对白名单策略性 optional exclusion 放行。Spring WS 保持上游 `spring-ws-bom` import，避免展开 modules 后解析 `spring-ws-security -> wss4j -> org.opensaml:*` 并触发 Shibboleth 仓库依赖。

仍使用 BOM import、尚未添加 exclusion 的组件（Spring Data 其它模块、Integration、Session、Pulsar 等）可能仍被 SCA 扫描到官方 Spring 传递链，待后续 change 处理。

## Phase A（已完成）

见归档变更 `openspec/changes/archive/2026-06-30-bootstrap-boot-3515-nes-fork/`。
