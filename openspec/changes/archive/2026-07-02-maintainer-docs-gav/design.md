## Context

2.7 的 `GAV 构建机制说明.md` 验证了维护者文档的价值（FAQ、Checklist 避免了重复踩坑）。3.5 有以下差异需要在文档中特别说明：

- Authorization Server 在 3.5 有独立版本变量和专门分支，2.7 没有。
- Phase C 建立了 A 类组件 BOM exclusion 机制（Phase C exclusion 模式）。
- AMQP/Batch/WS/RESTDocs 从 bom() 改回 modules 的 bom→modules 转换模式是 3.5 独有的工程经验。

## Goals / Non-Goals

**Goals:**
- 提供完整的 eachDependency 机制说明，供维护者理解和扩展。
- 为新增 A 类组件 exclusion 提供 Checklist，避免遗漏 artifactId 前缀等常见错误。
- 明确区分同系列 fork（Framework/Security）和独立 fork（A 类 exclusion）两种模式。

**Non-goals:**
- 不修改任何构建脚本。
- 不替代 NES_GAV_MAPPING.md（消费者视角文档独立存在）。

## Decisions

### Decision 1：文档结构沿用 2.7 五节结构并适配 3.5

2.7 结构清晰（概述→两类命名空间→Checklist→FAQ→文件索引），3.5 版本沿用并替换为 3.5 的具体规则和例子。

### Decision 2：不创建 OpenSpec spec

这是纯文档交付，不引入新的 capability 或 requirement。不需要 spec 文件。

### Decision 3：bom→modules 作为独立一节

这是 3.5 独有的工程经验（Phase C exclusion 机制的一部分），单独成节说明，而非作为 Checklist 的一部分。
