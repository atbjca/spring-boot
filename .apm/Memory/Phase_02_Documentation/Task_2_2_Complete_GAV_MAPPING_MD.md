---
agent: Agent_Docs
task_ref: Task 2.2
status: Completed
ad_hoc_delegation: false
compatibility_issues: false
important_findings: true
---

# Task Log: Task 2.2 - 完善 doc/GAV_MAPPING.md

## Summary
全面重写 GAV_MAPPING.md，从原有 6 节扩充为 8 节，新增 35 个活跃 Starter 完整列表、18 个已排除 Starter 清单、Spring Framework 20 个模块映射、Spring Security 18 个模块映射（含 Authorization Server）、自动映射机制说明及兼容关系链。

## Details
- 读取 settings.gradle 提取完整模块列表和 ignoredStarters 集合
- 从文件系统 glob 扫描 `spring-boot-starters/` 目录，确认 54 个 starter 目录，其中 35 个活跃、18 个已排除、1 个特殊（starter-parent）
- 原文档 Starter 节仅列出 17 个，补充了 18 个缺失的活跃 Starter（data-elasticsearch、data-jdbc、data-mongodb、data-mongodb-reactive、data-redis、data-redis-reactive、freemarker、groovy-templates、jetty、log4j2、mustache、oauth2-client、oauth2-resource-server、quartz、reactor-netty、undertow、web-services、starter-parent）
- 新增已排除 Starter 清单（3.2 节），记录排除原因便于后续恢复决策
- 原文档工具节缺少 4 个模块（configuration-metadata、jarmode-layertools、gradle-test-support、test-support），已补充
- 新增 Spring Framework 完整模块映射（第 5 节），按功能分类为 6 个子节（核心容器、AOP、数据访问、Web、消息与测试、BOM）
- 新增 Spring Security 完整模块映射（第 6 节），包含核心模块、OAuth2/SAML、扩展模块、Authorization Server（独立版本）、BOM
- 从 spring-boot-dependencies/build.gradle 确认 Authorization Server 为独立 library 条目（0.4.5-nes.patch.1-SNAPSHOT），已单独标注
- 新增自动映射机制说明（第 7 节），涵盖 gradle.properties 单点配置、resolutionStrategy 工作原理、下游 BOM 使用方法（Maven/Gradle 示例）、buildSrc 特殊处理
- 新增兼容关系链（第 8 节）

## Output
- 修改文件：`doc/GAV_MAPPING.md`
- 文档结构：8 个主节，覆盖 Spring Boot（核心+Starter+工具）、Spring Framework、Spring Security 三大系列的完整模块映射 + 自动映射机制说明

## Issues
无

## Important Findings
- 发现 `spring-boot-dependencies/build.gradle` 中除 Spring Framework 和 Spring Security 的 BOM 导入外，还有一个独立的 Spring Authorization Server library 条目（版本 `0.4.5-nes.patch.1-SNAPSHOT`），使用 `forkGroupIdBase + ".security"` 作为 GroupId。此组件版本号独立于 Spring Security 主版本管理。Manager 应知悉此依赖关系，确保后续 Authorization Server 版本升级时同步更新此条目。

## Next Steps
无
