## Context

Spring Boot 2.7 NES 当前导入官方 Reactor BOM `2020.0.47`，由其管理 Reactor Core 3.4.x 和官方 Reactor Netty 1.0.48；`spring-boot-starter-reactor-netty` 直接声明 `io.projectreactor.netty:reactor-netty-http`。根构建已有多组 `resolutionStrategy.eachDependency` 规则，用于把仓库内部请求的官方 Spring/Spring Data/Spring Kafka GAV 透明替换成 NES GAV，但这种解析期替换不会自动改写 Gradle 生成的 Maven POM。

Reactor Netty NES fork 已以以下坐标部署到 Nexus：

| 模块 | NES 坐标 | 版本 |
|---|---|---|
| 聚合模块 | `cn.bjca.footstone.beactor.netty:bjca-footstone-beactor-netty` | `1.0.48-nes.patch.1-SNAPSHOT` |
| Core | `cn.bjca.footstone.beactor.netty:bjca-footstone-beactor-netty-core` | 同上 |
| HTTP | `cn.bjca.footstone.beactor.netty:bjca-footstone-beactor-netty-http` | 同上 |
| HTTP Brave | `cn.bjca.footstone.beactor.netty:bjca-footstone-beactor-netty-http-brave` | 同上 |

该 fork 没有 BOM，内部 Netty 已升级并全量验证至 `4.1.136.Final`，Java 字节码仍兼容 Java 8。它当前基于官方 Reactor Netty 1.0.48，并在 commit `da3c7cf2` backport `CVE-2025-22227` 与 `CVE-2026-41715` 的完整重定向凭据修复。2026-07-22 从 Nexus 干净解析的新制品已确认包含 `UriEndpoint.isSecure()` 降级剥头分支，因此源码、测试与制品证据已经闭环。

Spring Boot 工作区当前业务文件干净，仅存在未跟踪的本地 AI 工具目录；实现不得纳入或修改这些目录。目标分支为 `2.7.x-bjca-patch`，其 GitLab 引用与当前 HEAD 一致，但既有 upstream tracking 显示 gone；大范围实现前必须再次确认分支、HEAD 和工作区状态。Reactor fork 已提交并推送 `da3c7cf2`，包含 GAV、Netty 4.1.136、HTTP/2 修复及两个重定向 CVE backport。重新部署后，Boot 使用全新 Maven 本地仓库解析到 HTTP 制品 `20260722.053243-4`，SHA-256 为 `19adc757f94b426c8654afdedb27eb67a0f4e40b7a35957411686524f2a4d5cc`，字节码包含 `UriEndpoint.isSecure()` 调用，正式发布前置门禁已满足。

## Goals / Non-Goals

**Goals:**

- 让 Spring Boot 仓库的 Reactor Netty 依赖解析统一使用 NES fork，且不存在官方/fork 双份模块。
- 让发布后的 `spring-boot-starter-reactor-netty` Maven POM 直接引用 NES HTTP 模块，使 Maven 消费者无需理解 Gradle 内部替换规则。
- 在 Spring Boot BOM 中显式管理所有受支持的 Reactor Netty NES 模块，并将 Netty 统一到 `4.1.136.Final`。
- 保留官方 Reactor BOM 管理 Reactor Core 等未 fork 组件，避免无关依赖管理扩张。
- 通过 TDD 验证坐标映射、BOM/POM 发布语义、依赖图、Java 8 兼容及 WebFlux/WebClient/RSocket/Actuator 关键路径。
- 如实同步 CVE、需求、组件历史、GAV、用户手册、快速入门和测试文档。

**Non-Goals:**

- 不在 Spring Boot 仓库中修复 Reactor Netty 的 `CVE-2025-22227` 或 `CVE-2026-41715` 源码；修复必须回到 Reactor Netty fork 独立 change 完成。
- 不把“切换到 fork”解释为上述两个 CVE 已修复。
- 不 fork 或替换 Reactor Core、Reactor Test、Reactor Addons 等非 Reactor Netty 模块。
- 不默认管理或引入 `bjca-footstone-beactor-netty-incubator-quic`；Spring Boot 2.7 默认 WebFlux/RSocket 路径不依赖该模块。
- 不引入新的第三方库、依赖替换框架或新的发布插件。
- 不改变 `reactor.netty.*` Java package、Spring Boot 公共 Java API 或应用配置属性。

## Decisions

### D1：构建期使用精确白名单映射，不做整个 group 的通配替换

根 `build.gradle` 新增独立规则，仅映射官方 `reactor-netty`、`reactor-netty-core`、`reactor-netty-http`、`reactor-netty-http-brave` 四个模块，并通过 `reactorNettyNesVersion` 单点取版本。ArtifactId 按明确映射或受控前缀转换生成。

选择白名单是因为 Reactor Netty 还存在 incubator QUIC 等不同 group、不同版本线模块；宽泛替换可能构造不存在的坐标。备选方案是直接修改仓库所有 `build.gradle` 的官方声明，修改面过大且容易遗漏测试/文档模块，因此只在发布语义敏感的 starter 中直接改坐标，其余使用全局映射。

### D2：starter 直接声明 NES HTTP GAV，不能仅依赖 resolutionStrategy

`spring-boot-starter-reactor-netty` 的 `api` 依赖直接改成 NES HTTP 坐标并引用单点版本属性。Gradle 的依赖解析规则只影响构建图，默认 MavenPublication 会保留声明侧依赖信息；若 starter 继续声明官方 GAV，下游 Maven 项目可能绕过本仓库规则并重新拉取官方 Reactor Netty。

备选方案是在通用 Maven 发布约定中用 `pom.withXml` 全局重写坐标。该方案会影响所有子项目发布、风险远大于一个 starter 的显式声明，也可能与既有 fork GAV 发布逻辑冲突，故不采用。

### D3：BOM 显式管理 fork 模块，同时保留官方 Reactor BOM

在 `spring-boot-dependencies` 中新增 Reactor Netty NES library/group，显式列出四个 fork 模块。官方 Reactor BOM `2020.0.47` 继续存在，仅负责 `reactor-core`、`reactor-test` 等官方 group 组件。由于 dependency management 以 GAV 为键，官方 BOM 无法管理新的 NES group，不能把它当作 fork BOM 使用。

备选方案是要求 Reactor fork 先发布 BOM。长期可行，但当前制品已部署且 Spring Boot 可以安全显式管理四个模块；等待 BOM 会无必要阻塞集成。若以后 fork 发布 BOM，应新建 change 评估替换显式清单。

### D4：Netty 与生产者验证基线对齐到 4.1.136.Final

Spring Boot BOM 将 Netty 从 `4.1.135.Final` 升至 `4.1.136.Final`。Reactor fork 已在该版本上暴露并修复 `Http2Settings.defaultSettings()` 默认 `maxConcurrentStreams=100` 所造成的语义回归，并完成全量测试和 japicmp 检查。消费者侧仍需通过依赖解析和关键路径测试验证最终 classpath 全部选择 4.1.136，无旧版本或双份模块。

备选方案是保留 Boot 的 4.1.135，让 BOM 覆盖 fork POM 的 4.1.136。该方案会偏离生产者的已验证组合并可能绕过 HTTP/2 修复前提，故不采用。

### D5：TDD 先覆盖“发布契约”，再修改依赖配置

本 change 不新增业务算法，主要风险在依赖与发布契约。实现顺序必须为：

1. 先增加或调整测试/自动断言，证明当前生成 POM、BOM 或依赖图仍出现官方 GAV/旧 Netty，并观察预期失败。
2. 再修改版本属性、坐标映射、BOM 和 starter 声明，使测试通过。
3. 再执行 WebFlux/WebClient、Actuator、RSocket 与 HTTP/2 相关回归。
4. 最后从独立临时 Maven/Gradle 消费者解析本地发布产物，验证下游行为。

构建配置和简单依赖声明不适用“复杂算法 60% 覆盖率”，但新增映射分支、BOM 管理项和发布 POM 契约必须有自动化断言覆盖。新增测试代码与必要注释优先使用中文，保留 GAV、POM、HTTP/2 等专业术语。

### D6：CVE 状态由补丁和可执行证据决定，不由坐标决定

`CVE-2025-22227`、`CVE-2026-41715` 的状态必须由源码补丁、回归测试和已发布制品共同决定，不能通过切换坐标直接闭环。本 change 已确认 commit `da3c7cf2`、生产者回归测试以及 Nexus HTTP 制品 `20260722.053243-4` 三项证据一致，因此可将两者更新为“已修复”。测试仍不得通过断言漏洞存在、忽略或禁用失败用例制造绿色门禁。

Netty 4.1.136 覆盖的漏洞则按官方修复线、依赖解析结果和生产者测试证据更新为已修复。文档必须区分“Reactor Netty 本体漏洞”和“Netty 传递依赖漏洞”。

### D7：消费者文档同时覆盖 NES starter 和直接使用 fork 的场景

User Manual 与 Quick Start 至少说明 Nexus 配置、NES Boot BOM/starter 用法、直接使用 Reactor Netty fork 时的坐标、SNAPSHOT 更新策略、Java 8 基线、已知未闭环 CVE 和回滚方法。示例不得暗示 Maven 能识别 Gradle `resolutionStrategy`，也不得继续推荐官方 Reactor Netty GAV 作为 NES 默认路径。

## Risks / Trade-offs

- [发布 POM 仍含官方 Reactor Netty] → 先写生成 POM 失败断言；starter 直接声明 NES GAV；使用独立 Maven 消费者复验。
- [官方与 NES Reactor Netty 同时进入 classpath] → 精确白名单映射并检查 compile/runtime 依赖图；对四个模块逐项断言无双份。
- [fork 没有 BOM造成模块漏管] → BOM 显式列出四个稳定模块；QUIC 明确排除并在文档中说明版本线独立。
- [Netty 4.1.136 带来 HTTP/2 行为变化] → 复用生产者修复证据，并在 Boot WebFlux/HTTP/2 路径执行针对性回归和完整测试门禁。
- [SNAPSHOT 缓存导致消费者拿到旧制品] → 保留 changing module 零缓存策略；独立消费者强制更新并记录 Nexus metadata/解析版本。
- [源码 commit 与 Nexus SNAPSHOT 不一致] → 已记录生产者 commit `da3c7cf2`；Boot 正式发布前强制刷新 Nexus，并以 JAR 字节码/行为测试确认部署制品包含该 commit 的重定向修复。
- [两个重定向 CVE 被错误标记已修复] → spec 规定只有补丁、回归测试和重新发布制品三者闭环才能更改状态；本 change 修正文档冲突。
- [内部 GAV 对外部消费者构成破坏性变化] → User Manual/Quick Start 明示必须配置 NES Nexus；提供回滚和官方坐标替代说明。
- [大范围回归耗时或受私服波动影响] → 先运行快速 TDD 和依赖/POM 门禁，再运行标准全量门禁；网络失败与代码失败分开记录，禁止把未执行写成通过。
- [工作区混入本地工具文件] → 实现前后检查 `git status`，只暂存 change 范围文件，不触碰 `.claude/commands/opsx`、`.claude/skills`。

## Migration Plan

1. 实现前提示备份并确认 `2.7.x-bjca-patch`、HEAD、GitLab 分支和干净业务工作区。
2. 从 Nexus/干净临时消费者确认四个 NES Reactor Netty SNAPSHOT 模块可解析，记录实际 timestamp/build metadata；核验 Java 8 class major。
3. 按 TDD 增加发布 POM、BOM 和依赖映射断言，运行并记录预期失败。
4. 增加版本属性、精确坐标映射、BOM 管理项，修改 starter 直接依赖。
5. 运行针对性依赖解析、POM/BOM、WebFlux/WebClient/Actuator/RSocket/HTTP2 测试，再执行标准全量门禁。
6. 将 Spring Boot 产物发布到本地临时 Maven 仓库，使用独立 Maven 和 Gradle 示例项目验证仅解析 NES Reactor Netty 与 Netty 4.1.136。
7. 更新全部安全、需求、GAV、用户手册、快速入门和测试文档；执行 `openspec validate --strict`。
8. 在正式 deploy Spring Boot 前确认 Reactor fork 已把部署源码提交并推送，确保制品可追溯。

回滚时同时恢复 starter 官方依赖、删除 Reactor Netty 映射和 NES BOM 管理项、移除单点 fork 版本属性、将 Netty 恢复为 4.1.135，并重新生成 POM/BOM验证官方坐标恢复。文档状态随实际依赖一并回滚，不保留与运行时不符的“已采用 fork”描述。

## Open Questions

- Reactor Netty fork 的已部署制品已通过字节码与 commit `da3c7cf2` 的关键安全分支交叉验证，无剩余部署可追溯性问题。
