## Why / 背景与动机

当前 `NES_GAV_MAPPING.md` 记录了 GAV 映射表（面向下游消费者），但缺失 **构建层面的自动替换机制说明**。

维护者在新增一个独立 fork 组件（如 logback）时：
- 不知道要在 `build.gradle` 的 `eachDependency` 中添加规则
- 不清楚为什么 Spring/Security 用变量计算、Logback 却要硬编码
- 容易遗漏版本号、artifactId 映射等细节

需要一份面向**维护者**的文档，说明构建时如何透明地将原始 GAV 替换为 fork GAV。

## What Changes / 变更内容

1. **新建 `doc/GAV 构建机制说明.md`**
   - 说明 `resolutionStrategy.eachDependency` 自动替换机制
   - 解释同系列 fork（Spring/Security）与独立 fork（Logback）的处理差异
   - 提供新增独立 fork 组件的 Checklist

2. **不修改 `NES_GAV_MAPPING.md`**
   - 该文档定位为消费者指南，保持现有结构不变

## Capabilities / 能力变化

### New Capabilities
- `gav-build-documentation`：提供 GAV 构建机制说明文档，帮助维护者理解 eachDependency 替换逻辑并正确新增独立 fork 组件的映射规则。

### Modified Capabilities
无

## Impact / 影响分析

- 涉及文件：`doc/GAV 构建机制说明.md`（新建）
- 影响范围：仅文档，无代码变更，无运行时影响
- 读者：未来需要新增 fork 组件 GAV 映射的维护者