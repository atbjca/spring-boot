---
agent: Agent_Docs
task_ref: Task 5.1
status: Completed
ad_hoc_delegation: false
compatibility_issues: false
important_findings: false
---

# Task Log: Task 5.1 - NES_GAV_MAPPING.md 新增 A 类组件传递依赖排除说明

## Summary
在 `doc/NES_GAV_MAPPING.md` 中新增第 9 章「A 类组件传递依赖排除说明」，覆盖全部 8 个 A 类库的缺失 Spring 传递依赖及对应 fork 替代坐标，并提供 Maven 配置示例。同步修复了原文档章节编号错误（两个 §8），将「注意事项」重编号为 §10。

## Details
- 读取现有 `doc/NES_GAV_MAPPING.md`，确认文档结构和风格
- 通过 Explore Agent 从本地 Gradle 缓存读取 Spring GraphQL 1.0.6 POM，确认其 Spring 传递依赖为：spring-context（直接）、spring-aop、spring-beans、spring-core、spring-expression（经 spring-context 传递）
- 新增 §9 包含四个子章节：
  - §9.1 背景：排除原因（防止双坐标冲突）、影响范围（8 个 A 类库总览表）、对下游消费者影响
  - §9.2 三类库影响程度：活跃 Starter（batch、web-services）、已排除 Starter（hateoas、data-ldap、amqp）、无 Starter（kafka、graphql、restdocs）
  - §9.3 各库缺失依赖详表（8 个子节，每库列出缺失依赖 → fork ArtifactId 映射表 + 最小补充集）
  - §9.4 Maven 配置示例（kafka、batch-core、amqp+rabbit、graphql 四个高频场景）
- 更新目录（TOC）：新增第 9 项，原第 9 项重编号为 10
- 修复原文档 §8 重复编号问题：「注意事项」及其子节（8.1-8.5）统一更新为 10.x

## Output
- 修改文件：`doc/NES_GAV_MAPPING.md`
  - 新增约 270 行内容（§9 全章）
  - TOC 更新（1 行新增，1 行修改）
  - §10 子节编号修复（5 处 8.x → 10.x）

## Issues
None

## Next Steps
None
