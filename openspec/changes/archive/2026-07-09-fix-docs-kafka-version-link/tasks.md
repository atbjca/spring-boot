## 1. 修改

- [x] 1.1 `spring-boot-project/spring-boot-docs/build.gradle:337`：将 `"spring-kafka-version": versionConstraints["org.springframework.kafka:spring-kafka"],` 改为 `"spring-kafka-version": "2.9.13",`，并加注释说明该值为 spring.io 官方基线版本、与 fork 内部版本解耦、升级 Kafka 基线时需手动同步

## 2. 验证

- [x] 2.1 确认改后该行语法正确、无残留 `versionConstraints[...]` 的 kafka 查询
- [x] 2.2 确认 `attributes.adoc:92` 拼出的外链为 `https://docs.spring.io/spring-kafka/docs/2.9.13/reference/html/`，不含 `null`

## 3. 归档

- [x] 3.1 归档本 change，spec 增量（新增 Requirement）sync 回 `openspec/specs/nes-spring-kafka-dependencies/`
- [x] 3.2 更新 memory：将 `docs337-spring-kafka-version-broken-link` 标记为已修复（或删除该 finding 记录）
