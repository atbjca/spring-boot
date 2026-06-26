# Spring Boot 3.5 测试策略与开发验证指南

> **分支**：`3.5.x-bjca-patch`  
> **基线**：3.5.15（commit `5bafd0a6bf1` 时代）  
> **对齐参考**：Spring Boot 2.7 NES fork（`2.7.x-bjca-patch`）  
> **最后更新**：2026-06-26

本文档是 3.5 fork **测试准备**的定稿说明：测什么、不测什么、日常怎么验、要不要外部服务。

---

## 目录

1. [核心结论](#1-核心结论)
2. [日常开发：改代码后怎么验](#2-日常开发改代码后怎么验)
3. [本地环境要求](#3-本地环境要求)
4. [Makefile 命令](#4-makefile-命令)
5. [质量 Tier（门槛定义）](#5-质量-tier门槛定义)
6. [Phase 1：当前已验证范围](#6-phase-1当前已验证范围)
7. [为何不跑全量 `./gradlew test`](#7-为何不跑全量-gradlew-test)
8. [发布与测试范围定稿](#8-发布与测试范围定稿)
9. [外部服务 FAQ（Kafka / Redis 等）](#9-外部服务-faqkafka--redis-等)
10. [失败分类](#10-失败分类)
11. [实施路线](#11-实施路线)
12. [维护规则](#12-维护规则)
13. [决策记录](#13-决策记录)

---

## 1. 核心结论

| 问题 | 答案 |
|------|------|
| 本地能跑测试吗？ | **能**（Gradle 8.14.5 本地 zip + Java 17 已验证） |
| 全量 `./gradlew test` 能全绿吗？ | **不能**，也不作为目标 |
| 日常 `make test` 要 Kafka/Redis/Docker 吗？ | **不要** |
| 当前 merge 门槛？ | **Phase 1**：`make build-thin` + `make test`（6308 条全绿） |
| 最终 merge 门槛？ | **Tier B**（`make test-gate`，待实施，见 §5） |
| 仅 2 模块全绿够吗？ | **不够**作长期标准；fork 前作过渡，Tier B 对齐 2.7 发布面 |

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
② make test           核心 6308 条单元/集成测试
  │
  ▼
③ （可选）单模块 test   只改了某一库时更快
  │
  ▼
④ （以后）make test-gate   Tier B 全绿
```

**日常最低安全线**：**① + ② 均 BUILD SUCCESSFUL**，再提交。

### 2.2 提交前检查清单

```
□ git diff 范围符合预期
□ make build-thin  → BUILD SUCCESSFUL
□ make test        → BUILD SUCCESSFUL
□ （若改了 autoconfigure / actuator / plugin）补跑对应单模块 test
□ 未误改 settings.gradle / BOM（除非本次任务就是要改）
```

### 2.3 按改动位置选择命令

| 改动位置 | 建议命令 |
|----------|----------|
| `spring-boot` 主库 | `make build-thin` + `make test` |
| `spring-boot-autoconfigure` | `build-thin` + `:spring-boot-project:spring-boot-autoconfigure:test` |
| 某个 `starter` | `make build-thin`（会编译保留的 starter） |
| `spring-boot-maven-plugin` | `build-thin` + `:spring-boot-tools:spring-boot-maven-plugin:test` |
| 仅 `doc/` / `Makefile` | 可不跑 test |
| `settings.gradle` 裁剪 | **必须** `make build-thin` 全绿 |

**单模块示例**：

```bash
./gradlew :spring-boot-project:spring-boot-autoconfigure:test \
  -x checkstyleMain -x checkstyleTest
```

### 2.4 不要做的事

| 做法 | 问题 |
|------|------|
| 只改不编译 | 编译错误遗留到他人环境 |
| 只 `build-thin` 不 `make test` | 行为回归测不到 |
| 用 `./gradlew test` 全量当标准 | 大量环境性失败，无法判断是不是你的改动导致 |
| 为本地通过而改 `src/main` 迁就环境 | 应排除测试或修测试，不改业务语义 |

---

## 3. 本地环境要求

| 项 | 要求 |
|----|------|
| **JDK** | 17+（实测 Amazon Corretto 17.0.17） |
| **Gradle** | 8.14.5；wrapper 使用本地分发包，**勿改回远程 URL** |
| **Gradle 分发包路径** | `file:///Users/anan/dev/gradle-8.14.5-bin.zip` |
| **Docker** | `make test` / `make build-thin` **不需要** |
| **Kafka / Redis / 等中间件** | `make test` **不需要**（见 §9） |
| **磁盘** | 首次构建依赖缓存可达数 GB（`~/.gradle` + 各模块 `build/`） |
| **网络** | 首次需从 Maven Central / Spring 仓库拉依赖 |

**Gradle 卡住时**：

```bash
make stop    # 或 ./gradlew --stop
rm -f .gradle/noVersion/buildLogic.lock   # 若有 lock 冲突
```

---

## 4. Makefile 命令

| 目标 | 说明 | 外部服务 |
|------|------|----------|
| `make help` | 显示帮助 | — |
| `make build-thin` | 编译打包，跳过 test / 文档 / 部分 checkstyle | ❌ |
| `make test` | Phase 1：两核心模块测试（6308 条，承诺全绿） | ❌ |
| `make test-gate` | Tier B 门槛（**待实施**） | ❌ |
| `make test-feedback` | Tier C 扩大反馈（**待实施**，非全绿） | 可能需 Docker |
| `make clean` | 清理构建产物 | — |
| `make stop` | 停止 Gradle Daemon | — |
| `make projects` | 列出子项目 | — |

**`make test` 等价命令**：

```bash
./gradlew \
  :spring-boot-project:spring-boot:test \
  :spring-boot-project:spring-boot-test:test \
  -x checkstyleMain -x checkstyleTest
```

---

## 5. 质量 Tier（门槛定义）

```
Tier 0   make build-thin 绿        → 能编译、能发布（裁剪后模块）
Tier B   make test-gate 全绿       → 核心库 + maven-plugin（目标 merge 门槛）
Tier C   make test-feedback        → 2.7 风格扩大范围，--continue，非全绿
         ./gradlew test 全量       → 不作门槛（官方 CI 级环境才现实）
```

| Tier | merge 门槛？ | 外部服务 |
|------|---------------|----------|
| 0 | ✅ 是 | ❌ |
| Phase 1 `make test` | ✅ 当前是 | ❌ |
| B `make test-gate` | ✅ 目标 | ❌ |
| C `make test-feedback` | ❌ 仅反馈 | 部分需 Docker |

### Tier B 目标模块（待摸底）

| 模块 | 状态 |
|------|------|
| `spring-boot` | ✅ 已验证 |
| `spring-boot-test` | ✅ 已验证 |
| `spring-boot-autoconfigure` | ⏳ |
| `spring-boot-actuator` | ⏳ |
| `spring-boot-actuator-autoconfigure` | ⏳ |
| `spring-boot-test-autoconfigure` | ⏳ |
| `spring-boot-maven-plugin`（`:test`，不含 `dockerTest`） | ⏳ |
| `spring-boot-configuration-processor` | ⏳ |
| `spring-boot-autoconfigure-processor` | ⏳ |

---

## 6. Phase 1：当前已验证范围

### 6.1 实测结果（2026-06-26，Java 17，3.5.15-SNAPSHOT）

| Gradle 任务 | 用例数 | 失败 | 首次耗时（含编译） |
|-------------|--------|------|-------------------|
| `:spring-boot-project:spring-boot:test` | 5332 | 0 | ~34 min |
| `:spring-boot-project:spring-boot-test:test` | 976 | 0 | ~27 min |
| **合计** | **6308** | **0** | ~1 h（分开跑；有缓存后显著加快） |

### 6.2 覆盖与不覆盖

**覆盖**：

- 核心运行时（嵌入式容器、配置、Banner 等）
- `@SpringBootTest`、测试切片等测试基础设施

**尚未覆盖**（Tier B 待扩展）：

- 自动配置矩阵（`autoconfigure`）
- Actuator 自动配置
- Maven 插件 repackage
- 各 Starter 行为

---

## 7. 为何不跑全量 `./gradlew test`

### 7.1 规模

当前 `settings.gradle` **尚未裁剪**，全量 include：

- 150+ Gradle 子项目
- 100 个 smoke-tests
- 5 个 integration-tests、2 个 system-tests

全量 `test` 通常需**数小时**，且大量失败。

### 7.2 环境依赖（非代码 bug）

```
Docker / Testcontainers
├── system-tests（deployment / image）
├── buildpack-platform:test
├── integration-tests（launch-script、loader、loader-classic、sni）
└── maven-plugin / docker-compose 的 dockerTest

外部中间件（smoke-tests）
├── Redis、MongoDB、Kafka、Cassandra、Elasticsearch…
└── 无 Docker / 无 broker → 失败
```

### 7.3 与官方 CI 的差异

官方在 **Linux + Java 21/25 + Docker + 大内存 CI** 上跑 `./gradlew build`，预期全绿。  
本地 macOS + Java 17 + 常无 Docker → **同一任务大量环境性失败**，不代表上游损坏。

### 7.4 2.7 fork 参考

2.7 使用 **`make test` = 受控范围 + 已知失败可接受**，从未追求本地全量全绿。

---

## 8. 发布与测试范围定稿

> 对齐 2.7 fork；**Kafka starter 保留**；**Redis starter 保留**；Pulsar 排除。

### 8.1 Starter：不发布（19 个）

| Starter | 原因 |
|---------|------|
| `spring-boot-starter-activemq` | 消息精简 |
| `spring-boot-starter-amqp` | 消息精简 |
| `spring-boot-starter-artemis` | 消息精简 |
| `spring-boot-starter-pulsar` | 消息精简（3.5 新增） |
| `spring-boot-starter-pulsar-reactive` | 同上 |
| `spring-boot-starter-data-cassandra` / `*-reactive` | 私服/精简 |
| `spring-boot-starter-data-couchbase` / `*-reactive` | 私服/精简 |
| `spring-boot-starter-data-neo4j` | 私服/精简 |
| `spring-boot-starter-data-r2dbc` | 精简 |
| `spring-boot-starter-data-rest` | 精简 |
| `spring-boot-starter-data-ldap` | 精简 |
| `spring-boot-starter-graphql` | 精简 |
| `spring-boot-starter-hateoas` | 精简 |
| `spring-boot-starter-integration` | 依赖链冲突 |
| `spring-boot-starter-jersey` | 精简 |
| `spring-boot-starter-jooq` | 精简 |
| `spring-boot-starter-rsocket` | 精简 |

### 8.2 Starter：保留发布（约 37 个，含 Kafka / Redis）

- **核心**：`starter` / `web` / `webflux` / `security` / `oauth2-*` / `actuator` / `test`
- **数据**：`data-jpa` / `data-jdbc` / **`data-redis*`** / `data-mongodb*` / `data-elasticsearch`
- **消息**：**`kafka`（保留）**
- **3.5 新增**：`oauth2-authorization-server`
- **其它**：`batch` / `quartz` / **`cache`** / `tomcat|jetty|undertow` / `validation` / 模板引擎等

### 8.3 Gradle 模块

**不发布**（`settings.gradle` exclude，待实施）：

`spring-boot-cli`、`spring-boot-docs`、`spring-boot-antlib`、`configuration-metadata-changelog-generator`、`spring-boot-properties-migrator`

**发布 + build-thin 即可**：`dependencies`、`starter-parent`、保留的 starter、loader*、`docker-compose`、`testcontainers`、`devtools`

**Tier C 反馈（不要求全绿）**：`gradle-plugin`、`buildpack-platform`、`configuration-processor-tests`、`server-tests`

**不跑 test**：`system-tests/*`、`launch-script-tests`、`loader-tests`、`loader-classic-tests`、`sni-tests`

### 8.4 Smoke-tests ignore（待写入 settings.gradle）

**继承 2.7（18 个）**：

`activemq, amqp, artemis, ant, cache, data-ldap, data-r2dbc*, graphql, hateoas, integration, jersey, parent-context, rsocket, secure-jersey, data-rest`

**3.5 追加**：

`pulsar, data-cassandra, data-couchbase, data-mongo, data-redis, data-elasticsearch, session-redis, session-mongo, session-webflux-redis, session-webflux-mongo`

**Kafka smoke**：

| 项 | 决策 |
|----|------|
| `spring-boot-starter-kafka` | **发布** ✅ |
| `spring-boot-smoke-test-kafka` | 可 include 编译；**test 归 Tier C**（要 Docker），不作 merge 门槛 |

---

## 9. 外部服务 FAQ（Kafka / Redis 等）

**原则：发布 starter ≠ 构建/测试时要起对应服务。**

| 场景 | 要 Kafka？ | 要 Redis？ | 要 Docker？ |
|------|-----------|-----------|------------|
| `make build-thin` | ❌ | ❌ | ❌ |
| **`make test`（当前）** | **❌** | **❌** | **❌** |
| Tier B `make test-gate`（规划） | ❌ | ❌ | ❌ |
| Tier C smoke（kafka / redis / cache） | ✅ | ✅ | ✅ |
| **下游业务应用运行时** | 用就要 | 用就要 | — |

- **Starter 发布**：只编译 jar、进 BOM，不需要 broker。
- **BOM 管客户端版本**（如 `spring-kafka`、`kafka-clients`、Lettuce），不管 Broker 装在哪。
- **Smoke 测 Broker 连通性**才要 Docker/Testcontainers，且已列入 ignore 或 Tier C。

---

## 10. 失败分类

| 代号 | 类型 | 示例 | `make test` 会遇到？ |
|------|------|------|---------------------|
| **C** | 核心单元测试 | spring-boot / spring-boot-test | ✅ 当前门槛 |
| **D** | Docker / Testcontainers | system-tests、buildpack | ❌ 未纳入 |
| **G** | Gradle DocTests | gradle-plugin ~900+ 条 | ❌ 未纳入 |
| **S** | Smoke 外部中间件 | Redis/Kafka smoke | ❌ 未纳入 |
| **E** | 其它环境/偶发 | Liquibase、Jersey SSL 等 | ❌ 未纳入 |

---

## 11. 实施路线

| 阶段 | 内容 | 状态 |
|------|------|------|
| **0** | 本地 Gradle + `doc/TESTING.md` + `Makefile` | ✅ |
| **1** | Phase 1：`make test` 两模块全绿 | ✅ 已验证 |
| **2** | `settings.gradle` 裁剪（§8） | ⏳ 待实施 |
| **3** | Tier B 摸底 + `make test-gate` | ⏳ 待实施 |
| **4** | `make test-feedback`（Tier C） | ⏳ 待实施 |
| **5** | fork GAV（`bootstrap-boot-3515-nes-fork`） | ⏸️ 晚于测试基线 |

---

## 12. 维护规则

1. **不**将 `./gradlew test` 全量全绿作为本地/merge 门槛。
2. **要**保证当前 merge 门槛（Phase 1：`make build-thin` + `make test`）在每次变更后全绿。
3. 扩大测试范围前，**先更新本文档**，再改 `Makefile`。
4. 环境性失败优先 **exclude / ignore / Tier C**，不改 `src/main` 迁就本地。
5. fork 引入的测试适配（Banner、GAV、版本号等）在 fork change 中单独记录。
6. 扩大 Tier B 模块后，在 §5 / §6 更新实测用例数与耗时。

---

## 13. 决策记录

| 日期 | 决策 |
|------|------|
| 2026-06-26 | 测试优先于 fork GAV；`bootstrap-boot-3515-nes-fork` 搁置至测试基线就绪 |
| 2026-06-26 | **Kafka starter 保留发布**；kafka smoke 归 Tier C |
| 2026-06-26 | **Redis / cache starter 保留发布**；redis 类 smoke 在 ignore 清单 |
| 2026-06-26 | Pulsar starter 排除；oauth2-authorization-server 保留 |
| 2026-06-26 | 其余 starter/模块/smoke 对齐 2.7 + 3.5 增量 |
| 2026-06-26 | 最终 merge 门槛目标 **Tier B**；当前 **Phase 1** 过渡 |
| 2026-06-26 | `make test` 不需要任何外部服务 |
| 2026-06-26 | 不采用 DELETE/tmp 缓存外置；Gradle 仅用 `~/dev` 本地 zip |
| 2026-06-26 | Phase 1 实测：6308 条，0 失败（Java 17，3.5.15-SNAPSHOT） |

---

## 相关文档

- Fork 变更（晚于测试）：`openspec/changes/bootstrap-boot-3515-nes-fork/`
- 2.7 参考：`spring-boot-2.7` 分支 `Makefile`、`doc/NES_GAV_MAPPING.md` §8
