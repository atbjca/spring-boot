## 1. 修改 spring-boot-dependencies/build.gradle

- [x] 1.1 Spring AMQP：将 `bom("spring-amqp-bom")` 改为显式 `modules` 列表（5 个模块），每个模块添加 `exclude group: "org.springframework", module: "*"`
- [x] 1.2 Spring Batch：将 `bom("spring-batch-bom")` 改为显式 `modules` 列表（4 个模块），每个模块添加 `exclude group: "org.springframework", module: "*"`
- [x] 1.3 Spring WS：将 `bom("spring-ws-bom")` 改为显式 `modules` 列表（5 个模块），每个模块添加排除；`spring-ws-security` 额外排除 `org.springframework.security`
- [x] 1.4 Spring RESTDocs：将 `bom("spring-restdocs-bom")` 改为显式 `modules` 列表（4 个模块），除 `spring-restdocs-asciidoctor` 外每个模块添加排除

## 2. 验证

- [x] 2.1 `make build-thin` BUILD SUCCESSFUL
- [x] 2.2 `make test-gate` BUILD SUCCESSFUL
- [x] 2.3 抽查生成的 BOM POM：`spring-amqp` 含 exclusion

## 3. 文档

- [x] 3.1 更新 `doc/NES_GAV_MAPPING.md` Phase C 表格，新增 AMQP / Batch / WS / RESTDocs 排除状态
