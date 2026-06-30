# NES GAV 映射（Spring Boot 3.5 兼容链）

## Phase A（当前）

| 组件 | 官方坐标 | Phase A 策略 | 版本 |
|------|----------|--------------|------|
| Spring Boot | `org.springframework.boot:*` | **Fork** → `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-*` | `3.5.15-nes.patch.1-SNAPSHOT` |
| Spring Framework | `org.springframework:*` | 官方 | `6.2.19` |
| Spring Security | `org.springframework.security:*` | 官方 | `6.5.11` |
| Logback | `ch.qos.logback:*` | 官方 | `1.5.34` |

### Fork 参数

| 参数 | 值 |
|------|-----|
| `forkGroupIdBase` | `cn.bjca.footstone.bpring` |
| `forkArtifactPrefix` | `bjca-footstone-bpring` |
| `springBootVersion` | `3.5.15` |

### 映射示例

| 官方 GAV | Fork GAV |
|----------|----------|
| `org.springframework.boot:spring-boot-starter-web:3.5.15` | `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-web:3.5.15-nes.patch.1-SNAPSHOT` |
| `org.springframework.boot:spring-boot-dependencies:3.5.15` | `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-dependencies:3.5.15-nes.patch.1-SNAPSHOT` |

## Phase B（待办）

- [ ] Fork Spring Framework 6.2.x → `cn.bjca.footstone.bpring.framework:*`
- [ ] Fork Spring Security 6.5.x → `cn.bjca.footstone.bpring.security:*`
- [ ] 在根 `build.gradle` 添加 `resolutionStrategy.eachDependency` 映射规则
- [ ] 更新本文件兼容链与 SCA 规避说明
