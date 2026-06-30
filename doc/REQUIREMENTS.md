# NES Fork 需求记录

## [需求-001] Bootstrap 3.5.15 NES Fork Phase A

| 字段 | 内容 |
|------|------|
| 状态 | 已完成 |
| 基线 | Spring Boot 3.5.15（commit `5bafd0a6bf1`） |
| Fork 版本 | `3.5.15-nes.patch.1-SNAPSHOT` |
| 范围 | Boot 层 GAV rebranding、Nexus 发布链路、Makefile 工具链 |
| 非目标 | Framework 6.2.x / Security 6.5.x / Logback fork（Phase B） |

### 验收标准

- 所有 Boot 模块发布坐标为 `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-*`
- `SpringBootVersion.getVersion()` 返回 `3.5.15`
- `make build-thin` 编译通过
- `make install` 本地仓库 GAV 正确

### Nexus 配置

在 `~/.gradle/gradle.properties` 中配置（勿提交凭据）：

```properties
nexusPublicUrl=http://host/repository/maven-public/
nexusReleaseUrl=http://host/repository/releases/
nexusSnapshotUrl=http://host/repository/snapshots/
nexusUsername=your-user
nexusPassword=your-password
```

## [需求-002] Framework / Security GAV 映射 Phase B

| 字段 | 内容 |
|------|------|
| 状态 | 实施中 |
| 基线 | Phase A 完成后的 `3.5.x-bjca-patch` |
| Framework 版本 | `6.2.19-nes.patch.1-SNAPSHOT` |
| Security 版本 | `6.5.11-nes.patch.1-SNAPSHOT` |
| Authorization Server 版本 | `1.5.8-nes.patch.1-SNAPSHOT` |
| 范围 | `resolutionStrategy` 映射、BOM 条目、buildSrc 坐标切换 |
| 前提 | Framework / Security fork 制品已发布到 Nexus |

### 验收标准

- 构建解析 `org.springframework:*` / `org.springframework.security:*` 为 fork GAV
- `make build-thin` 编译通过
- `make test` 核心模块全绿
- BOM POM 中 Framework / Security managed deps 使用 fork groupId
