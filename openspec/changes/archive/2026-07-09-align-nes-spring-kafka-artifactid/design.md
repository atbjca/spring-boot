## Context

上一次 change `2026-07-08-adopt-nes-spring-kafka-dependencies` 在消费端 `spring-boot-2.7` 建立了 Spring Kafka 的 fork 替换，但当时 producer 仅完成 GroupId/Version 去特征化，artifactId 仍沿用 `spring-kafka` / `spring-kafka-test`。因此消费端两处对 artifactId 的处理都建立在"原样透传"之上：

- `build.gradle` 替换规则三：`useTarget("cn.bjca.footstone.bpring.kafka:${requested.name}:2.9.13-nes.patch.1-SNAPSHOT")`——`${requested.name}` 直接透传官方 artifactId。
- `spring-boot-dependencies/build.gradle` 的 `library("Spring Kafka")`：`modules` key 写死 `spring-kafka` / `spring-kafka-test`。

producer（`spring-kafka-2.9` commit `b35fa1b86`）随后补齐了 artifactId 去特征化并已 deploy 到 Nexus：发布坐标变为 `bjca-footstone-bpring-kafka{,-test}`。旧 artifactId 在 Nexus 上已不存在，消费端若不对齐，解析将 could-not-resolve。

约束：坚守 Spring Boot 2.7.x 基线；不改动业务模块的官方坐标声明（fork 方案的透明性核心）；遵循项目"四件套"（版本对齐/归档/台账/验证）节奏。

## Goals / Non-Goals

**Goals:**
- 消费端解析目标与 Nexus 已发布的 `bjca-footstone-bpring-kafka{,-test}` 对齐。
- BOM `modules` key 同步为新 artifactId，使 `exclude org.springframework:*` 在替换后的最终坐标上仍能匹配。
- 维护者文档与实际构建行为一致（消除"artifactId 仍为 spring-kafka"的过时/错误表述）。

**Non-Goals:**
- 不改动业务模块中 `org.springframework.kafka:spring-kafka` 的依赖声明。
- 不修 `spring-boot-docs/build.gradle:337` 的 `versionConstraints` 坏链（正交的既有 bug，单独 change）。
- 不调整 `doc/GAV 构建机制说明.md` 的 2.1/2.2 fork 分类结构。
- 不改动 GroupId、Version，不引入 Kafka BOM。

## Decisions

### 决策 1：替换规则采用前缀替换（写法 B），而非逐一 if 映射
改为与同文件规则一（Framework）、规则二（Security）同构的 `replaceFirst` 前缀替换：

```groovy
else if (requested.group == 'org.springframework.kafka' && requested.name.startsWith('spring-kafka')) {
    def newArtifactId = requested.name.replaceFirst(/^spring-/, "bjca-footstone-bpring-")
    details.useTarget("cn.bjca.footstone.bpring.kafka:${newArtifactId}:2.9.13-nes.patch.1-SNAPSHOT")
}
```

`spring-kafka` → `bjca-footstone-bpring-kafka`、`spring-kafka-test` → `bjca-footstone-bpring-kafka-test`，一次覆盖。

**为何不用逐一 if 映射**：显式 if 写法更冗长，且与仓库既有 Framework/Security 规则风格不一致。前缀替换与 `forkArtifactPrefix`（`bjca-footstone-bpring`）的语义天然吻合。
**关键陷阱**：映射结果不能多留 `spring-` 前缀（正确 `bjca-footstone-bpring-kafka`，错误 `bjca-footstone-bpring-spring-kafka`）——这正是 `doc/GAV 构建机制说明.md` Q3 反复警告的经典错误。`replaceFirst(/^spring-/, …)` 恰好避开此坑。

### 决策 2：替换规则与 BOM modules 必须配对修改
Gradle 解析顺序：先经 `resolutionStrategy.eachDependency` 的 `useTarget` 得到最终坐标，再由 `dependencyManagement` 按**最终坐标**匹配 `modules` 以套用 `exclude`。因此 `modules` key 必须使用替换后的 artifactId（`bjca-footstone-bpring-kafka{,-test}`），而非逻辑名。

**若只改替换规则、漏改 modules key**：`exclude group: "org.springframework"` 将匹配不到已改名的最终坐标 → 官方 `org.springframework:*` 传递依赖漏进 classpath → 同一 classpath 出现两套 Spring Framework，产生运行时冲突。两处是强耦合，必须同一 change 内配对完成。

### 决策 3：文档修正采取"最小改"
仅纠正与事实/行为冲突的表述，不重构文档结构：
- `doc/GAV 构建机制说明.md`：更正表格与注释中"artifactId 仍保持 spring-kafka / Spring Kafka 是例外"的措辞；Kafka 仍留在 2.1 同系列 fork 节（其 GroupId 挂 `.kafka` 子命名空间，与 `forkGroupIdBase` 有继承关系，不属于 Logback 那种完全独立命名空间）。
- `doc/NES_GAV_MAPPING.md`：更新映射表/示例为新 artifactId；第 586 行的"未发布 `bjca-footstone-bpring-kafka*`"是与 deploy 事实相反的错误陈述，须改为"已发布"；但同句"未发布 `-bom`"仍成立且呼应 spec 的 "Kafka BOM is not assumed" 约束，必须**保留**。

## Risks / Trade-offs

- **[漏改 BOM modules → 两套 Spring 冲突]** → 决策 2 明确配对修改；`make build-thin` 验证依赖解析，必要时检查 `dependencies` 输出确认无官方 `org.springframework:*` 泄漏。
- **[映射多留 `spring-` 前缀 → 坐标错误]** → 用 `replaceFirst(/^spring-/, …)`，并以 Nexus 实际发布的 `bjca-footstone-bpring-kafka{,-test}` 为准核对。
- **[误删 NES_GAV_MAPPING.md 的无 BOM 警告]** → 明确区分"artifactId 已发布"（改）与"BOM 未发布"（留），不整段删除。
- **[前缀条件 `startsWith('spring-kafka')` 误伤未来新模块]** → 当前 producer 仅发布 `bjca-footstone-bpring-kafka{,-test}`；若未来新增其他 `spring-kafka-*` 模块，需确认其在 Nexus 存在再依赖，属后续维护范畴。

## Migration Plan

1. 前提：producer 已 deploy `bjca-footstone-bpring-kafka{,-test}` 至 Nexus（已确认）。
2. 配对修改 `build.gradle` 替换规则 + `spring-boot-dependencies` BOM modules。
3. 同步修正两份文档。
4. `make build-thin` 验证无 could-not-resolve；按四件套完成台账/归档。
5. 回滚：本 change 仅调整坐标字符串与文档，`git revert` 即可恢复旧透传行为（但旧坐标已不在 Nexus，回滚仅用于应急）。
