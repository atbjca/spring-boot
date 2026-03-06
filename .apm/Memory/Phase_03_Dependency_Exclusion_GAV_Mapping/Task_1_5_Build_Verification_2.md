---
agent: User
task_ref: Task 1.5
status: Completed
ad_hoc_delegation: false
compatibility_issues: false
important_findings: true
---

# Task Log: Task 1.5 - 二次构建验证

## Summary
构建失败，bomrCheck 仍报告 7 个模块的 exclude 为 "Unnecessary exclusions"。

## Details
- spring-data-bom 版本升级问题已由用户解决（制品已发布到 Nexus）
- bomrCheck 报告 7 个模块的通配符 exclude `[org.springframework:*]` 为 Unnecessary
- 这些模块实际不传递依赖 org.springframework（Spring 依赖为 provided/compileOnly）

## Output
- 构建状态：FAILED（bomrCheck）
- 不必要 exclude 的模块：activemq-spring、cache2k-spring、hazelcast-spring、spring-restdocs-asciidoctor、spring-retry、thymeleaf-spring5、thymeleaf-extras-springsecurity5

## Issues
7 个模块的 exclude 实为不必要，需移除。

## Important Findings
bomrCheck 通配符验证通过 resolved dependencies 确认是否有对应 group 的制品。这 7 个模块的 Spring 依赖为 provided/compileOnly 不传递给下游，exclude 无意义。

## Next Steps
- Task 1.6：移除这 7 个模块的不必要 exclude
