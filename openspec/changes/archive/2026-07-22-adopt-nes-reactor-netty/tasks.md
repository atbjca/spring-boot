## 1. 实现审批与前置核验

- [x] 1.1 向用户汇报本 change 的问题原因、设计决策、影响分析、预期文件清单、测试计划和回滚方案，取得明确的实现批准；未批准前不得修改 OpenSpec 之外的代码或业务文档
- [x] 1.2 提示用户确认代码备份策略，并复核当前分支为 `2.7.x-bjca-patch`、HEAD/GitLab 引用、业务工作区状态；记录并隔离 `.claude/commands/opsx`、`.claude/skills` 等无关未跟踪文件
- [x] 1.3 从 Nexus 或禁用 `mavenLocal()` 的干净临时消费者解析四个 Reactor Netty NES 模块，记录 SNAPSHOT timestamp/build metadata，并确认 POM 传递依赖为 Netty `4.1.136.Final`
- [x] 1.4 检查 Reactor Netty NES/Core/HTTP 关键 class 的 bytecode major 不高于 52，确认 Java 8 兼容
- [x] 1.5 记录生产者修复已绑定并推送 commit `da3c7cf2`；将“重新部署该 commit 对应 SNAPSHOT，并由 Boot 验证 JAR 字节码/行为一致”设为 Spring Boot 正式 deploy 前置门禁

## 2. TDD：先建立失败的发布与解析契约

- [x] 2.1 调研现有 buildSrc、BOM 和 starter 发布测试结构，选用项目既有测试模式，不引入新第三方库或新设计模式
- [x] 2.2 先增加版本单点、官方→NES Reactor Netty 四模块白名单映射的自动化断言，并运行证明当前配置尚未满足（预期失败）
- [x] 2.3 先增加 `spring-boot-dependencies` 生成 POM 对四个 NES managed dependencies 和 Netty `4.1.136.Final` 的断言，并运行证明当前 POM 尚未满足（预期失败）
- [x] 2.4 先增加 `spring-boot-starter-reactor-netty` 生成 POM 断言：必须包含 NES HTTP GAV、不得包含官方 HTTP GAV；运行证明当前 POM 尚未满足（预期失败）
- [x] 2.5 先增加依赖图无官方/fork 双份 Reactor Netty、无旧 Netty 的可执行检查，并记录修改前结果
- [x] 2.6 对新增测试与构建规则关键分支统计覆盖情况；配置类和简单声明可豁免算法覆盖率，但新增映射/发布契约必须全部被断言覆盖

## 3. 依赖映射与发布实现

- [x] 3.1 在 `gradle.properties` 增加 Reactor Netty NES 版本单点属性及中文说明，禁止在多个构建文件重复硬编码版本
- [x] 3.2 在根 `build.gradle` 增加官方 Reactor Netty 四模块精确白名单映射规则，使用中文注释说明 group、artifact、版本和 QUIC 排除边界
- [x] 3.3 在 `spring-boot-dependencies/build.gradle` 显式管理四个 NES Reactor Netty 模块，同时保留官方 Reactor BOM 管理非 fork Reactor 组件
- [x] 3.4 将 Netty BOM 从 `4.1.135.Final` 升级至 `4.1.136.Final`，同步相关构建注释与约束
- [x] 3.5 将 `spring-boot-starter-reactor-netty` 的直接 API 依赖改为 NES HTTP GAV，确保 MavenPublication 输出 NES 坐标
- [x] 3.6 运行 2.2—2.5 的测试/断言并确认由红转绿；若发布 POM 仍输出官方 GAV，暂停实现并重新提交设计调整审批

## 4. 消费者与运行时回归

- [x] 4.1 生成 Spring Boot BOM 和 starter POM，逐项确认 NES Reactor Netty 四模块版本、starter NES HTTP 依赖及 Netty 4.1.136 管理结果
- [x] 4.2 解析 WebFlux、WebClient、Actuator、RSocket 相关 compile/runtime classpath，确认只存在 NES Reactor Netty 且 Netty 核心模块全为 4.1.136.Final
- [x] 4.3 运行 WebFlux/WebClient、Actuator、RSocket 受影响模块的针对性测试，排查 classpath、自动装配、客户端和嵌入式服务端回归
- [x] 4.4 增加或复用 HTTP/2 配置回归测试，验证用户显式 `maxConcurrentStreams` 不会被 Netty 4.1.136 默认值静默压低为 100
- [x] 4.5 将 Spring Boot 相关产物发布到临时本地 Maven 仓库，使用独立 Maven 消费者验证 starter POM 仅引入 NES Reactor Netty
- [x] 4.6 使用独立 Gradle 消费者验证 NES BOM/starter 解析结果；消费者不得复制本仓库内部 `resolutionStrategy`
- [x] 4.7 在可访问 Nexus 的干净环境强制刷新 `da3c7cf2` 对应 SNAPSHOT 后复验；HTTP 制品解析为 `20260722.053243-4`，SHA-256 `19adc757f94b426c8654afdedb27eb67a0f4e40b7a35957411686524f2a4d5cc`，字节码包含 `UriEndpoint.isSecure()` 降级剥头分支

## 5. 安全评估与防呆

- [x] 5.1 核对 fork 中 `CVE-2025-22227`、`CVE-2026-41715` 的源码补丁、回归测试与 Nexus 制品证据；仅在三者闭环后标记为已修复
- [x] 5.2 记录同 origin、跨 host/port、链式重定向、HTTPS→HTTP 降级以及 `Authorization`/`Proxy-Authorization` 的评估矩阵；不得把“预期泄露”写成永久绿色回归测试
- [x] 5.3 将 Reactor Netty 本体漏洞与 Netty 传递依赖漏洞分开定性；只对修复线和证据确实由 4.1.136 覆盖的 Netty CVE 标记已修复
- [x] 5.4 检查依赖替换不会引入额外暴露端口、远程管理接口、凭据日志或不安全仓库配置；确认本 change 不涉及 SQL、鉴权或数据访问面，记录“不适用”理由
- [x] 5.5 全仓搜索两个重定向 CVE、Reactor Netty 版本和 Netty 版本，消除“已修复/修复中”及 4.1.135/4.1.136 的文档冲突

## 6. 文档与交付物同步

- [x] 6.1 更新 `doc/REQUIREMENTS.md`，登记采用 Reactor Netty NES、Netty 4.1.136、发布 POM 契约、CVE 未闭环边界及回滚方案
- [x] 6.2 更新 `doc/COMPONENTS_UPGRADE_HISTORY.md`，登记官方 Reactor Netty→NES GAV 和 Netty 4.1.135→4.1.136
- [x] 6.3 更新 `doc/VULNERABILITY_REPORT.md`、`doc/CVE/CVE-2025-22227.md` 和 `doc/CVE/CVE-2026-41715.md`；按最终 Nexus 制品证据统一标记两个漏洞为“已修复”
- [x] 6.4 更新 `doc/NES_GAV_MAPPING.md` 与 `doc/GAV_MAPPING.md`，补充四模块映射、版本、官方 Reactor BOM 保留范围和 QUIC 排除说明
- [x] 6.5 更新 `doc/USER_MANUAL.md`，覆盖 Nexus、BOM/starter、直接 GAV、SNAPSHOT、Java 8、安全限制、故障排查与回滚
- [x] 6.6 更新 `doc/QUICK_START.md`，提供可复制的 Maven/Gradle 最小示例，并确保示例不依赖内部 resolutionStrategy
- [x] 6.7 按实际测试命令和结果更新 `doc/TESTING.md`；未执行或因环境阻塞的门禁必须如实标注，不得写成通过
- [x] 6.8 新增注释优先使用中文，并复核命名、日志、异常与构建风格符合项目现有约定

## 7. 完整验证与归档准备

- [x] 7.1 运行新增构建/发布契约测试、BOM/POM 生成检查及依赖解析检查，确认全部通过
- [x] 7.2 运行项目标准 Tier A 门禁 `make clean test`；定位并修复 Tomcat forward-header 首请求偶发 `NoHttpResponseException` 后，连续两轮分别以 6m56s、8m29s 和退出码 0 通过
- [x] 7.3 在 7.2 连续两轮通过后运行 `make build-thin`，以约 14m49s 和退出码 0 完成；Reactor Netty NES 关键 class 的 bytecode major 52 证据继续满足 Java 8 基线
- [x] 7.4 执行 `openspec validate adopt-nes-reactor-netty --strict`，修复全部规格格式或一致性问题
- [x] 7.5 复核 Git diff 和 `git status`，确认只包含本 change 文件且未纳入本地 AI 工具目录或其他历史改动
- [x] 7.6 汇报实现清单、测试证据、覆盖率适用性、未闭环 CVE、上游 commit 可追溯性门禁和剩余风险，等待用户明确批准归档、提交、部署或推送
