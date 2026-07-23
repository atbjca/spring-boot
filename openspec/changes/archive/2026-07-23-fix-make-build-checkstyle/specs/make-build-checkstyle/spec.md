## ADDED Requirements

### Requirement: spring-boot Checkstyle passes on make build path

在执行 `make build`（或等价 Gradle `build`，含 checkstyle）时，`:spring-boot-project:spring-boot` 的 `checkstyleMain` 与 `checkstyleTest` MUST 成功，不得因已知 import 顺序或 Javadoc 风格违规失败。

#### Scenario: checkstyleTest passes for Tomcat reactive factory tests

- **WHEN** 执行 `:spring-boot-project:spring-boot:checkstyleTest`
- **THEN** `TomcatReactiveWebServerFactoryTests` 的 import 符合 `SpringImportOrder`（含正确分组与组间空行）
- **AND** 该任务不以 Checkstyle error 失败

#### Scenario: checkstyleMain passes for Tomcat servlet factory Javadoc

- **WHEN** 执行 `:spring-boot-project:spring-boot:checkstyleMain`
- **THEN** `TomcatServletWebServerFactory` 中 `LoaderHidingWebResourceSet` 的 `getAllowLinking` / `setAllowLinking` Javadoc 首句以句号结尾
- **AND** 该任务不以 `JavadocStyle` error 失败

#### Scenario: make build clears Checkstyle gate

- **WHEN** 开发者执行 `make clean build` 或 `make build`
- **THEN** 构建不得因上述 Checkstyle 违规在 `checkstyleMain` / `checkstyleTest` 失败
