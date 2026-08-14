# Quick Start

## 使用 NES Boot BOM

Maven 项目可通过 Parent POM 或 dependencyManagement 引入 NES Spring Boot。

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>cn.bjca.footstone.bpring.boot</groupId>
            <artifactId>bjca-footstone-bpring-boot-dependencies</artifactId>
            <version>2.7.18-nes.patch.2-SNAPSHOT</version>
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
    <artifactId>bjca-footstone-bpring-kafka</artifactId>
</dependency>
```

如需测试支持：

```xml
<dependency>
    <groupId>cn.bjca.footstone.bpring.kafka</groupId>
    <artifactId>bjca-footstone-bpring-kafka-test</artifactId>
    <scope>test</scope>
</dependency>
```

当前私服未发布 `bjca-footstone-bpring-kafka-bom`。版本由 `bjca-footstone-bpring-boot-dependencies` 统一管理。

## 引入 Spring Retry NES

```xml
<dependency>
    <groupId>cn.bjca.footstone.bpring.retry</groupId>
    <artifactId>bjca-footstone-bpring-retry</artifactId>
</dependency>
```

Boot BOM 不再管理官方 `org.springframework.retry:spring-retry`。直接依赖官方 GAV 的消费者必须迁移到上述 NES GAV；Java import 仍保持 `org.springframework.retry.*`。当前 Retry patch.1 和 Kafka patch.2 都是 SNAPSHOT，验收时应刷新依赖并核对实际时间戳，不能据此发布 Boot RELEASE。

## Kafka 与 Elasticsearch 同时使用时的 lz4 排除

NES Boot BOM 将 `at.yawk.lz4:lz4-java` 管理为 1.11.1，并在 NES Elasticsearch 模块上排除旧 `org.lz4:lz4-java`。`spring-boot-starter-data-elasticsearch` 会显式加入替换实现。Maven BOM 仍不能把旧坐标改写成新坐标，因此直接依赖 NES SDE/HLRC、不用 starter 的消费者，在生产者 POM 补上替换依赖之前必须自行排除旧坐标：

```xml
<dependency>
    <groupId>cn.bjca.footstone.blasticsearch</groupId>
    <artifactId>bjca-footstone-blasticsearch</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.lz4</groupId>
            <artifactId>lz4-java</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

推荐优先使用 starter：

```xml
<dependency>
    <groupId>cn.bjca.footstone.bpring.boot</groupId>
    <artifactId>bjca-footstone-bpring-boot-starter-data-elasticsearch</artifactId>
</dependency>
```

执行 `mvn dependency:tree` 后 starter 路径应只看到 `at.yawk.lz4:lz4-java:1.11.1`。Gradle 下游也不会自动继承 NES Boot 源码仓库中的 substitution 规则。

当前 Elasticsearch / Java Client / Barsson / Spring Data patch.2 仍是 SNAPSHOT。请配置 NES snapshots 仓库，并在验收时刷新 changing module。正式 Boot RELEASE 在这些内部依赖变为已验证 RELEASE 之前保持阻断。回滚时需同时恢复官方 Elasticsearch 坐标、Jakarta JSON-P 1.1.6 禁止规则、Spring Data patch.1 和 starter 依赖，不要只换单个 JAR。

## JSON-P 双轨

`javax.json.*` 必须使用 `javax.json:javax.json-api`（Johnzon / JSON-B 路径）。即使旧依赖写的是 `jakarta.json:jakarta.json-api:1.1.6`，也不要继续用这个 1.1.x 别名。NES Elasticsearch Java Client 使用 `jakarta.json.*`，必须解析到 `jakarta.json:jakarta.json-api:2.0.2` 和 `cn.bjca.footstone.barsson:bjca-footstone-barsson`。禁止同时引入 Parsson 与 Barsson。

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
    implementation platform("cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-dependencies:2.7.18-nes.patch.2-SNAPSHOT")
    implementation "cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-reactor-netty"
}
```

下游只需配置 NES Nexus，不需要复制 Spring Boot 源码仓库中的 `resolutionStrategy`。最终依赖应解析为 Reactor Netty NES `1.0.48-nes.patch.1` 和 Netty `4.1.136.Final`。

> 安全提示：生产者 commit `da3c7cf2` 已修复 CVE-2025-22227、CVE-2026-41715；Nexus HTTP 制品 `20260722.053243-4` 已验证包含跨 origin 和 HTTPS→HTTP 降级剥头逻辑。当前版本仍为 SNAPSHOT，首次使用和升级验收时请强制刷新依赖并核对实际解析时间戳。
