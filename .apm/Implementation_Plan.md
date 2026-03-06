# Spring Boot 2.7 Fork 传递依赖排除与 NES GAV 映射文档 – APM Implementation Plan
**Memory Strategy:** Dynamic-MD
**Last Modification:** Phase 1 全部完成（7/7 任务），新增 Task 1.8 维护 REQUIREMENTS.md。
**Project Overview:** 对 Spring Boot 2.7.18 fork 项目实施两项并行改造：(1) 在 spring-boot-dependencies BOM 中排除第三方组件对原始 Spring/Spring Security/Authorization Server 的传递依赖，确保下游消费者不会因第三方 POM 引入原始坐标；(2) 整合四个 fork 项目（spring-boot、spring-framework、spring-security、spring-authorization-server）的 GAV 映射，编写面向下游使用者的完整 NES_GAV_MAPPING.md 文档。

## Phase 1: 传递依赖排除与 NES GAV 映射文档编写

### Task 1.1 – spring-boot-dependencies 第三方组件传递依赖排除 - Agent_Build
**Objective:** 在 spring-boot-dependencies/build.gradle 中对逐个声明的第三方模块添加 exclude，排除其对原始 Spring/Spring Security/Authorization Server 的传递依赖，确保发布的 BOM POM 包含 exclusion 元素。
**Output:** 修改后的 spring-boot-dependencies/build.gradle，包含完整的 exclude 声明和结构化中文注释。
**Guidance:** 仅处理逐个声明的 library 模块，跳过 BOM 导入的组件（spring-data-bom、spring-session-bom、spring-integration-bom）。已在 settings.gradle 中忽略的 starter 不处理。每处 exclude 需有结构化注释便于日后 fork 对应组件时快速移除。需区分 A 类（未 fork 的 Spring 生态组件）和 B 类（非 Spring 第三方组件）。

1. 审查 `spring-boot-dependencies/build.gradle` 中所有逐个声明的 library 模块（跳过 BOM 导入的 spring-data-bom、spring-session-bom、spring-integration-bom），列出可能传递依赖原始 Spring 坐标的第三方组件
2. 对识别出的每个组件，确认其传递依赖的具体 group（`org.springframework` / `org.springframework.security`），并确定需要排除的 group 列表
3. 在对应的 library 声明中添加 `exclude group:` 语句，排除原始 Spring / Spring Security / Authorization Server 传递依赖
4. 为每处 exclude 添加结构化中文注释，包含：排除原因（组件类别 A/B）、排除的 group、移除条件（"当此组件完成 fork 后移除此 exclude"）

### Task 1.2 – NES_GAV_MAPPING.md 编写 - Agent_Docs
**Objective:** 整合四个 fork 项目的 GAV 映射信息，编写面向下游使用者的完整 NES GAV 映射文档。
**Output:** doc/NES_GAV_MAPPING.md，覆盖全部 fork 模块映射、使用说明、配置示例。
**Guidance:** 目标读者是下游组件使用者。语言中英混合、尽量中文。版本以 gradle.properties 实际值为准（springFrameworkVersion=5.3.39-nes.patch.1-SNAPSHOT 等）。内容越详细越好，包含 Maven/Gradle 配置示例。整合来源：spring-boot-2.7（/Volumes/LIBIAO_EX/dev/GitHub/spring-boot-2.7/doc/GAV_MAPPING.md）、spring-framework（/Users/anan/Documents/GitHub/spring-framework/doc/GAV_MAPPING.md）、spring-security（/Users/anan/Documents/GitHub/spring-security/doc/GAV_MAPPING.md）、spring-authorization-server（/Users/anan/Documents/GitHub/spring-authorization-server/doc/GAV_MAPPING.md）。

- 整合四个 fork 项目的 GAV 映射表，按组件系列（Spring Boot、Spring Framework、Spring Security、Authorization Server）分章节，每个模块列出完整的原始坐标→fork 坐标映射，版本以 gradle.properties 实际值为准
- 添加「快速开始」章节：包含 Maven dependencyManagement 和 Gradle dependencyManagement 的完整 BOM 引入示例，以及常用 starter 的依赖声明示例
- 添加「兼容关系链」章节：说明四个 fork 项目的版本对应关系、BOM 层级继承关系
- 添加「注意事项」章节：说明 Java 包名不变（org.springframework.*）、import 语句无需修改、NES（Never-Ending Support）命名含义等使用者需要知道的关键信息

### Task 1.3 – 构建验证 - User
**Objective:** 验证 Task 1.1 的 exclude 修改后项目构建是否通过。
**Output:** 构建日志（成功或失败信息）。
**Guidance:** 由用户手动执行。如有失败，提供完整错误日志供 Agent_Build 分析修复。**Depends on: Task 1.1 Output**

- 用户执行全量构建，验证 exclude 修改不破坏现有构建。如有失败，提供完整错误日志供 Agent_Build 分析修复

### Task 1.4 – bomrCheck 修复与版本升级 - Agent_Build
**Objective:** 修复 Task 1.1 exclude 导致的 bomrCheck 失败，并完成两项版本升级（spring-data-bom、logback）。
**Output:** 修改后的 spring-boot-dependencies/build.gradle，bomrCheck 通过且版本已更新。
**Guidance:** bomrCheck 报告所有 exclude 为 "Unnecessary exclusions"（`[org.springframework:null]`），需研究 bomr 检查机制并修正 exclude 方式或配置 bomr 允许规则。版本升级：spring-data-bom 由 `2021.2.18` 改为 `2021.2.18-nes.patch.1-SNAPSHOT`；Logback 由 `1.2.13` 改为 `1.2.13-nes.patch.1-SNAPSHOT`。**Depends on: Task 1.3 Output**

1. 研究项目的 bomr 检查机制（bomrCheck task），理解其如何验证 exclusion 合法性，找出 "Unnecessary exclusions" 的判定逻辑
2. 修复 Task 1.1 添加的 exclude 使其通过 bomrCheck（可能需要调整 exclude 语法、配置 bomr 允许规则、或采用其他机制）
3. 将 spring-data-bom 版本从 `2021.2.18` 改为 `2021.2.18-nes.patch.1-SNAPSHOT`
4. 将 Logback 版本从 `1.2.13` 改为 `1.2.13-nes.patch.1-SNAPSHOT`

### Task 1.5 – 二次构建验证 - User
**Objective:** 验证 Task 1.4 的修复和版本升级后项目构建是否通过。
**Output:** 构建日志（成功或失败信息）。
**Guidance:** 由用户手动执行。**Depends on: Task 1.4 Output**

- 用户执行全量构建，验证所有修改不破坏现有构建

### Task 1.6 – 移除不必要的 exclude - Agent_Build
**Objective:** 移除 bomrCheck 判定为"Unnecessary"的 7 个模块的 exclude（这些模块实际不传递依赖 org.springframework）。
**Output:** 修改后的 spring-boot-dependencies/build.gradle，移除 7 个模块的 exclude 及对应注释。
**Guidance:** bomrCheck 通配符逻辑验证 resolved dependencies 中是否存在对应 group 的制品，以下 7 个模块不存在（其 Spring 依赖为 provided/compileOnly 不传递）：activemq-spring、cache2k-spring、hazelcast-spring、spring-restdocs-asciidoctor、spring-retry、thymeleaf-spring5、thymeleaf-extras-springsecurity5。移除这些 exclude 及对应注释，保留其他组件的 exclude 不变。**Depends on: Task 1.5 Output**

1. 移除以下 7 个模块的 exclude 声明及其结构化注释，将 library 声明还原为原始格式（plain string 或无 exclude 的 closure）：activemq-spring、cache2k-spring、hazelcast-spring、spring-restdocs-asciidoctor、spring-retry、thymeleaf-spring5、thymeleaf-extras-springsecurity5
2. 验证其余组件的 exclude 未被影响

### Task 1.7 – 三次构建验证 - User
**Objective:** 验证 Task 1.6 修复后项目构建是否通过。
**Output:** 构建日志（成功或失败信息）。
**Guidance:** 由用户手动执行。**Depends on: Task 1.6 Output**

- 用户执行全量构建，验证所有修改不破坏现有构建
