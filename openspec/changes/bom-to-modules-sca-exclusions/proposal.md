## Why

3.5 上游将 Spring AMQP / Batch / WS / RESTDocs 从显式 `modules` 列表改为 `bom()` import。2.7 fork 在这些组件的每个模块上都有 `exclude group: "org.springframework"` 排除，防止 SCA 扫描到官方 Spring 传递依赖。3.5 切换到 `bom()` 后这些排除丢失，形成 SCA 回归。

## What Changes

- 将 `spring-boot-dependencies/build.gradle` 中 4 个组件从 `bom()` import 改回显式 `modules` 列表，并添加 `exclude group: "org.springframework", module: "*"` 排除：
  - **Spring AMQP** (3.2.12)：5 个模块
  - **Spring Batch** (5.2.6)：4 个模块
  - **Spring WS** (4.1.4)：5 个模块（`spring-ws-security` 额外排除 `org.springframework.security`）
  - **Spring RESTDocs** (3.0.6)：4 个模块（`spring-restdocs-asciidoctor` 无 Spring 依赖，不排除）
- 保留原有 `links {}` 块不变。
- 更新 `doc/NES_GAV_MAPPING.md` SCA 覆盖状态。

### Non-goals

- 不 fork 这些组件（仍用官方坐标 + exclusion 模式）。
- 不处理 Spring Data / Integration / Session / Pulsar（这些在 2.7 也无 exclusion，留后续评估）。

## Capabilities

### New Capabilities

### Modified Capabilities

- `fork-ecosystem-sca-excludes`: 从仅覆盖 Phase C 的 5 个显式模块组件，扩展到覆盖 AMQP / Batch / WS / RESTDocs 4 个 bom() 回归组件。

## Impact

- **构建脚本**：仅修改 `spring-boot-dependencies/build.gradle`。
- **BOM POM**：生成的 BOM 中上述模块的 `<dependencyManagement>` 含 `<exclusions>`。
- **运行时**：消费者通过 Boot BOM + resolutionStrategy 获得 fork Framework，与 2.7 行为一致。
- **SCA**：AMQP / Batch / WS / RESTDocs 的传递 `org.springframework:*` 坐标不再暴露。
