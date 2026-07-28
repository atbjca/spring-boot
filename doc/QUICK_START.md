# Quick Start

## 使用 NES Boot BOM

Maven 项目可通过 Parent POM 或 dependencyManagement 引入 NES Spring Boot。

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>cn.bjca.footstone.bpring.boot</groupId>
            <artifactId>bjca-footstone-bpring-boot-dependencies</artifactId>
            <version>2.7.18-nes.patch.1</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

## 引入 Spring Kafka NES

```xml
<dependency>
    <groupId>cn.bjca.footstone.bpring.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```

如需测试支持：

```xml
<dependency>
    <groupId>cn.bjca.footstone.bpring.kafka</groupId>
    <artifactId>spring-kafka-test</artifactId>
    <scope>test</scope>
</dependency>
```

当前私服未发布 `bjca-footstone-bpring-kafka-bom`。版本由 `bjca-footstone-bpring-boot-dependencies` 统一管理。

## 引入 Reactor Netty NES

推荐通过 NES WebFlux starter 间接使用：

```xml
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-webflux</artifactId>
</dependency>
```

如只需要响应式 HTTP 引擎：

```xml
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-reactor-netty</artifactId>
</dependency>
```

Gradle：

```groovy
dependencies {
    implementation platform("cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-dependencies:2.7.18-nes.patch.1")
    implementation "cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-reactor-netty"
}
```

下游只需配置 NES Nexus，不需要复制 Spring Boot 源码仓库中的 `resolutionStrategy`。最终依赖应解析为 Reactor Netty NES `1.0.48-nes.patch.1` 和 Netty `4.1.136.Final`。

> 安全提示：生产者 commit `da3c7cf2` 已修复 CVE-2025-22227、CVE-2026-41715；Nexus HTTP 制品 `20260722.053243-4` 已验证包含跨 origin 和 HTTPS→HTTP 降级剥头逻辑。当前版本仍为 SNAPSHOT，首次使用和升级验收时请强制刷新依赖并核对实际解析时间戳。
