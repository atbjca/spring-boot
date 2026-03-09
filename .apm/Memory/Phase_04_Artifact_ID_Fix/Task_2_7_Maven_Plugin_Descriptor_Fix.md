---
agent: Agent_Build
task_ref: Task 2.7
status: Completed
ad_hoc_delegation: false
compatibility_issues: false
important_findings: false
---

# Task Log: Task 2.7 - Maven 插件描述符 artifactId 修复

## Summary
扩展了 `spring-boot-maven-plugin/build.gradle` 中的 POM 坐标同步任务，在原有 groupId 同步基础上增加了 artifactId 同步逻辑，确保 Maven Plugin Tools 生成的 `plugin.xml` 描述符中 artifactId 与发布名一致。

## Details
- 将任务名从 `syncPluginPomGroupId` 重命名为 `syncPluginPomCoordinates`，更准确地反映任务职责
- 保留原有 groupId 同步逻辑（`replaceAll('<groupId>.*</groupId>', ...)`）
- 新增 artifactId 同步逻辑（第 185-192 行）：
  - 通过 `project.findProperty("forkArtifactPrefix")` 获取属性
  - 使用 `project.getName().replace("spring-boot", forkPrefix + "-boot")` 计算 fork artifactId（与 DeployedPlugin.java 逻辑一致）
  - 使用 `replaceFirst('<artifactId>[^<]+</artifactId>', ...)` 仅替换 POM 中第一个 `<artifactId>`（项目级坐标），不影响 `<build><plugins>` 下的插件 artifactId
  - 幂等设计：无论当前 pom.xml 中 artifactId 为何值，均会被正确覆写
- 更新了 `dependsOn` 引用为新任务名 `syncPluginPomCoordinates`
- Groovy truthiness 检查确保向后兼容（forkPrefix 为 null 或空时跳过 artifactId 替换）
- 任务名 `syncPluginPomGroupId` 在 pom.xml 注释和文档中有非功能性引用，按最小修改原则未修改

## Output
- 修改文件: `spring-boot-project/spring-boot-tools/spring-boot-maven-plugin/build.gradle`
- 修改范围: 第 160-204 行（替换原 160-183 行）

## Issues
None

## Next Steps
- 运行 `./gradlew :spring-boot-project:spring-boot-tools:spring-boot-maven-plugin:syncPluginPomCoordinates` 验证 pom.xml 中 artifactId 是否被正确同步
- 完整构建后检查 JAR 中 `META-INF/maven/plugin.xml` 的 `<artifactId>` 值
