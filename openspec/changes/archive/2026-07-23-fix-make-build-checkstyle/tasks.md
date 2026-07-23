## 1. Fix Checkstyle violations

- [x] 1.1 调整 `TomcatReactiveWebServerFactoryTests` 的 import：将 `reactor.*` 与 `ReactorClientHttpConnector` 按 `SpringImportOrder` 放到正确分组（第三方在 `org.springframework` 前，组间空行）
- [x] 1.2 修正 `TomcatServletWebServerFactory.LoaderHidingWebResourceSet` 中 `getAllowLinking` / `setAllowLinking` 的 Javadoc 首句，以句号结尾
- [x] 1.3 修正验证阶段发现的 `EndpointRequestTests` import 字母序（`OrServerWebExchangeMatcher` 应在 `ServerWebExchangeMatcher` 前）

## 2. Verify build gate

- [x] 2.1 运行 `:spring-boot-project:spring-boot:checkstyleMain` 与 `checkstyleTest`，确认无 error
- [x] 2.2 运行相关 checkstyle（含 `actuator-autoconfigure:checkstyleTest`）确认不再因 Checkstyle 违规失败；`make build` 中原 Tomcat 相关违规已清除（验证中曾遇无关 Quartz Jersey `Connection reset` 偶发，复跑通过）
