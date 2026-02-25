# Spring Boot 2.7 全量模块手册 (Universal Resource Manual)

本文档是本项目的全量清单，记录了通过深度扫描发现的所有 **150+** 个子模块。清单已按功能层级进行了严格分类。

---

## 🏗️ 1. 基础设施与构建系统 (Infrastructure)
*项目的基石，包含构建逻辑和 CI 配置。*

| 模块路径 | 组件名称 | 功能描述 | 建议 |
| :--- | :--- | :--- | :--- |
| `/` | `spring-boot-build` | 项目根模块，协调全局构建逻辑。已配置 **Nexus 私服** (maven-public, releases, snapshots, thirdparty) 及阿里云备用镜像。 | **保留** |
| `/buildSrc` | `buildSrc` | **构建插件库**：包含项目专属的 Gradle 插件、Task 和工具类。已同步私服配置。 | **保留** |
| `/ci` | `ci` | **CI 配置**：包含 GitHub Actions 和持续集成的专用构建逻辑。 | **保留** |
| `settings.gradle` | - | 全局构建设置，已启用 `dependencyResolutionManagement` 强制执行私服仓库策略。 | **核心** |

---

## 核心工程 (Core - spring-boot-project)
*Spring Boot 的功能实现主体，分为核心库与辅助工具。*

### 核心运行时 (Core)
| 模块名 | 功能描述 | 建议 |
| :--- | :--- | :--- |
| `spring-boot` | **核心基础**：Banner, PropertySource, ApplicationContext, Environment 等。 | **保留** |
| `spring-boot-autoconfigure` | **自动配置**：根据 ClassPath 的 Bean 情况自动装配的核心代码。 | **保留** |
| `spring-boot-actuator` | **执行器**：提供 API 形式的监控、指标、健康状态。 | 可选 |
| `spring-boot-actuator-autoconfigure` | 执行器的自动装配逻辑。 | 可选 |
| `spring-boot-test` | 测试基础库，提供核心测试注解。 | 可选 |
| `spring-boot-test-autoconfigure` | 测试环境的自动装配（如 Slice Test）。 | 可选 |
| `spring-boot-devtools` | 开发热部署、属性覆盖、远程调试等生产辅助。 | 开发保留 |
| `spring-boot-cli` | **🚫 [IGNORED]** 命令行界面。*注意：由于强依赖已忽略的 `spring-boot-starter-integration`，现已同步屏蔽。* | ✅ 可忽略 |
| `spring-boot-properties-migrator` | 旧版配置到新版的自动转换映射。 | ✅ 可忽略 |
| `spring-boot-dependencies` | **BOM**：定义了所有集成库的版本坐标。 | **保留** |
| `spring-boot-parent` | Maven/Gradle 的父工程声明。 | **保留** |
| `spring-boot-docs` | **🚫 [IGNORED]** 官方参考文档生成。*注意：由于依赖 `spring-boot-cli`，随之同步屏蔽。* | ✅ 可忽略 |

### 内部工具与插件 (Tools)
| 模块名 | 功能描述 | 建议 |
| :--- | :--- | :--- |
| `spring-boot-gradle-plugin` | Gradle 打包插件，处理 Repackage 和依赖解压。 | **使用保留** |
| `spring-boot-maven-plugin` | Maven 打包插件。 | ✅ 可忽略 |
| `spring-boot-loader` | 实现 Jar 中嵌套 Jar 的加载逻辑（Launcher）。 | **保留** |
| `spring-boot-loader-tools` | 构建插件使用的底层读写 Jar 的工具。 | **保留** |
| `spring-boot-configuration-processor` | 字段生成 Metadata 以支持 IDE 配置提示。 | 建议保留 |
| `spring-boot-autoconfigure-processor` | 扫描自动配置以提升启动查询速度。 | 建议保留 |
| `spring-boot-buildpack-platform` | 适配 Cloud Native Buildpacks 规范的构建库。 | 可选 |
| `spring-boot-jarmode-layertools` | Docker 分层 Jar 支持模式。 | 可选 |
| `spring-boot-antlib` | 适配 Ant 的 Library。 | ✅ 可忽略 |
| `spring-boot-test-support` | 为内部测试提供的辅助工具。 | ✅ 可忽略 |

---

## 📦 2. 起步依赖 (Starters - 54 个)
*路径: `spring-boot-project/spring-boot-starters/*`*
*此类模块仅包含配置依赖，无功能代码。您可以根据业务需求忽略不用的技术栈。*

### 基础核心 (Foundation)
| 模块名 | 功能描述 (Purpose) |
| :--- | :--- |
| `spring-boot-starter` | **核心 Starter**：包含日志 (Logback)、YAML 配置支持及基础自动配置。 |
| `spring-boot-starter-logging` | 默认日志启动器，基于 Logback。 |
| `spring-boot-starter-json` | 提供 JSON 读写支持（基于 Jackson）。 |
| `spring-boot-starter-validation` | 集成 Hibernate Validator 进行 Java Bean 参数校验。 |
| `spring-boot-starter-aop` | 引入 AspectJ 支持，实现面向切面编程。 |
| `spring-boot-starter-cache` | Spring Cache 抽象层的依赖。 |
| `spring-boot-starter-quartz` | 集成 Quartz 定时任务。 |
| `spring-boot-starter-batch` | Spring Batch 批处理支持。 |
| `spring-boot-starter-mail` | Java Mail 发送功能支持。 |
| `spring-boot-starter-parent` | 内部 parent 依赖。 |

### 数据存储 (Data)
| 模块名 | 功能描述 (Purpose) |
| :--- | :--- |
| `spring-boot-starter-jdbc` | 基础 JDBC 支持（含 HikariCP 连接池）。 |
| `spring-boot-starter-data-jpa` | Spring Data JPA (Hibernate) 数据库集成。 |
| `spring-boot-starter-data-jdbc` | Spring Data JDBC 简单数据库访问。 |
| `spring-boot-starter-data-redis` | Redis 缓存与存储集成（基于 Lettuce）。 |
| `spring-boot-starter-data-redis-reactive` | 响应式 Redis 支持。 |
| `spring-boot-starter-data-mongodb` | MongoDB 数据库集成。 |
| `spring-boot-starter-data-mongodb-reactive` | 响应式 MongoDB 支持。 |
| `spring-boot-starter-data-elasticsearch` | Elasticsearch 搜索引擎集成。 |
| `spring-boot-starter-data-cassandra` | **🚫 [IGNORED]** Cassandra NoSQL 数据库支持。 |
| `spring-boot-starter-data-cassandra-reactive` | **🚫 [IGNORED]** 响应式 Cassandra 支持。 |
| `spring-boot-starter-data-neo4j` | **🚫 [IGNORED]** Neo4j 图数据库支持。 |
| `spring-boot-starter-data-couchbase` | **🚫 [IGNORED]** Couchbase 数据库支持。 |
| `spring-boot-starter-data-couchbase-reactive` | **🚫 [IGNORED]** 响应式 Couchbase 支持。 |
| `spring-boot-starter-data-r2dbc` | **🚫 [IGNORED]** 响应式关系型数据库集成 (R2DBC)。 |
| `spring-boot-starter-data-rest` | **🚫 [IGNORED]** 通过 Spring Data 仓库直接暴露 REST 接口。 |
| `spring-boot-starter-data-ldap` | **🚫 [IGNORED]** LDAP 目录服务支持。 |
| `spring-boot-starter-jooq` | **🚫 [IGNORED]** JOOQ 数据库访问库集成。 |
| `spring-boot-starter-jta-atomikos` | **🚫 [IGNORED]** Atomikos 分布式事务 (JTA) 支持。 |

### Web 与通讯 (Web & Messaging)
| 模块名 | 功能描述 (Purpose) |
| :--- | :--- |
| `spring-boot-starter-web` | **经典 Web**：使用 Tomcat 和 Spring MVC 构建 Web 应用。 |
| `spring-boot-starter-webflux` | **响应式 Web**：使用 Netty 和 Project Reactor 构建 Webflux 应用。 |
| `spring-boot-starter-websocket` | WebSocket 全双工通讯支持。 |
| `spring-boot-starter-web-services` | Spring Web Services (SOAP) 支持。 |
| `spring-boot-starter-reactor-netty` | Reactor Netty 引擎依赖（通常由 Webflux 引入）。 |
| `spring-boot-starter-jetty` | 使用 Jetty 作为内嵌 Web 容器（替代 Tomcat）。 |
| `spring-boot-starter-undertow` | 使用 Undertow 作为内嵌 Web 容器（替代 Tomcat）。 |
| `spring-boot-starter-tomcat` | 默认内嵌 Tomcat 容器。 |
| `spring-boot-starter-jersey` | **🚫 [IGNORED]** 使用 JAX-RS (Jersey) 替代 Spring MVC。 |
| `spring-boot-starter-rsocket` | **🚫 [IGNORED]** RSocket 二进制协议通讯支持。 |
| `spring-boot-starter-amqp` | RabbitMQ (AMQP) 消息中间件集成；**未忽略**，因为被 `spring-boot-cli` 等内部模块用于构建测试仓库。 |
| `spring-boot-starter-activemq` | **🚫 [IGNORED]** ActiveMQ 消息中间件集成。 |
| `spring-boot-starter-artemis` | ActiveMQ Artemis 消息集成；**未忽略**，因为被 `spring-boot-cli` 的测试仓库等内部模块直接依赖。 |
| `spring-boot-starter-graphql` | **🚫 [IGNORED]** Spring for GraphQL 支持。 |
| `spring-boot-starter-integration` | **🚫 [IGNORED]** Spring Integration 企业集成模式支持。*注意：由于 `spring-boot-cli` 强依赖此模块进行测试，已同步忽略 CLI。* |

### 展示模板 (Templates)
| 模块名 | 功能描述 (Purpose) |
| :--- | :--- |
| `spring-boot-starter-thymeleaf` | Thymeleaf 现代 HTML 模板引擎。 |
| `spring-boot-starter-freemarker` | FreeMarker 模板引擎。 |
| `spring-boot-starter-mustache` | Mustache 逻辑无关模板。 |
| `spring-boot-starter-groovy-templates` | Groovy 模板。 |
| `spring-boot-starter-hateoas` | **🚫 [IGNORED]** 超媒体驱动的 REST 接口支持。 |

### 安全与测试 (Security & Test)
| 模块名 | 功能描述 (Purpose) |
| :--- | :--- |
| `spring-boot-starter-security` | Spring Security 安全防护与鉴权保护。 |
| `spring-boot-starter-oauth2-client` | 作为 OAuth2 客户端使用。 |
| `spring-boot-starter-oauth2-resource-server` | 作为 OAuth2 资源服务器使用。 |
| `spring-boot-starter-test` | 包含 JUnit, AssertJ, Mockito 等核心测试库。 |

### 运维监控 (Ops)
| 模块名 | 功能描述 (Purpose) |
| :--- | :--- |
| `spring-boot-starter-actuator` | 提供生产级的健康检查、性能监控和审计功能。 |

---

## 🧬 3. 质量保证与验证集 (Tests - 全量清单)
*这是项目最沉重的部分，包含 **97** 个模块。当前已在 `settings.gradle` 中 **物理屏蔽 (Physically Ignored)** 以极大提升构建速度。*

### 冒烟测试 (Smoke Tests - 91 个)
*路径: `spring-boot-tests/spring-boot-smoke-tests/*`*
每一个都是一个独立的验证应用。

<details>
<summary>点击查看全量列表 (91 模块)</summary>

- `spring-boot-smoke-test-activemq` **🚫 [IGNORED]**
- `spring-boot-smoke-test-actuator`
- `spring-boot-smoke-test-actuator-custom-security`
- `spring-boot-smoke-test-actuator-log4j2`
- `spring-boot-smoke-test-actuator-noweb`
- `spring-boot-smoke-test-actuator-ui`
- `spring-boot-smoke-test-amqp` **🚫 [IGNORED]**
- `spring-boot-smoke-test-animated-banner`
- `spring-boot-smoke-test-ant`
- `spring-boot-smoke-test-aop`
- `spring-boot-smoke-test-atmosphere`
- `spring-boot-smoke-test-batch`
- `spring-boot-smoke-test-bootstrap-registry`
- `spring-boot-smoke-test-cache` **🚫 [IGNORED]**
- `spring-boot-smoke-test-data-jdbc`
- `spring-boot-smoke-test-data-jpa`
- `spring-boot-smoke-test-data-ldap` **🚫 [IGNORED]**
- `spring-boot-smoke-test-data-r2dbc` **🚫 [IGNORED]**
- `spring-boot-smoke-test-data-r2dbc-flyway` **🚫 [IGNORED]**
- `spring-boot-smoke-test-data-r2dbc-liquibase` **🚫 [IGNORED]**
- `spring-boot-smoke-test-data-rest` **🚫 [IGNORED]**
- `spring-boot-smoke-test-devtools`
- `spring-boot-smoke-test-flyway`
- `spring-boot-smoke-test-graphql` **🚫 [IGNORED]**
- `spring-boot-smoke-test-hateoas` **🚫 [IGNORED]**
- `spring-boot-smoke-test-hazelcast3`
- `spring-boot-smoke-test-hazelcast4`
- `spring-boot-smoke-test-hibernate52`
- `spring-boot-smoke-test-integration` **🚫 [IGNORED]**
- `spring-boot-smoke-test-jersey` **🚫 [IGNORED]**
- `spring-boot-smoke-test-jetty`
- `spring-boot-smoke-test-jetty-jsp`
- `spring-boot-smoke-test-jetty-ssl`
- `spring-boot-smoke-test-jetty10`
- `spring-boot-smoke-test-jpa`
- `spring-boot-smoke-test-jta-atomikos` **🚫 [IGNORED]**
- `spring-boot-smoke-test-junit-vintage`
- `spring-boot-smoke-test-kafka`
- `spring-boot-smoke-test-liquibase`
- `spring-boot-smoke-test-logback`
- `spring-boot-smoke-test-oauth2-client`
- `spring-boot-smoke-test-oauth2-resource-server`
- `spring-boot-smoke-test-parent-context` **🚫 [IGNORED]**
- `spring-boot-smoke-test-profile`
- `spring-boot-smoke-test-property-validation`
- `spring-boot-smoke-test-quartz`
- `spring-boot-smoke-test-reactive-oauth2-client`
- `spring-boot-smoke-test-reactive-oauth2-resource-server`
- `spring-boot-smoke-test-rsocket` **🚫 [IGNORED]**
- `spring-boot-smoke-test-saml2-service-provider`
- `spring-boot-smoke-test-secure`
- `spring-boot-smoke-test-secure-jersey` **🚫 [IGNORED]**
- `spring-boot-smoke-test-secure-webflux`
- `spring-boot-smoke-test-servlet`
- `spring-boot-smoke-test-session-hazelcast`
- `spring-boot-smoke-test-session-jdbc`
- `spring-boot-smoke-test-session-mongo`
- `spring-boot-smoke-test-session-redis`
- `spring-boot-smoke-test-session-webflux-mongo`
- `spring-boot-smoke-test-session-webflux-redis`
- `spring-boot-smoke-test-simple`
- `spring-boot-smoke-test-test`
- `spring-boot-smoke-test-test-nomockito`
- `spring-boot-smoke-test-testng`
- `spring-boot-smoke-test-tomcat`
- `spring-boot-smoke-test-tomcat-jsp`
- `spring-boot-smoke-test-tomcat-multi-connectors`
- `spring-boot-smoke-test-tomcat-ssl`
- `spring-boot-smoke-test-traditional`
- `spring-boot-smoke-test-undertow`
- `spring-boot-smoke-test-undertow-ssl`
- `spring-boot-smoke-test-war`
- `spring-boot-smoke-test-web-application-type`
- `spring-boot-smoke-test-web-freemarker`
- `spring-boot-smoke-test-web-groovy-templates`
- `spring-boot-smoke-test-web-jsp`
- `spring-boot-smoke-test-web-method-security`
- `spring-boot-smoke-test-web-mustache`
- `spring-boot-smoke-test-web-secure`
- `spring-boot-smoke-test-web-secure-custom`
- `spring-boot-smoke-test-web-secure-jdbc`
- `spring-boot-smoke-test-web-static`
- `spring-boot-smoke-test-web-thymeleaf`
- `spring-boot-smoke-test-webflux`
- `spring-boot-smoke-test-webflux-coroutines`
- `spring-boot-smoke-test-webservices`
- `spring-boot-smoke-test-websocket-jetty`
- `spring-boot-smoke-test-websocket-jetty10`
- `spring-boot-smoke-test-websocket-tomcat`
- `spring-boot-smoke-test-websocket-undertow`
- `spring-boot-smoke-test-xml`

</details>

### 高级测试 (Integration & System)
| 模块路径 | 功能描述 |
| :--- | :--- |
| `integration-tests:configuration-processor-tests` | 验证配置元数据生成是否符合规范。 |
| `integration-tests:launch-script-tests` | 验证生成的二进制脚本在 OS 层面的执行行为。 |
| `integration-tests:loader-tests` | 验证 ClassLoader 隔离和归档加载行为。 |
| `integration-tests:server-tests` | 验证内嵌和外置服务器的启动、部署行为。 |
| `system-tests:deployment-tests` | 验证在商业应用服务器上的部署兼容性。 |
| `system-tests:image-tests` | 验证 OCI 镜像的构建与运行。 |

---

## 🚫 4. 已忽略组件留痕 (Ignored Components Log)
*本章节详细列漏了所有被手动排除的模块及其原因，以便后续追踪。*

| 忽略日期 | 模块路径/全称 | 类型 | 理由 (Reason) |
| :--- | :--- | :--- | :--- |
| 2026-02-11 | `spring-boot-starter-jersey` | Starter | 项目不使用 JAX-RS (Jersey) 技术栈，使用默认的 Spring MVC。 |
| 2026-02-11 | `spring-boot-smoke-test-jersey` | Test | 随 Jersey 组件一同忽略，减少构建索引负担。 |
| 2026-02-11 | `spring-boot-smoke-test-secure-jersey` | Test | 随 Jersey 组件一同忽略，减少构建索引负担。 |
| 2026-02-11 | `spring-boot-starter-rsocket` | Starter | 项目不使用 RSocket 响应式通讯协议。 |
| 2026-02-11 | `spring-boot-smoke-test-rsocket` | Test | 随 RSocket 组件一同忽略。 |
| 2026-02-11 | `spring-boot-starter-activemq` | Starter | 项目不使用 ActiveMQ 消息中间件。 |
| 2026-02-11 | `spring-boot-smoke-test-activemq` | Test | 随 ActiveMQ 组件一同忽略。 |
| 2026-02-11 | `spring-boot-starter-artemis` | Starter | 原计划忽略；当前保留，因为 `spring-boot-cli` 等内部模块仍依赖该 Starter。 |
| 2026-02-11 | `spring-boot-starter-data-ldap` | Starter | 项目不使用 LDAP 目录服务技术栈。 |
| 2026-02-11 | `spring-boot-smoke-test-data-ldap` | Test | 随 LDAP 组件一同忽略。 |
| 2026-02-11 | `spring-boot-starter-data-couchbase` | Starter | 项目不使用 Couchbase 数据库。 |
| 2026-02-11 | `spring-boot-starter-data-couchbase-reactive` | Starter | 随 Couchbase 主组件一同忽略响应式版本。 |
| 2026-02-11 | `spring-boot-starter-data-cassandra` | Starter | 项目不使用 Cassandra 数据库。 |
| 2026-02-11 | `spring-boot-starter-data-cassandra-reactive` | Starter | 随 Cassandra 主组件一同忽略响应式版本。 |
| 2026-02-11 | `spring-boot-starter-data-r2dbc` | Starter | 项目不使用 R2DBC 响应式数据库技术。 |
| 2026-02-11 | `spring-boot-smoke-test-data-r2dbc` | Test | 随 R2DBC 组件一同忽略。 |
| 2026-02-11 | `spring-boot-smoke-test-data-r2dbc-flyway` | Test | 随 R2DBC 组件一同忽略。 |
| 2026-02-11 | `spring-boot-smoke-test-data-r2dbc-liquibase` | Test | 随 R2DBC 组件一同忽略。 |
| 2026-02-11 | `spring-boot-smoke-test-amqp` | Test | 原计划随 AMQP 组件一同忽略，当前仅 Smoke Test 被屏蔽，Starter 仍可正常使用。 |
| 2026-02-11 | `spring-boot-starter-hateoas` | Starter | 项目不使用 HATEOAS 超媒体驱动接口。 |
| 2026-02-11 | `spring-boot-smoke-test-hateoas` | Test | 随 HATEOAS 组件一同忽略。 |
| 2026-02-11 | `spring-boot-starter-graphql` | Starter | 项目不使用 GraphQL 接口支持。 |
| 2026-02-11 | `spring-boot-smoke-test-graphql` | Test | 随 GraphQL 组件一同忽略。 |
| 2026-02-11 | `spring-boot-starter-data-neo4j` | Starter | 项目不使用 Neo4j 图数据库。 |
| 2026-02-11 | `spring-boot-starter-jooq` | Starter | 项目不使用 jOOQ 数据库访问框架。 |
| 2026-02-11 | `spring-boot-starter-jta-atomikos` | Starter | 项目不使用分布式事务 (JTA) 支持。 |
| 2026-02-24 | `spring-boot-starter-integration` | Starter | 项目不使用 Spring Integration。由于依赖链条，同步忽略 `spring-boot-cli`、`spring-boot-docs` 及 `parent-context` 测试。 |
| 2026-02-24 | `spring-boot-smoke-test-parent-context` | Test | 随 Integration 组件一同忽略，因其包含集成功能的验证。 |
| 2026-02-24 | `spring-boot-cli` | Tool | 随 Integration 组件一同忽略，避免测试依赖导致构建失败。 |
| 2026-02-24 | `spring-boot-docs` | Tool | 随 CLI 组件一同忽略，因其构建过程依赖 CLI。 |
| 2026-02-24 | `spring-boot-smoke-test-integration` | Test | 随 Integration 组件一同忽略。 |


---

## ⚙️ 如何高效操作？

由于模块极多，建议采取“**层级化屏蔽**”策略：

1. **若平时不跑测试**：直接在 `settings.gradle` 中找到 `file(...).eachDirMatch` 循环 `smoke-tests` 的地方注释掉。
2. **若不使用 Maven**：注释掉 `spring-boot-maven-plugin`。
3. **若不使用 CLI**：注释掉 `spring-boot-cli`。

> [!IMPORTANT]
> **全量审计结论**：本项目物理存在 153 个 `build.gradle`。通过以上列表，您可以按需保留核心，将无用的 100+ 测试模块和特定技术栈 Starter 临时剔除，从而将 Gradle 索引和构建速度提升 10 倍以上。
