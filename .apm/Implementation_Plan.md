# Spring Boot 2.7 Fork 构建与 GAV 治理 – APM Implementation Plan
**Memory Strategy:** Dynamic-MD
**Last Modification:** Phase 6 全部完成（Manager Agent 1）——Quartz 2.3.2→2.4.1、Commons Lang3 3.12.0→3.20.0 升级完毕，bomrCheck 修复（移除 c3p0/HikariCP exclude），3 个 CVE 文档已创建，[需求-029] 已追加。
**Project Overview:** 对 Spring Boot 2.7.18 fork 项目实施持续改造：Phase 1（已完成）在 BOM 中排除传递依赖并编写 NES GAV 映射文档；Phase 2（已完成）修复 Maven 发布时 artifactId 未使用 fork 前缀的问题；Phase 3（已完成）升级 Netty 版本修复安全漏洞；Phase 4（已完成）升级 Jackson 版本；Phase 5（已完成）编写 A 类组件传递依赖排除影响文档；Phase 6 升级 Quartz 与 Commons Lang3 修复安全漏洞并编写 CVE 文档。

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

## Phase 2: Artifact ID 发布修复与文档同步

### Task 2.1 – DeployedPlugin.java artifactId 发布修复 - Agent_Build
**Objective:** 在 DeployedPlugin.java 的 MavenPublication 创建后显式设置 artifactId，将 `spring-boot` 替换为 `forkArtifactPrefix + "-boot"`，确保 Maven 发布的制品使用 fork 命名。
**Output:** 修改后的 buildSrc/src/main/java/org/springframework/boot/build/DeployedPlugin.java，包含详尽中文注释。
**Guidance:** 方案 B（仅修改发布阶段）。从 `project.findProperty("forkArtifactPrefix")` 读取属性，确保单一配置源。不修改 settings.gradle、不修改内部项目名。与 spring-framework fork 的做法一致。每处新增代码必须添加详尽中文注释。

- 在 `DeployedPlugin.java` 的 `apply()` 方法中，`MavenPublication` 创建后（第 46 行之后），从 `project.findProperty("forkArtifactPrefix")` 获取制品名前缀属性
- 使用 `publication.setArtifactId(project.getName().replace("spring-boot", forkArtifactPrefix + "-boot"))` 显式设置 artifactId，确保发布的 Maven 制品使用 fork 命名
- 为新增代码添加详尽中文注释，说明：(1) 为什么需要显式设置 artifactId——settings.gradle 的项目名替换因执行顺序问题未生效 (2) 替换逻辑的原理——将 project.name 中的 "spring-boot" 替换为 forkArtifactPrefix + "-boot" (3) 修改方法——仅需修改 gradle.properties 中 forkArtifactPrefix 即可全局生效

### Task 2.2 – 构建验证 - User
**Objective:** 验证 Task 2.1 修改后 make install 的制品 artifactId 是否正确。
**Output:** 验证结果（成功或失败信息）。
**Guidance:** 由用户手动执行。**Depends on: Task 2.1 Output by Agent_Build**

- 执行 `make install`，确认构建成功
- 检查 `~/.m2/repository/cn/bjca/footstone/bpring/boot/` 目录下所有 artifact 名称是否已变为 `bjca-footstone-bpring-boot-*`。如有失败，提供完整错误日志供 Agent_Build 分析修复

### Task 2.3 – NES_GAV_MAPPING.md artifact 映射更新 - Agent_Docs
**Objective:** 更新 NES_GAV_MAPPING.md 中 Spring Boot 模块的 artifact ID 映射，反映 fork 后的实际 artifactId。
**Output:** 更新后的 doc/NES_GAV_MAPPING.md。
**Guidance:** 将所有 Spring Boot 模块的 artifactId 从 `spring-boot-*` 更新为 `bjca-footstone-bpring-boot-*`（基于 forkArtifactPrefix 的实际值）。语言中英混合、尽量中文。**Depends on: Task 2.2 Output by User**

- 更新所有 Spring Boot 模块的原始坐标→fork 坐标映射表，artifact ID 从 `spring-boot-*` 改为 `bjca-footstone-bpring-boot-*`
- 更新「快速开始」章节中的 Maven/Gradle 依赖声明示例，确保 artifactId 使用 fork 命名
- 全文检查所有出现 `spring-boot` artifact 引用的地方，确保一致性

### Task 2.4 – spring-boot-starter-parent POM 硬编码 artifactId 修复 - Agent_Build
**Objective:** 修复 `spring-boot-starter-parent/build.gradle` 中 `pom.withXml` 闭包里 3 处硬编码的 `spring-boot-*` artifactId，改为动态读取 `forkArtifactPrefix` 属性进行替换，确保生成的 POM 中 `<parent>` 和 pluginManagement 引用正确的 fork artifactId。
**Output:** 修改后的 `spring-boot-project/spring-boot-starters/spring-boot-starter-parent/build.gradle`，包含详尽中文注释。
**Guidance:** 3 处需修复的硬编码位置：(1) 第 15 行 `delegate.artifactId("spring-boot-dependencies")` — parent POM 的 artifactId (2) 第 158 行 `delegate.artifactId('spring-boot-maven-plugin')` — pluginManagement 中 repackage 插件 (3) 第 192 行 `delegate.artifactId('spring-boot-maven-plugin')` — shade 插件依赖。使用 `project.findProperty("forkArtifactPrefix")` 读取属性，替换逻辑与 DeployedPlugin.java 一致（将 "spring-boot" 替换为 forkArtifactPrefix + "-boot"）。每处修改添加详尽中文注释。遵循最小修改原则。**Depends on: Task 2.1 Output**

1. 在 `pom.withXml` 闭包开头，通过 `project.findProperty("forkArtifactPrefix")` 获取 fork 前缀属性，计算 fork 后的 artifactId
2. 将第 15 行 `"spring-boot-dependencies"` 替换为动态计算的 fork artifactId（如 `"bjca-footstone-bpring-boot-dependencies"`）
3. 将第 158 行和第 192 行 `'spring-boot-maven-plugin'` 替换为动态计算的 fork artifactId（如 `"bjca-footstone-bpring-boot-maven-plugin"`）
4. 为新增代码添加详尽中文注释，说明替换原因和逻辑

### Task 2.5 – 构建验证与 POM 结构检查 - User
**Objective:** 验证 Task 2.4 修改后 `make install` 构建成功，且 `bjca-footstone-bpring-boot-starter-parent` POM 中 `<parent>` artifactId 正确。
**Output:** 验证结果（成功或失败信息）。
**Guidance:** 由用户手动执行。**Depends on: Task 2.4 Output by Agent_Build**

- 执行 `make install`，确认构建成功
- 检查 `~/.m2/repository/cn/bjca/footstone/bpring/boot/bjca-footstone-bpring-boot-starter-parent/` 下的 POM 文件，确认 `<parent>` 中 artifactId 为 `bjca-footstone-bpring-boot-dependencies`（而非 `spring-boot-dependencies`）
- 检查 POM 中 pluginManagement 的 `spring-boot-maven-plugin` artifactId 是否也已正确替换

### Task 2.6 – BomPlugin POM 生成 artifactId 全局替换 - Agent_Build
**Objective:** 在 BomPlugin.java 的 PublishingCustomizer 中增加 fork artifactId 替换逻辑，确保生成的 `spring-boot-dependencies` POM 中所有 `<dependencyManagement>` 和 `<pluginManagement>` 条目的 artifactId 均使用 fork 命名。
**Output:** 修改后的 `buildSrc/src/main/java/org/springframework/boot/build/bom/BomPlugin.java`，包含详尽中文注释。
**Guidance:** 当前问题：BomPlugin 生成的 POM 中，69 个 Spring Boot 内部模块的 artifactId 仍为 `spring-boot-*`，与 DeployedPlugin 发布的 `bjca-footstone-bpring-boot-*` 不匹配。修复方案：在 `PublishingCustomizer.customizePom()` 的 `pom.withXml` 逻辑中，遍历所有 `<dependencyManagement>` 和 `<pluginManagement>` 中的 `<artifactId>` 节点，对以 `spring-boot` 开头的值应用 `"spring-boot"` → `forkArtifactPrefix + "-boot"` 替换。通过 `project.findProperty("forkArtifactPrefix")` 读取属性。未配置时保持原始值（向后兼容）。每处修改添加详尽中文注释。

1. 读取 `buildSrc/src/main/java/org/springframework/boot/build/bom/BomPlugin.java`，理解 `PublishingCustomizer` 内部类的 `customizePom()` 方法和 `pom.withXml` 逻辑
2. 在 `customizePom()` 方法的 `pom.withXml` 回调中，获取 `forkArtifactPrefix` 属性
3. 遍历 `<dependencyManagement><dependencies>` 下所有 `<dependency>` 节点的 `<artifactId>` 子节点，对以 `spring-boot` 开头的值执行替换
4. 遍历 `<pluginManagement><plugins>` 下所有 `<plugin>` 节点的 `<artifactId>` 子节点，对以 `spring-boot` 开头的值执行替换
5. 为新增代码添加详尽中文注释

### Task 2.7 – Maven 插件描述符 artifactId 修复 - Agent_Build
**Objective:** 修复 `spring-boot-maven-plugin` 的 Maven 插件描述符（`plugin.xml`）中 artifactId 与发布名不匹配的问题，确保 JAR 内部的 `plugin.xml` 使用 fork artifactId。
**Output:** 修改后的 `spring-boot-project/spring-boot-tools/spring-boot-maven-plugin/build.gradle`（扩展现有同步任务）。
**Guidance:** 当前问题：`src/maven/resources/pom.xml` 模板中 `<artifactId>spring-boot-maven-plugin</artifactId>` 硬编码，Maven Plugin Tools 据此生成的 `plugin.xml` 中 artifactId 为 `spring-boot-maven-plugin`，与发布名 `bjca-footstone-bpring-boot-maven-plugin` 不匹配，导致 Maven 报 InvalidPluginDescriptorException。修复方案：扩展现有的 `syncPluginPomGroupId` 任务（约第 160-183 行），使其同时替换 `<artifactId>` 中的 `spring-boot` 为 `forkArtifactPrefix + "-boot"`。重命名任务为 `syncPluginPomCoordinates` 或类似名称。**Depends on: Task 2.6 Output**

1. 读取 `spring-boot-project/spring-boot-tools/spring-boot-maven-plugin/build.gradle`，理解现有 `syncPluginPomGroupId` 任务逻辑
2. 扩展该任务的 `replaceAll` 逻辑，增加 artifactId 替换：将 `<artifactId>spring-boot-maven-plugin</artifactId>` 替换为动态计算的 fork artifactId
3. 考虑将任务名从 `syncPluginPomGroupId` 改为更准确的名称（如 `syncPluginPomCoordinates`），并更新所有引用
4. 为新增代码添加详尽中文注释

### Task 2.8 – 全面构建验证与 POM/插件描述符检查 - User
**Objective:** 验证 Task 2.6 和 2.7 修改后构建成功，BOM POM 中所有 artifactId 正确，Maven 插件描述符匹配，且下游 Maven 项目可正常使用。
**Output:** 验证结果（成功或失败信息）。
**Guidance:** 由用户手动执行。**Depends on: Task 2.7 Output by Agent_Build**

- 执行 `make install`，确认构建成功
- 检查 `bjca-footstone-bpring-boot-dependencies` POM：所有 Spring Boot 模块 artifactId 应为 `bjca-footstone-bpring-boot-*`，pluginManagement 中应为 `bjca-footstone-bpring-boot-maven-plugin`
- 检查 Maven 插件 JAR 内 `META-INF/maven/plugin.xml`：artifactId 应为 `bjca-footstone-bpring-boot-maven-plugin`
- 使用 `bjca-footstone-bpring-boot-starter-parent` 创建测试 Maven 项目，执行 `mvn clean package` 确认不报错

## Phase 3: Netty 安全漏洞版本升级

### Task 3.1 – Netty BOM 版本升级 - Agent_Build
**Objective:** 将 spring-boot-dependencies 中 Netty 版本从 4.1.118.Final 升级至 4.1.131.Final，修复 4 个安全漏洞。
**Output:** 修改后的 spring-boot-dependencies/build.gradle。
**Guidance:** 单行版本号修改，Netty 通过 BOM 导入（`netty-bom`）管理所有子模块，升级 BOM 版本即覆盖全部 Netty 组件。4.1.x 分支内升级，Java 8 兼容。

- 将 `library("Netty", "4.1.118.Final")` 改为 `library("Netty", "4.1.131.Final")`

### Task 3.2 – 构建验证 - User
**Objective:** 验证 Task 3.1 的版本升级后项目构建是否通过。
**Output:** 构建日志（成功或失败信息）。
**Guidance:** 由用户手动执行。如有失败，提供完整错误日志供 Agent_Build 分析修复。**Depends on: Task 3.1 Output**

- 用户执行 `make build-thin`，验证 Netty 版本升级不破坏现有构建。如有失败，提供完整错误日志供 Agent_Build 分析修复

### Task 3.3 – REQUIREMENTS.md 需求追加 - Agent_Docs
**Objective:** 在 doc/REQUIREMENTS.md 中追加 [需求-026]，记录 Netty 安全漏洞版本升级的完整信息。
**Output:** 更新后的 doc/REQUIREMENTS.md。
**Guidance:** 沿用现有文档风格（日期标题 + 需求编号 + 背景/修改内容/CVE表格/涉及文件）。语言中英混合、尽量中文。日期使用 2026年03月11日。**Depends on: Task 3.2 Output by User**

- 在文件顶部（`---` 分隔线之后、现有最新需求之前）追加日期标题 `## 📅 2026年03月11日` 和需求标题 `### [需求-026] Netty 安全漏洞版本升级`
- 编写「背景与目的」：说明安全扫描发现 Netty 存在 4 个已知 CVE（CVE-2025-55163 HTTP/2 DDoS、CVE-2025-58057 Zip Bomb DoS、CVE-2025-58056 HTTP 请求走私、CVE-2025-67735 CRLF 注入请求走私），需升级至修复版本以消除安全风险
- 编写「修改内容」：记录版本变更 `library("Netty", "4.1.118.Final")` → `library("Netty", "4.1.131.Final")`；添加 CVE 修复覆盖表格（CVE 编号、组件模块、漏洞类型、CVSS、修复版本）；添加兼容性说明（4.1.x 分支内升级、BOM 管理所有 Netty 子模块、Java 8 兼容）
- 编写「涉及文件」：`spring-boot-project/spring-boot-dependencies/build.gradle`（Netty 版本）

## Phase 4: Jackson 版本升级

### Task 4.1 – Jackson BOM 版本升级 - Agent_Build
**Objective:** 将 gradle.properties 中 Jackson 版本从 2.15.4 升级至 2.21.1。
**Output:** 修改后的 gradle.properties。
**Guidance:** 单行版本号修改。Jackson 通过 BOM 导入（`jackson-bom`）管理所有子模块，`spring-boot-dependencies/build.gradle` 中 `library("Jackson Bom", "${jacksonVersion}")` 引用该变量，无需修改 build.gradle。

- 将 `gradle.properties` 中 `jacksonVersion=2.15.4` 改为 `jacksonVersion=2.21.1`

### Task 4.2 – 构建验证 - User
**Objective:** 验证 Task 4.1 的版本升级后项目构建是否通过。
**Output:** 构建日志（成功或失败信息）。
**Guidance:** 由用户手动执行。Jackson 跨多个小版本升级（2.15→2.21），已知风险包括 PropertyNamingStrategy 常量移除（2.20）、POJO 属性内省重写（2.18）、StreamReadConstraints 新限制（2.18）。如有失败，提供完整错误日志供 Agent_Build 分析修复。**Depends on: Task 4.1 Output**

- 用户执行 `make build-thin`，验证 Jackson 版本升级不破坏现有构建。如有失败，提供完整错误日志供 Agent_Build 分析修复

### Task 4.3 – 构建失败分析与修复 - Agent_Build
**Objective:** 分析 Task 4.2 构建失败的错误日志，修复 Jackson 2.21.1 引入的不兼容问题。
**Output:** 修复后的源代码文件，附中文注释说明修复原因。
**Guidance:** 条件性任务——仅在 Task 4.2 构建失败时执行。重点关注已知风险：(1) PropertyNamingStrategy 旧常量/内部类被移除（2.20），项目 JacksonAutoConfiguration 中有 fallback 路径可能受影响；(2) POJO 属性内省重写（2.18）导致序列化/反序列化行为变化；(3) jackson-annotations 版本号格式变化（2.20+）。**Depends on: Task 4.2 Output by User**

1. 分析用户提供的构建错误日志，识别 Jackson 2.21.1 引入的不兼容问题（重点关注：`PropertyNamingStrategy` 常量移除、POJO 属性内省变化、`StreamReadConstraints` 新限制）
2. 针对每个错误定位源文件并实施修复，为每处修改添加中文注释说明修复原因
3. 确认所有已知错误均已修复，列出修改文件清单供 User 执行二次构建验证

### Task 4.4 – 二次构建验证 - User
**Objective:** 验证 Task 4.3 修复后项目构建是否通过。
**Output:** 构建日志（成功或失败信息）。
**Guidance:** 条件性任务——仅在 Task 4.3 执行后需要。由用户手动执行。**Depends on: Task 4.3 Output**

- 用户执行 `make build-thin`，验证修复后构建通过。如仍有失败，提供错误日志供 Agent_Build 继续修复（迭代直到通过）

### Task 4.5 – REQUIREMENTS.md 需求追加 - Agent_Docs
**Objective:** 在 doc/REQUIREMENTS.md 中追加 [需求-027]，记录 Jackson 版本升级的完整信息。
**Output:** 更新后的 doc/REQUIREMENTS.md。
**Guidance:** 沿用现有文档风格（日期标题 + 需求编号 + 背景/修改内容/涉及文件）。语言中英混合、尽量中文。日期使用 2026年03月11日。如 Task 4.2 构建成功则无修复内容记录；如经过 Task 4.3 修复则需包含所有修复详情。**Depends on: Task 4.2 Output by User 或 Task 4.4 Output by User**

- 在文件顶部（现有最新需求之前，与 [需求-026] 同日期区块或新建日期区块）追加需求标题 `### [需求-027] Jackson 版本升级`
- 编写「背景与目的」：说明将 Jackson 从 2.15.4 升级至 2.21.1，增强安全防御纵深（新增 token count 限制等），保持依赖版本活跃维护状态
- 编写「修改内容」：记录版本变更（`gradle.properties` 中 `jacksonVersion=2.15.4` → `2.21.1`）；列出跨版本主要变更摘要（2.16~2.21 关键变化）；如有构建修复，记录所有修复内容和涉及文件；添加兼容性说明（Java 8 兼容、BOM 管理所有子模块）
- 编写「涉及文件」：`gradle.properties`（jacksonVersion）及构建修复涉及的所有文件

## Phase 5: A 类组件传递依赖变化文档

### Task 5.1 – NES_GAV_MAPPING.md 新增 A 类组件传递依赖变化章节 - Agent_Docs
**Objective:** 在 doc/NES_GAV_MAPPING.md 中新增章节，详细记录 BOM 中 8 个 A 类库 exclude 后缺失的 Spring 传递依赖，以及下游 Maven 消费者的补偿方案。
**Output:** 更新后的 doc/NES_GAV_MAPPING.md。
**Guidance:** 在现有章节后合适位置新增。语言中英混合、尽量中文。需覆盖全部 8 个 A 类库（Spring AMQP、Batch、GraphQL、HATEOAS、Kafka、LDAP、RESTDocs、WS）。对每个库列出 exclude 导致缺失的 Spring 传递依赖及对应 fork GAV 替代坐标。区分活跃 Starter（batch、web-services）、已排除 Starter（hateoas、data-ldap、amqp）、无 Starter 的库（kafka、graphql、restdocs、ws）。提供 Maven `<dependency>` 配置示例。以下为各 A 类库缺失的非 optional compile scope 的 Spring 传递依赖调研数据，供 Agent_Docs 编写时参考：

**Spring Kafka 2.9.13**（无 Starter）：spring-context、spring-messaging、spring-tx
**Spring Batch Core 4.3.10**（活跃 Starter: spring-boot-starter-batch）：spring-aop、spring-beans、spring-context、spring-core、spring-tx
**Spring HATEOAS 1.5.6**（已排除 Starter: spring-boot-starter-hateoas）：spring-aop、spring-beans、spring-context、spring-core、spring-web
**Spring LDAP Core 2.4.1**（已排除 Starter: spring-boot-starter-data-ldap）：spring-core、spring-beans、spring-tx
**Spring WS Core 3.1.8**（活跃 Starter: spring-boot-starter-web-services）：spring-aop、spring-beans、spring-oxm、spring-web、spring-webmvc；spring-xml 额外依赖：spring-beans、spring-context
**Spring AMQP 2.4.17 + Spring Rabbit 2.4.17**（已排除 Starter: spring-boot-starter-amqp）：spring-core（amqp）、spring-context、spring-messaging、spring-tx（rabbit）
**Spring GraphQL 1.0.6**（无 Starter）：需从 POM 确认具体 Spring 传递依赖
**Spring RESTDocs 2.0.8.RELEASE**（无 Starter，通常 test scope）：spring-restdocs-core 依赖 spring-web；spring-restdocs-mockmvc 依赖 spring-test、spring-webmvc

- 在 NES_GAV_MAPPING.md 现有章节后新增章节，标题如「A 类组件传递依赖排除说明」
- 编写背景说明：解释 exclude 的原因（防止原始 `org.springframework:spring-*` 与 fork GAV 冲突）、影响范围（BOM 中 8 个 A 类库）、对下游 Maven 消费者的影响（传递依赖链断裂，需显式补充 fork 依赖）
- 编写各 A 类库的缺失依赖表格，按库分组列出：库名、被 exclude 的 Spring 传递依赖、对应的 fork GAV 替代坐标（groupId: `cn.bjca.footstone.bpring`，artifactId: `bjca-footstone-bpring-*`，version: `${springFrameworkVersion}`）
- 提供下游 Maven 用户的补偿方案：对使用频率较高的库（如 spring-kafka、spring-batch-core）给出完整的 Maven `<dependency>` 配置示例

### Task 5.2 – REQUIREMENTS.md 需求追加 - Agent_Docs
**Objective:** 在 doc/REQUIREMENTS.md 中追加 [需求-028]，记录 A 类组件传递依赖排除影响文档的编写。
**Output:** 更新后的 doc/REQUIREMENTS.md。
**Guidance:** 沿用现有文档风格。语言中英混合、尽量中文。日期使用 2026年03月11日。**Depends on: Task 5.1 Output**

- 在文件顶部（与 [需求-026]、[需求-027] 同日期区块）追加 `### [需求-028] A 类组件传递依赖排除影响文档`
- 编写「背景与目的」：说明 BOM 中 A 类组件的 `exclude group: "org.springframework"` 切断了原始 Spring 传递依赖链，下游 Maven 消费者可能缺失必要的 Spring 依赖，需在 NES_GAV_MAPPING.md 中详细记录变更前后差异和补偿方案
- 编写「修改内容」：记录在 NES_GAV_MAPPING.md 中新增的章节内容概要（8 个 A 类库传递依赖变化 + 下游 Maven 配置示例）；编写「涉及文件」：`doc/NES_GAV_MAPPING.md`

## Phase 6: Quartz 与 Commons Lang3 安全漏洞版本升级

### Task 6.1 – BOM 版本升级（Quartz + Commons Lang3） - Agent_Build
**Objective:** 将 spring-boot-dependencies 中 Quartz 版本从 2.3.2 升级至 2.4.1，Commons Lang3 版本从 3.12.0 升级至 3.20.0，修复 CVE-2023-39017 和 CVE-2025-48924。
**Output:** 修改后的 spring-boot-dependencies/build.gradle。
**Guidance:** 两处单行版本号修改。Quartz 2.4.1 要求 Java 8+（与 Spring Boot 2.7 兼容），主要变更为移除 NativeJob 类、c3p0/HikariCP 改为 provided scope（BOM 已 exclude 不受影响）。Commons Lang3 3.20.0 保持 Java 8 兼容。

- 将 `library("Quartz", "2.3.2")` 改为 `library("Quartz", "2.4.1")`
- 将 `library("Commons Lang3", "3.12.0")` 改为 `library("Commons Lang3", "3.20.0")`

### Task 6.2 – 构建验证 - User
**Objective:** 验证 Task 6.1 的版本升级后项目构建是否通过。
**Output:** 构建日志（成功或失败信息）。
**Guidance:** 由用户手动执行。如有失败，提供完整错误日志供 Agent_Build 分析修复。**Depends on: Task 6.1 Output**

- 用户执行 `make build-thin`，验证版本升级不破坏现有构建。如有失败，提供完整错误日志供 Agent_Build 分析修复

### Task 6.3 – 构建失败分析与修复 - Agent_Build
**Objective:** 分析 Task 6.2 构建失败的错误日志，修复 Quartz 2.4.1 或 Commons Lang3 3.20.0 引入的不兼容问题。
**Output:** 修复后的源代码文件，附中文注释说明修复原因。
**Guidance:** 条件性任务——仅在 Task 6.2 构建失败时执行。已知风险：(1) Quartz 2.4.1 移除 NativeJob 类（Spring Boot QuartzAutoConfiguration 未引用，风险低）；(2) Commons Lang3 3.20.0 跨 8 个小版本（3.12→3.20），可能存在 API 行为变化。**Depends on: Task 6.2 Output by User**

1. 分析用户提供的构建错误日志，识别 Quartz 2.4.1 或 Commons Lang3 3.20.0 引入的不兼容问题（重点关注：`NativeJob` 类移除影响、Commons Lang3 API 行为变化）
2. 针对每个错误定位源文件并实施修复，为每处修改添加中文注释说明修复原因
3. 确认所有已知错误均已修复，列出修改文件清单供 User 执行二次构建验证

### Task 6.4 – 二次构建验证 - User
**Objective:** 验证 Task 6.3 修复后项目构建是否通过。
**Output:** 构建日志（成功或失败信息）。
**Guidance:** 条件性任务——仅在 Task 6.3 执行后需要。由用户手动执行。**Depends on: Task 6.3 Output**

- 用户执行 `make build-thin`，验证修复后构建通过。如仍有失败，提供错误日志供 Agent_Build 继续修复（迭代直到通过）

### Task 6.5 – CVE 文档编写 - Agent_Docs
**Objective:** 新建 doc/CVE/ 目录，为 CVE-2023-39017、CVE-2026-27727、CVE-2025-48924 各创建一个独立的 CVE 文档。
**Output:** `doc/CVE/CVE-2023-39017.md`、`doc/CVE/CVE-2026-27727.md`、`doc/CVE/CVE-2025-48924.md`。
**Guidance:** 每个文件包含：CVE 编号、组件、漏洞描述、CVSS/CWE、受影响版本、修复版本、官方修复 commit、参考链接。语言中英混合、尽量中文。CVE-2023-39017 需标注 disputed。CVE-2026-27727 需注明当前 BOM 已 exclude c3p0 作为缓解措施。**Depends on: Task 6.2 Output by User 或 Task 6.4 Output by User**

- 创建 `doc/CVE/` 目录
- 创建 `doc/CVE/CVE-2023-39017.md`：quartz-jobs ≤ 2.3.2 代码注入（`SendQueueMessageJob.execute`），CVSS 9.8 CRITICAL，CWE-94，**disputed**，Quartz 2.4.0 修复（移除 `NativeJob` 类，Issue quartz-scheduler/quartz#943），参考链接
- 创建 `doc/CVE/CVE-2026-27727.md`：mchange-commons-java < 0.4.0 JNDI RCE，CVSS 9.8 CRITICAL（v3.1）/ 8.9 HIGH（v4.0），CWE-74，修复 commit `a433b28e4d1172049840472c5e361cf4c658626f`（swaldman/mchange-commons-java），注明当前 BOM 已 exclude `com.mchange:c3p0` 作为缓解措施
- 创建 `doc/CVE/CVE-2025-48924.md`：commons-lang3 < 3.18.0 `ClassUtils.getClass()` 不受控递归 DoS，CVSS 5.3 MEDIUM，CWE-674，修复 commit `b424803abdb2bec818e4fbcb251ce031c22aca53`（apache/commons-lang），参考链接

### Task 6.6 – REQUIREMENTS.md 需求追加 - Agent_Docs
**Objective:** 在 doc/REQUIREMENTS.md 中追加 [需求-029]，记录 Quartz 与 Commons Lang3 安全漏洞版本升级及 CVE 文档编写的完整信息。
**Output:** 更新后的 doc/REQUIREMENTS.md。
**Guidance:** 沿用现有文档风格（日期标题 + 需求编号 + 背景/修改内容/CVE表格/兼容性说明/涉及文件）。语言中英混合、尽量中文。日期使用 2026年03月13日。如 Task 6.2 构建成功则无修复内容记录；如经过 Task 6.3 修复则需包含所有修复详情。**Depends on: Task 6.5 Output**

- 在文件顶部（`---` 分隔线之后、现有最新需求之前）追加日期标题 `## 📅 2026年03月13日` 和需求标题 `### [需求-029] Quartz 与 Commons Lang3 安全漏洞版本升级`
- 编写「背景与目的」：说明安全扫描发现 Quartz 存在 CVE-2023-39017（代码注入，disputed）和 CVE-2026-27727（JNDI RCE，通过 c3p0/mchange-commons-java 传递），Commons Lang3 存在 CVE-2025-48924（不受控递归 DoS），需升级至修复版本以消除安全风险
- 编写「修改内容」：记录版本变更 Quartz 2.3.2 → 2.4.1、Commons Lang3 3.12.0 → 3.20.0；添加 CVE 修复覆盖表格（CVE 编号、组件、漏洞类型、CVSS、修复版本）；添加兼容性说明（Quartz 2.4.x Java 8 兼容、NativeJob 移除不影响 Spring Boot AutoConfiguration；Commons Lang3 3.20.0 Java 8 兼容）；记录新建 doc/CVE/ 目录及 3 个 CVE 文档；如经过 Task 6.3 修复则需包含所有修复详情
- 编写「涉及文件」：`spring-boot-project/spring-boot-dependencies/build.gradle`、`doc/CVE/CVE-2023-39017.md`、`doc/CVE/CVE-2026-27727.md`、`doc/CVE/CVE-2025-48924.md` 及构建修复涉及的所有文件
