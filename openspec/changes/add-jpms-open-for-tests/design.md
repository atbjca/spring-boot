## Context

`add-makefile-test-target` 完成后，`make test` 在 `spring-boot` 主模块 369 条 D 类失败保持，集中在 `web.embedded.{tomcat,jetty,undertow}.*ServletWebServerFactoryTests` 整组。

实地调查发现：
- `spring-boot-project/spring-boot/build.gradle:195-197` **已写**：
  ```groovy
  toolchain {
      testJvmArgs.add("--add-opens=java.base/java.net=ALL-UNNAMED")
  }
  ```
- 但 `buildSrc` 的 `ToolchainPlugin.configureToolchain` 第 45-46 行判定：
  ```java
  JavaLanguageVersion toolchainVersion = toolchain.getJavaVersion();
  if (toolchainVersion != null) {
      project.afterEvaluate((evaluated) -> configure(evaluated, toolchain));
  }
  ```
- 而 `ToolchainExtension` 的 `javaVersion` **只在通过 `-PtoolchainVersion=X` 显式传入时**才非 null。默认 `./gradlew test` 不传该属性，于是 `testJvmArgs` 完全不应用到 Test 任务。
- Stack trace 直接验证：`InaccessibleObjectException ... module java.base does not "opens java.net" to unnamed module`，来自 `DirtiesUrlFactoriesExtension.reset` 通过反射改 `URL.factory` 字段。

约束：
- 不动 `src/main/java` 业务源码（fork 一直以来的约束）。
- 可改 `build.gradle`（用户在归档前 propose 阶段已接受 D 类必须改 build.gradle，本次 change 的整体意图就是修 build.gradle）。
- 仅动 `spring-boot` 模块自身的 `build.gradle`，不动 `buildSrc/ToolchainPlugin`（保持 upstream 设计原状以便未来 merge）。

全仓库 `testJvmArgs` 唯一用法是 spring-boot/build.gradle 第 196 行；没有其它模块依赖 `ToolchainPlugin.configureTestToolchain` 的副作用，因此本变更只影响 spring-boot 模块。

## Goals / Non-Goals

**Goals:**
- 让 `make test` 在不传 `-PtoolchainVersion` 的默认场景下，spring-boot 模块的 Test 任务 JVM 获得 `--add-opens=java.base/java.net=ALL-UNNAMED`。
- 该模块 `*ServletWebServerFactoryTests`（tomcat/jetty/jetty10/undertow + Reactive 变种）从失败转为通过。
- 既有 `toolchain { testJvmArgs.add(...) }` 块保留，保持 `-PtoolchainVersion=X` 场景下行为兼容（同参数即使被加两次，JVM 仍正常启动）。
- 更新归档变更 `add-makefile-test-target` 的 `make-test-target` capability 的 spec：在"已知失败分类"段落中删除 D 类，残留数字下调约 369 条。

**Non-Goals:**
- 不改 `buildSrc/`（不修 `ToolchainPlugin` 的条件判断，保持与 upstream 一致）。
- 不动其它模块的 `build.gradle`。
- 不引入或移除 `-PtoolchainVersion` 相关用法。
- 不解决 G/E/S 三类残留（各自独立 change 处理）。
- 不动 src/main 业务源码。

## Decisions

### Decision 1：在 spring-boot/build.gradle 增加无条件的 `tasks.named('test')` 配置块

新增一段（紧贴现有 `toolchain {}` 块之后）：

```groovy
// FORK: 直接给默认 ./gradlew test 任务加 --add-opens，绕过 ToolchainPlugin 仅在
// -PtoolchainVersion=X 场景下激活 testJvmArgs 的限制。原 toolchain {} 块保留
// 以兼容传入 -PtoolchainVersion 的场景（JVM 接受重复 --add-opens，无副作用）。
tasks.named('test').configure {
    jvmArgs '--add-opens=java.base/java.net=ALL-UNNAMED'
}
```

**理由：**
- 修改聚焦在唯一受影响模块。
- 不改 `buildSrc`，未来 merge upstream 风险最低。
- 行为可预测：无论是否传 `-PtoolchainVersion`，spring-boot 模块的 test JVM 都获得该 opens 参数。

**已否决替代方案：**
- 改 `ToolchainPlugin` 让 `testJvmArgs` 总生效 → 修改 buildSrc 这种 "基础设施" 文件、影响所有模块（虽然实际无其它调用方）、合 upstream 麻烦；否决。
- 让 `make test` 命令加 `-PtoolchainVersion=17` → 会激活 Gradle toolchain 切换模式，可能触发 SDK 下载或重新编译，副作用不可控；否决。
- 删除现有 `toolchain {}` 块，只留新加的 `tasks.named('test')` → 丢失 `-PtoolchainVersion` 场景兼容；否决。

### Decision 2：保留原 toolchain {} 块

原 `toolchain {}` 块保持原样，不删不改。JVM 接受同一 `--add-opens` 参数被重复传入。

**理由：**
- 兼容上游 / fork 后续可能引入的 `-PtoolchainVersion=X` 跨版本测试场景。
- 减少 diff 噪音。

### Decision 3：每处改动加 `// FORK:` 注释

便于未来 merge upstream 时识别 fork 增量。

### Decision 4：跨变更联动 — 更新 add-makefile-test-target 的归档 spec

本变更落地后，`openspec/specs/make-test-target/spec.md` 中"已知失败分类"对应的 D 类条目应被删除。该归档 spec 已合入主 specs，本变更在实施阶段顺带改之；不再回过头改归档变更的 `EXECUTION_NOTES.md`（历史快照保留）。

## Risks / Trade-offs

- **`jvmArgs` 与未来 upstream 在 spring-boot/build.gradle 改动可能冲突**：本变更新增 5-6 行，区分度高，`// FORK:` 注释有利于合并。
- **`--add-opens` 重复传入**：JVM 行为是叠加无影响，已验证 upstream 类似 patch 同样写法。
- **D 类失败可能不止 `URLStreamHandlerFactory` 一个 opens**：调研 stack trace 仅看到这一个 opens 缺失；如果实施后跑 `make test` 还出现其它 `InaccessibleObjectException` 类型的失败，需补充更多 `--add-opens`（design 假设单一 opens 已足够，实施阶段验证）。
- **配置块位置**：放在 `toolchain {}` 之后是最自然位置；如果该模块未来引入了 `tasks.named('test')` 其它配置，需与之合并。

## Migration Plan

- 无迁移：纯 `build.gradle` 增量，影响只在 `spring-boot:test` 任务的 JVM 启动参数。
- 回滚：删除新增的 `tasks.named('test').configure { ... }` 块即可。

## Open Questions

- 是否还需要其它 `--add-opens`（如 `java.base/java.lang`, `java.base/java.util.concurrent.atomic`）来覆盖 E 类中 LocalDevTools 等可能的 JPMS 失败？本变更不预判，留待 `investigate-e-class-test-failures` 变更逐一确认。
