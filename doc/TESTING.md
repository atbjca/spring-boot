# Spring Boot 2.7 测试策略与开发验证指南

> **分支**：`2.7.x-bjca-patch`  
> **基线**：2.7.18（当前开发版本 `2.7.18-nes.patch.2-SNAPSHOT`；已发布版本 `2.7.18-nes.patch.1`）
> **对齐参考**：3.5 fork 的 Tier 分层（`doc/TESTING.md`）  
> **最后更新**：2026-08-13

本文档说明 2.7 fork **测什么、不测什么、日常怎么验**，以及 `make test` 与 `make test-feedback` 的分工。

---

## 目录

1. [核心结论](#1-核心结论)
2. [日常开发：改代码后怎么验](#2-日常开发改代码后怎么验)
3. [本地环境要求](#3-本地环境要求)
4. [Makefile 命令](#4-makefile-命令)
5. [质量 Tier（门槛定义）](#5-质量-tier门槛定义)
6. [Tier A：make test 范围](#6-tier-amake-test-范围)
7. [Tier C：make test-feedback 范围](#7-tier-cmake-test-feedback-范围)
8. [已知失败分类](#8-已知失败分类)
9. [Gradle TestKit 与离线分发包](#9-gradle-testkit-与离线分发包)
10. [与 3.5 fork 的差异](#10-与-35-fork-的差异)
11. [维护规则](#11-维护规则)

---

## 1. 核心结论

| 问题 | 答案 |
|------|------|
| 本地能跑测试吗？ | **能**（Java 8/11 + Gradle 7.6.3 本地 zip） |
| 全量 `./gradlew test` 能全绿吗？ | **不能**，也不作为目标 |
| `make build` / `make clean build` 能全绿吗？ | **能**（稳定门禁：全量编译打包 + checkstyle + Tier A 测试；TestRetry 默认开启） |
| 日常 `make test` 要 Kafka/Redis/Docker 吗？ | **需要内嵌 Kafka（NES EmbeddedKafka），不需要外部 Kafka/Redis/Docker** |
| 日常 merge 门槛？ | **`make build-thin` + `make test`（Tier A，核心模块 + Kafka smoke，承诺维护全绿）** |
| 扩大反馈？ | **`make test-feedback`（Tier C，`--continue`，已知红可接受）** |
| 和 3.5 的 `make test` 一样短吗？ | **策略相同**（先窄后宽）；2.7 已投入更广摸底，用 `test-feedback` 保留 |

---

## 2. 日常开发：改代码后怎么验

### 2.1 推荐流程（由快到慢）

```
改代码
  │
  ▼
① make build-thin     编译、打包（跳过 test）
  │
  ▼
② make test           Tier A：核心模块（spring-boot + spring-boot-test）+ Kafka smoke
  │
  ▼
③ （按需）单模块 test  只改了某一库时更快
  │
  ▼
④ （发布前/大改后）make test-feedback   Tier C：扩大反馈面
```

**日常最低安全线**：**① + ② 均 BUILD SUCCESSFUL**，再提交。

### 2.2 提交前检查清单

```
□ git diff 范围符合预期
□ make build-thin  → BUILD SUCCESSFUL
□ make test        → BUILD SUCCESSFUL
□ （若改了 autoconfigure / actuator / gradle-plugin）补跑对应单模块 test
□ （大版本升级 / BOM 变更后）make test-feedback 摸底
```

### 2.3 按改动位置选择命令

| 改动位置 | 建议命令 |
|----------|----------|
| `spring-boot` 主库 | `make build-thin` + `make test` |
| `spring-boot-autoconfigure` | `build-thin` + `:spring-boot-project:spring-boot-autoconfigure:test` |
| `spring-boot-gradle-plugin` | `build-thin` + `:spring-boot-project:spring-boot-tools:spring-boot-gradle-plugin:test` |
| 某个 `starter` | `make build-thin` |
| 仅 `doc/` / `Makefile` | 可不跑 test |
| BOM / `spring-boot-dependencies` | **必须** `make build-thin` + `make test-feedback` |
| Reactor Netty/Netty 坐标或版本 | buildSrc 映射契约 + BOM/starter POM + autoconfigure Netty 测试 + 独立消费者解析 |

### 2.5 Reactor Netty NES 专项门禁

采用或升级 Reactor Netty NES 时至少验证：

```bash
./gradlew -p buildSrc test \
  --tests org.springframework.boot.build.ForkDependencySubstitutionTests

./gradlew \
  :spring-boot-project:spring-boot-dependencies:generatePomFileForMavenPublication \
  :spring-boot-project:spring-boot-starters:spring-boot-starter-reactor-netty:generatePomFileForMavenPublication

./gradlew :spring-boot-project:spring-boot-autoconfigure:test \
  --tests org.springframework.boot.autoconfigure.web.embedded.NettyWebServerFactoryCustomizerTests
```

还必须检查 starter/BOM 生成 POM、runtimeClasspath 和独立 Maven/Gradle 消费者：不得出现官方/NES Reactor Netty 双份，所有 Netty 核心模块必须为 `4.1.136.Final`。重定向 CVE 必须以源码、回归测试和已发布制品三项证据闭环，不允许用“预期泄露”的永久绿色测试掩盖风险。

#### 2026-07-22 实施记录

- buildSrc 契约测试：修改前新增 3 个用例按预期失败；实现后 6/6 通过。
- BOM/starter 生成 POM：通过；starter 直接依赖 NES HTTP，BOM 管理四个 NES 模块和 Netty 4.1.136。
- `NettyWebServerFactoryCustomizerTests`：通过，包含 `maxStreams(123)` 回归。
- 独立 Gradle 消费者：通过，仅解析 NES Reactor Netty，Netty 全为 4.1.136。
- 独立 Maven 消费者：将新 BOM/starter 安装到隔离临时仓库后通过；依赖树仅包含 NES HTTP/Core，Netty 全为 4.1.136，无官方 Reactor Netty。
- WebFlux/WebClient、Actuator、RSocket、Netty server 针对性测试：通过（`BUILD SUCCESSFUL in 51s`）。
- Tier A 首轮发现 classpath 排除仍按旧 artifactId 匹配；修复后针对性用例通过。后续复验确认 98% 阶段仍会继续执行，并非 Jetty 死锁；真正的偶发失败是 Tomcat `useForwardHeaders()` 在高负载下首请求收到 `NoHttpResponseException`。公共 Servlet WebServer 测试辅助方法现仅对该瞬时异常做最长 10 秒的有限重试，其他 I/O、URI 和断言错误仍立即失败。
- 2026-07-22 修复后连续两轮 `make clean test` 均通过：分别为 `BUILD SUCCESSFUL in 6m 56s`、`BUILD SUCCESSFUL in 8m 29s`，退出码均为 0；随后 `make build-thin` 约 14m49s 完成，退出码 0。Tier A 与 build 门禁现可如实标记为全绿。
- Nexus 上尚未部署本次新的 Boot SNAPSHOT，因此直接消费 Nexus 仍会得到旧 starter；正式部署后必须再做一次不使用临时本地仓库的 Maven/Gradle 依赖树验收。
- Reactor Netty 生产者已提交并推送 `da3c7cf2`。重新部署后，使用全新 Maven 本地仓库从 Nexus 解析到 HTTP 制品 `20260722.053243-4`，SHA-256 为 `19adc757f94b426c8654afdedb27eb67a0f4e40b7a35957411686524f2a4d5cc`；`javap` 确认字节码包含两次 `UriEndpoint.isSecure()` 调用，跨 origin 与 HTTPS→HTTP 降级剥头修复已进入制品。

### 2.6 Spring Security patch.2 候选专项门禁

当前开发基线采用 `5.8.16-nes.patch.2-SNAPSHOT`，但它仍是候选而非正式 RELEASE。采用或升级 NES Spring Security 时至少验证：

- `springSecurityVersion` 继续作为唯一版本源，现有官方到 NES 坐标映射和 Boot dependency-management 中的 Security BOM import 均由它驱动；
- 生成的 Boot BOM、Security starter POM和 Gradle Module Metadata只包含 patch.2 NES Security，不得残留 patch.1 或官方 Security 实现；
- OAuth2 resource-server、SAML2、servlet、reactive、OAuth2 client、X.509 和通用 Security auto-configuration 完成代表性 Boot 回归；
- 发布所需 Boot 模块到隔离临时 Maven 仓库后，独立 Maven/Gradle consumers 只依靠发布元数据解析，不复制根构建 `resolutionStrategy` 或源码 substitution；
- Maven/Gradle consumers 在真实 Java 8 上完成 Security、OAuth2、SAML/OpenSAML、Crypto和 Bouncy Castle smoke，代表性主 artifact 的 class major 不高于 52；
- SendGrid 与 Security SAML/Crypto 的 Bouncy Castle 图有唯一且经过 Maven、Gradle、Boot自动配置和 Java 8 行为验证的处置；当前选择 SendGrid 4.10.1并统一到 jdk18on 1.84；不同 artifactId 能共存不等于图已收敛；
- 正式 Boot RELEASE 必须等待 Nexus 中的 Security `5.8.16-nes.patch.2` RELEASE和精确 `v5.8.16-nes.patch.2` tag，内部 SNAPSHOT 残留必须阻止发布。

#### 2026-08-13 阶段记录

- patch.1 与 patch.2 在测试适配前均出现相同的 14 个唯一失败：12 个 OAuth2 resource-server和 2 个 SAML filter-chain断言。两者失败集合一致，根因是测试仍引用 Spring Security 5.8 的旧包兼容 stub；测试已改为实际安装的新包 filter 类。
- `scripts/verify-spring-security-adoption.sh all` 已通过版本单点、Boot BOM import、Security/OAuth2 starter POM、Gradle Module Metadata以及代表性 compile/runtime图断言。解析到的 Security 候选为 `5.8.16-nes.patch.2-20260811.065312-1`，producer source为 `9c5e51ee66dc47bc02bb25e803f5bccc71b7cd5a`。
- OAuth2/SAML 目标测试首轮在 `compileTestJava` 阶段因主机内存压力以 exit 137 终止，未产生测试结果；解除暂停后使用 `--no-daemon --no-parallel --max-workers=1`、`-Xmx2g` 受限复跑，两个目标类均通过（`BUILD SUCCESSFUL in 1m 20s`）。随后 servlet/reactive、OAuth2 client/resource-server、SAML2 和通用 Security auto-configuration 代表性测试也通过（`BUILD SUCCESSFUL in 39s`）；仓库该包下没有独立 X.509 Boot 测试类，因此未虚构单独结果。
- 使用 Amazon Corretto `1.8.0_482` 的 Maven/Gradle baseline smoke确认 SendGrid `4.9.3` 图同时含 `bcprov-jdk15on:1.70`和 Security `jdk18on:1.84`；两者有 1,475 个重叠 class。该基线风险已被记录。
- SendGrid `4.10.1` 的 Maven/Gradle 图断言均通过，只含 `jdk18on:1.84` family；Java 8 SendGrid/Security/OpenSAML smoke和 Boot `SendGridAutoConfigurationTests`均通过，最终 BC 处置为小版本升级。
- 独立 Maven/Gradle consumers 已从同一隔离仓库解析 Boot BOM、Boot core/autoconfigure、Security starter、OAuth2 resource-server starter、Security SAML/Crypto、OpenSAML、BC 和 SendGrid。发布运行的七个 Boot 项目统一使用 timestamp/build `20260813.054327-1`；Security candidate 解析为 `5.8.16-nes.patch.2-20260811.065312-1`。
- Amazon Corretto `1.8.0_482` 上 Maven 和 Gradle smoke 均通过，直接运行共享 smoke（Maven 使用真实 Java classpath，避免 exec 插件 classloader 隔离）。Boot、Security、OAuth2、SAML、Crypto、BC 和 SendGrid 均从预期制品加载，OpenSAML 初始化、Security Crypto、BC AES-GCM 和 SendGrid 构造均成功。
- Maven/Gradle 关键图一致：只含 NES Security `5.8.16-nes.patch.2-SNAPSHOT`，无官方 Security、无 patch.1、无 `bcprov-jdk15on`，SendGrid 为 `4.10.1`，BC 为 `bcpkix/bcprov/bcutil-jdk18on:1.84`。代表性 Boot、Security、OAuth2、SAML、Crypto 和 BC class major 均为 52；Java 8 runtime、依赖树、timestamp/build 和 SHA-256 明细在验证运行时生成到 `build/spring-security-adoption/evidence/`，最终 `make build` 的 `clean` 已清理该临时目录，关键摘要已固化在本 change 的 `evidence.md`，可由验证脚本重建。
- 代表性 consumers 和 BC 处置自动检查已解除此前的 Gradle 暂停并通过。随后按 Java 17、Gradle 7.6.3、单 worker、禁用并行和受限 JVM 配置运行 `make build`：全量非测试 build 退出码 0（`BUILD SUCCESSFUL in 19m 11s`，2167 actionable tasks），Tier A 测试退出码 0（`BUILD SUCCESSFUL in 5m 16s`，67 actionable tasks）。输出中的 Java 17 removal/Javadoc 警告和未认证 build scan 不影响退出码；远程 build cache 403 被 Gradle 当作可恢复 cache miss。首次重跑曾发现本 change SAML 测试 import 分组 Checkstyle 错误并退出码 2，修正后定点 checkstyle 及完整 `make build` 均通过。

**单模块示例**：

```bash
./gradlew :spring-boot-project:spring-boot-autoconfigure:test \
  -x checkstyleMain -x checkstyleTest
```

### 2.4 不要做的事

| 做法 | 问题 |
|------|------|
| 只改不编译 | 编译错误遗留到他人环境 |
| 只 `build-thin` 不 `make test` | 核心行为回归测不到 |
| 用 `make test-feedback` 当日常门槛 | 耗时长，且含已知环境性失败 |
| 为本地通过而改 `src/main` 迁就环境 | 应排除测试或修测试，不改业务语义 |

---

## 3. 本地环境要求

| 项 | 要求 |
|----|------|
| **JDK** | **Java 11 推荐**（`sdk use java 11.x`）；Java 8 可编译主工程，但 fork 已升级 Jackson 2.21 / Log4j 2.21，部分模块在 Java 8 + `-Werror` 下需额外编译参数 |
| **Gradle** | 7.6.3；wrapper 使用本地分发包（见 `gradle/wrapper/gradle-wrapper.properties`） |
| **Gradle 分发包** | `file:///…/gradle-7.6.3-bin.zip`（路径见 `doc/gradle-bin 配置.md`） |
| **Docker** | `make test` / `make build-thin` **不需要** |
| **Kafka / Redis 等** | `make test` 使用 NES EmbeddedKafka，不需要外部 Kafka；Redis 等外部服务不需要 |
| **TestKit 多版本 zip** | 仅 `gradle-plugin:test` 需要；见 [§9](#9-gradle-testkit-与离线分发包) |

**Gradle 卡住时**：

```bash
make stop
```

---

## 4. Makefile 命令

| 命令 | 作用 | 外部服务 |
|------|------|----------|
| `make build` / `make clean build` | **稳定绿灯门禁**：全量编译/打包/checkstyle + Tier A 测试（与 `make test` 相同）；插件/Docker/文档/actuator 全量不在此门禁 | ❌ |
| `make build-thin` | 编译打包，跳过 test / 文档 | ❌ |
| `make test` | **Tier A**：核心两模块 + Kafka smoke，承诺全绿 | 内嵌 Kafka |
| `make test-feedback` | **Tier C**：三子树扩大反馈，`--continue` | 部分 smoke 需 H2/Kafka 等 |
| `make install` / `deploy` | 发布（`-x test`） | ❌ |

**`make test` 等价命令**：

```bash
./gradlew \
  :spring-boot-project:spring-boot:test \
  :spring-boot-project:spring-boot-test:test \
  :spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test \
  -x checkstyleMain -x checkstyleTest
```

---

## 5. 质量 Tier（门槛定义）

```
Tier 0   make build-thin 绿          → 能编译、能发布（裁剪后模块）
Tier A   make test 全绿             → 核心库 + Kafka smoke（当前 merge 门槛）
Tier B   （规划）扩展核心库 + plugin  → 待摸底后纳入 make test
Tier C   make test-feedback         → 2.7 风格扩大范围，--continue，非全绿
```

| Tier | merge 门槛？ | 典型耗时 |
|------|-------------|----------|
| A `make test` | ✅ 当前是 | 首次 ~1h，有缓存后显著加快 |
| B（规划） | ⏳ 目标扩展 | 待摸底 |
| C `make test-feedback` | ❌ 仅反馈 | 十几～数十分钟 |

### Tier B 候选扩展（待摸底后并入 `make test`）

| 模块 | 状态 |
|------|------|
| `spring-boot` | ✅ Tier A |
| `spring-boot-test` | ✅ Tier A |
| `spring-boot-autoconfigure` | ⏳ Thymeleaf 编译/测试残留 |
| `spring-boot-actuator` | ⏳ E 类少量失败 |
| `spring-boot-actuator-autoconfigure` | ⏳ E 类（Jersey 等） |
| `spring-boot-gradle-plugin` | ⏳ TestKit 修复中（Jackson / bin/main / 离线 zip） |
| `spring-boot-maven-plugin` | ⏳ 待摸底 |

---

## 6. Tier A：`make test` 范围

### 6.1 包含模块

| Gradle 任务 | 说明 |
|-------------|------|
| `:spring-boot-project:spring-boot:test` | 主库（~5300 条） |
| `:spring-boot-project:spring-boot-test:test` | 测试基础设施（~970 条） |
| `:spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test` | NES Kafka EmbeddedKafka 基础收发 |

### 6.2 覆盖与不覆盖

**覆盖**：

- 嵌入式容器、配置、Banner、版本号等核心运行时
- `@SpringBootTest`、测试切片、`MockMvc` 等测试 API
- NES `spring-kafka-test` 与 fork Kafka 3.9.2 的 EmbeddedKafka 兼容性

**不覆盖**（由 `make test-feedback` 或单模块补跑）：

- 自动配置矩阵（`autoconfigure`）
- Actuator
- Gradle / Maven 插件
- 除 Kafka 以外的 Smoke / integration / system-tests

### 6.3 JPMS 前置条件

`:spring-boot:test` 依赖 `spring-boot/build.gradle` 中的 `--add-opens=java.base/java.net=ALL-UNNAMED`（变更 `add-jpms-open-for-tests`）。若 Tomcat/Jetty/Undertow 工厂测试批量失败，先确认该 JVM 参数已生效。

---

## 7. Tier C：`make test-feedback` 范围

### 7.1 调度方式

```bash
./gradlew test --continue \
  -x <显式排除清单…>
```

覆盖 `settings.gradle` 启用的三子树：

- `spring-boot-project`（除显式 `-x`）
- `spring-boot-tests/spring-boot-integration-tests`
- `spring-boot-tests/spring-boot-smoke-tests`（`ignoredSmokeTests` 已在源头排除 18 个）

**不调度** `spring-boot-system-tests`（Docker 强依赖）。

### 7.2 显式 `-x` 排除清单

| 任务 | 原因 |
|------|------|
| `:spring-boot-project:spring-boot-autoconfigure:test` | Thymeleaf 升级残留 |
| `:spring-boot-project:spring-boot-autoconfigure:compileTestJava` | 双保险 |
| `:spring-boot-project:spring-boot-tools:spring-boot-buildpack-platform:test` | Docker |
| `:spring-boot-tests:…:spring-boot-launch-script-tests:test` | Testcontainers / Docker |
| `:spring-boot-tests:…:spring-boot-loader-tests:test` | Testcontainers / Docker |
| `:spring-boot-system-tests:spring-boot-deployment-tests:test` | Docker |
| `:spring-boot-system-tests:spring-boot-image-tests:test` | Docker |

### 7.3 语义

- **`--continue`**：单模块失败不阻断其它模块
- **非全绿承诺**：用于发布前摸底、BOM 大改后回归，不作为日常 merge 硬门槛
- 失败分类见 [§8](#8-已知失败分类)

---

## 8. 已知失败分类

| 代号 | 类型 | 示例 | `make test` 会遇到？ | `make test-feedback` |
|------|------|------|---------------------|----------------------|
| **G** | Gradle TestKit / 文档测试 | `*DocumentationTests`、`BuildInfoDslIntegrationTests` | ❌ | 修复中（见 §9） |
| **E** | 未定位 / 少量断言 | Liquibase、Quartz、Jersey*、WebTestClient | 少量可能在 `spring-boot` | ✅ |
| **S** | Smoke 外部依赖 | data-jpa、flyway、hibernate52 | Kafka 已纳入，其它 ❌ | ✅ |
| **D** | JPMS | `*ServletWebServerFactoryTests` | 已修（`--add-opens`） | 已修 |

**维护原则**：环境性失败 → `-x` 或 Tier C；可修测试 → 改 `src/test` + `// FORK:` 注释；禁止为通过测试改 `src/main` 业务语义。

---

## 9. Gradle TestKit 与离线分发包

`gradle-plugin:test` 会通过 TestKit 拉取 **Gradle 6.8.3、7.0.2、8.0.2** 等多版本分发包。fork 已在 `GradleBuild` / `GradleDistributionLocator` 中按序解析：

1. `~/dev/gradle-{version}/`（已解压）
2. `~/dev/gradle-{version}-bin.zip`
3. 腾讯云镜像（默认）
4. `services.gradle.org`

配置项与建议 zip 清单见 **`doc/gradle-bin 配置.md`**。

---

## 10. 与 3.5 fork 的差异

| 维度 | 2.7 | 3.5 |
|------|-----|-----|
| `make test` 宽度 | Tier A：2 核心模块 + Kafka smoke（NES Kafka 门禁） | Phase 1：2 模块 |
| 扩大反馈 | **`make test-feedback`**（保留历史 `./gradlew test --continue`） | 规划 `make test-feedback`（Tier C） |
| JDK | 8/11（推荐 11） | 17+ |
| Gradle | 7.6.3 | 8.14.5 |
| 成熟度 | 已跑过全量摸底，有 G/E/S 分类 | Bootstrap 阶段，Tier B 待扩展 |

3.5 文档明确「最终 Tier B 对齐 2.7 发布面」；2.7 则通过 **Tier A + Tier C 拆分**，避免日常开发被 `gradle-plugin` / smoke 拖慢。

---

## 11. 维护规则

1. **扩大 Tier A** 前必须在本地实测全绿，并更新 §5 / §6 用例数与耗时。
2. **新增永久 `-x`** 须在 `Makefile` 与本文 §7.2 同步，并注明单行原因。
3. **修绿 G/E/S 类** 后，从 §8 删除或降级对应条目，并考虑是否升入 Tier A/B。
4. OpenSpec `make-test-target` spec 若与本文冲突，以**本文 + Makefile 实装**为准，并开 change 更新 spec。

---

## 决策记录

| 日期 | 决策 |
|------|------|
| 2026-05-20 | 引入 `make test` = `./gradlew test --continue` + 7 条 `-x`（OpenSpec `add-makefile-test-target`） |
| 2026-05-20 | JPMS `--add-opens` 修复 D 类（`add-jpms-open-for-tests`） |
| 2026-06-30 | 拆分为 **`make test`（Tier A）** + **`make test-feedback`（Tier C）**；借鉴 3.5 分层策略 |
| 2026-06-30 | `gradle-plugin` TestKit：Jackson 2.13.5、`bin/main` 优先级、离线 Gradle 分发包 |
| 2026-07-08 | NES `spring-kafka-test` 已兼容 fork Kafka 3.9.2 EmbeddedKafka，`spring-boot-smoke-test-kafka` 纳入 `make test` |
