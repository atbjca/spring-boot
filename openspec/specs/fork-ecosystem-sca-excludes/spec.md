## ADDED Requirements

### Requirement: A 类生态组件排除官方 Spring 传递依赖

对 `spring-boot-dependencies/build.gradle` 中使用显式 `modules` 且尚未 fork 的 A 类 Spring 生态库（GraphQL、HATEOAS、Kafka、LDAP、Retry），MUST 在每个 managed module 上声明 `exclude group: "org.springframework", module: "*"`，使下游通过 Boot BOM 引入时不传递官方 `org.springframework:*` 坐标。

#### Scenario: spring-kafka managed dependency 含 exclusion
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** `org.springframework.kafka:spring-kafka` 的 dependencyManagement 条目包含 exclusion `org.springframework:*`

#### Scenario: 消费者仍解析 fork Framework
- **WHEN** 子模块声明 `org.springframework.kafka:spring-kafka` 且根 `resolutionStrategy` 已配置 Framework 映射
- **THEN** 编译 classpath 中 spring-context 解析为 `cn.bjca.footstone.bpring:bjca-footstone-bpring-context`
