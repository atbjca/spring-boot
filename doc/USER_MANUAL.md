# User Manual

## Spring Kafka NES 坐标

Spring Kafka NES 分支使用以下 Maven 坐标：

| 用途 | GroupId | ArtifactId | 版本 |
|------|---------|------------|------|
| 主模块 | `cn.bjca.footstone.bpring.kafka` | `bjca-footstone-bpring-kafka` | 由 Boot BOM 管理 |
| 测试模块 | `cn.bjca.footstone.bpring.kafka` | `bjca-footstone-bpring-kafka-test` | 由 Boot BOM 管理 |

Java 包名不变，业务代码中的 `import org.springframework.kafka.*` 无需修改。

## 传递依赖说明

Spring Kafka NES POM 仍包含官方 Spring Framework 传递依赖。NES Boot BOM 已排除这些官方 `org.springframework:*` 坐标，避免与 NES Spring Framework 混用。

如果项目直接使用 Spring Kafka 且没有通过 Starter 获得相关 Spring Framework 模块，请按 `doc/NES_GAV_MAPPING.md` 的 Spring Kafka 小节补充 `bjca-footstone-bpring-context`、`bjca-footstone-bpring-messaging`、`bjca-footstone-bpring-tx` 等依赖。

## 不存在的 Kafka BOM

当前私服未发布 `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-bom`。请通过 NES Spring Boot BOM 管理 Spring Kafka 版本，不要单独导入 Kafka BOM。

## Kafka Header 反序列化安全配置

Spring Kafka NES commit `c119b8f62` 已回移 CVE-2026-41731 修复。`DefaultKafkaHeaderMapper` 现在仅按**精确包名**判断受信类型，父包不再自动信任子包。

例如，仅配置：

```java
mapper.addTrustedPackages("com.example");
```

只会信任直接声明在 `com.example` 包中的类型，不会继续信任 `com.example.events.OrderEvent`。需要显式列出实际使用的子包：

```java
mapper.addTrustedPackages(
		"com.example",
		"com.example.events",
		"com.example.shared");
```

不要使用 `addTrustedPackages("*")` 代替迁移。该配置会显式信任所有类型，只适用于 Producer 和 Topic 写权限完全可信的环境。

当前 Boot 仍管理可变版本 `2.9.13-nes.patch.1-SNAPSHOT`。已验证的安全时间戳为 `20260721.054238-2`；旧构建环境可能缓存修复前的同版本 JAR，升级或发布前应刷新 changing module 并运行 Kafka 安全回归测试。
