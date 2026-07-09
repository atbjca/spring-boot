## Context

`spring-boot-docs/build.gradle` 通过 `versionConstraints`（来自 `ExtractVersionConstraints` 任务，key = BOM 声明的 `group:artifactId`）为一批文档属性注入版本号。官方原版对 Spring Kafka 用 `versionConstraints["org.springframework.kafka:spring-kafka"]`。

fork 场景下这条路已断：`adopt-nes-spring-kafka` 把 BOM 中 Spring Kafka 的 group 改为 `cn.bjca.footstone.bpring.kafka`（后续 `align-nes-spring-kafka-artifactid` 又把 artifactId 改为 `bjca-footstone-bpring-kafka`），因此官方 key 查不到 → `null`。而该属性唯一消费点 `attributes.adoc:92` 是拼 **spring.io 官方文档站**外链，需要的是官方版本号 `2.9.13`——即使改用 BOM 现坐标查到 `2.9.13-nes.patch.1-SNAPSHOT`，官网也无此版本文档。

## Goals / Non-Goals

**Goals:**
- `spring-kafka-version` 解析为可达的官方基线 `2.9.13`，生成的 spring.io 外链有效、不含 `null`。

**Non-Goals:**
- 不改动依赖解析、BOM、替换规则。
- 不改动 `versionConstraints` 机制本身或其他组件的版本属性。
- 不引入新的 gradle 版本变量。

## Decisions

### 决策：直接使用官方基线常量 `"2.9.13"`，弃用 versionConstraints 查询
将该行改为 `"spring-kafka-version": "2.9.13",` 并加注释说明：该值是 spring.io 文档站的官方基线版本，与 fork 内部版本（BOM 的 `2.9.13-nes.patch.1-SNAPSHOT`）解耦；Kafka 基线升级时需手动同步此处。

**为何不修 key 了事**：修对 key 只能消灭字面 `null`，值仍是 fork 后缀版本，spring.io 无此文档 → 链接照样 404。属性的语义就是"官方文档版本"，直接写官方基线最诚实、可达。
**为何不新引入变量推导**：consumer 侧无 kafka 基线变量，为一条文档外链引入变量并做后缀剥离过重；Kafka 版本升级本就需人工介入（同步 producer），手动跟一行常量不构成额外负担。

## Risks / Trade-offs

- **[升级 Kafka 基线后忘改此常量 → 链接指向旧版文档]** → 加注释显式提示；此风险与项目既有"fork 版本升级需人工介入"的性质一致，可接受。
- **[误判官方基线号]** → fork 版本 `2.9.13-nes.patch.1-SNAPSHOT` 的上游基线即 `2.9.13`（见 producer `springKafkaVersion=2.9.13`），确定。
