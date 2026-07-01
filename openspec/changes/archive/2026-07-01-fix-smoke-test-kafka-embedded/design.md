## Context

`@EmbeddedKafka` 注解只是声明了一个 embedded Kafka broker，但 Spring Boot test 需要 `@AutoConfigureEmbeddedKafka` 来触发 `EmbeddedKafkaBean` 的自动配置，将 broker 地址注入到 `spring.kafka.bootstrap-servers` property 中。缺少后者时，`spring.embedded.kafka.brokers` 没有被正确填充，测试用空地址连接导致失败。

## Goals / Non-Goals

**Goals:**
- `spring-boot-smoke-test-kafka:test` 在 `make test-feedback` 中通过，不再依赖外部 Kafka broker

**Non-Goals:**
- 不涉及其它 smoke-test 或 core 模块

## Decisions

### 加 `@AutoConfigureEmbeddedKafka`

在 `SampleKafkaApplicationTests` 类上加 `@AutoConfigureEmbeddedKafka`，替代目前的排除策略。

**理由：**
- `@AutoConfigureEmbeddedKafka` 是 Spring Boot 官方提供的配置钩子，正确注入 broker 地址
- 最小改动，单 annotation 解决问题
- 不引入新依赖，`spring-kafka-test` 已在 `build.gradle` 中

## Risks / Trade-offs

- [Risk] `@AutoConfigureEmbeddedKafka` 与 `@EmbeddedKafka` 在某些 Spring Boot 版本可能有兼容性问题 → Mitigation：当前 `spring-kafka-test` 已在依赖中，annotation 组合是标准用法
