# NES GAV 映射完整指南

> **NES = Never-Ending Support**（永续支持）
>
> 本文档面向**下游组件使用者**，整合了四个 NES fork 项目的 GAV（GroupId / ArtifactId / Version）映射信息，
> 帮助您快速将项目从官方 Spring 依赖迁移到 NES 内部维护版本。

---

## 目录

1. [兼容关系链](#1-兼容关系链)
2. [快速开始](#2-快速开始)
3. [Spring Boot GAV 映射表](#3-spring-boot-gav-映射表)
4. [Spring Framework GAV 映射表](#4-spring-framework-gav-映射表)
5. [Spring Security GAV 映射表](#5-spring-security-gav-映射表)
6. [Spring Authorization Server GAV 映射表](#6-spring-authorization-server-gav-映射表)
7. [Logback GAV 映射表](#7-logback-gav-映射表)
8. [已排除的 Starter 清单](#8-已排除的-starter-清单)
9. [A 类组件传递依赖排除说明](#9-a-类组件传递依赖排除说明)
10. [注意事项](#10-注意事项)

---

## 1. 兼容关系链

四个 NES fork 项目之间存在严格的版本对应关系与 BOM 层级继承关系，**必须配套使用**。

### 1.1 版本对应关系

| 组件 | 官方基线版本 | NES Fork 版本 |
| :--- | :--- | :--- |
| Spring Boot | `2.7.18` | `2.7.18-nes.patch.1-SNAPSHOT` |
| Spring Framework | `5.3.39` | `5.3.39-nes.patch.1-SNAPSHOT` |
| Spring Security | `5.8.16` | `5.8.16-nes.patch.1-SNAPSHOT` |
| Spring Authorization Server | `0.4.5` | `0.4.5-nes.patch.1-SNAPSHOT` |

### 1.2 BOM 层级继承关系

```
bjca-footstone-bpring-boot-dependencies (Spring Boot BOM — 版本管理中心)
├── bjca-footstone-bpring-framework-bom (Spring Framework BOM)
│     GroupId:  cn.bjca.footstone.bpring
│     Version: 5.3.39-nes.patch.1-SNAPSHOT
├── bjca-footstone-bpring-security-bom (Spring Security BOM)
│     GroupId:  cn.bjca.footstone.bpring.security
│     Version: 5.8.16-nes.patch.1-SNAPSHOT
└── 第三方依赖版本（Jackson、Tomcat、JUnit 等）
      └── 由 Spring Boot BOM 统一管控
```

**关键结论：** 下游项目只需引入 **Spring Boot BOM**（`bjca-footstone-bpring-boot-dependencies`），即可自动继承 Spring Framework BOM 和 Spring Security BOM 的全部版本管理，**无需额外声明**这两个子 BOM。

### 1.3 GroupId 总览

| 组件系列 | 原始 GroupId | NES Fork GroupId |
| :--- | :--- | :--- |
| Spring Boot | `org.springframework.boot` | `cn.bjca.footstone.bpring.boot` |
| Spring Framework | `org.springframework` | `cn.bjca.footstone.bpring` |
| Spring Security | `org.springframework.security` | `cn.bjca.footstone.bpring.security` |
| Authorization Server | `org.springframework.security` | `cn.bjca.footstone.bpring.security` |
| Logback | `ch.qos.logback` | `cn.bjca.footstone.bogback` |

---

## 2. 快速开始

### 2.1 Maven 项目 — 使用 Parent POM（推荐）

最简方式：直接继承 NES 版 `starter-parent`，无需手动声明 `dependencyManagement`。

```xml
<parent>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-parent</artifactId>
    <version>2.7.18-nes.patch.1-SNAPSHOT</version>
    <relativePath/> <!-- lookup parent from repository -->
</parent>
```

然后在 `<dependencies>` 中直接声明 starter，**无需写版本号**：

```xml
<dependencies>
    <!-- Web Starter -->
    <dependency>
        <groupId>cn.bjca.footstone.bpring.boot</groupId>
        <artifactId>bjca-footstone-bpring-boot-starter-web</artifactId>
    </dependency>

    <!-- Security Starter -->
    <dependency>
        <groupId>cn.bjca.footstone.bpring.boot</groupId>
        <artifactId>bjca-footstone-bpring-boot-starter-security</artifactId>
    </dependency>

    <!-- Test Starter -->
    <dependency>
        <groupId>cn.bjca.footstone.bpring.boot</groupId>
        <artifactId>bjca-footstone-bpring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### 2.2 Maven 项目 — 使用 BOM 导入

如果项目已有自己的 Parent POM，无法继承 `starter-parent`，则通过 `dependencyManagement` 导入 BOM：

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

<dependencies>
    <!-- Web Starter（版本由 BOM 管控，无需声明） -->
    <dependency>
        <groupId>cn.bjca.footstone.bpring.boot</groupId>
        <artifactId>bjca-footstone-bpring-boot-starter-web</artifactId>
    </dependency>

    <!-- 如需直接引用 Spring Framework 模块（版本由 BOM 管控） -->
    <dependency>
        <groupId>cn.bjca.footstone.bpring</groupId>
        <artifactId>bjca-footstone-bpring-context</artifactId>
    </dependency>

    <!-- 如需直接引用 Spring Security 模块（版本由 BOM 管控） -->
    <dependency>
        <groupId>cn.bjca.footstone.bpring.security</groupId>
        <artifactId>bjca-footstone-bpring-security-core</artifactId>
    </dependency>
</dependencies>
```

### 2.3 Gradle 项目 — 使用 BOM 平台

```groovy
plugins {
    id 'java'
    id 'io.spring.dependency-management' version '1.0.15.RELEASE'
}

dependencyManagement {
    imports {
        mavenBom "cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-dependencies:2.7.18-nes.patch.1-SNAPSHOT"
    }
}

dependencies {
    // Web Starter（版本由 BOM 管控）
    implementation 'cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-web'

    // Security Starter
    implementation 'cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-security'

    // 直接引用 Spring Framework 模块
    implementation 'cn.bjca.footstone.bpring:bjca-footstone-bpring-jdbc'

    // 直接引用 Spring Security 模块
    implementation 'cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-client'

    // Test
    testImplementation 'cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-test'
}
```

### 2.4 Gradle Kotlin DSL 项目

```kotlin
plugins {
    java
    id("io.spring.dependency-management") version "1.0.15.RELEASE"
}

dependencyManagement {
    imports {
        mavenBom("cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-dependencies:2.7.18-nes.patch.1-SNAPSHOT")
    }
}

dependencies {
    implementation("cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-web")
    implementation("cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-security")
    testImplementation("cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-test")
}
```

### 2.5 使用 Maven 插件打包

```xml
<build>
    <plugins>
        <plugin>
            <groupId>cn.bjca.footstone.bpring.boot</groupId>
            <artifactId>bjca-footstone-bpring-boot-maven-plugin</artifactId>
            <!-- 如使用 starter-parent 则无需版本号；否则需指定 -->
            <version>2.7.18-nes.patch.1-SNAPSHOT</version>
            <executions>
                <execution>
                    <goals>
                        <goal>repackage</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

---

## 3. Spring Boot GAV 映射表

> **GroupId 映射**：`org.springframework.boot` → `cn.bjca.footstone.bpring.boot`
>
> **Version**：`2.7.18-nes.patch.1-SNAPSHOT`
>
> **ArtifactId 映射规则**：`spring-boot-{name}` → `bjca-footstone-bpring-boot-{name}`
>
> **例外**：`spring-boot-gradle-plugin` 保留原始 artifactId 不变（使用独立发布机制，不经过 DeployedPlugin）

### 3.1 核心基础设施（BOM / Parent）

| 原始 ArtifactId | NES Fork ArtifactId | 说明 |
| :--- | :--- | :--- |
| `spring-boot-dependencies` | `bjca-footstone-bpring-boot-dependencies` | **核心 BOM**（版本管理中心，下游必须引入） |
| `spring-boot-parent` | `bjca-footstone-bpring-boot-parent` | 内部 Parent POM |
| `spring-boot-starter-parent` | `bjca-footstone-bpring-boot-starter-parent` | **Maven 项目推荐 Parent POM** |

### 3.2 核心框架模块

| 原始 ArtifactId | NES Fork ArtifactId |
| :--- | :--- |
| `spring-boot` | `bjca-footstone-bpring-boot` |
| `spring-boot-autoconfigure` | `bjca-footstone-bpring-boot-autoconfigure` |
| `spring-boot-actuator` | `bjca-footstone-bpring-boot-actuator` |
| `spring-boot-actuator-autoconfigure` | `bjca-footstone-bpring-boot-actuator-autoconfigure` |
| `spring-boot-devtools` | `bjca-footstone-bpring-boot-devtools` |
| `spring-boot-test` | `bjca-footstone-bpring-boot-test` |
| `spring-boot-test-autoconfigure` | `bjca-footstone-bpring-boot-test-autoconfigure` |
| `spring-boot-properties-migrator` | `bjca-footstone-bpring-boot-properties-migrator` |

### 3.3 Starter 模块（活跃）

所有 Starter 遵循统一映射规则：`spring-boot-starter-{name}` → `bjca-footstone-bpring-boot-starter-{name}`

| 原始 ArtifactId | NES Fork ArtifactId |
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

### 3.4 构建工具与类加载器

| 原始 ArtifactId | NES Fork ArtifactId | 说明 |
| :--- | :--- | :--- |
| `spring-boot-loader` | `bjca-footstone-bpring-boot-loader` | 可执行 JAR 类加载器 |
| `spring-boot-loader-tools` | `bjca-footstone-bpring-boot-loader-tools` | Loader 工具库 |
| `spring-boot-maven-plugin` | `bjca-footstone-bpring-boot-maven-plugin` | Maven 打包插件 |
| `spring-boot-gradle-plugin` | `spring-boot-gradle-plugin` | Gradle 打包插件（**保留原始命名**，使用独立发布机制，不经过 DeployedPlugin） |
| `spring-boot-autoconfigure-processor` | `bjca-footstone-bpring-boot-autoconfigure-processor` | 自动配置注解处理器 |
| `spring-boot-configuration-processor` | `bjca-footstone-bpring-boot-configuration-processor` | 配置元数据注解处理器 |
| `spring-boot-configuration-metadata` | `bjca-footstone-bpring-boot-configuration-metadata` | 配置元数据模型 |
| `spring-boot-buildpack-platform` | `bjca-footstone-bpring-boot-buildpack-platform` | Buildpack 平台支持 |
| `spring-boot-jarmode-layertools` | `bjca-footstone-bpring-boot-jarmode-layertools` | 分层 JAR 工具 |
| `spring-boot-gradle-test-support` | `bjca-footstone-bpring-boot-gradle-test-support` | Gradle 测试支持 |
| `spring-boot-test-support` | `bjca-footstone-bpring-boot-test-support` | 测试基础设施 |

---

## 4. Spring Framework GAV 映射表

> **GroupId 映射**：`org.springframework` → `cn.bjca.footstone.bpring`
>
> **Version**：`5.3.39-nes.patch.1-SNAPSHOT`
>
> **ArtifactId 映射规则**：`spring-{name}` → `bjca-footstone-bpring-{name}`

### 4.1 核心容器

| 原始坐标 | NES Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-core` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-core` |
| `org.springframework:spring-beans` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-beans` |
| `org.springframework:spring-context` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-context` |
| `org.springframework:spring-context-support` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-context-support` |
| `org.springframework:spring-context-indexer` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-context-indexer` |
| `org.springframework:spring-expression` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-expression` |
| `org.springframework:spring-jcl` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-jcl` |

### 4.2 AOP 与 Instrumentation

| 原始坐标 | NES Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-aop` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-aop` |
| `org.springframework:spring-aspects` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-aspects` |
| `org.springframework:spring-instrument` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-instrument` |

### 4.3 数据访问与事务

| 原始坐标 | NES Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-jdbc` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-jdbc` |
| `org.springframework:spring-tx` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-tx` |
| `org.springframework:spring-orm` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-orm` |
| `org.springframework:spring-oxm` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-oxm` |
| `org.springframework:spring-r2dbc` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-r2dbc` |
| `org.springframework:spring-jms` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-jms` |

### 4.4 Web

| 原始坐标 | NES Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-web` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-web` |
| `org.springframework:spring-webmvc` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-webmvc` |
| `org.springframework:spring-webflux` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-webflux` |
| `org.springframework:spring-websocket` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-websocket` |

### 4.5 消息与测试

| 原始坐标 | NES Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-messaging` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-messaging` |
| `org.springframework:spring-test` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-test` |

### 4.6 BOM

| 原始坐标 | NES Fork 坐标 |
| :--- | :--- |
| `org.springframework:spring-framework-bom` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom` |

---

## 5. Spring Security GAV 映射表

> **GroupId 映射**：`org.springframework.security` → `cn.bjca.footstone.bpring.security`
>
> **Version**：`5.8.16-nes.patch.1-SNAPSHOT`
>
> **ArtifactId 映射规则**：`spring-security-{name}` → `bjca-footstone-bpring-security-{name}`

### 5.1 核心模块

| 原始坐标 | NES Fork 坐标 | 说明 |
| :--- | :--- | :--- |
| `o.s.security:spring-security-core` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-core` | 核心认证授权逻辑 |
| `o.s.security:spring-security-config` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-config` | XML/Java 配置支持 |
| `o.s.security:spring-security-web` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-web` | Web 安全 Filter 支持 |
| `o.s.security:spring-security-crypto` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-crypto` | 加密工具模块 |

> **表格约定**：`o.s.security` 为 `org.springframework.security` 的缩写，用于表格排版。

### 5.2 OAuth2 与 SAML

| 原始坐标 | NES Fork 坐标 | 说明 |
| :--- | :--- | :--- |
| `o.s.security:spring-security-oauth2-client` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-client` | OAuth2 客户端功能 |
| `o.s.security:spring-security-oauth2-core` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-core` | OAuth2 核心协议支持 |
| `o.s.security:spring-security-oauth2-jose` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-jose` | JOSE（JWT/JWE）支持 |
| `o.s.security:spring-security-oauth2-resource-server` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-resource-server` | 资源服务器支持 |
| `o.s.security:spring-security-saml2-service-provider` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-saml2-service-provider` | SAML2 服务提供者 |

### 5.3 扩展模块

| 原始坐标 | NES Fork 坐标 | 说明 |
| :--- | :--- | :--- |
| `o.s.security:spring-security-acl` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-acl` | ACL 权限控制 |
| `o.s.security:spring-security-cas` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-cas` | CAS 单点登录对接 |
| `o.s.security:spring-security-data` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-data` | Spring Data 集成 |
| `o.s.security:spring-security-ldap` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-ldap` | LDAP 对接 |
| `o.s.security:spring-security-messaging` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-messaging` | 消息安全支持 |
| `o.s.security:spring-security-rsocket` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-rsocket` | RSocket 安全支持 |
| `o.s.security:spring-security-taglibs` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-taglibs` | JSP 标签库 |
| `o.s.security:spring-security-test` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-test` | 测试框架支持 |

### 5.4 BOM 与依赖管理

| 原始坐标 | NES Fork 坐标 | 说明 |
| :--- | :--- | :--- |
| `o.s.security:spring-security-bom` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-bom` | Spring Security BOM |
| `o.s.security:spring-security-dependencies` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-dependencies` | 内部依赖管理 |

---

## 6. Spring Authorization Server GAV 映射表

> **GroupId 映射**：`org.springframework.security` → `cn.bjca.footstone.bpring.security`
>
> **Version**：`0.4.5-nes.patch.1-SNAPSHOT`（**独立版本号**，与 Spring Security 不同）
>
> **注意**：Spring Authorization Server 是独立项目，虽然 GroupId 与 Spring Security 相同，但版本号独立管理。

| 原始坐标 | NES Fork 坐标 | 说明 |
| :--- | :--- | :--- |
| `o.s.security:spring-security-oauth2-authorization-server` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-authorization-server` | OAuth2 授权服务器核心 |
| `o.s.security:spring-authorization-server-dependencies` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-spring-authorization-server-dependencies` | 授权服务器依赖管理 |

### Maven 引入示例

```xml
<dependency>
    <groupId>cn.bjca.footstone.bpring.security</groupId>
    <artifactId>bjca-footstone-bpring-security-oauth2-authorization-server</artifactId>
    <version>0.4.5-nes.patch.1-SNAPSHOT</version>
</dependency>
```

### Gradle 引入示例

```groovy
implementation 'cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-oauth2-authorization-server:0.4.5-nes.patch.1-SNAPSHOT'
```

> **提示**：Authorization Server 的版本需要显式声明，不在 Spring Boot BOM 的自动管理范围内。

---

## 7. Logback GAV 映射表

| 原始 GroupId | 原始 ArtifactId | NES Fork GroupId | NES Fork ArtifactId | NES Fork Version |
| :--- | :--- | :--- | :--- | :--- |
| `ch.qos.logback` | `logback-core` | `cn.bjca.footstone.bogback` | `bjca-footstone-bogback-core` | `1.2.13-nes.patch.1` |
| `ch.qos.logback` | `logback-classic` | `cn.bjca.footstone.bogback` | `bjca-footstone-bogback-classic` | `1.2.13-nes.patch.1` |

> **说明**：`logback-access` 暂未 fork，如需使用请继续引用原始坐标 `ch.qos.logback:logback-access`。

### Maven 依赖声明

```xml
<dependency>
  <groupId>cn.bjca.footstone.bogback</groupId>
  <artifactId>bjca-footstone-bogback-classic</artifactId>
  <version>1.2.13-nes.patch.1</version>
</dependency>
<dependency>
  <groupId>cn.bjca.footstone.bogback</groupId>
  <artifactId>bjca-footstone-bogback-core</artifactId>
  <version>1.2.13-nes.patch.1</version>
</dependency>
```

### Gradle 依赖声明

```groovy
implementation 'cn.bjca.footstone.bogback:bjca-footstone-bogback-classic:1.2.13-nes.patch.1'
implementation 'cn.bjca.footstone.bogback:bjca-footstone-bogback-core:1.2.13-nes.patch.1'
```

> **提示**：引入 `bjca-footstone-bpring-boot-dependencies` BOM 后，版本号可省略，由 BOM 统一管理。Java 包名保持不变（`ch.qos.logback.*`），import 语句无需修改。

---

## 8. 已排除的 Starter 清单

以下 Starter 因依赖链冲突、私服缺失或构建精简策略，已从当前 NES 构建中排除，**不产生 fork 制品**。如下游项目需要使用这些功能，请继续使用官方原始坐标或联系维护团队评估纳入。

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

## 9. A 类组件传递依赖排除说明

### 9.1 背景

NES BOM 对 8 个 **A 类第三方库** 执行了 `<exclusions>`，排除其对 `org.springframework:spring-*` 的传递依赖。

**排除原因：** 这些第三方库（如 Spring Kafka、Spring Batch 等）在其 POM 中声明的传递依赖指向官方 `org.springframework:spring-*` 坐标。如果不排除，Maven/Gradle 会同时引入官方坐标和 NES fork 坐标（`cn.bjca.footstone.bpring:bjca-footstone-bpring-*`），导致类路径上存在两套 Spring Framework 实现，产生运行时冲突。

**影响范围：** BOM 中以下 8 个 A 类库受到影响：

| 序号 | A 类库 | 版本 | Starter 状态 |
| :--- | :--- | :--- | :--- |
| 1 | Spring Kafka | 2.9.13 | 无 Starter |
| 2 | Spring Batch Core | 4.3.10 | 活跃 Starter（`spring-boot-starter-batch`） |
| 3 | Spring HATEOAS | 1.5.6 | 已排除 Starter（`spring-boot-starter-hateoas`） |
| 4 | Spring LDAP Core | 2.4.1 | 已排除 Starter（`spring-boot-starter-data-ldap`） |
| 5 | Spring WS Core | 3.1.8 | 活跃 Starter（`spring-boot-starter-web-services`） |
| 6 | Spring AMQP + Spring Rabbit | 2.4.17 | 已排除 Starter（`spring-boot-starter-amqp`） |
| 7 | Spring GraphQL | 1.0.6 | 已排除 Starter（`spring-boot-starter-graphql`） |
| 8 | Spring RESTDocs | 2.0.8.RELEASE | 无 Starter（通常 test scope） |

**对下游 Maven 消费者的影响：** 排除操作会切断这些库到 Spring Framework 的传递依赖链。如果下游项目未通过其他途径（如 Starter）获得这些 Spring 模块，则需显式添加对应的 NES fork 依赖。

### 9.2 三类库的影响程度

#### 活跃 Starter（影响较小）

适用于：**Spring Batch Core**、**Spring WS Core**

这两个库有对应的活跃 Starter（`spring-boot-starter-batch`、`spring-boot-starter-web-services`）。Starter 内部已显式声明必要的 Spring Framework fork 依赖，**使用 Starter 的用户无需额外操作**。仅在不使用 Starter、直接引用底层库时需要手动补充缺失依赖。

#### 已排除 Starter（需手动配置）

适用于：**Spring HATEOAS**、**Spring LDAP Core**、**Spring AMQP + Spring Rabbit**

这些库的对应 Starter 已从 NES 构建中排除（见第 8 章）。使用这些库时必须手动添加所有缺失的 Spring Framework fork 依赖。

#### 无 Starter 的库（需显式添加全部依赖）

适用于：**Spring Kafka**、**Spring GraphQL**、**Spring RESTDocs**

这些库本身没有可用的 Starter，使用时必须显式添加所有缺失的 Spring Framework fork 依赖。

### 9.3 各库缺失依赖详表

以下按库分组列出被排除的 Spring 传递依赖及对应的 NES fork 替代坐标。

> **说明：**
> - 所有 fork 替代坐标的 GroupId 为 `cn.bjca.footstone.bpring`，版本由 BOM 统一管理，引入 BOM 后无需显式声明版本号。
> - 表中列出各库 **直接缺失** 的 Spring 传递依赖；fork 制品自身的传递依赖会自动解析（例如添加 `bjca-footstone-bpring-context` 会自动传递引入 `bjca-footstone-bpring-core`、`bjca-footstone-bpring-beans` 等）。
> - **最小补充集** 是考虑传递依赖后实际需要显式声明的最少依赖。

---

#### 9.3.1 Spring Kafka 2.9.13（无 Starter）

| 缺失的原始依赖 | Fork 替代 ArtifactId |
| :--- | :--- |
| `spring-context` | `bjca-footstone-bpring-context` |
| `spring-messaging` | `bjca-footstone-bpring-messaging` |
| `spring-tx` | `bjca-footstone-bpring-tx` |

**最小补充集：** `bjca-footstone-bpring-context`、`bjca-footstone-bpring-messaging`、`bjca-footstone-bpring-tx`

---

#### 9.3.2 Spring Batch Core 4.3.10（活跃 Starter: `spring-boot-starter-batch`）

| 缺失的原始依赖 | Fork 替代 ArtifactId |
| :--- | :--- |
| `spring-aop` | `bjca-footstone-bpring-aop` |
| `spring-beans` | `bjca-footstone-bpring-beans` |
| `spring-context` | `bjca-footstone-bpring-context` |
| `spring-core` | `bjca-footstone-bpring-core` |
| `spring-tx` | `bjca-footstone-bpring-tx` |

**最小补充集（不使用 Starter 时）：** `bjca-footstone-bpring-context`、`bjca-footstone-bpring-tx`（`spring-context` 会传递引入 `spring-aop`、`spring-beans`、`spring-core`）

> **提示：** 使用 `bjca-footstone-bpring-boot-starter-batch` 的用户无需额外操作，Starter 已包含所有必要依赖。

---

#### 9.3.3 Spring HATEOAS 1.5.6（已排除 Starter: `spring-boot-starter-hateoas`）

| 缺失的原始依赖 | Fork 替代 ArtifactId |
| :--- | :--- |
| `spring-aop` | `bjca-footstone-bpring-aop` |
| `spring-beans` | `bjca-footstone-bpring-beans` |
| `spring-context` | `bjca-footstone-bpring-context` |
| `spring-core` | `bjca-footstone-bpring-core` |
| `spring-web` | `bjca-footstone-bpring-web` |

**最小补充集：** `bjca-footstone-bpring-context`、`bjca-footstone-bpring-web`

---

#### 9.3.4 Spring LDAP Core 2.4.1（已排除 Starter: `spring-boot-starter-data-ldap`）

| 缺失的原始依赖 | Fork 替代 ArtifactId |
| :--- | :--- |
| `spring-core` | `bjca-footstone-bpring-core` |
| `spring-beans` | `bjca-footstone-bpring-beans` |
| `spring-tx` | `bjca-footstone-bpring-tx` |

**最小补充集：** `bjca-footstone-bpring-tx`（`spring-tx` 会传递引入 `spring-core`、`spring-beans`）

---

#### 9.3.5 Spring WS Core 3.1.8（活跃 Starter: `spring-boot-starter-web-services`）

Spring WS Core 及其依赖 `spring-xml` 的缺失依赖如下：

| 来源模块 | 缺失的原始依赖 | Fork 替代 ArtifactId |
| :--- | :--- | :--- |
| `spring-ws-core` | `spring-aop` | `bjca-footstone-bpring-aop` |
| `spring-ws-core` | `spring-beans` | `bjca-footstone-bpring-beans` |
| `spring-ws-core` | `spring-oxm` | `bjca-footstone-bpring-oxm` |
| `spring-ws-core` | `spring-web` | `bjca-footstone-bpring-web` |
| `spring-ws-core` | `spring-webmvc` | `bjca-footstone-bpring-webmvc` |
| `spring-xml` | `spring-beans` | `bjca-footstone-bpring-beans` |
| `spring-xml` | `spring-context` | `bjca-footstone-bpring-context` |

**去重后最小补充集（不使用 Starter 时）：** `bjca-footstone-bpring-webmvc`、`bjca-footstone-bpring-oxm`（`spring-webmvc` 会传递引入 `spring-web`、`spring-context`、`spring-aop`、`spring-beans`、`spring-core`）

> **提示：** 使用 `bjca-footstone-bpring-boot-starter-web-services` 的用户无需额外操作，Starter 已包含所有必要依赖。

---

#### 9.3.6 Spring AMQP 2.4.17 + Spring Rabbit 2.4.17（已排除 Starter: `spring-boot-starter-amqp`）

| 来源模块 | 缺失的原始依赖 | Fork 替代 ArtifactId |
| :--- | :--- | :--- |
| `spring-amqp` | `spring-core` | `bjca-footstone-bpring-core` |
| `spring-rabbit` | `spring-context` | `bjca-footstone-bpring-context` |
| `spring-rabbit` | `spring-messaging` | `bjca-footstone-bpring-messaging` |
| `spring-rabbit` | `spring-tx` | `bjca-footstone-bpring-tx` |

**最小补充集：** `bjca-footstone-bpring-context`、`bjca-footstone-bpring-messaging`、`bjca-footstone-bpring-tx`（`spring-context` 会传递引入 `spring-core`）

---

#### 9.3.7 Spring GraphQL 1.0.6（已排除 Starter: `spring-boot-starter-graphql`）

| 缺失的原始依赖 | Fork 替代 ArtifactId | 说明 |
| :--- | :--- | :--- |
| `spring-context` | `bjca-footstone-bpring-context` | 直接依赖 |
| `spring-aop` | `bjca-footstone-bpring-aop` | 经 `spring-context` 传递 |
| `spring-beans` | `bjca-footstone-bpring-beans` | 经 `spring-context` 传递 |
| `spring-core` | `bjca-footstone-bpring-core` | 经 `spring-context` 传递 |
| `spring-expression` | `bjca-footstone-bpring-expression` | 经 `spring-context` 传递 |

**最小补充集：** `bjca-footstone-bpring-context`

> **注意：** Spring GraphQL 另需 `io.projectreactor:reactor-core` 和 `com.graphql-java:graphql-java`（非 Spring 依赖，BOM 已管理版本）。

---

#### 9.3.8 Spring RESTDocs 2.0.8.RELEASE（无 Starter，通常 test scope）

| 来源模块 | 缺失的原始依赖 | Fork 替代 ArtifactId |
| :--- | :--- | :--- |
| `spring-restdocs-core` | `spring-web` | `bjca-footstone-bpring-web` |
| `spring-restdocs-mockmvc` | `spring-test` | `bjca-footstone-bpring-test` |
| `spring-restdocs-mockmvc` | `spring-webmvc` | `bjca-footstone-bpring-webmvc` |

**最小补充集：** `bjca-footstone-bpring-webmvc`、`bjca-footstone-bpring-test`（scope: test）

> **提示：** Spring RESTDocs 通常仅在测试中使用。如果项目已引入 `bjca-footstone-bpring-boot-starter-web` 和 `bjca-footstone-bpring-boot-starter-test`，则 `spring-web`、`spring-webmvc`、`spring-test` 已被 Starter 传递引入，无需额外添加。

### 9.4 Maven 配置示例

以下示例均假设已通过 Parent POM 或 BOM 导入引入了 `bjca-footstone-bpring-boot-dependencies`，因此 fork 依赖无需声明版本号。

#### 9.4.1 Spring Kafka 使用示例

```xml
<!-- Spring Kafka -->
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>

<!-- 补充被排除的 Spring Framework fork 依赖 -->
<dependency>
    <groupId>cn.bjca.footstone.bpring</groupId>
    <artifactId>bjca-footstone-bpring-context</artifactId>
</dependency>
<dependency>
    <groupId>cn.bjca.footstone.bpring</groupId>
    <artifactId>bjca-footstone-bpring-messaging</artifactId>
</dependency>
<dependency>
    <groupId>cn.bjca.footstone.bpring</groupId>
    <artifactId>bjca-footstone-bpring-tx</artifactId>
</dependency>
```

#### 9.4.2 Spring Batch Core 使用示例（不使用 Starter 时）

```xml
<!-- Spring Batch Core（直接引用底层库） -->
<dependency>
    <groupId>org.springframework.batch</groupId>
    <artifactId>spring-batch-core</artifactId>
</dependency>

<!-- 补充被排除的 Spring Framework fork 依赖（最小集） -->
<dependency>
    <groupId>cn.bjca.footstone.bpring</groupId>
    <artifactId>bjca-footstone-bpring-context</artifactId>
</dependency>
<dependency>
    <groupId>cn.bjca.footstone.bpring</groupId>
    <artifactId>bjca-footstone-bpring-tx</artifactId>
</dependency>
```

> **推荐：** 如无特殊需求，建议直接使用 Starter 方式引入 Spring Batch，更简洁且无需手动补充依赖：
>
> ```xml
> <dependency>
>     <groupId>cn.bjca.footstone.bpring.boot</groupId>
>     <artifactId>bjca-footstone-bpring-boot-starter-batch</artifactId>
> </dependency>
> ```

#### 9.4.3 Spring AMQP + Spring Rabbit 使用示例

```xml
<!-- Spring AMQP -->
<dependency>
    <groupId>org.springframework.amqp</groupId>
    <artifactId>spring-amqp</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.amqp</groupId>
    <artifactId>spring-rabbit</artifactId>
</dependency>

<!-- 补充被排除的 Spring Framework fork 依赖 -->
<dependency>
    <groupId>cn.bjca.footstone.bpring</groupId>
    <artifactId>bjca-footstone-bpring-context</artifactId>
</dependency>
<dependency>
    <groupId>cn.bjca.footstone.bpring</groupId>
    <artifactId>bjca-footstone-bpring-messaging</artifactId>
</dependency>
<dependency>
    <groupId>cn.bjca.footstone.bpring</groupId>
    <artifactId>bjca-footstone-bpring-tx</artifactId>
</dependency>
```

#### 9.4.4 Spring GraphQL 使用示例

```xml
<!-- Spring GraphQL -->
<dependency>
    <groupId>org.springframework.graphql</groupId>
    <artifactId>spring-graphql</artifactId>
</dependency>

<!-- 补充被排除的 Spring Framework fork 依赖 -->
<dependency>
    <groupId>cn.bjca.footstone.bpring</groupId>
    <artifactId>bjca-footstone-bpring-context</artifactId>
</dependency>
```

---

## 10. 注意事项

### 10.1 Java 包名保持不变

NES fork 项目**仅修改了 Maven/Gradle 制品坐标（GAV）**，**不修改任何 Java 包名**。所有源码中的包名依然是：

- `org.springframework.*`
- `org.springframework.boot.*`
- `org.springframework.security.*`

因此，下游项目迁移到 NES 版本后：

- **所有 `import` 语句无需修改**
- **所有 `@Configuration`、`@Bean`、`@Autowired` 等注解使用方式不变**
- **`application.properties` / `application.yml` 中的配置键名不变**
- **`SpringApplication.run()` 等 API 调用方式不变**
- **`META-INF/spring.factories` 自动装配机制完全兼容**

### 10.2 NES 命名含义

**NES = Never-Ending Support**（永续支持）

NES 版本号遵循格式：`{官方基线版本}-nes.patch.{补丁序号}-SNAPSHOT`

示例：
- `2.7.18-nes.patch.1-SNAPSHOT` → 基于官方 Spring Boot 2.7.18，NES 第 1 次补丁
- `5.3.39-nes.patch.1-SNAPSHOT` → 基于官方 Spring Framework 5.3.39，NES 第 1 次补丁

NES 的定位：
- 官方已停止维护（EOL）的版本，由内部团队继续提供**安全补丁和漏洞修复**
- 保证与官方基线版本的**完全 API 兼容性**
- 适用于无法升级到新大版本但仍需安全合规的生产系统

### 10.3 迁移检查清单

从官方 Spring 依赖迁移到 NES 版本时，请按以下清单逐项确认：

| 序号 | 检查项 | 说明 |
| :--- | :--- | :--- |
| 1 | 配置私服仓库地址 | NES 制品发布在内部私服，需在 `settings.xml` 或 `build.gradle` 中添加私服仓库 |
| 2 | 替换 Parent POM 或 BOM | 将 `org.springframework.boot:spring-boot-starter-parent` 替换为 NES 版本 |
| 3 | 替换所有依赖的 GroupId 和 ArtifactId | 按本文档映射表逐一替换（或使用全局查找替换） |
| 4 | 检查 Authorization Server 版本 | 该模块版本独立，需单独声明 |
| 5 | 检查已排除 Starter | 确认是否使用了已排除的 Starter（见第 7 章），如有则需保留官方坐标 |
| 6 | 确认 Java import 无需修改 | 包名不变，无需任何 import 调整 |
| 7 | 运行完整测试套件 | 迁移后执行全量测试确保兼容性 |

### 10.4 常见问题

**Q: 引入 NES BOM 后，是否还需要单独引入 Spring Framework BOM 和 Spring Security BOM？**

A: **不需要**。`bjca-footstone-bpring-boot-dependencies`（Spring Boot BOM）内部已通过 `imports` 方式引入了 Spring Framework BOM 和 Spring Security BOM，下游项目只需引入 Spring Boot BOM 即可。

**Q: 我的项目中某些第三方库传递依赖了官方 `org.springframework` 坐标，会冲突吗？**

A: 会产生坐标冲突。由于 NES 版本使用了不同的 GroupId/ArtifactId，Maven/Gradle 会将其视为不同的依赖。建议在 `dependencyManagement` 中通过 `<exclusions>` 排除第三方库中传递的官方坐标，并显式声明 NES 坐标。

**Q: `SpringBootVersion.getVersion()` 返回什么版本号？**

A: 返回 `2.7.18`（官方基线版本号），不包含 NES 补丁后缀。这是为了保持与官方版本的运行时兼容性。

**Q: Authorization Server 为什么不在 Spring Boot BOM 管控范围内？**

A: Spring Authorization Server 是独立项目，官方原版在 Spring Boot 2.7.x 时代尚未纳入 BOM 统一管理。NES fork 保持了这一独立性，使用者需显式声明其版本号 `0.4.5-nes.patch.1-SNAPSHOT`。

### 10.5 常用依赖坐标速查

以下是最常用的 NES 依赖坐标，可直接复制使用：

```xml
<!-- ==================== Spring Boot Starters ==================== -->

<!-- Web 应用 -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-web</artifactId>
</dependency>

<!-- Security -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-security</artifactId>
</dependency>

<!-- JPA -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- Redis -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-data-redis</artifactId>
</dependency>

<!-- JDBC -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-jdbc</artifactId>
</dependency>

<!-- Validation -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-validation</artifactId>
</dependency>

<!-- Actuator -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-actuator</artifactId>
</dependency>

<!-- Test -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>

<!-- ==================== OAuth2 / Authorization Server ==================== -->

<!-- OAuth2 Client -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-oauth2-client</artifactId>
</dependency>

<!-- OAuth2 Resource Server -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-oauth2-resource-server</artifactId>
</dependency>

<!-- Authorization Server（需显式指定版本） -->
<dependency>
    <groupId>cn.bjca.footstone.bpring.security</groupId>
    <artifactId>bjca-footstone-bpring-security-oauth2-authorization-server</artifactId>
    <version>0.4.5-nes.patch.1-SNAPSHOT</version>
</dependency>
```
