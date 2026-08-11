## Purpose

Define consistent Spring Boot fork groupId, artifactId, project naming, publication metadata, and Java namespace preservation.

## Requirements

### Requirement: Boot 模块全局 groupId

根 `build.gradle` 的 `allprojects` 块 MUST 设置：

```groovy
group "${forkGroupIdBase}.boot"
```

所有 Boot 子模块发布的 groupId MUST 为 `cn.bjca.footstone.bpring.boot`。

#### Scenario: 子模块 groupId 正确
- **WHEN** 执行 `./gradlew :spring-boot-project:spring-boot:properties` 并查看 `group`
- **THEN** `group` 等于 `cn.bjca.footstone.bpring.boot`

### Requirement: settings.gradle 项目名动态替换

`settings.gradle` MUST：
- 设置 `rootProject.name = "${forkArtifactPrefix}-boot-build"`
- 遍历 `rootProject.children` 将项目名中 `spring-boot` 替换为 `${forkArtifactPrefix}-boot`

物理目录名 MUST 保持 `spring-boot-*` 不变。

#### Scenario: Gradle 项目名使用 fork 前缀
- **WHEN** 执行 `./gradlew projects`
- **THEN** 根项目名包含 `bjca-footstone-bpring-boot-build`
- **AND** 子项目名形如 `bjca-footstone-bpring-boot-starter-web`（非 `spring-boot-starter-web`）

### Requirement: DeployedPlugin artifactId 显式设置

`buildSrc/.../DeployedPlugin.java` MUST 在创建 `MavenPublication` 后检查 `forkArtifactPrefix` 属性，若存在则将 `artifactId` 设为 `project.name.replace("spring-boot", forkArtifactPrefix + "-boot")`。所有生成的 Spring Boot fork publications MUST inherit the single root project version and MUST NOT declare a module-specific version override.

#### Scenario: 发布制品 artifactId 使用 fork 命名和当前 snapshot 版本
- **WHEN** 为 `:spring-boot-project:spring-boot-starter-web` 生成 Maven publication metadata
- **THEN** GAV 为 `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-web:3.5.15-nes.patch.2-SNAPSHOT`
- **AND** artifactId 不以 `spring-boot-` 开头
- **AND** version 来自根 `gradle.properties` 的单一 `version` 属性

### Requirement: BOM 与 Maven 插件 groupId 动态传播

`BomPlugin.java` 和 `MavenPluginPlugin.java` MUST 将硬编码的 `org.springframework.boot` groupId 替换为 `${project.group}` 或等效动态引用，确保 `spring-boot-dependencies` BOM 和 Maven 插件描述符使用 fork groupId。

#### Scenario: BOM 文件 groupId 正确
- **WHEN** 生成 `spring-boot-dependencies` 的 POM
- **THEN** POM 中 `<groupId>` 为 `cn.bjca.footstone.bpring.boot`
- **AND** 管理的 Boot 组件 groupId 均为 `cn.bjca.footstone.bpring.boot`

### Requirement: buildSrc 独立构建兼容

`buildSrc/build.gradle` MUST 能独立编译，不依赖根项目 `resolutionStrategy`。若 buildSrc 引用 Spring Framework 依赖，Phase A 可继续使用官方坐标（buildSrc 不受 fork 映射影响）。

#### Scenario: buildSrc 编译成功
- **WHEN** 执行 `./gradlew :buildSrc:build` 或触发任意需要 buildSrc 的任务
- **THEN** buildSrc 编译无错误

### Requirement: Java 包名不变

所有 GAV rebranding MUST NOT 修改任何 `org.springframework.*` Java 包名、类名或 `META-INF` 资源路径。

#### Scenario: 源码包名未变
- **WHEN** 检查任意 `src/main/java` 文件的 package 声明
- **THEN** package 仍以 `org.springframework` 开头
