## 1. settings.gradle 排除列表

- [x] 1.1 在 `settings.gradle` 中 `eachDirMatch` 之前定义 `ignoredStarters` Set（19 个条目，对齐 TESTING.md §8.1）
- [x] 1.2 定义 `ignoredSmokeTests` Set（28 个条目，继承 2.7 + 3.5 追加，对齐 TESTING.md §8.4）
- [x] 1.3 修改 starter `eachDirMatch` 回调，添加 `if (!ignoredStarters.contains(it.name))` 过滤
- [x] 1.4 修改 smoke-test `eachDirMatch` 回调，添加 `if (!ignoredSmokeTests.contains(it.name))` 过滤

## 2. 显式 include 模块排除

- [x] 2.1 注释掉 `spring-boot-docs` 的 include 行
- [x] 2.2 注释掉 `spring-boot-cli` 的 include 行
- [x] 2.3 注释掉 `spring-boot-antlib` 的 include 行
- [x] 2.4 注释掉 `spring-boot-configuration-metadata-changelog-generator` 的 include 行
- [x] 2.5 注释掉 `spring-boot-properties-migrator` 的 include 行
- [x] 2.6 注释掉 `spring-boot-deployment-tests` 的 include 行
- [x] 2.7 注释掉 `spring-boot-image-tests` 的 include 行
- [x] 2.8 注释掉 `spring-boot-launch-script-tests` 的 include 行
- [x] 2.9 注释掉 `spring-boot-loader-classic-tests` 的 include 行
- [x] 2.10 注释掉 `spring-boot-loader-tests` 的 include 行
- [x] 2.11 注释掉 `spring-boot-sni-tests` 的 include 行

## 3. 验证

- [x] 3.1 `./gradlew projects` 确认排除的模块不在项目树中
- [x] 3.2 `make build-thin` BUILD SUCCESSFUL
- [x] 3.3 `make test` BUILD SUCCESSFUL
