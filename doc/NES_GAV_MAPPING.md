# NES GAV 映射（Spring Boot 3.5 兼容链）

## Phase B（当前）

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

Phase B 完成后，Boot 构建传递依赖中的 `org.springframework` / `org.springframework.security` groupId 均被 `resolutionStrategy.eachDependency` 透明替换为 fork 坐标。以下 A 类生态组件仍可能传递官方 Spring 坐标（待后续 change 处理）：

- Spring Data / Session / GraphQL / Kafka / Integration 等

## Phase A（已完成）

见归档变更 `openspec/changes/archive/2026-06-30-bootstrap-boot-3515-nes-fork/`。
