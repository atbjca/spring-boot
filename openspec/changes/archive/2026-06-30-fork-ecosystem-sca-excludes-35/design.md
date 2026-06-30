## Context

Phase B 完成 Framework / Security fork 映射。`spring-boot-dependencies` 中部分 A 类组件使用显式 `modules` 列表（GraphQL、Kafka 等），BomPlugin 支持在模块上声明 `exclude group: org.springframework, module: "*"` 并写入生成的 BOM POM。

3.5 上游将 AMQP / Batch / Integration / Session / WS 等改为 `bom()` import，无法在 import 层直接加 exclusion（与 2.7 显式模块方式不同），本 change 仅覆盖仍使用 `modules` 的条目。

## Goals / Non-Goals

**Goals:**
- 对齐 2.7 A 类排除模式，减少 SCA 对 `org.springframework:*` 的误报。
- 零修改子模块 `build.gradle`。

**Non-goals:**
- Spring Data BOM import 条目（待独立 fork change）。
- Logback bogback fork。

## Decisions

### Decision 1：仅对显式 modules 条目添加 exclude

与 BomPlugin 能力边界一致；BOM import 型条目留待后续 change（或生态 fork 制品就绪后改回 modules）。

### Decision 2：仅排除 org.springframework，不排除 org.springframework.security

Security 已由 Phase B 映射；Kafka 等组件不传递 Security。WS security 模块在 3.5 使用 `spring-ws-bom` import，本 change 不处理。

## Risks

- **[构建时缺传递依赖]** → resolutionStrategy 仍将显式声明的 `org.springframework:*` 替换为 fork；排除仅阻止 A 类 jar 自带的传递链。
- **[BOM import 条目未覆盖]** → 文档标注剩余 SCA 盲区。

## Verification

1. `publishToMavenLocal` 后检查 `spring-kafka` managed dependency 含 exclusion。
2. `make build-thin` BUILD SUCCESSFUL。
3. `make test` 核心模块全绿。
