## 1. Add smoke-test-kafka to exclusion list

- [x] 1.1 In root `Makefile`, add `-x :spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test` to `test-feedback` target's exclusion list
- [x] 1.2 Add single-line comment for the new exclusion: `#   (S) smoke-tests 需外部组件：spring-boot-smoke-test-kafka（testVanillaExchange 需真实 Kafka broker）`

## 2. Update S class comment in Makefile

- [x] 2.1 In `test-feedback` target comment, update (S) line to note `spring-boot-smoke-test-kafka` is explicitly excluded

## 3. Sync delta spec to main spec

- [x] 3.1 Merge delta spec into `openspec/specs/make-test-target/spec.md`

## 4. Verify

- [x] 4.1 Makefile 已更新，-x 清单追加 `:spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test`
