# Spring Boot GAV 映射全选清单 (Comprehensive Artifact Mapping)

本文件记录了本项目所有 fork 组件的原始官方 GAV 坐标与自定义 GAV 坐标之间的完整映射关系，涵盖 Spring Boot、Spring Framework、Spring Security、Spring Kafka 等组件系列。

> **全局属性**
> - **GroupId**: `cn.bjca.footstone.bpring.boot`
> - **Version**: `2.7.18-nes.patch.1-SNAPSHOT`
> - **代码运行时版本 (SpringBootVersion.getVersion())**: `2.7.18`（保持不变）

---

## 1. 核心基础设施 (Core Infrastructure)

所有 Spring Boot 模块的 GroupId 统一从 `org.springframework.boot` 映射为 `cn.bjca.footstone.bpring.boot`。

| 原始 ArtifactId | 新 ArtifactId | 说明 |
| :--- | :--- | :--- |
| `spring-boot-dependencies` | `bjca-footstone-bpring-boot-dependencies` | 自定义 BOM（版本管理中心） |
| `spring-boot-parent` | `bjca-footstone-bpring-boot-parent` | 自定义 Parent POM |
| `spring-boot-starter-parent` | `bjca-footstone-bpring-boot-starter-parent` | Maven 项目的 Parent POM |

---

## 2. 核心框架模块 (Core Framework Modules)

| 原始 ArtifactId | 新 ArtifactId |
| :--- | :--- |
| `spring-boot` | `bjca-footstone-bpring-boot` |
| `spring-boot-autoconfigure` | `bjca-footstone-bpring-boot-autoconfigure` |
| `spring-boot-actuator` | `bjca-footstone-bpring-boot-actuator` |
| `spring-boot-actuator-autoconfigure` | `bjca-footstone-bpring-boot-actuator-autoconfigure` |
| `spring-boot-devtools` | `bjca-footstone-bpring-boot-devtools` |
| `spring-boot-test` | `bjca-footstone-bpring-boot-test` |
| `spring-boot-test-autoconfigure` | `bjca-footstone-bpring-boot-test-autoconfigure` |
| `spring-boot-properties-migrator` | `bjca-footstone-bpring-boot-properties-migrator` |

---

## 3. Starter 模块映射 (Starters)

所有 Starter 遵循统一映射规则：`spring-boot-starter-{name}` → `bjca-footstone-bpring-boot-starter-{name}`。

### 3.1 活跃 Starter（当前构建中包含）

| 原始 ArtifactId | 新 ArtifactId |
| :--- | :--- |
| `spring-boot-starter` | `bjca-footstone-bpring-boot-starter` |
| `spring-boot-starter-actuator` | `bjca-footstone-bpring-boot-starter-actuator` |
| `spring-boot-starter-aop` | `bjca-footstone-bpring-boot-starter-aop` |
| `spring-boot-starter-batch` | `bjca-footstone-bpring-boot-starter-batch` |
| `spring-boot-starter-cache` | `bjca-footstone-bpring-boot-starter-cache` |
| `spring-boot-starter-data-elasticsearch` | `bjca-footstone-bpring-boot-starter-data-elasticsearch` |
| `spring-boot-starter-data-jdbc` | `bjca-footstone-bpring-boot-starter-data-jdbc` |
| `spring-boot-starter-data-jpa` | `bjca-footstone-bpring-boot-starter-data-jpa` |
| `spring-boot-starter-data-mongodb` | `bjca-footstone-bpring-boot-starter-data-mongodb` |
| `spring-boot-starter-data-mongodb-reactive` | `bjca-footstone-bpring-boot-starter-data-mongodb-reactive` |
| `spring-boot-starter-data-redis` | `bjca-footstone-bpring-boot-starter-data-redis` |
| `spring-boot-starter-data-redis-reactive` | `bjca-footstone-bpring-boot-starter-data-redis-reactive` |
| `spring-boot-starter-freemarker` | `bjca-footstone-bpring-boot-starter-freemarker` |
| `spring-boot-starter-groovy-templates` | `bjca-footstone-bpring-boot-starter-groovy-templates` |
| `spring-boot-starter-jdbc` | `bjca-footstone-bpring-boot-starter-jdbc` |
| `spring-boot-starter-jetty` | `bjca-footstone-bpring-boot-starter-jetty` |
| `spring-boot-starter-json` | `bjca-footstone-bpring-boot-starter-json` |
| `spring-boot-starter-log4j2` | `bjca-footstone-bpring-boot-starter-log4j2` |
| `spring-boot-starter-logging` | `bjca-footstone-bpring-boot-starter-logging` |
| `spring-boot-starter-mail` | `bjca-footstone-bpring-boot-starter-mail` |
| `spring-boot-starter-mustache` | `bjca-footstone-bpring-boot-starter-mustache` |
| `spring-boot-starter-oauth2-client` | `bjca-footstone-bpring-boot-starter-oauth2-client` |
| `spring-boot-starter-oauth2-resource-server` | `bjca-footstone-bpring-boot-starter-oauth2-resource-server` |
| `spring-boot-starter-quartz` | `bjca-footstone-bpring-boot-starter-quartz` |
| `spring-boot-starter-reactor-netty` | `bjca-footstone-bpring-boot-starter-reactor-netty` |
| `spring-boot-starter-security` | `bjca-footstone-bpring-boot-starter-security` |
| `spring-boot-starter-test` | `bjca-footstone-bpring-boot-starter-test` |
| `spring-boot-starter-thymeleaf` | `bjca-footstone-bpring-boot-starter-thymeleaf` |
| `spring-boot-starter-tomcat` | `bjca-footstone-bpring-boot-starter-tomcat` |
| `spring-boot-starter-undertow` | `bjca-footstone-bpring-boot-starter-undertow` |
| `spring-boot-starter-validation` | `bjca-footstone-bpring-boot-starter-validation` |
| `spring-boot-starter-web` | `bjca-footstone-bpring-boot-starter-web` |
| `spring-boot-starter-web-services` | `bjca-footstone-bpring-boot-starter-web-services` |
| `spring-boot-starter-webflux` | `bjca-footstone-bpring-boot-starter-webflux` |
| `spring-boot-starter-websocket` | `bjca-footstone-bpring-boot-starter-websocket` |

### 3.2 已排除 Starter（settings.gradle 中 ignoredStarters）

以下 Starter 因依赖链冲突、私服缺失或构建精简策略已从当前构建中排除，不产生 fork 制品：

| 原始 ArtifactId | 排除原因 |
| :--- | :--- |
| `spring-boot-starter-activemq` | 消息中间件精简 |
| `spring-boot-starter-amqp` | 消息中间件精简 |
| `spring-boot-starter-artemis` | 消息中间件精简 |
| `spring-boot-starter-data-cassandra` | 私服依赖缺失 |
| `spring-boot-starter-data-cassandra-reactive` | 私服依赖缺失 |
| `spring-boot-starter-data-couchbase` | 私服依赖缺失 |
| `spring-boot-starter-data-couchbase-reactive` | 私服依赖缺失 |
| `spring-boot-starter-data-ldap` | 构建精简 |
| `spring-boot-starter-data-neo4j` | 私服依赖缺失 |
| `spring-boot-starter-data-r2dbc` | 构建精简 |
| `spring-boot-starter-data-rest` | 构建精简 |
| `spring-boot-starter-graphql` | 构建精简 |
| `spring-boot-starter-hateoas` | 构建精简 |
| `spring-boot-starter-integration` | 依赖链冲突 |
| `spring-boot-starter-jersey` | 构建精简 |
| `spring-boot-starter-jooq` | 构建精简 |
| `spring-boot-starter-jta-atomikos` | 构建精简 |
| `spring-boot-starter-rsocket` | 构建精简 |

---

## 4. 构建工具与类加载器 (Tools & Loaders)

| 原始 ArtifactId | 新 ArtifactId |
| :--- | :--- |
| `spring-boot-loader` | `bjca-footstone-bpring-boot-loader` |
| `spring-boot-loader-tools` | `bjca-footstone-bpring-boot-loader-tools` |
| `spring-boot-maven-plugin` | `bjca-footstone-bpring-boot-maven-plugin` |
| `spring-boot-gradle-plugin` | `bjca-footstone-bpring-boot-gradle-plugin` |
| `spring-boot-autoconfigure-processor` | `bjca-footstone-bpring-boot-autoconfigure-processor` |
| `spring-boot-configuration-processor` | `bjca-footstone-bpring-boot-configuration-processor` |
| `spring-boot-configuration-metadata` | `bjca-footstone-bpring-boot-configuration-metadata` |
| `spring-boot-buildpack-platform` | `bjca-footstone-bpring-boot-buildpack-platform` |
| `spring-boot-jarmode-layertools` | `bjca-footstone-bpring-boot-jarmode-layertools` |
| `spring-boot-gradle-test-support` | `bjca-footstone-bpring-boot-gradle-test-support` |
| `spring-boot-test-support` | `bjca-footstone-bpring-boot-test-support` |

---

## 5. Spring Framework 完整模块映射

> **映射规则**：`org.springframework:spring-{name}` → `cn.bjca.footstone.bpring:bjca-footstone-bpring-{name}`
>
> **版本**：`5.3.39-nes.patch.1-SNAPSHOT`
>
> **映射方式**：由根 `build.gradle` 的 `resolutionStrategy.eachDependency` **自动完成**，无需手动声明。子模块中仍使用原始 `org.springframework` 坐标，构建系统在依赖解析阶段透明替换。
>
> **版本管理**：通过 BOM 导入 `cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom` 自动覆盖所有子模块版本。

### 5.1 核心容器

| 原始坐标 | Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-core` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-core` |
| `org.springframework:spring-beans` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-beans` |
| `org.springframework:spring-context` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-context` |
| `org.springframework:spring-context-support` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-context-support` |
| `org.springframework:spring-context-indexer` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-context-indexer` |
| `org.springframework:spring-expression` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-expression` |
| `org.springframework:spring-jcl` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-jcl` |

### 5.2 AOP 与 Instrumentation

| 原始坐标 | Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-aop` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-aop` |
| `org.springframework:spring-aspects` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-aspects` |
| `org.springframework:spring-instrument` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-instrument` |

### 5.3 数据访问与事务

| 原始坐标 | Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-jdbc` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-jdbc` |
| `org.springframework:spring-tx` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-tx` |
| `org.springframework:spring-orm` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-orm` |
| `org.springframework:spring-oxm` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-oxm` |
| `org.springframework:spring-r2dbc` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-r2dbc` |
| `org.springframework:spring-jms` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-jms` |

### 5.4 Web

| 原始坐标 | Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-web` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-web` |
| `org.springframework:spring-webmvc` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-webmvc` |
| `org.springframework:spring-webflux` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-webflux` |
| `org.springframework:spring-websocket` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-websocket` |

### 5.5 消息与测试

| 原始坐标 | Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-messaging` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-messaging` |
| `org.springframework:spring-test` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-test` |

### 5.6 BOM

| 原始坐标 | Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-framework-bom` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom` |

---

## 6. Spring Security 完整模块映射

> **映射规则**：`org.springframework.security:spring-security-{name}` → `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-{name}`
>
> **版本**：`5.8.16-nes.patch.1-SNAPSHOT`
>
> **映射方式**：由根 `build.gradle` 的 `resolutionStrategy.eachDependency` **自动完成**，无需手动声明。
>
> **版本管理**：通过 BOM 导入 `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-bom` 自动覆盖所有子模块版本。

### 6.1 核心模块

| 原始坐标 | Fork 坐标 |
| :--- | :--- |
| `o.s.security:spring-security-core` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-core` |
| `o.s.security:spring-security-config` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-config` |
| `o.s.security:spring-security-web` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-web` |
| `o.s.security:spring-security-crypto` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-crypto` |

### 6.2 OAuth2 与 SAML

| 原始坐标 | Fork 坐标 |
| :--- | :--- |
| `o.s.security:spring-security-oauth2-client` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-client` |
| `o.s.security:spring-security-oauth2-core` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-core` |
| `o.s.security:spring-security-oauth2-jose` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-jose` |
| `o.s.security:spring-security-oauth2-resource-server` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-resource-server` |
| `o.s.security:spring-security-saml2-service-provider` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-saml2-service-provider` |

---

## 7. Spring Kafka NES 模块映射

Spring Kafka NES 分支当前采用 **GroupId 去特征化 + 版本 NES 化**，ArtifactId 保持 upstream 名称不变。

> **映射方式**：根 `build.gradle` 的 `resolutionStrategy.eachDependency` 会在本仓库构建期将 `org.springframework.kafka` 组透明替换为 `cn.bjca.footstone.bpring.kafka`。
>
> **版本管理**：`spring-boot-dependencies` BOM 直接管理以下 NES 坐标。

| 原始坐标 | NES 坐标 |
| :--- | :--- |
| `org.springframework.kafka:spring-kafka` | `cn.bjca.footstone.bpring.kafka:spring-kafka` |
| `org.springframework.kafka:spring-kafka-test` | `cn.bjca.footstone.bpring.kafka:spring-kafka-test` |

**版本：** `2.9.13-nes.patch.1-SNAPSHOT`

> **注意：** 当前私服中未发布 `bjca-footstone-bpring-kafka-bom`，也未发布 `bjca-footstone-bpring-kafka` / `bjca-footstone-bpring-kafka-test` artifactId。下游应使用上表中的实际坐标。

### 6.3 扩展模块

| 原始坐标 | Fork 坐标 |
| :--- | :--- |
| `o.s.security:spring-security-acl` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-acl` |
| `o.s.security:spring-security-cas-client` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-cas-client` |
| `o.s.security:spring-security-data` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-data` |
| `o.s.security:spring-security-ldap` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-ldap` |
| `o.s.security:spring-security-messaging` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-messaging` |
| `o.s.security:spring-security-rsocket` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-rsocket` |
| `o.s.security:spring-security-taglibs` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-taglibs` |
| `o.s.security:spring-security-test` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-test` |

### 6.4 Authorization Server（独立版本管理）

> **注意**：Spring Authorization Server 是独立项目，非 Spring Security 核心模块，版本号独立管理。

| 原始坐标 | Fork 坐标 | 版本 |
| :--- | :--- | :--- |
| `o.s.security:spring-security-oauth2-authorization-server` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-authorization-server` | `0.4.5-nes.patch.1-SNAPSHOT` |

### 6.5 BOM

| 原始坐标 | Fork 坐标 |
| :--- | :--- |
| `o.s.security:spring-security-bom` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-bom` |

> **表格约定**：`o.s.security` 为 `org.springframework.security` 的缩写，用于表格排版。

---

## 8. 自动映射机制说明

### 7.1 配置单点管理（gradle.properties）

所有 fork GAV 转换参数集中在项目根目录的 `gradle.properties` 中，修改以下两个参数即可全局生效：

```properties
# 制品名前缀：替换所有 "spring" 前缀
forkArtifactPrefix=bjca-footstone-bpring

# 基础 GroupId：所有模块 groupId 的根路径
forkGroupIdBase=cn.bjca.footstone.bpring
```

**GroupId 自动派生关系：**
| 组件系列 | 原始 GroupId | Fork GroupId | 派生规则 |
| :--- | :--- | :--- | :--- |
| Spring Boot | `org.springframework.boot` | `cn.bjca.footstone.bpring.boot` | `${forkGroupIdBase}.boot` |
| Spring Framework | `org.springframework` | `cn.bjca.footstone.bpring` | `${forkGroupIdBase}` |
| Spring Security | `org.springframework.security` | `cn.bjca.footstone.bpring.security` | `${forkGroupIdBase}.security` |

### 7.2 resolutionStrategy.eachDependency 工作原理

在根 `build.gradle` 的 `allprojects.configurations.all` 块中，通过 Gradle 的 `resolutionStrategy.eachDependency` 钩子在**依赖解析阶段**拦截并透明替换坐标：

**规则一 —— Spring Framework 组映射：**
```
触发条件：requested.group == 'org.springframework' && requested.name.startsWith('spring-')
转换逻辑：
  GroupId:     org.springframework                → ${forkGroupIdBase}
  ArtifactId:  spring-{name}                      → ${forkArtifactPrefix}-{name}
  Version:     (任意)                               → ${springFrameworkVersion}
```

**规则二 —— Spring Security 组映射：**
```
触发条件：requested.group == 'org.springframework.security' && requested.name.startsWith('spring-security-')
转换逻辑：
  GroupId:     org.springframework.security        → ${forkGroupIdBase}.security
  ArtifactId:  spring-security-{name}              → ${forkArtifactPrefix}-security-{name}
  Version:     (任意)                               → ${springSecurityVersion}
```

> 此外，根 `build.gradle` 还实现了 **规则三（Spring Kafka）**、**规则四（Logback）**，详见源码内注释。

**规则五 —— Spring Data 组映射（仅 commons / keyvalue）：**
```
触发条件：requested.group == 'org.springframework.data'
          && requested.name ∈ { spring-data-commons, spring-data-keyvalue }
转换逻辑：
  GroupId:     org.springframework.data            → cn.bjca.footstone.bpring.data
  ArtifactId:  spring-data-{name}                  → ${forkArtifactPrefix}-data-{name}
  Version:     (任意)                               → 2.7.18-nes.patch.1-SNAPSHOT（硬编码）
```
> 仅 commons/keyvalue 两个模块完成 fork（含本体 CVE 修复），其余 `spring-data-*` 保持官方坐标 + 官方版本，由私服/mavenCentral 代理解析。规则五同时堵住 `spring-data-redis` 等官方模块经传递依赖回拉官方 `spring-data-commons` 的链路。见 [需求-034]。

**关键特性：**
- 所有子模块 `build.gradle` **无需任何修改**，仍使用上游原始坐标声明依赖
- 替换在依赖解析阶段自动完成，对开发者完全透明
- 如需新增映射组，只需在 `resolutionStrategy` 中仿照现有规则添加新的 `else if` 分支

### 7.3 下游项目使用 BOM

下游 Maven/Gradle 项目只需引用 `bjca-footstone-bpring-boot-dependencies` BOM 即可继承全部版本管理：

**Maven 用法：**
```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>cn.bjca.footstone.bpring.boot</groupId>
            <artifactId>bjca-footstone-bpring-boot-dependencies</artifactId>
            <version>2.7.18-nes.patch.1-SNAPSHOT</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

**Gradle 用法：**
```groovy
dependencyManagement {
    imports {
        mavenBom "cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-dependencies:2.7.18-nes.patch.1-SNAPSHOT"
    }
}
```

该 BOM 内部已通过 `imports` 方式引入了 Spring Framework BOM 和 Spring Security BOM，因此下游项目**无需额外声明**这两个 BOM。

### 7.4 buildSrc 特殊处理

`buildSrc` 是 Gradle 的独立构建单元，先于主项目编译。根 `build.gradle` 中的 `resolutionStrategy.eachDependency` 规则**不作用于 buildSrc**，因此：

1. **手动加载配置**：`buildSrc/build.gradle` 通过读取根目录 `gradle.properties` 获取 `forkGroupIdBase` 和 `forkArtifactPrefix`
2. **直接使用 fork 坐标**：所有 Spring Framework 依赖必须使用完整的 fork 坐标
   ```groovy
   implementation("${forkGroupIdBase}:${forkArtifactPrefix}-context")
   implementation("${forkGroupIdBase}:${forkArtifactPrefix}-core")
   implementation("${forkGroupIdBase}:${forkArtifactPrefix}-web")
   ```
3. **使用 fork BOM 进行版本管理**：
   ```groovy
   implementation(platform("${forkGroupIdBase}:${forkArtifactPrefix}-framework-bom:${versions.springFramework}"))
   ```
4. **GString 注意事项**：Groovy `GString`（含 `${}` 插值的字符串）不能直接传入 Java DSL 方法，需在 Groovy 层面先完成字符串拼接（使用 `+` 运算符）

---

## 9. 兼容关系链

```
Spring Boot 2.7.18 (fork: 2.7.18-nes.patch.1-SNAPSHOT)
  ├── Spring Framework 5.3.39 (fork: 5.3.39-nes.patch.1-SNAPSHOT)
  │     GroupId: cn.bjca.footstone.bpring
  │     BOM: bjca-footstone-bpring-framework-bom
  └── Spring Security 5.8.16 (fork: 5.8.16-nes.patch.1-SNAPSHOT)
        GroupId: cn.bjca.footstone.bpring.security
        BOM: bjca-footstone-bpring-security-bom
        └── Authorization Server 0.4.5 (fork: 0.4.5-nes.patch.1-SNAPSHOT)
```
