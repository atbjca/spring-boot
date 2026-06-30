## Context / 背景

Spring Boot fork 项目通过 `resolutionStrategy.eachDependency` 在构建期透明地将原始 GAV 替换为 fork GAV，使所有子模块无需手动修改依赖声明。

目前有两类 fork 命名空间：

```
同系列 fork（使用 forkGroupIdBase 变量动态计算）
───────────────────────────────────────────────────
  Spring Framework  → cn.bjca.footstone.bpring:bjca-footstone-bpring-*
  Spring Security   → cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-*
  命名规律：共享 forkGroupIdBase（cn.bjca.footstone.bpring），自然派生子空间

独立 fork（硬编码规则）
───────────────────────────────────────────────────
  Logback           → cn.bjca.footstone.bogback:bjca-footstone-bogback-*
  命名规律：独立命名空间（bogback ≠ bpring），无法通过变量计算得到
```

## Goals / Non-Goals

**Goals:**
- 文档结构清晰，分层说明机制与操作步骤
- 涵盖同系列 fork 与独立 fork 的判断标准
- 提供可直接照做的 Checklist，降低遗漏风险

**Non-Goals:**
- 不修改任何代码
- 不改动 NES_GAV_MAPPING.md 的现有内容
- 不提供运行时验证（文档层面保证正确性即可）

## Decisions / 关键决策

### Decision 1: 文档名称
`doc/GAV 构建机制说明.md`

理由：简洁、明确表达文档面向维护者说明构建机制，与 `NES_GAV_MAPPING.md` 形成系列。

### Decision 2: 文档结构
```
1. 概述：自动替换机制的工作原理
2. 两种命名空间处理方式（同系列 vs 独立）
3. 新增独立 fork 组件的 Checklist
4. 常见问题与风险提示
```

理由：按"理解 → 区分 → 操作 → 风险"的认知顺序组织，符合学习曲线。

### Decision 3: 不重复已有映射表
本文档不复制 `NES_GAV_MAPPING.md` 中的映射表，仅在"新增 Checklist"中引用该文档作为版本信息源。

理由：避免两处维护同一份数据，消除后续同步遗漏风险。

## Risks / Trade-offs

| 风险 | 级别 | 缓解措施 |
|------|------|----------|
| 文档与代码实现不同步 | 低 | Checklist 中的步骤需与实际代码对照验证 |
| 维护者忽略文档直接硬编码 | 低 | Checklist 强调"先查文档再动手" |