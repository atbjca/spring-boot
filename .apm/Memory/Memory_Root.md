# Spring Boot 2.7 Fork NES 改造 – APM Memory Root
**Memory Strategy:** Dynamic-MD
**Project Overview:** 对 Spring Boot 2.7.18 fork 项目实施 NES (Never-Ending Support) 改造。Phase 01-02 完成了 GAV 自动映射机制（resolutionStrategy、BOM 导入、文档完善）。Phase 03 实施传递依赖排除（spring-boot-dependencies BOM 中排除第三方组件对原始 Spring 坐标的传递依赖）与 NES GAV 映射文档编写（整合四个 fork 项目的完整 GAV 映射文档）。

## Phase 01 – Gradle 构建基础设施改造 Summary
* **结果**: BUILD SUCCESSFUL (4m29s, 1977 tasks)。全部 5 个任务完成，经过 5 轮迭代修复。
* **核心交付**: gradle.properties 集中化配置（forkArtifactPrefix/forkGroupIdBase）、root build.gradle resolutionStrategy 自动映射、settings.gradle 动态化、BOM 导入恢复（framework-bom/security-bom）。
* **关键发现**: buildSrc 不受主项目 resolutionStrategy 影响需直接使用 fork 坐标；Groovy GString 传入 Java DSL 方法会触发 ClassCastException 需用字符串拼接；effective-bom-settings.xml 使用占位符模板 + BomExtension 运行时替换。
* **涉及 Agent**: Agent_Build（Task 1.1~1.4 实现 + Task 1.5 修复）、User（Task 1.5 构建验证）
* **Memory Logs**:
  - `.apm/Memory/Phase_01_Gradle_Build_Infrastructure/Task_1_1_Gradle_Properties_GAV_Config.md`
  - `.apm/Memory/Phase_01_Gradle_Build_Infrastructure/Task_1_2_Root_Build_Gradle_Auto_Mapping.md`
  - `.apm/Memory/Phase_01_Gradle_Build_Infrastructure/Task_1_3_Settings_Gradle_Dynamic.md`
  - `.apm/Memory/Phase_01_Gradle_Build_Infrastructure/Task_1_4_BOM_Import_Fix.md`
  - `.apm/Memory/Phase_01_Gradle_Build_Infrastructure/Task_1_5_Build_Verification.md`

## Phase 02 – 文档完善 Summary
* **结果**: 全部 2 个任务完成，两份核心文档均已完善。
* **核心交付**:
  - `doc/REQUIREMENTS.md`：从 git 历史恢复需求-001~017，新增需求-018（GAV 自动映射改造，含 8 个子章节）
  - `doc/GAV_MAPPING.md`：从 6 节扩充为 8 节，覆盖 35 个活跃 Starter + 18 个已排除 Starter、Spring Framework 20 个模块、Spring Security 18 个模块（含 Authorization Server 独立条目）、自动映射机制说明、兼容关系链
* **关键发现**: REQUIREMENTS.md 曾被简化版本覆盖致历史记录丢失，已通过 git 恢复；Authorization Server 在 spring-boot-dependencies 中作为独立 library 条目，版本号（0.4.5-nes.patch.1-SNAPSHOT）独立于 Spring Security 主版本管理。
* **涉及 Agent**: Agent_Docs（Task 2.1、Task 2.2）
* **Memory Logs**:
  - `.apm/Memory/Phase_02_Documentation/Task_2_1_Restore_REQUIREMENTS_MD.md`
  - `.apm/Memory/Phase_02_Documentation/Task_2_2_Complete_GAV_MAPPING_MD.md`

## Phase 03 – 传递依赖排除与 NES GAV 映射文档 Summary
* **结果**: BUILD SUCCESSFUL (4m35s)。全部 7 个任务完成，经过 3 轮构建验证迭代修复。
* **核心交付**:
  - `spring-boot-dependencies/build.gradle`：7 个组件共 29 个有效 exclude（28 个 `org.springframework:*` + 1 个 `org.springframework.security:*`）+ 8 处结构化中文注释；版本升级 spring-data-bom → 2021.2.18-nes.patch.1-SNAPSHOT、Logback → 1.2.13-nes.patch.1-SNAPSHOT
  - `doc/NES_GAV_MAPPING.md`：~450 行完整 NES GAV 映射文档，覆盖 4 个 fork 项目 80+ 模块映射、Maven/Gradle 配置示例、BOM 层级、迁移清单、FAQ
* **关键发现**: bomrCheck 通配符排除必须使用 `module: "*"` 语法（不能省略 module）；7 个模块的 Spring 依赖为 provided/compileOnly 不传递给下游，exclude 无意义需移除。
* **涉及 Agent**: Agent_Build（Task 1.1、1.4、1.6）、Agent_Docs（Task 1.2）、User（Task 1.3、1.5、1.7 构建验证）
* **Memory Logs**:
  - `.apm/Memory/Phase_03_Dependency_Exclusion_GAV_Mapping/Task_1_1_Transitive_Dependency_Exclusion.md`
  - `.apm/Memory/Phase_03_Dependency_Exclusion_GAV_Mapping/Task_1_2_NES_GAV_MAPPING.md`
  - `.apm/Memory/Phase_03_Dependency_Exclusion_GAV_Mapping/Task_1_3_Build_Verification.md`
  - `.apm/Memory/Phase_03_Dependency_Exclusion_GAV_Mapping/Task_1_4_bomrCheck_Fix_Version_Upgrade.md`
  - `.apm/Memory/Phase_03_Dependency_Exclusion_GAV_Mapping/Task_1_5_Build_Verification_2.md`
  - `.apm/Memory/Phase_03_Dependency_Exclusion_GAV_Mapping/Task_1_6_Remove_Unnecessary_Excludes.md`
  - `.apm/Memory/Phase_03_Dependency_Exclusion_GAV_Mapping/Task_1_7_Build_Verification_3.md`
