# Spring Boot 2.7 Fork GAV 自动映射改造 – APM Implementation Plan
**Memory Strategy:** Dynamic-MD
**Last Modification:** Phase 2 complete — All tasks finished. REQUIREMENTS.md restored with 需求-001~018; GAV_MAPPING.md expanded to 8 sections covering full module mappings. Project complete.
**Project Overview:** 对 Spring Boot 2.7.18 fork 项目实施 GAV 自动映射机制改造。通过 Gradle resolutionStrategy.eachDependency 实现 org.springframework / org.springframework.security 到 fork GAV 的透明替换，使子模块 build.gradle 无需修改即可解析 fork 依赖。同时恢复 BOM 导入方式、集中化 GAV 配置、完善项目文档。所有变更需添加完备中文注释。

## Phase 1: Gradle 构建基础设施改造

### Task 1.1 – gradle.properties GAV 配置集中化 - Agent_Build
**Objective:** 将所有 fork 相关的 GAV 映射参数集中定义到 gradle.properties，实现单点管理。
**Output:** 更新后的 gradle.properties 文件，包含完整的 fork 配置参数和中文注释。
**Guidance:** 核心发现——所有 artifactId 转换共享同一规则（`spring` → fork 前缀），因此仅需两个核心参数。所有参数必须有中文注释。

- 新增 `forkArtifactPrefix=bjca-footstone-bpring`（制品名前缀，替换原始 `spring`）和 `forkGroupIdBase=cn.bjca.footstone.bpring`（基础 GroupId，自动派生 `.boot` / `.security`）
- 保留并整理已有版本配置（`version`、`springFrameworkVersion`、`springSecurityVersion`），新增 `springBootVersion=2.7.18`（用于 SpringBootVersion.getVersion() 运行时常量）
- 每个配置项添加完备中文注释，说明用途、影响范围、配置变更示例

### Task 1.2 – root build.gradle 自动映射机制实现 - Agent_Build
**Objective:** 通过 resolutionStrategy.eachDependency 实现 org.springframework / org.springframework.security 到 fork GAV 的自动透明替换。
**Output:** 修改后的 build.gradle，包含完整的自动映射逻辑和中文注释。
**Guidance:** 映射规则——对 `org.springframework` 组：artifactId 中 `spring-` 替换为 `${forkArtifactPrefix}-`，GroupId 替换为 `${forkGroupIdBase}`；对 `org.springframework.security` 组：同理但 GroupId 替换为 `${forkGroupIdBase}.security`。需确保不影响 buildSrc 插件解析。**Depends on: Task 1.1 Output**

1. 将 `group "cn.bjca.footstone.bpring.boot"` 改为动态引用 `group "${forkGroupIdBase}.boot"`
2. 在 `allprojects` 块内添加 `configurations.all { resolutionStrategy.eachDependency }` 规则：当 `requested.group == 'org.springframework'` 时，将 artifactId 中的 `spring-` 替换为 `${forkArtifactPrefix}-`，GroupId 替换为 `${forkGroupIdBase}`，版本设为 `${springFrameworkVersion}`；当 `requested.group == 'org.springframework.security'` 时同理替换为 `.security` 子组
3. 处理边界情况：确保 resolutionStrategy 不影响 buildSrc 插件解析、不误替换非 `spring-` 前缀的依赖项
4. 所有新增代码添加完备中文注释块，解释映射规则、配置来源、以及如何修改

### Task 1.3 – settings.gradle 动态化改造 - Agent_Build
**Objective:** 将项目名称转换中的硬编码值改为从 gradle.properties 读取，使 GAV 变更时无需修改 settings.gradle。
**Output:** 修改后的 settings.gradle，项目名转换使用动态配置。
**Guidance:** 需处理 settings.gradle 中访问 gradle.properties 的方式（Gradle 属性在 settings 阶段可用）。**Depends on: Task 1.1 Output**

- 将 `rootProject.name` 硬编码值改为使用 `forkArtifactPrefix` 动态拼接：`"${forkArtifactPrefix}-boot-build"`
- 将子项目名称替换中的硬编码 `"bjca-footstone-bpring-boot"` 改为 `"${forkArtifactPrefix}-boot"`，保持 `"spring-boot"` 作为替换源不变
- 添加中文注释说明配置来源、修改方法、以及与 gradle.properties 的关联

### Task 1.4 – spring-boot-dependencies BOM 修正 - Agent_Build
**Objective:** 将 BOM 中 Spring Framework 和 Spring Security 的显式模块列表恢复为 BOM 导入方式，使用 fork 坐标。
**Output:** 修改后的 spring-boot-dependencies/build.gradle，使用 BOM 导入代替显式模块列表。
**Guidance:** BOM 导入方式自动覆盖所有子模块，无需手动维护模块清单。与 Task 1.2 的 resolutionStrategy 配合，实现完整的依赖映射链。**Depends on: Task 1.1 Output**

1. 将 Spring Framework library 定义从 `group("cn.bjca.footstone.bpring") { modules = [...] }` 改为 `group("${forkGroupIdBase}") { imports = ["${forkArtifactPrefix}-framework-bom"] }`，版本使用 `"${springFrameworkVersion}"`
2. 将 Spring Security library 定义从 `group("cn.bjca.footstone.bpring.security") { modules = [...] }` 改为 `group("${forkGroupIdBase}.security") { imports = ["${forkArtifactPrefix}-security-bom"] }`，版本使用 `"${springSecurityVersion}"`
3. 添加中文注释说明 BOM 导入方式的优势（自动覆盖所有子模块、无需手动维护模块列表、与 resolutionStrategy 的协作关系）

### Task 1.5 – 构建验证 - User ✅ Complete
**Objective:** 验证所有 Gradle 改动后构建是否通过。
**Output:** 构建日志（成功或失败信息）。
**Guidance:** 由用户手动执行。如有失败，提供完整错误日志供 Agent_Build 分析。**Depends on: Task 1.1, 1.2, 1.3, 1.4 Output**
**Status:** ✅ BUILD SUCCESSFUL in 4m 29s — 1977 actionable tasks: 1913 executed, 45 from cache, 19 up-to-date。经过五轮代码修复（buildSrc 坐标替换、属性访问、GString 类型转换 x2、Maven 仓库配置）后构建全部通过。

## Phase 2: 文档完善

### Task 2.1 – 恢复并完善 doc/REQUIREMENTS.md - Agent_Docs ✅ Complete
**Objective:** 恢复历史变更记录并新增 GAV 自动映射改造需求章节，形成完整的项目需求文档。
**Output:** 完整的 doc/REQUIREMENTS.md，包含历史记录（需求-001 到 需求-017）和新增的 GAV 改造章节。
**Guidance:** 需从 git 历史恢复被删除的内容，新增章节需涵盖背景、约束、目标、红线、SCA 规避原则、兼容关系链。**Depends on: Task 1.1, 1.2, 1.3, 1.4 Output by Agent_Build**

1. 从 git 恢复 REQUIREMENTS.md 的历史变更记录（需求-001 到 需求-017 的完整内容）
2. 在文档顶部新增「GAV 自动映射改造」章节（需求-018），完整记录：背景与目的、核心约束与红线（源码兼容性、功能完整性）、GAV 重命名规则（含 `forkArtifactPrefix` / `forkGroupIdBase` 单点配置说明）、自动映射机制原理（resolutionStrategy.eachDependency）、SCA 规避策略、与 Spring Framework 和 Spring Security fork 的完整兼容关系链
3. 确保新增章节与历史记录格式统一，按时间倒序排列，所有内容使用中文

### Task 2.2 – 完善 doc/GAV_MAPPING.md - Agent_Docs ✅ Complete
**Objective:** 补充缺失模块映射，添加完整的跨项目依赖清单和自动映射机制说明。
**Output:** 完整的 doc/GAV_MAPPING.md，覆盖所有模块映射和配置方法。
**Guidance:** 需参考 settings.gradle 中已包含的模块列表和 fork 仓库中的模块清单。

- 补充缺失的 starter 模块映射（data-redis、data-mongodb、data-elasticsearch、data-jdbc、webflux、websocket、web-services、oauth2-client、oauth2-resource-server、freemarker、mustache、groovy-templates、quartz、batch、mail、cache、jetty、undertow、reactor-netty 等）
- 新增「Spring Framework 完整模块映射」节，列出所有 `org.springframework:spring-xxx` → `cn.bjca.footstone.bpring:bjca-footstone-bpring-xxx` 的映射（含 r2dbc、webmvc、websocket 等）
- 新增「Spring Security 完整模块映射」节，列出所有 `org.springframework.security:spring-security-xxx` → `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-xxx` 的映射
- 新增「自动映射机制说明」节，说明 gradle.properties 单点配置方法、resolutionStrategy.eachDependency 工作原理、下游项目如何使用 BOM
