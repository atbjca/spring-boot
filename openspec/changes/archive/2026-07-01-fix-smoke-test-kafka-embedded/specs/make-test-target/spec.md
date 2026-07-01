# make-test-target Specification Delta

## MODIFIED Requirements

### Requirement: smoke-test-kafka 显式排除

~~`spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test` MUST 在 `test-feedback` 的 `-x` 排除清单中~~

`spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test` 已通过 `@AutoConfigureEmbeddedKafka` 修复，不再需要排除。

#### Scenario: smoke-test-kafka 恢复正常覆盖
- **WHEN** `make test-feedback` 执行
- **AND** `spring-boot-smoke-test-kafka` 未被 `-x` 排除
- **THEN** `SampleKafkaApplicationTests` 全部通过（含 `testVanillaExchange`）
- **AND** `make test-feedback` 不因 kafka 而失败
