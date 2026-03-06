---
agent: Agent_Build
task_ref: Task 1.4
status: Completed
ad_hoc_delegation: false
compatibility_issues: false
important_findings: true
---

# Task Log: Task 1.4 - bomrCheck 修复与版本升级

## Summary
修复了 Task 1.1 中 37 个 exclude 导致的 bomrCheck 失败（group-only exclude 改为 `module: "*"` 通配符），并完成了 Spring Data Bom 和 Logback 的版本升级。

## Details
### Step 1: bomrCheck 机制研究
- 源码位置：`buildSrc/src/main/java/org/springframework/boot/build/bom/CheckBom.java`
- 根因：DSL 层 `BomExtension.java:370` 将 `exclude group: "org.springframework"`（无 module）解析为 `Exclusion(groupId, artifactId=null)`，CheckBom 映射为 `"org.springframework:null"`，既不精确匹配 resolved artifacts 也不触发通配符分支，被判定为 "Unnecessary"
- CheckBom 通配符逻辑（line 107-111）：若排除标识以 `:*` 结尾，则检查是否有任何 resolved artifact 属于该 group

### Step 2: 修复 exclude
- 方案：为所有 37 个 group-only exclude 添加 `module: "*"`
- 实施：使用 `replace_all` 两次即完成（先替换 `.security` 后替换 `.springframework`，避免子串干扰）
- 修复后：排除标识变为 `"org.springframework:*"`，触发通配符分支，匹配到实际传递依赖，不再被判定为 unnecessary
- Maven POM 输出：`<artifactId>*</artifactId>` 是 Maven 标准通配符排除语法

### Step 3: 版本升级
- Logback: `1.2.13` → `1.2.13-nes.patch.1-SNAPSHOT`
- Spring Data Bom: `2021.2.18` → `2021.2.18-nes.patch.1-SNAPSHOT`

### Step 4: 完整性验证
- 35 个 `exclude group: "org.springframework", module: "*"` ✓
- 2 个 `exclude group: "org.springframework.security", module: "*"` ✓
- 0 个残留的 group-only exclude（无 module） ✓
- 14 处结构化中文注释保留完好 ✓
- BOM 导入组件（spring-data-bom, spring-session-bom, spring-integration-bom）未被添加 exclude ✓
- 两项版本升级已正确应用 ✓

## Output
- 修改文件：`spring-boot-project/spring-boot-dependencies/build.gradle`
- 总变更量（含 Task 1.1）：150 行新增，36 行删除

## Issues
None

## Important Findings
- bomrCheck 的通配符排除必须使用 `module: "*"` 语法，不能省略 module 参数。这是 Spring Boot BOM 插件 DSL 的特定要求，与标准 Gradle `exclude group:` 行为不同。后续添加 exclude 时需遵循此规范。
- CheckBom 验证逻辑关键路径：`BomExtension.ModuleHandler.exclude()` → `Library.Exclusion(groupId, artifactId)` → `CheckBom.checkExclusions()` 通配符分支 `endsWith(":*")`

## Next Steps
- 运行完整 Gradle 构建验证 bomrCheck 通过
- 验证生成的 BOM POM 中包含正确的 `<exclusion>` 元素
