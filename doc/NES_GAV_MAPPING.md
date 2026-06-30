# NES GAV 映射（Spring Boot 3.5 兼容链）

## Phase C（当前）

在 Phase B 基础上，对仍使用官方 groupId 的 A 类生态组件（GraphQL、HATEOAS、Kafka、LDAP、Retry）在 BOM 中排除传递的 `org.springframework:*`，Framework 由 `resolutionStrategy` 提供 fork 坐标。

| 组件 | 官方 groupId | Fork | BOM 排除 org.springframework |
|------|-------------|------|------------------------------|
| Spring GraphQL | `org.springframework.graphql` | 官方 | ✅ |
| Spring HATEOAS | `org.springframework.hateoas` | 官方 | ✅ |
| Spring Kafka | `org.springframework.kafka` | 官方 | ✅ |
| Spring LDAP | `org.springframework.ldap` | 官方 | ✅ |
| Spring Retry | `org.springframework.retry` | 官方 | ✅ |
| Spring Data / Integration / Session 等 | 各官方 groupId | 官方 BOM import | ⏳ 待后续 change |

Logback 仍用官方 `ch.qos.logback:1.5.34`（不 fork bogback）。

## Phase B（已完成）

| 组件 | 官方坐标 | Fork 坐标 | 版本 |
|------|----------|-----------|------|
| Spring Boot | `org.springframework.boot:*` | `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-*` | `3.5.15-nes.patch.1-SNAPSHOT` |
| Spring Framework | `org.springframework:*` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-*` | `6.2.19-nes.patch.1-SNAPSHOT` |
| Spring Security | `org.springframework.security:*` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-*` | `6.5.11-nes.patch.1-SNAPSHOT` |
| Authorization Server | `org.springframework.security:spring-security-oauth2-authorization-server` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-authorization-server` | `1.5.8-nes.patch.1-SNAPSHOT` |
| Logback | `ch.qos.logback:*` | 官方 | `1.5.34` |

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

### SCA 规避说明

Phase B 完成后，显式声明的 `org.springframework:*` / `org.springframework.security:*` 由 `resolutionStrategy` 替换为 fork 坐标。Phase C 对 GraphQL / Kafka 等 A 类模块在 BOM 中排除传递的官方 Spring 依赖。

仍使用 BOM import、尚未添加 exclusion 的组件（Spring Data、Integration、Session、AMQP、Batch、Pulsar、WS 等）可能仍被 SCA 扫描到官方 Spring 传递链，待后续 change 处理。

## Phase A（已完成）

见归档变更 `openspec/changes/archive/2026-06-30-bootstrap-boot-3515-nes-fork/`。
