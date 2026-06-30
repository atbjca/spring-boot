## ADDED Requirements

### Requirement: Framework 依赖透明映射

根 `build.gradle` 的 `resolutionStrategy.eachDependency` MUST 包含规则：当 `requested.group == 'org.springframework'` 且 `requested.name.startsWith('spring-')` 时，将依赖替换为 `${forkGroupIdBase}:${forkArtifactPrefix}-<module>:${springFrameworkVersion}`，其中 `<module>` 为原 artifactId 去掉 `spring-` 前缀后的部分。

#### Scenario: spring-context 解析为 fork 坐标
- **WHEN** 任意子模块声明 `org.springframework:spring-context`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring:bjca-footstone-bpring-context:6.2.19-nes.patch.1-SNAPSHOT`

#### Scenario: spring-framework-bom 解析为 fork BOM
- **WHEN** 构建脚本引用 `org.springframework:spring-framework-bom`
- **THEN** Gradle 解析结果为 `cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1-SNAPSHOT`

### Requirement: Framework BOM 条目使用 fork 坐标

`spring-boot-dependencies/build.gradle` 中 Spring Framework library 条目 MUST 使用 `group(forkGroupIdBase)` 并通过 `imports` 引入 `${forkArtifactPrefix}-framework-bom`，不再引用 `org.springframework` groupId。

#### Scenario: BOM 中 Framework groupId 为 fork
- **WHEN** 生成 `spring-boot-dependencies` POM
- **THEN** Framework 相关 managed dependency 的 groupId 为 `cn.bjca.footstone.bpring`

### Requirement: buildSrc 使用 fork Framework 坐标

`buildSrc/build.gradle` MUST 将 `org.springframework:spring-framework-bom` 及 `spring-context` / `spring-core` / `spring-web` / `spring-test` 依赖替换为对应的 fork 坐标，不依赖根项目 resolutionStrategy。

#### Scenario: buildSrc 编译使用 fork Framework
- **WHEN** 执行 `./gradlew :buildSrc:compileJava`
- **THEN** compileClasspath 中 spring-core 的 groupId 为 `cn.bjca.footstone.bpring`
