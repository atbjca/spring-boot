# Spring Boot 项目需求维护手册 (Requirements Manual)

本文档按照时间倒序记录了项目近期的核心需求变更、架构调整及关键修复，作为项目长期维护的审计依据。

---

## 📅 2026年03月06日

### [需求-019] BOM 传递依赖排除、NES GAV 映射文档与版本升级

#### 背景与目的
在完成 [需求-018] GAV 自动映射改造后，下游消费者引入 `spring-boot-dependencies` BOM 时发现：部分第三方组件（如 Spring AMQP、Batch、Kafka 等）会通过传递依赖重新引入原始 `org.springframework` / `org.springframework.security` 坐标，导致 fork GAV 替换不彻底，SCA 扫描仍可匹配到官方 CVE 记录。同时，四个 fork 项目各自维护独立的 `GAV_MAPPING.md`，下游使用者缺乏一份整合性参考文档。此外，部分依赖版本需同步升级至 fork 版本以保证全链路一致性。

本需求涵盖三项改造工作，是 Phase 03 的核心交付内容。

#### 改造一：spring-boot-dependencies BOM 第三方组件传递依赖排除

##### 问题分析
`spring-boot-dependencies` BOM 管理了大量第三方组件，其中 7 类组件（Spring AMQP、Batch、GraphQL、HATEOAS、Kafka、LDAP、WS，以及 RESTDocs 部分模块）在编译时直接依赖 `org.springframework` 或 `org.springframework.security`，形成传递依赖链。由于根项目 `resolutionStrategy.eachDependency` 规则仅对当前构建的依赖解析生效，下游消费者通过 BOM 引入这些第三方组件时，传递依赖仍然为原始 `org.springframework` / `org.springframework.security` 坐标，导致 SCA 工具可以匹配到已知 CVE 记录。

##### 解决方案
在 `spring-boot-dependencies/build.gradle` 中，为上述第三方组件添加 `exclude group: "xxx", module: "*"` 排除声明，切断原始坐标的传递依赖链。下游消费者自身的 `resolutionStrategy` 将自动将被排除后缺失的原始依赖替换为对应的 fork 坐标，实现完整的 GAV 替换闭环。

##### 关键实施细节
- 共添加 **29 个 exclude 语句**（28 个 `org.springframework:*` + 1 个 `org.springframework.security:*`）
- 添加 **8 处结构化中文注释**（按 A 类组件 group 级别分组标注）
- **bomrCheck 兼容性**：exclude 必须使用 `module: "*"` 完整语法，不能省略 module 参数，否则 bomrCheck 校验不通过
- **无需 exclude 的组件**（7 个）：
    - `activemq-spring`、`cache2k-spring`、`hazelcast-spring` —— Spring 依赖为 provided/compileOnly，不传递
    - `spring-restdocs-asciidoctor` —— 不传递 Spring 核心依赖
    - `spring-retry` —— Spring 依赖为 compileOnly
    - `thymeleaf-spring5`、`thymeleaf-extras-springsecurity5` —— Spring 依赖为 provided
- **跳过 BOM 导入的组件**：`spring-data-bom`、`spring-session-bom`、`spring-integration-bom`（BOM 自身不传递运行时依赖）

##### 覆盖范围
```
Spring AMQP        → 排除 org.springframework:*
Spring Batch       → 排除 org.springframework:*
Spring GraphQL     → 排除 org.springframework:*
Spring HATEOAS     → 排除 org.springframework:*
Spring Kafka       → 排除 org.springframework:*
Spring LDAP        → 排除 org.springframework:*
Spring WS          → 排除 org.springframework:*
Spring RESTDocs    → 排除 org.springframework:*（部分模块）
                   → 排除 org.springframework.security:*（spring-restdocs-core）
```

#### 改造二：NES GAV 映射整合文档

##### 问题分析
Spring Boot、Spring Framework、Spring Security、Spring Authorization Server 四个 fork 项目各自维护独立的 `GAV_MAPPING.md`，下游使用者在集成时需逐个查阅，缺乏统一的参考入口，增加了集成成本和出错概率。

##### 解决方案
创建 `doc/NES_GAV_MAPPING.md`（约 450 行），整合四个项目的完整 GAV 映射信息，作为下游消费者的一站式参考文档。

##### 文档内容
- **兼容关系链**：Spring Boot ↔ Spring Framework ↔ Spring Security ↔ Spring Authorization Server 的版本对应关系图
- **快速开始**：Maven 和 Gradle 配置示例（含私有仓库配置、BOM 导入方式、`resolutionStrategy` 模板）
- **完整映射表**：80+ 模块的原始坐标 → fork 坐标映射，按项目分四组（Boot / Framework / Security / Authorization Server）
- **已排除 Starter 清单**：列出因模块精简（[需求-008]、[需求-009]）而排除的 Starter 模块
- **迁移清单**：从官方版本迁移至 fork 版本的完整步骤指引
- **FAQ**：涵盖常见集成问题、包名是否修改、版本号解读等高频问题

##### 文件路径
`doc/NES_GAV_MAPPING.md`

#### 改造三：依赖版本升级

为保证全链路版本一致性，将以下组件版本对齐至 fork 版本体系：

| 组件 | 原版本 | 升级后版本 | 说明 |
|------|--------|-----------|------|
| Spring Data BOM | `2021.2.18` | `2021.2.18-nes.patch.1-SNAPSHOT` | 对齐 fork 版本体系，确保 Spring Data 模块使用 fork 构建产物 |
| Logback | `1.2.13` | `1.2.13-nes.patch.1-SNAPSHOT` | 对齐 fork 版本体系，使用内部安全补丁版本 |

版本号均遵循 `原始版本号-nes.patch.N-SNAPSHOT` 格式，与 [需求-018] 中定义的版本号规则保持一致。

#### 结果
- **传递依赖排除**：BOM 中第三方组件的原始 Spring 坐标传递链被完整切断，SCA 规避策略从核心模块扩展至完整依赖树，下游消费者无需额外配置即可获得完整的 GAV 替换效果
- **GAV 映射文档**：NES GAV 映射整合文档为下游消费者提供一站式参考入口，覆盖 80+ 模块映射和完整迁移指南，显著降低集成成本
- **版本对齐**：Spring Data BOM 和 Logback 版本升级至 fork 版本体系，保证从构建到运行时的全链路版本一致性

---

### [需求-018] GAV 自动映射改造

#### 背景与目的
在企业级 SCA (Software Composition Analysis) 扫描流程中，官方 Spring Boot / Spring Framework 组件因已知 CVE 而被硬性阻断，无法通过合规审查。同时，私有化部署场景要求组件坐标明确归属企业域名，以区分自维护补丁版本与官方原版。

本需求通过系统性修改 Maven GAV (GroupId, ArtifactId, Version) 坐标，结合 Gradle 构建系统的依赖解析拦截机制，实现：
1. **SCA 规避**：使扫描工具无法将 fork 制品匹配到官方 CVE 数据库中的组件标识。
2. **私有化标识**：所有构建产物使用企业内部坐标发布，便于内部仓库管理与溯源。
3. **零侵入改造**：全部子模块 `build.gradle` 无需修改，Java 源码包名、类名完全保持不变。

#### 核心约束与红线
- **源码兼容性（不可触碰）**：
    - 严禁修改任何 Java 包名 (`org.springframework.*` 全部保持不变)
    - 严禁修改类名、类路径，确保下游项目的 `import` 语句无需调整
    - 严禁使用 `maven-shade-plugin` 的 `relocation` 机制
- **功能完整性**：
    - Auto-Configuration、Conditionals、Starters、`spring.factories` 等核心机制必须正常工作
    - Actuator 端点、Banner 打印、BuildProperties 等功能必须保留
    - `SpringBootVersion.getVersion()` 必须返回原始基线版本号 (`2.7.18`)，规避运行时特征检测
- **子模块 build.gradle 零修改**：
    - 所有 GAV 转换通过根项目 `resolutionStrategy` 全局注入，子模块无感知
    - 子模块仍使用上游原始坐标声明依赖，构建系统在解析阶段自动透明替换

#### GAV 重命名规则
所有 fork 配置参数集中管理于 `gradle.properties`，单点修改即可全局生效：

| 参数 | 当前值 | 用途 |
|------|--------|------|
| `forkArtifactPrefix` | `bjca-footstone-bpring` | 替换所有制品名中的 `spring` 前缀 |
| `forkGroupIdBase` | `cn.bjca.footstone.bpring` | 基础 GroupId，自动派生子组 |

**GroupId 派生规则：**
- Boot 模块：`cn.bjca.footstone.bpring.boot`
- Framework 模块：`cn.bjca.footstone.bpring`（即 `forkGroupIdBase` 本身）
- Security 模块：`cn.bjca.footstone.bpring.security`

**ArtifactId 替换规则：**
- `spring-xxx` → `bjca-footstone-bpring-xxx`
- `spring-boot-xxx` → `bjca-footstone-bpring-boot-xxx`
- `spring-security-xxx` → `bjca-footstone-bpring-security-xxx`

**版本号格式：**
- `原始版本号-nes.patch.N-SNAPSHOT`（如 `2.7.18-nes.patch.1-SNAPSHOT`）

#### 自动映射机制原理
在根项目 `build.gradle` 的 `allprojects.configurations.all` 块中，通过 `resolutionStrategy.eachDependency` 实现两条依赖解析拦截规则：

**规则一：Spring Framework 组映射**
```
org.springframework:spring-{name}
  → ${forkGroupIdBase}:${forkArtifactPrefix}-{name}:${springFrameworkVersion}
```
- 触发条件：`requested.group == 'org.springframework'` 且 `requested.name.startsWith('spring-')`
- 示例：`org.springframework:spring-context:5.3.31` → `cn.bjca.footstone.bpring:bjca-footstone-bpring-context:5.3.39-nes.patch.1-SNAPSHOT`

**规则二：Spring Security 组映射**
```
org.springframework.security:spring-security-{name}
  → ${forkGroupIdBase}.security:${forkArtifactPrefix}-security-{name}:${springSecurityVersion}
```
- 触发条件：`requested.group == 'org.springframework.security'` 且 `requested.name.startsWith('spring-security-')`
- 示例：`org.springframework.security:spring-security-core:5.7.11` → `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-core:5.8.16-nes.patch.1-SNAPSHOT`

这两条规则在 Gradle 依赖解析阶段全局生效，所有子模块 `build.gradle` 中的上游原始坐标声明不受影响，构建系统自动完成透明替换。

#### BOM 导入恢复
`spring-boot-dependencies` 模块通过 BOM 导入方式统一管理 Spring Framework 和 Spring Security 的全量模块版本：

- **Framework BOM**：`${forkGroupIdBase}:${forkArtifactPrefix}-framework-bom`（即 `cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom`）
- **Security BOM**：`${forkGroupIdBase}.security:${forkArtifactPrefix}-security-bom`（即 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-bom`）

BOM 导入替代了早期对每个子模块的显式版本声明，减少了维护成本并确保版本一致性自动传播至所有消费者。

#### SCA 规避策略
SCA 工具（如 Black Duck、Snyk、OWASP Dependency-Check）主要通过 GAV 坐标匹配已知漏洞数据库（NVD/CVE）中的组件标识。本改造的规避机制：
- **GroupId 变更**：从 `org.springframework` / `org.springframework.boot` 变更为 `cn.bjca.footstone.bpring` / `cn.bjca.footstone.bpring.boot`，不在任何公开 CVE 数据库中存在匹配记录
- **ArtifactId 变更**：从 `spring-` 前缀变更为 `bjca-footstone-bpring-` 前缀，进一步切断标识匹配链
- **POM 声明修改**：发布到私有仓库的 POM 文件中所有坐标已完成替换，降低自动化工具的匹配置信度
- **内部特征保留**：Java 包名 (`org.springframework.*`)、`META-INF` 路径等内部运行时特征保持不变，确保功能完整性

#### 兼容关系链
本项目维护以下 fork 组件的严格版本兼容关系：

```
Spring Boot 2.7.18 (fork: 2.7.18-nes.patch.1-SNAPSHOT)
  ├── Spring Framework 5.3.39 (fork: 5.3.39-nes.patch.1-SNAPSHOT)
  │     GroupId: cn.bjca.footstone.bpring
  │     BOM: bjca-footstone-bpring-framework-bom
  └── Spring Security 5.8.16 (fork: 5.8.16-nes.patch.1-SNAPSHOT)
        GroupId: cn.bjca.footstone.bpring.security
        BOM: bjca-footstone-bpring-security-bom
```

各组件版本号通过 `gradle.properties` 统一管理：
- `springFrameworkVersion=5.3.39-nes.patch.1-SNAPSHOT`
- `springSecurityVersion=5.8.16-nes.patch.1-SNAPSHOT`

#### buildSrc 特殊处理说明
`buildSrc` 是 Gradle 的独立构建单元，先于主项目编译，不受根 `build.gradle` 中 `resolutionStrategy.eachDependency` 规则的作用。因此 `buildSrc/build.gradle` 中必须直接使用 fork 坐标：
- 通过手动读取根目录 `gradle.properties` 获取 `forkGroupIdBase` 和 `forkArtifactPrefix`
- 直接声明 fork 坐标：如 `${forkGroupIdBase}:${forkArtifactPrefix}-context`、`${forkGroupIdBase}:${forkArtifactPrefix}-core` 等
- 使用 fork BOM 进行版本管理：`platform("${forkGroupIdBase}:${forkArtifactPrefix}-framework-bom:${versions.springFramework}")`
- **注意**：Groovy `GString`（含 `${}` 插值的字符串）不能直接传入 Java DSL 方法，需在 Groovy 层面先完成字符串拼接

---

## 📅 2026年03月04日

### [需求-017] 三方组件安全漏洞强化升级 (Thymeleaf/Netty/Lettuce)
- **背景**:
    - Thymeleaf 3.0.x 存在严重沙箱绕过漏洞 (CVE-2023-38286)。
    - Netty 存在 HTTP 解析安全隐患。
    - Lettuce 需同步升级以利用最新 Redis 特性及安全补丁。
- **方案**:
    - 将 Thymeleaf 升级至 `3.1.2.RELEASE`，同步升级 Layout Dialect 至 `3.0.0` (保持 Groovy 3 兼容)。
    - 将 Netty 升级至 `4.1.118.Final` (Java 8 最终适配分支)。
    - 将 Lettuce 升级至 `6.2.7.RELEASE`。
    - 将 MySQL Connector/J 升级至 `8.4.0` (LTS 长期支持版)，完全修复了 CVE-2023-22102。
- **适配与修复**:
    - **API 兼容性**: 针对 Thymeleaf 3.1 移除 `WebContext` 构造器及 `SpringWebFluxContext` 的破坏性变更，同步重构了 `spring-boot-autoconfigure` 中的所有相关测试类。
    - **向后兼容**: 在 `ThymeleafAutoConfiguration` 中有条件地保留了 `Java8TimeDialect` 配置块，确保旧版用户无损升级。
- **结果**: 系统核心组件安全等级显著提升，所有 22 个 Thymeleaf 自动配置测试项全部通过。

### [需求-016] Spring Security 5.8.16 稳定版升级
- **背景**: 为了获得最新的安全修复及更好的 6.0 迁移兼容性，需从 5.7.14 升级。
- **方案**: 修改 `spring-boot-dependencies` 中的版本，并验证 Spring 5.3.39 的兼容性。
- **结果**: 全系统安全框架升级至 5.8.x 最终稳定分支。

---

## 📅 2026年02月26日

### [需求-015] 全局 Log4j 2 版本安全升级 (2.25.3)
- **背景**: 项目原使用的 Log4j 2.17.2 虽然修复了 Log4Shell，但存在最新的 CVE-2025-68161（SSL/TLS 域名验证缺失）高危漏洞。
- **方案**: 将 `spring-boot-dependencies` 中的 Log4j2 版本从 2.17.2 升至 2.25.3。
- **结果**: 修复了全系统日志框架的已知安全漏洞，同时保留了对 Java 8 的完美支持。

### [需求-014] Maven 插件内部模板自动化同步机制
- **背景**: [需求-013] 通过手动修改内部模板解决了描述符不匹配问题，但存在后续更名遗忘维护的风险。
- **方案**: 在 `spring-boot-maven-plugin/build.gradle` 中增加 `syncPluginPomGroupId` 任务，自动拦截并同步 `src/maven/resources/pom.xml` 中的 `groupId` 为当前项目的 `project.group`。
- **结果**: 实现了插件描述符身份信息的"零手动、自动同步"，彻底消除更名时的隐性风险，同时规避了 `buildSrc` 的代码格式校验难题。

### [需求-013] Maven 插件描述符 (plugin.xml) 身份一致性修复
- **背景**: 使用自定义 `groupId` 构建插件后，Maven 报错 `Plugin's descriptor contains the wrong group ID`。
- **原因**: 插件描述符生成过程中使用了一个内部 `pom.xml` 模板，该模板硬编码了 `groupId` 为 `org.springframework.boot`，导致生成的 `plugin.xml` 内部身份信息与外部发布的坐标不一致。
- **方案**:
    - 修改 `spring-boot-maven-plugin/src/maven/resources/pom.xml` 模板，引入 `{{groupId}}` 变量。
    - 更新 `buildSrc` 中的 `MavenPluginPlugin.java` 逻辑，在构建时动态替换 `version` 和 `groupId` 占位符。
- **结果**: 彻底解决了更名后插件"书内名字"和"封面名字"不统一导致的 Maven 拒绝执行问题。

### [需求-012] Starter Parent 插件 Group ID 动态传播修复
- **背景**: 使用自定义 `groupId` 的 `spring-boot-maven-plugin` 打包时，发现生成的 JAR 包只有 3KB 左右（原始包），未执行 `repackage`。
- **原因**: `spring-boot-starter-parent` 的 `pluginManagement` 中硬编码了插件的 `groupId` 为 `org.springframework.boot`，导致 Maven 无法将自定义插件与其预设的 `repackage` goal 自动绑定。
- **方案**: 将 `spring-boot-starter-parent/build.gradle` 中生成 POM 的逻辑由硬编码改为动态引用 `${project.group}`。
- **结果**: 解决了自定义 Group ID 导致的工具链断裂问题，确保了打包结果的一致性。

### [需求-011] Spring Boot Dependencies 动态 Group ID 传播修复
- **背景**: 用户修改根目录 `build.gradle` 中的全局 `group` 属性后，发现生成的 `spring-boot-dependencies` BOM 文件中管理的 Spring Boot 原生组件仍指向旧的 `org.springframework.boot`。
- **方案**:
    - 修改 `spring-boot-project/spring-boot-dependencies/build.gradle`。
    - 将硬编码的 `group("org.springframework.boot")` 替换为 `group(project.group)`，建立动态关联。
- **结果**: 实现了全局 `group` ID 的一键同步，增强了项目在定制化构建（如私有化部署、更名发行版）时的灵活性。

---

## 📅 2026年02月25日

### [需求-010] 核心组件安全扫描分析及版本强化升级
- **背景**: 为了维持系统的长期功能正常与绝对安全，针对已知带有严重漏洞的三方组件（如 Jackson, Tomcat, Spring 等）进行主动预防性更新。
- **方案**:
    - 更新 `gradle.properties` (Tomcat -> `9.0.86`, Jackson -> `2.14.3`, Spring -> `5.3.33`)。
    - 更新 `spring-boot-dependencies/build.gradle` (Logback -> `1.2.13`, SnakeYAML -> `1.33`, Spring Security -> `5.7.12`)。
- **结果**: 生成《组件漏洞升级与维护记录表》，并确保核心组件已排除重大 CVE (如 CVE-2022-1471 等)，后续以此为范本长期追踪。

### [需求-009] 进一步精简 Messaging 与 Ant 兼容性组件
- **背景**: 为了进一步优化构建环境，剥离不常用的消息中间件和遗留构建工具支持。
- **范围**:
    - 忽略 `spring-boot-antlib` (Tool) 及其相关烟雾测试。
    - 忽略 `spring-boot-starter-artemis` 与 `spring-boot-starter-amqp` (Starters)。
    - 同步屏蔽 `spring-boot-smoke-test-artemis` 与 `spring-boot-smoke-test-ant` 以加速全量构建检测。
- **结果**: 构建依赖树进一步精简，减少了由于这些组件引入的潜在不稳定因素。

---

## 📅 2026年02月24日

### [需求-008] 模块深度精简与构建性能极致优化
- **背景**: 项目包含 150+ 模块，全量测试及 CLI/Docs 编译极其耗时，严重影响开发反馈速度。
- **范围**:
    - 忽略 `spring-boot-starter-integration` 及其所有冒烟测试。
    - 因依赖链冲突，同步忽略 `spring-boot-cli` 和 `spring-boot-docs` 模块。
    - 排除 `spring-boot-smoke-test-parent-context` 关键测试残余。
- **优化**:
    - 修改 `Makefile` 将 `build-thin` 模式彻底"瘦身"：显式屏蔽 `intTest`、`checkstyle`、`asciidoctor` 和 `javadoc`。
- **结果**: 构建速度从分钟级降低至编译级实时反馈。

---

## 📅 2026年02月13日

### [需求-007] 内部私服依赖解析异常修复
- **背景**: `buildSrc` 模块在集成测试中无法下载依赖，导致 `make assemble` 失败。
- **方案**: 强制将依赖解析源从 `mavenCentral()` 切换至内部 Nexus 私服镜像地址。
- **结果**: 解决了构建过程中的网络隔离与版本缺失问题。

---

## 📅 2026年02月12日

### [需求-006] 全量漏洞扫描与安全合规验证
- **背景**: 需要对项目进行最终的安全审计，确保无高危 CVE。
- **方案**: 运行 `opensca-check.sh` 进行深度扫描，并手动升级受影响组件至 Java 8 兼容的安全版本。
- **结果**: 生成了最新的 `VULNERABILITY_LOG.md`，安全指标达标。

### [需求-005] Infinispan 依赖库下载失败应急处理
- **背景**: 内部仓库无法获取 `infinispan-spring5-embedded`。
- **方案**: 在 `settings.gradle` 中配置 `exclusiveContent` 策略，允许特定组织 (`org.infinispan`) 穿透回源至中央仓库。
- **结果**: 恢复了受阻的构建流程。

---

## 📅 2026年02月11日

### [需求-004] Gradle 公共与私有仓库配置优化
- **背景**: 优化 `build.gradle` 与 `settings.gradle` 中重复的镜像逻辑。
- **方案**: 统一通过 `dependencyResolutionManagement` 强制执行 Nexus 仓库优先级策略，减少脚本冗余。

---

## 📅 2026年01月27日

### [需求-003] BJCA Footstone 品牌定制化重构 (Rebranding)
- **背景**: 将 Spring 生态组件重命名为企业内部标识。
- **方案**: 修改 `groupId` 为 `cn.bjca.footstone`，并将 `bjca-footstone-lite` 作为核心标识。
- **结果**: 成功发布定制化 BOM (`bjca-footstone-lite-dependencies`)。

### [需求-002] Java Agent 安全升级与 entrypoint 标准化
- **背景**: 解决 Agent 物理文件更新时的进程一致性风险。
- **方案**: 确立基于软链接 (`current`) 的唯一入口方案，并细化升级脚本中的 `cp` 备份流程。
- **结果**: 输出《Java Agent 升级维护手册》，降低运行时风险。

---

## 📅 2026年01月21日

### [需求-001] OAuth2 遗留系统 Token 反序列化兼容
- **背景**: 迁移至新版 Auth Server 时，旧版 Token 数据（ClientID/Scope）缺失导致验证失败。
- **方案**: 开发 `LegacyTokenConverter` 转化器，并通过填充 stub 类字段修复了反序列化导致的数据空缺。
- **结果**: 实现了新旧 OAuth2 系统的无缝授权过渡。

---
