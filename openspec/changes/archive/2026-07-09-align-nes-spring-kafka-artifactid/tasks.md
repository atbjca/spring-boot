## 1. 代码层：替换规则与 BOM（必须配对）

- [x] 1.1 修改 `build.gradle` 替换规则三（约 126-133 行）：改为前缀替换写法 `requested.name.replaceFirst(/^spring-/, "bjca-footstone-bpring-")`，条件用 `requested.group == 'org.springframework.kafka' && requested.name.startsWith('spring-kafka')`，`useTarget("cn.bjca.footstone.bpring.kafka:${newArtifactId}:2.9.13-nes.patch.1-SNAPSHOT")`
- [x] 1.2 更新 `build.gradle` 124-127 行注释：删除"仅更换 groupId 和版本号，artifactId 仍保持 spring-kafka / spring-kafka-test"表述，改为反映 artifactId 已映射为 `bjca-footstone-bpring-kafka{,-test}`
- [x] 1.3 修改 `spring-boot-project/spring-boot-dependencies/build.gradle` 的 `library("Spring Kafka", …)`（约 1900、1903 行）：`modules` key `spring-kafka` → `bjca-footstone-bpring-kafka`、`spring-kafka-test` → `bjca-footstone-bpring-kafka-test`；保持各 module 的 `exclude group: "org.springframework", module: "*"` 不变
- [x] 1.4 复核：确认 artifactId 未多留 `spring-` 前缀（应为 `bjca-footstone-bpring-kafka`，非 `bjca-footstone-bpring-spring-kafka`），且与 Nexus 实际发布坐标一致

## 2. 文档层：最小改

- [x] 2.1 `doc/GAV 构建机制说明.md` 第 67 行表格：Spring Kafka 行的 Fork GAV/处理方式更新为 artifactId 已去特征化
- [x] 2.2 `doc/GAV 构建机制说明.md` 第 89-90、102 行：更正"artifactId 仍保持 spring-kafka / Spring Kafka 是例外"的注释与说明；不改动 2.1/2.2 分类结构
- [x] 2.3 `doc/NES_GAV_MAPPING.md` 第 63 行及第 583-584 行映射表：NES 坐标 artifactId 更新为 `bjca-footstone-bpring-kafka{,-test}`
- [x] 2.4 `doc/NES_GAV_MAPPING.md` 第 586 行：将"当前私服实际发布 artifactId 仍为 spring-kafka / spring-kafka-test"改为"已发布 bjca-footstone-bpring-kafka*"；**保留**同句"未发布 …-bom"警告
- [x] 2.5 `doc/NES_GAV_MAPPING.md` 第 713 行 XML 示例：`<artifactId>spring-kafka</artifactId>` → `bjca-footstone-bpring-kafka`

## 3. 验证与归档（四件套）

- [x] 3.1 运行 `make build-thin`，确认无 could-not-resolve 依赖解析错误
- [x] 3.2 检查解析结果无官方 `org.springframework:*` 传递依赖泄漏（确认 exclude 在改名后的最终坐标上仍生效）
- [x] 3.3 按项目规范更新版本台账/维护记录（对齐"四件套"节奏）
- [x] 3.4 归档本 change（`/opsx:archive`），将 spec 增量 apply 回 `openspec/specs/nes-spring-kafka-dependencies/`

## 4. 范围外（记录，不在本 change 处理）

- [x] 4.1 记录 finding：`spring-boot-project/spring-boot-docs/build.gradle:337` 的 `versionConstraints["org.springframework.kafka:spring-kafka"]` 静默坏链（返回 null → 文档链接 `.../docs/null/...`），留待单独 change
