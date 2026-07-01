## 1. Fix flaky test

- [x] 1.1 In `TomcatReactiveWebServerFactoryTests.java`, change `sslWithValidAlias()` method's annotation from `@Test` to `@RepeatedTest(10)`
- [x] 1.2 Verify the fix by running `./gradlew :spring-boot-project:spring-boot:test --tests "TomcatReactiveWebServerFactoryTests.sslWithValidAlias"` and confirming all 10 iterations pass

## 2. Update Makefile documentation

- [x] 2.1 In root `Makefile`, update the `test` target comment to add `TomcatReactiveWebServerFactoryTests.sslWithValidAlias` to the known flaky/E-class list, noting it is handled via `@RepeatedTest(10)`
