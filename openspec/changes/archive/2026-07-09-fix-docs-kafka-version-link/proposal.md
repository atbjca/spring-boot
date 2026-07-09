## Why

`spring-boot-project/spring-boot-docs/build.gradle:337` 的 `"spring-kafka-version": versionConstraints["org.springframework.kafka:spring-kafka"]` 查询 key 与 BOM 实际坐标失配（BOM 中 Spring Kafka 的 group 早已改为 `cn.bjca.footstone.bpring.kafka`），返回 `null`，导致 `attributes.adoc:92` 的官方参考文档外链渲染成 `https://docs.spring.io/spring-kafka/docs/null/reference/html/`（静默坏链）。即便把 key 修对，值也会变成 fork 内部版本 `2.9.13-nes.patch.1-SNAPSHOT`，而 spring.io 官网只有官方版本号 `2.9.13` 的文档——链接仍不可达。

## What Changes

- `spring-boot-docs/build.gradle:337`：将 `spring-kafka-version` 的取值由 `versionConstraints[...]` 查询改为直接使用官方基线版本号 `"2.9.13"`（该变量唯一用途是拼 spring.io 官方文档外链，天然需要官方版本而非 fork 内部版本）；加注释说明来源与升级时的手动跟随约定。

不改动任何依赖解析逻辑、BOM、替换规则；仅此一行 + 注释。

## Capabilities

### New Capabilities
<!-- 无 -->

### Modified Capabilities
- `nes-spring-kafka-dependencies`: 新增一条 Requirement，约束参考文档中 Spring Kafka 版本属性必须解析为**可达的官方基线版本**（不得为 `null` 或带 fork 后缀的不可达版本）。归入既有 "fork status is documented consistently" 主题所在 capability。

## Impact

- **文档构建**：`spring-boot-project/spring-boot-docs/build.gradle`（1 行 + 注释）
- **可见影响**：仅在生成参考文档（asciidoctor）时体现；`make build-thin` / `make clean deploy` 因 `-x asciidoctor` 不触发，故本次不因构建暴露
- **验证**：确认 `spring-kafka-version` 属性解析为 `2.9.13`，拼出的外链指向 spring.io 真实存在的文档路径
- **来源**：探索 `align-nes-spring-kafka-artifactid` 时记录的 finding（memory: `docs337-spring-kafka-version-broken-link`），与 artifactId 改名正交，故独立成 change
