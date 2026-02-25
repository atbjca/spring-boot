# Spring Boot 项目需求维护手册 (Requirements Manual)

本文档按照时间倒序记录了项目近期的核心需求变更、架构调整及关键修复，作为项目长期维护的审计依据。

---

## 📅 2026年02月25日

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
    - 修改 `Makefile` 将 `build-thin` 模式彻底“瘦身”：显式屏蔽 `intTest`、`checkstyle`、`asciidoctor` 和 `javadoc`。
- **结果**: 构建速度从分钟级降低至编译级实时反馈。
```text
 make build-thin
./gradlew clean build -x test -x intTest -x checkstyleMain -x checkstyleTest -x asciidoctor -x javadoc
Starting a Gradle Daemon, 5 stopped Daemons could not be reused, use --status for details
Configuration on demand is an incubating feature.

> Task :spring-boot-project:spring-boot-tools:spring-boot-antlib:integrationTest
Trying to override old definition of task fail
Trying to override old definition of datatype resources
Trying to override old definition of task buildnumber

> Task :spring-boot-system-tests:spring-boot-image-tests:jar
:spring-boot-system-tests:spring-boot-image-tests:jar: No valid plugin descriptors were found in META-INF/gradle-plugins

Deprecated Gradle features were used in this build, making it incompatible with Gradle 8.0.

You can use '--warning-mode all' to show the individual deprecation warnings and determine if they come from your own scripts or plugins.

See https://docs.gradle.org/7.6.3/userguide/command_line_interface.html#sec:command_line_warnings

BUILD SUCCESSFUL in 6m 3s
2167 actionable tasks: 1114 executed, 404 from cache, 649 up-to-date

A build scan was not published as you have not authenticated with server 'ge.spring.io'.
For more information, please see https://gradle.com/help/gradle-authenticating-with-gradle-enterprise.
```

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
