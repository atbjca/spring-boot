## Why

上游 NES Spring Kafka fork（`spring-kafka-2.9`，分支 `2.9.x-bjca-patch`）已完成 artifactId 去特征化并**已 deploy 到 Nexus**：`spring-kafka` → `bjca-footstone-bpring-kafka`、`spring-kafka-test` → `bjca-footstone-bpring-kafka-test`（GroupId、Version 不变，仅 artifactId 变化）。消费端 `spring-boot-2.7` 仍停在"artifactId 仍为 `spring-kafka`"的旧假设上，导致 Gradle 解析 `cn.bjca.footstone.bpring.kafka:spring-kafka:2.9.13-nes.patch.1-SNAPSHOT` 时会失败——该坐标在 Nexus 上已不存在。

## What Changes

- **build.gradle 替换规则三**：将 `org.springframework.kafka:spring-kafka{,-test}` 的替换目标从原样透传 artifactId（`${requested.name}`）改为 name 映射（`spring-kafka` → `bjca-footstone-bpring-kafka`、`spring-kafka-test` → `bjca-footstone-bpring-kafka-test`）；同步更新其上方过时注释。
- **spring-boot-dependencies BOM**：`library("Spring Kafka", …)` 的 `modules` key 从 `spring-kafka` / `spring-kafka-test` 改为新 artifactId；`exclude group: "org.springframework"` 规则保持不变。
- **doc/GAV 构建机制说明.md**：纠正"artifactId 仍保持 `spring-kafka` / Spring Kafka 是例外"的过时表述；不改动 2.1/2.2 fork 分类结构。
- **doc/NES_GAV_MAPPING.md**：更新映射表与 XML 示例为新 artifactId；修正"私服仍为 `spring-kafka`、未发布 `bjca-footstone-bpring-kafka*`"这一与事实相反的陈述，同时保留"未发布 `-bom`"的警告。

不改动业务模块中 `org.springframework.kafka:spring-kafka` 的依赖声明（逻辑坐标，由替换规则透明处理）。

## Capabilities

### New Capabilities
<!-- 无新增 capability -->

### Modified Capabilities
- `nes-spring-kafka-dependencies`: 两条 Requirement 的 scenario 中，NES 目标坐标的 artifactId 从 `spring-kafka{,-test}` 更新为 `bjca-footstone-bpring-kafka{,-test}`——涉及 "Boot BOM manages NES Spring Kafka modules" 与 "Build resolves Spring Kafka declarations to NES modules"。另两条 Requirement（"Kafka BOM is not assumed"、"Spring Kafka fork status is documented consistently"）不变。

## Impact

- **构建**：`build.gradle`、`spring-boot-project/spring-boot-dependencies/build.gradle`
- **文档**：`doc/GAV 构建机制说明.md`、`doc/NES_GAV_MAPPING.md`
- **依赖坐标**：消费端解析目标对齐 Nexus 已发布的 `bjca-footstone-bpring-kafka{,-test}`
- **验证**：`make build-thin`，确认无 could-not-resolve 依赖解析错误
- **不在本次范围**（单独 finding）：`spring-boot-project/spring-boot-docs/build.gradle:337` 的 `versionConstraints["org.springframework.kafka:spring-kafka"]` 静默坏链（返回 null → 文档链接 `.../docs/null/...`），系上一次 adopt 变更遗留、与本次改名正交的既有 bug，留待单独 change 处理。
