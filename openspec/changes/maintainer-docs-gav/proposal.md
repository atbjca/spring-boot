## Why

3.5 fork 已有 `NES_GAV_MAPPING.md`（消费者视角映射表）和 `REQUIREMENTS.md`（需求记录），但缺少面向**维护者**的构建机制说明。新人接手或需要扩展 fork 范围时，需要一份类似 2.7 `GAV 构建机制说明.md` 的文档，解释 eachDependency 规则如何工作、如何新增 A 类组件 exclusion、如何处理 bom→modules 转换。

## What Changes

创建 `doc/GAV_BUILD_MECHANISM.md`，内容包括：

- **eachDependency 概述**：构建期透明替换机制的工作流程。
- **两种命名空间处理**：同系列 fork（Framework/Security 用变量计算）vs 独立 fork（AMQP/Batch/WS/RESTDocs 用 exclusion）。
- **Authorization Server 特殊处理**：3.5 独有的独立版本变量和专门分支。
- **bom→modules 转换模式**：3.5 上游改 BOM import 后如何恢复 exclusion。
- **A 类组件 exclusion Checklist**：参考 2.7，新增独立 fork 组件时的操作步骤。
- **FAQ / 常见错误**：artifactId 前缀遗漏、版本升级同步注意事项。

### Non-goals

- 不修改构建脚本本身（仅文档）。
- 不覆盖 Logback bogback（3.5 不 fork Logback）。

## Capabilities

### New Capabilities

- `gav-build-docs`: GAV 构建机制维护者文档，记录构建期自动替换规则、新增组件操作手册、FAQ。

## Impact

- **新增文件**：`doc/GAV_BUILD_MECHANISM.md`。
- **无代码变更**：不影响构建和测试。
