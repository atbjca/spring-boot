# User Manual

## Spring Kafka NES 坐标

Spring Kafka NES 分支使用以下 Maven 坐标：

| 用途 | GroupId | ArtifactId | 版本 |
|------|---------|------------|------|
| 主模块 | `cn.bjca.footstone.bpring.kafka` | `spring-kafka` | 由 Boot BOM 管理 |
| 测试模块 | `cn.bjca.footstone.bpring.kafka` | `spring-kafka-test` | 由 Boot BOM 管理 |

Java 包名不变，业务代码中的 `import org.springframework.kafka.*` 无需修改。

## 传递依赖说明

Spring Kafka NES POM 仍包含官方 Spring Framework 传递依赖。NES Boot BOM 已排除这些官方 `org.springframework:*` 坐标，避免与 NES Spring Framework 混用。

如果项目直接使用 Spring Kafka 且没有通过 Starter 获得相关 Spring Framework 模块，请按 `doc/NES_GAV_MAPPING.md` 的 Spring Kafka 小节补充 `bjca-footstone-bpring-context`、`bjca-footstone-bpring-messaging`、`bjca-footstone-bpring-tx` 等依赖。

## 不存在的 Kafka BOM

当前私服未发布 `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-bom`。请通过 NES Spring Boot BOM 管理 Spring Kafka 版本，不要单独导入 Kafka BOM。
