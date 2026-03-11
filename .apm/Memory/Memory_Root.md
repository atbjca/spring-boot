# Spring Boot 2.7 Fork NES 改造 – APM Memory Root
**Memory Strategy:** Dynamic-MD
**Project Overview:** 对 Spring Boot 2.7.18 fork 项目实施 NES (Never-Ending Support) 改造。Phase 01-02 完成了 GAV 自动映射机制（resolutionStrategy、BOM 导入、文档完善）。Phase 03 实施传递依赖排除（spring-boot-dependencies BOM 中排除第三方组件对原始 Spring 坐标的传递依赖）与 NES GAV 映射文档编写（整合四个 fork 项目的完整 GAV 映射文档）。Phase 04 修复 Maven 发布时 artifactId 未使用 fork 前缀的问题（仅在 DeployedPlugin 发布阶段显式设置 artifactId），并同步更新 NES GAV 映射文档。Phase 05 升级 Netty 版本（4.1.118.Final → 4.1.131.Final）修复 4 个安全漏洞。Phase 06 升级 Jackson 版本（2.15.4 → 2.21.1）增强安全防御纵深，并维护需求文档。Phase 07 编写 A 类组件传递依赖排除影响文档（8 个 A 类库缺失的 Spring 传递依赖及下游 Maven 补偿方案）。

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

## Phase 04 – Artifact ID 发布修复与文档同步 Summary
* **结果**: BUILD SUCCESSFUL，已部署到 Nexus。全部 5 个任务完成（含后续追加的 Task 2.4~2.5）。
* **核心交付**:
  - `buildSrc/src/main/java/org/springframework/boot/build/DeployedPlugin.java`：在 MavenPublication 创建后添加 artifactId 显式设置逻辑（方案 B），通过 `project.findProperty("forkArtifactPrefix")` 读取属性，将 `spring-boot` 替换为 `forkArtifactPrefix + "-boot"`，附详尽中文注释
  - `spring-boot-starter-parent/build.gradle`：修复 `pom.withXml` 闭包中 3 处硬编码 artifactId（parent 的 `spring-boot-dependencies`、pluginManagement 和 shade 依赖的 `spring-boot-maven-plugin`），改为动态读取 forkArtifactPrefix
  - `doc/NES_GAV_MAPPING.md`：修正 `spring-boot-gradle-plugin` 保留原始命名的例外说明，全文 artifactId 一致性验证通过
* **关键发现**: `spring-boot-gradle-plugin` 使用独立的 `java-gradle-plugin` 发布机制，不经过 DeployedPlugin，artifactId 保留原始命名；`spring-boot-parent` 使用 BOM import（非 `<parent>`）是 Gradle java-platform 插件的预期行为，与原始 Spring Boot 一致；`spring-boot-starter-parent` 的 `<parent>` 元素由 `pom.withXml` 手动构建，其中硬编码的 artifactId 需动态替换。
* **涉及 Agent**: Agent_Build（Task 2.1、2.4）、User（Task 2.2、2.5 构建验证）、Agent_Docs（Task 2.3）
* **Memory Logs**:
  - `.apm/Memory/Phase_04_Artifact_ID_Fix/Task_2_1_DeployedPlugin_ArtifactId_Fix.md`
  - `.apm/Memory/Phase_04_Artifact_ID_Fix/Task_2_2_Build_Verification.md`
  - `.apm/Memory/Phase_04_Artifact_ID_Fix/Task_2_3_NES_GAV_MAPPING_Update.md`
  - `.apm/Memory/Phase_04_Artifact_ID_Fix/Task_2_4_Starter_Parent_POM_Fix.md`
  - `.apm/Memory/Phase_04_Artifact_ID_Fix/Task_2_5_Build_Verification_POM_Check.md`

## Phase 05 – Netty 安全漏洞版本升级 Summary
* **结果**: BUILD SUCCESSFUL。全部 3 个任务完成，一次构建通过无需迭代修复。
* **核心交付**:
  - `spring-boot-dependencies/build.gradle`：Netty BOM 版本从 `4.1.118.Final` 升级至 `4.1.131.Final`，修复 4 个 CVE（CVE-2025-55163、CVE-2025-58057、CVE-2025-67735、CVE-2025-58056）
  - `doc/REQUIREMENTS.md`：追加 [需求-026] Netty 安全漏洞版本升级条目，含 CVE 修复覆盖表格（CVSS 评分）、兼容性说明
* **关键发现**: 无特殊发现。4.1.x 分支内升级完全兼容，BOM 导入覆盖全部 Netty 子模块，Java 8 兼容。
* **涉及 Agent**: Agent_Build（Task 3.1）、User（Task 3.2 构建验证）、Agent_Docs（Task 3.3）
* **Memory Logs**:
  - `.apm/Memory/Phase_05_Netty_Security_Upgrade/Task_3_1_Netty_BOM_Version_Upgrade.md`
  - `.apm/Memory/Phase_05_Netty_Security_Upgrade/Task_3_2_Build_Verification.md`
  - `.apm/Memory/Phase_05_Netty_Security_Upgrade/Task_3_3_Requirements_Doc_Update.md`

## Phase 06 – Jackson 版本升级 Summary
* **结果**: BUILD SUCCESSFUL (5m 31s)。全部 5 个任务完成（含 2 个条件性任务均执行），经过 4 轮迭代修复。
* **核心交付**:
  - `gradle.properties`：Jackson 版本从 `2.15.4` 升级至 `2.21.1`
  - `spring-boot-dependencies/build.gradle`：Jackson BOM 中 `jackson-module-jaxb-annotations` 排除 `jaxb-api`；`jackson-module-kotlin` 使用 `strictly "2.16.2"` 约束固定（Kotlin 1.6.21 兼容）
  - `buildSrc/JavaConventions.java`：新增 `configureProhibitedTransitiveExclusions()` 方法，全局排除 `javax.activation-api` 和 `jaxb-api`
  - `doc/REQUIREMENTS.md`：追加 [需求-027] Jackson 版本升级条目，含构建修复详情
* **关键发现**: BOM 插件的 module exclusion DSL 仅影响 Maven POM 发布，不影响 Gradle 本地依赖解析，需两层修复（BOM + Gradle）；bomrCheck 验证排除时仅检查直接传递依赖，不检查子传递依赖；`jackson-module-kotlin` 从 2.17.x 起使用 Kotlin 1.7+ 编译，与项目 Kotlin 1.6.21 不兼容需固定版本；Gradle `strictly` 约束可覆盖 BOM 管理版本。
* **涉及 Agent**: Agent_Build（Task 4.1、4.3 含 4 次迭代）、User（Task 4.2、4.4 构建验证）、Agent_Docs（Task 4.5）
* **Memory Logs**:
  - `.apm/Memory/Phase_06_Jackson_Version_Upgrade/Task_4_1_Jackson_BOM_Version_Upgrade.md`
  - `.apm/Memory/Phase_06_Jackson_Version_Upgrade/Task_4_2_Build_Verification.md`
  - `.apm/Memory/Phase_06_Jackson_Version_Upgrade/Task_4_3_Build_Failure_Fix.md`
  - `.apm/Memory/Phase_06_Jackson_Version_Upgrade/Task_4_4_Build_Verification_2.md`
  - `.apm/Memory/Phase_06_Jackson_Version_Upgrade/Task_4_5_Requirements_Doc_Update.md`

## Phase 07 – A 类组件传递依赖变化文档 Summary
* **结果**: 全部 2 个任务完成，纯文档修改无需构建验证。
* **核心交付**:
  - `doc/NES_GAV_MAPPING.md`：新增 §9「A 类组件传递依赖排除说明」（约 270 行），覆盖 8 个 A 类库（Kafka、Batch、HATEOAS、LDAP、WS、AMQP、GraphQL、RESTDocs）的缺失 Spring 传递依赖详表、三类库影响分类（活跃 Starter / 已排除 Starter / 无 Starter）、4 个 Maven 配置示例；修复原文档 §8 重复编号问题
  - `doc/REQUIREMENTS.md`：追加 [需求-028] A 类组件传递依赖排除影响文档
* **关键发现**: Spring GraphQL 1.0.6 直接依赖 spring-context，传递依赖 spring-aop、spring-beans、spring-core、spring-expression（通过 POM 实际确认）。
* **涉及 Agent**: Agent_Docs（Task 5.1、5.2）
* **Memory Logs**:
  - `.apm/Memory/Phase_07_A_Class_Transitive_Dependency_Docs/Task_5_1_NES_GAV_MAPPING_Transitive_Dependency_Chapter.md`
  - `.apm/Memory/Phase_07_A_Class_Transitive_Dependency_Docs/Task_5_2_Requirements_Doc_Update.md`
