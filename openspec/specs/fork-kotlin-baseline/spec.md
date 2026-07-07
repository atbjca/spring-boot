## ADDED Requirements

### Requirement: Kotlin 编译基线以 gradle.properties 单一来源为准

fork 分支 SHALL 在 `gradle.properties` 中以 `kotlinVersion=<version>` 作为 Kotlin 版本的唯一来源。所有 Kotlin 相关构件（`kotlin-gradle-plugin`、`kotlin-compiler-embeddable`、`kotlin-stdlib` 等）MUST 通过 `${versions.kotlin}` 或等价机制解析同一个版本号；MUST NOT 在任何 `build.gradle` / `buildSrc` 中硬编码 Kotlin 版本字符串。

#### Scenario: 抬升 Kotlin 版本
- **WHEN** 维护者需要抬升 Kotlin 版本（例如为覆盖 CVE 或让第三方 kotlin_module 二进制兼容）
- **THEN** 只需修改 `gradle.properties` 的 `kotlinVersion` 一处，构建即应识别一致；若存在硬编码，视为违反本要求

#### Scenario: fork 与上游对齐审计
- **WHEN** 审计 fork 与上游 Spring Boot 2.7.x 的 Kotlin 版本差异
- **THEN** 只需比对 `gradle.properties` 的 `kotlinVersion` 一行即可得到完整答案

### Requirement: KotlinConventions 的 languageVersion/apiVersion MUST 与 kotlinVersion 兼容

fork 分支 SHALL 保证 `buildSrc/src/main/java/org/springframework/boot/build/KotlinConventions.java` 中配置的 `apiVersion` 与 `languageVersion` 在当前 `kotlinVersion` 的编译器**支持范围**之内。当抬升 `kotlinVersion` 时，如果新版本不再支持此前配置的 language/api version，MUST 在同一次 change 中同步抬升 language/api version（或以 design.md 明示地降级到新编译器仍支持的最低档）。

#### Scenario: kotlinVersion 抬升后 languageVersion 失配
- **WHEN** 执行 `./gradlew clean compileKotlin` 且编译器输出 `Language version X is no longer supported`
- **THEN** 视为违反本要求；必须在同一次 change 中修正 `KotlinConventions` 与 `kotlinVersion` 的匹配关系

### Requirement: jackson-module-kotlin 版本策略必须显式登记

fork 分支 SHALL 在 `spring-boot-project/spring-boot-dependencies/build.gradle` 中就 `jackson-module-kotlin` 的版本策略给出**显式说明**——要么设 `strictly` 约束（当 `kotlinVersion` 不能满足 jackson-module-kotlin 主版本的 Kotlin 最低要求时），要么明确注释说明"随 `jacksonVersion` 由 jackson-bom 统一管理"（当 `kotlinVersion` 已满足最低要求时）。策略变更 MUST 与 `kotlinVersion` 抬升在同一次 change 中一并提交。

#### Scenario: 抬升 kotlinVersion 但遗漏 jackson 约束调整
- **WHEN** 抬升 `kotlinVersion` 越过 jackson-module-kotlin 的 Kotlin 门槛（例如 1.6→1.9 越过 2.17 门槛），但 `spring-boot-dependencies/build.gradle` 中的注释仍描述旧策略
- **THEN** 视为违反本要求，change 不可归档

#### Scenario: 引入新的 jackson-module-kotlin 二进制不兼容
- **WHEN** 未来某次 Jackson 抬升引入了 fork 当前 `kotlinVersion` 不支持的 metadata 版本
- **THEN** 必须要么再抬升 `kotlinVersion`（走本 capability 的正常流程），要么重新加回 `strictly` 约束把 jackson-module-kotlin 钉在最后一个兼容版本

### Requirement: Kotlin 版本抬升必须留痕于 fork 文档

fork 分支 SHALL 在每次 `kotlinVersion` 变化时同步更新 `doc/COMPONENTS_UPGRADE_HISTORY.md`（登记升级前后版本、日期、动因），以及在动因是 CVE 时同步更新 `doc/VULNERABILITY_REPORT.md` 及 `doc/CVE/` 下相关条目。

#### Scenario: 提交 Kotlin 版本抬升但未更新文档
- **WHEN** 一次 commit 修改了 `gradle.properties` 的 `kotlinVersion` 却未同步修改 `doc/COMPONENTS_UPGRADE_HISTORY.md`
- **THEN** 视为违反本要求；PR/change 不可合并

### Requirement: Kotlin 抬升必须在离线状态下通过 make clean test-feedback 的编译阶段

fork 分支 SHALL 保证 `kotlinVersion` 抬升后，执行 `make clean test-feedback`（对应 `./gradlew -Dorg.gradle.caching=false clean` + 全量 `test --continue`）时，所有模块的 `compileKotlin` / `compileTestKotlin` / `compileJava` 任务通过；不得依赖增量编译缓存来掩盖二进制兼容问题。

#### Scenario: 依赖缓存掩盖的 Kotlin metadata 冲突
- **WHEN** 抬升 `kotlinVersion` 后仅跑增量 `./gradlew test` 通过、但 `make clean test-feedback` 在 `compileKotlin` 阶段爆出 `Module was compiled with an incompatible version of Kotlin`
- **THEN** 视为违反本要求；抬升不可视为完成，须在同一 change 内解决二进制不兼容再归档
