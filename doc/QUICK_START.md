# Quick Start

## 使用 NES Boot BOM

Maven 项目可通过 Parent POM 或 dependencyManagement 引入 NES Spring Boot。

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
