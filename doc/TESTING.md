# Spring Boot 2.7 测试策略与开发验证指南

> **分支**：`2.7.x-bjca-patch`  
> **基线**：2.7.18（NES fork `2.7.18-nes.patch.1-SNAPSHOT`）  
> **对齐参考**：3.5 fork 的 Tier 分层（`doc/TESTING.md`）  
> **最后更新**：2026-07-23

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
