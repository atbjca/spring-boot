# User Manual

## Reactor Netty NES

NES Spring Boot 的响应式 HTTP starter 已直接发布 Reactor Netty NES 坐标：

| 模块 | GroupId | ArtifactId | 版本 |
|------|---------|------------|------|
| 聚合模块 | `cn.bjca.footstone.beactor.netty` | `bjca-footstone-beactor-netty` | `1.0.48-nes.patch.1` |
| Core | `cn.bjca.footstone.beactor.netty` | `bjca-footstone-beactor-netty-core` | 同上 |
| HTTP | `cn.bjca.footstone.beactor.netty` | `bjca-footstone-beactor-netty-http` | 同上 |
| HTTP Brave | `cn.bjca.footstone.beactor.netty` | `bjca-footstone-beactor-netty-http-brave` | 同上 |

业务代码仍使用 `reactor.netty.*` package，无需修改 import。Netty 由 NES Boot BOM 统一管理为 `4.1.136.Final`；官方 Reactor BOM 继续管理 `reactor-core`，不能用它管理新的 NES Reactor Netty group。

下游必须配置 NES Nexus public/snapshots 仓库。当前使用可变 SNAPSHOT，升级或验收时应刷新依赖缓存。Spring Boot 内部的 `resolutionStrategy` 不会传播到下游，Maven/Gradle 用户应通过 NES Boot starter/BOM 或直接使用上表 GAV。

生产者源码 commit `da3c7cf2` 已修复 `CVE-2025-22227` 与 `CVE-2026-41715`。Boot 使用全新 Maven 本地仓库验证 Nexus HTTP 制品 `20260722.053243-4` 已包含 `UriEndpoint.isSecure()` 降级剥头分支，源码、测试和制品证据均已闭环。由于当前仍使用 SNAPSHOT，下游验收和升级时必须强制刷新并核对实际解析时间戳，避免旧缓存回退到修复前制品。

若需回滚，应同时恢复官方 Reactor Netty HTTP 坐标、BOM 管理语义和 Netty 版本。不要只替换单个 JAR，否则可能形成官方/NES双份 classpath。

## c3p0 0.14.0 迁移说明

NES Boot 当前管理 `com.mchange:c3p0:0.14.0`，其传递依赖为 `com.mchange:mchange-commons-java:0.6.0`。Spring Boot 的 `DataSourceBuilder` 和 Hibernate 5.6 c3p0 provider 已完成兼容验证。

c3p0 0.14.0 移除了部分旧 API，例如 `PoolConfig`。通过 Spring Boot 标准数据源配置使用 c3p0 的应用无需改动；直接编译调用已移除 API 的应用需按 c3p0 上游 API 迁移，NES Boot 不提供兼容回填。

## lz4-java 1.11.1 与 Elasticsearch 排除

NES Boot BOM 管理 `at.yawk.lz4:lz4-java:1.11.1`，用于覆盖 Kafka Client 声明的旧 fork 版本，并在 NES Elasticsearch 生产模块上排除 `org.lz4:lz4-java`。`bjca-footstone-bpring-boot-starter-data-elasticsearch` 会显式加入替换实现。Spring Boot 源码仓库内部还配置了 Gradle substitution；这条规则**不会传播给下游**。

Maven BOM 只能管理同一坐标的版本，不能把 `org.lz4:lz4-java` 改成 `at.yawk.lz4:lz4-java`。直接依赖 NES SDE 或 HLRC、不走 starter 的消费者，在 Elasticsearch 生产者 POM 发布替换依赖之前仍须自行排除旧坐标：

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

如果 Elasticsearch 由 starter 引入，starter 已带替换依赖。验收时执行 `mvn dependency:tree`，starter 路径最终只能出现 `at.yawk.lz4:lz4-java:1.11.1`。

下游 Gradle 应用可使用等价 substitution，或在 Elasticsearch 路径排除旧坐标：

```groovy
configurations.all {
    resolutionStrategy.dependencySubstitution {
        substitute module("org.lz4:lz4-java") using module("at.yawk.lz4:lz4-java:1.11.1")
    }
}
```

CVE-2026-59949 只影响 JNI XXHash 且要求攻击者能控制数组引用、offset 或 length；仅控制合法数组内容不受影响。无论是否使用 native 实现，仍建议统一升级到 1.11.1。

## JSON-P 双轨与 Elasticsearch NES

Boot / Johnzon / JSON-B 继续使用 `javax.json.*`，依赖 `javax.json:javax.json-api`。NES Java API Client 使用 `jakarta.json.*`，依赖 `jakarta.json:jakarta.json-api:2.0.2` 和 NES Barsson。旧坐标 `jakarta.json:jakarta.json-api:1.1.6` 只是 javax API 的别名，不能再当作运行时。Java import 保持 `org.elasticsearch.*`。

当前 Elasticsearch 闭包、Barsson 和 Spring Data patch.2 仍是 SNAPSHOT。下游必须配置 NES Nexus public/snapshots 仓库，升级或验收时刷新依赖缓存。正式 Boot RELEASE 在这些内部 SNAPSHOT 清零之前保持阻断。回滚需同时恢复官方 Elasticsearch 管理块、Jakarta JSON-P 1.1.6 禁止规则、Spring Data patch.1 和 starter 依赖。

## Spring Retry NES 坐标与迁移

NES Boot BOM 只管理以下 Retry 坐标：

```xml
<dependency>
    <groupId>cn.bjca.footstone.bpring.retry</groupId>
    <artifactId>bjca-footstone-bpring-retry</artifactId>
</dependency>
```

官方 `org.springframework.retry:spring-retry` 不再由 BOM 管理，这是有意的 GAV 迁移断点。Java 包名不变，业务源码中的 `import org.springframework.retry.*` 无需修改。`bjca-footstone-bpring-boot-starter-batch` 已直接提供 NES Retry；直接组合 Spring Batch、AMQP 或 Integration 底层模块的 Maven 应用必须避免重新引入官方 Retry。

当前版本为 `1.3.4-nes.patch.1-SNAPSHOT`，已验证时间戳 `20260810.073226-2` 和 Java 8 variant。容量为 2 的 LRU 回归证明访问 A 后插入 C 会保留 A/C、驱逐 B且不抛容量异常。由于 RELEASE 尚未发布，CVE-2026-41710 状态仅为“⚠️已缓解”；升级或验收时必须刷新 changing module，并限制攻击者可控的有状态重试 key。

## Spring Kafka NES 坐标

Spring Kafka NES 分支使用以下 Maven 坐标：

| 用途 | GroupId | ArtifactId | 版本 |
|------|---------|------------|------|
| 主模块 | `cn.bjca.footstone.bpring.kafka` | `bjca-footstone-bpring-kafka` | `2.9.13-nes.patch.2-SNAPSHOT` |
| 测试模块 | `cn.bjca.footstone.bpring.kafka` | `bjca-footstone-bpring-kafka-test` | `2.9.13-nes.patch.2-SNAPSHOT` |

Java 包名不变，业务代码中的 `import org.springframework.kafka.*` 无需修改。

## 传递依赖说明

Spring Kafka NES POM 仍包含官方 Spring Framework 传递依赖。NES Boot BOM 已排除这些官方 `org.springframework:*` 坐标，避免与 NES Spring Framework 混用。

如果项目直接使用 Spring Kafka 且没有通过 Starter 获得相关 Spring Framework 模块，请按 `doc/NES_GAV_MAPPING.md` 的 Spring Kafka 小节补充 `bjca-footstone-bpring-context`、`bjca-footstone-bpring-messaging`、`bjca-footstone-bpring-tx` 等依赖。

## 不存在的 Kafka BOM

当前私服未发布 `cn.bjca.footstone.bpring.kafka:bjca-footstone-bpring-kafka-bom`。请通过 NES Spring Boot BOM 管理 Spring Kafka 版本，不要单独导入 Kafka BOM。

## Kafka Header 反序列化安全配置

Spring Kafka NES commit `c119b8f62` 已回移 CVE-2026-41731 修复。`DefaultKafkaHeaderMapper` 现在仅按**精确包名**判断受信类型，父包不再自动信任子包。

例如，仅配置：

```java
mapper.addTrustedPackages("com.example");
```

只会信任直接声明在 `com.example` 包中的类型，不会继续信任 `com.example.events.OrderEvent`。需要显式列出实际使用的子包：

```java
mapper.addTrustedPackages(
		"com.example",
		"com.example.events",
		"com.example.shared");
```

不要使用 `addTrustedPackages("*")` 代替迁移。该配置会显式信任所有类型，只适用于 Producer 和 Topic 写权限完全可信的环境。

当前 Boot 管理可变版本 `2.9.13-nes.patch.2-SNAPSHOT`。已验证的安全时间戳为 `20260814.020248-2`；旧构建环境可能缓存不同内容的同版本 JAR，升级或发布前应刷新 changing module 并运行 Kafka 安全回归测试。
