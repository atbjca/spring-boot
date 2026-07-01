## Why

`add-makefile-test-target` 完成 + A/C 类修复 + 后续 D/G/S 类 change 入项后，仍有约 30 条 E 类失败用例未逐一定位，分布于多个模块：

- `spring-boot-actuator:test` — `LiquibaseEndpointTests` 6 条、`QuartzEndpointTests.canConvertIntervalUnit[6]` 1 条、`WebFluxEndpointIntegrationTests.writeOperationWithVoidResponse` 1 条（疑 flaky）
- `spring-boot-actuator-autoconfigure:test` — `Jersey*ManagementContextConfigurationTests` 7 条（疑与 fork 的 `ignoredStarters` 排除 jersey 有关）、`ReactiveCloudFoundryActuatorAutoConfigurationTests.skipSslValidation`（疑 flaky）
- `spring-boot-test:test` — `SpringBootTestContextHierarchyTests` 1 条、`WebTestClientContextCustomizerWithoutWebfluxIntegrationTests` 1 条
- `spring-boot-devtools:test` — `LocalDevToolsAutoConfigurationTests.defaultPropertyCanBeOverriddenFrom*` 2 条

本变更目标是把这些失败按"调查 → 分类 → 修复或排除"流程跑一遍，最终消除或正式纳入排除清单。

## What Changes

- 为每个失败用例采集 stack trace 与失败上下文，按 A/B/C/D/E 五类重新定位（前一变更中归为"E 类未定位"，本变更细化）。
- 对每条失败给出处置：
  - 测试断言可调适（仍在"不动 src/main"约束下）→ 修测试代码。
  - fork 配置变化导致（如 jersey starter 被排除）→ 修测试或加 `@EnabledIf` 条件。
  - 真实缺陷 / upstream 已修但未回合 → 排除并加 `-x` 注释。
  - flaky → 标 `@RepeatedTest` 或 `@DisabledIf` 临时回避。
- 更新 `make-test-target` capability 的 spec：根据处置结果调整"已知失败分类"中 E 类条目。

## Capabilities

### New Capabilities
<!-- 无 -->

### Modified Capabilities
- `make-test-target`：E 类失败被处置后，"已知失败分类"段落同步更新；若有新增排除项，追加到"显式排除清单"。

## Impact

- 受影响文件：上述模块各自的 `src/test/java` 文件（不动 `src/main`）；如有结构性排除，也涉及根 `Makefile`。
- 工作量：30 条用例 × 单独调查 + 修复 / 排除决策，估算需要拆成若干 sub-change 或在本 change 内分模块阶段推进。
- 风险：发现的根因可能反推到"必须改 src/main"或"必须改 build.gradle"，届时需要重新评估约束。
