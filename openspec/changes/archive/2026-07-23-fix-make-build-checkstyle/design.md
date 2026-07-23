## Context

`make build` 依赖 `setup-gradle`、`clean`、`format`，随后执行完整 `./gradlew build`。当前失败点不在编译，而在 `:spring-boot-project:spring-boot:checkstyleMain` 与 `checkstyleTest`：

1. **test**：`TomcatReactiveWebServerFactoryTests` 中 `reactor.*` / `org.springframework.http.client.reactive.ReactorClientHttpConnector` 的 import 落在 `org.springframework.*` 分组之后，且未正确空行分隔，触发 `SpringImportOrder`（Wrong order + import.separation）。
2. **main**：`TomcatServletWebServerFactory.LoaderHidingWebResourceSet` 上两段中文 Javadoc 首句未以句号结尾，触发 `JavadocStyle`。

这是风格门禁失败，不是功能回归。修复应最小、可机械验证。

## Goals / Non-Goals

**Goals:**

- 消除上述 4 处 Checkstyle error，使 `checkstyleMain` / `checkstyleTest` 通过
- 保持既有 Tomcat 9.0.84+ `getAllowLinking` / `setAllowLinking` 委托行为与测试语义不变
- 恢复 `make clean build` / `make build` 可通过 Checkstyle 关卡

**Non-Goals:**

- 不调整 Checkstyle 规则或抑制列表
- 不改依赖版本、不重构 Tomcat 嵌入式工厂
- 不把 `make build` 改成跳过 checkstyle（与 `build-thin` 分工保持不变）

## Decisions

1. **仅改违规行，不跑大范围 format 重写**
   - Rationale：`make build` 已含 `format`；当前失败是局部 import/Javadoc，手工对齐 Spring 项目 import 约定更可控，避免无关 diff。
   - Alternative：只跑 `./gradlew format` — 可能改动更多文件；本次已知违规点明确，优先定点修复。

2. **Import 顺序：第三方（含 reactor）在 `org.springframework` 之前，同组内按字母序，组间空行**
   - Rationale：与仓库 `SpringImportOrder` 及周边测试文件一致；`reactor.core` / `reactor.test` 属第三方，应与 `org.springframework.*` 分开。
   - Alternative：把 reactor import 挪到 static import 之后 — 仍会违规。

3. **Javadoc：在中文首句末尾补全句号（`。`）**
   - Rationale：Checkstyle `JavadocStyle` 要求首句以句号结束；中文句号符合现有中文注释风格。
   - Alternative：改写成英文首句 — 会扩大与 NES patch 注释语言不一致的差异。

## Risks / Trade-offs

- [Risk] 仅修 checkstyle 后，后续 test/intTest 仍可能失败 → Mitigation：本 change 验收以 Checkstyle 与 `make build` 实际结果为准；若后续另有测试失败，另立 change。
- [Risk] format 与手工 import 顺序冲突 → Mitigation：修复后先跑相关 checkstyle task，再视需要跑 format 确认无回流。

## Migration Plan

- 直接合入源码修正；无需数据迁移或配置切换。
- 回滚：还原两个文件即可恢复到失败前状态（但构建仍会红）。

## Open Questions

- 无。违规点与修复方式已由 `make clean build` 日志确认。
