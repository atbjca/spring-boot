# Spring Boot 项目 Group ID 动态更名维护手册

## 1. 核心原理 (The Big Picture)

本项目已实现“一键全链路更名”能力。当您在根目录修改了 `group` 属性（如改为 `com.yourcompany.boot`）时，系统会自动同步以下三个关键环节：

1.  **BOM (Bill of Materials)**：`spring-boot-dependencies` 会动态引用当前 group。
2.  **父 POM (Starter Parent)**：确保 Maven 能够识别并执行自定义插件的 `repackage` 任务。
3.  **插件自述 (Plugin Descriptor)**：`spring-boot-maven-plugin` 内部的 `plugin.xml` 会自动更新。

---

## 2. 常见报错及排查 (Troubleshooting)

### 现象 A：生成的 JAR 包只有 3KB (太小)
*   **症状**：构建成功，但在 `target` 目录下生成的包远小于 10MB。
*   **原因**：Maven 没能将您的插件与父 POM 定义的 `repackage` 任务匹配上。
*   **检查点**：检查 `spring-boot-project/spring-boot-starters/spring-boot-starter-parent/build.gradle` 里的生成逻辑，确保第 153 行附近的 `groupId` 是动态引用的 `${project.group}`。

### 现象 B：报错 `Invalid plugin descriptor ... wrong group ID`
*   **症状**：Maven 运行报错，指出插件内部的 `plugin.xml` 声明的名字与实际不符。
*   **原因**：插件内部的 POM 模板未更新。
*   **检查点**：
    1.  确认 `spring-boot-project/spring-boot-tools/spring-boot-maven-plugin/build.gradle` 末尾是否有 `syncPluginPomGroupId` 任务及其 `dependsOn` 钩子。
    2.  运行一遍 `./gradlew :spring-boot-project:spring-boot-tools:spring-boot-maven-plugin:jar`，看控制台是否输出了“成功同步...”的日志。

---

## 3. 自动化机制背后的“守门员”

为了绕过复杂的 Java 格式校验并实现自动化，我们采用了以下机制：

### `syncPluginPomGroupId` 自动化任务
位于：[spring-boot-maven-plugin/build.gradle](file:///Volumes/LIBIAO_EX/dev/GitHub/spring-boot-2.7/spring-boot-project/spring-boot-tools/spring-boot-maven-plugin/build.gradle)

这个脚本会在您每次打包前，自动读取并修改：
`spring-boot-tools/spring-boot-maven-plugin/src/maven/resources/pom.xml`

**它的工作流程：**
1.  读取 `pom.xml` 模板内容。
2.  匹配 `<groupId>...</groupId>`。
3.  强制将其内容替换为当前项目的 `project.group` 值。
4.  写回文件。

---

## 4. 手动修复紧急方案
如果自动化脚本失效（例如您删除了钩子），以下是手动对齐的步骤：

1.  **步骤 1**：打开 [spring-boot-maven-plugin/src/maven/resources/pom.xml](file:///Volumes/LIBIAO_EX/dev/GitHub/spring-boot-2.7/spring-boot-project/spring-boot-tools/spring-boot-maven-plugin/src/maven/resources/pom.xml)。
2.  **步骤 2**：手动将 `<groupId>` 标签里的名字改成您在根目录定义的那个名字。
3.  **步骤 3**：重新运行 `./gradlew install` 或打包任务。

---

## 5. 设计初衷：为什么不改 Java 代码？
本项目内嵌了 `io.spring.javaformat` 代码格式校验。修改 `buildSrc` 里的 Java 代码极其容易导致触发不一致的格式报错（例如 TAB 与空格的差异）。

因此，**“通过 Gradle 脚本动态同步资源文件”** 是目前最稳定、维护成本最低的方案。
