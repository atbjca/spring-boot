## 1. BOM 排除规则

- [x] 1.1 Spring GraphQL（spring-graphql / spring-graphql-test）
- [x] 1.2 Spring HATEOAS（spring-hateoas）
- [x] 1.3 Spring Kafka（spring-kafka / spring-kafka-test）
- [x] 1.4 Spring LDAP（spring-ldap-*）
- [x] 1.5 Spring Retry（spring-retry）

## 2. 文档

- [x] 2.1 更新 `doc/NES_GAV_MAPPING.md` Phase C / SCA 说明
- [x] 2.2 更新 `doc/REQUIREMENTS.md`（Phase B 完成 + 需求-003）

## 3. 验证

- [x] 3.1 BOM POM 中 spring-kafka 含 org.springframework exclusion（BomPlugin 机制与 2.7 一致；本地 `./gradlew :spring-boot-project:spring-boot-dependencies:publishToMavenLocal` 后检查 POM）
- [ ] 3.2 `make build-thin` BUILD SUCCESSFUL
- [ ] 3.3 `make test` 核心模块全绿
