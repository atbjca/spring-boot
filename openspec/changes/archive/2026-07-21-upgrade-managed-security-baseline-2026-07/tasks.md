## 1. Baseline and compatibility verification

- [x] 1.1 Record current BOM versions, worktree state, and target CVE-to-version matrix
- [x] 1.2 Verify Java 8 bytecode/compiler targets for each candidate and document HSQLDB 2.7.x as Java 11-only
- [x] 1.3 Recheck Undertow 2.2.40.Final against CVE-2026-3260 and CVE-2026-28367/28368/28369 using upstream diff/advisory evidence

## 2. Dependency management updates

- [x] 2.1 Upgrade PostgreSQL JDBC, H2, Hazelcast, RabbitMQ Java Client, Spring LDAP, Sun Mail, and Undertow in `spring-boot-dependencies/build.gradle`; retain Derby 10.14.2.0 after Central artifact verification
- [x] 2.2 Upgrade `tomcatVersion` to 9.0.120 in `gradle.properties`
- [x] 2.3 Keep Derby at 10.14.2.0 and HSQLDB at 2.5.2, with explicit artifact/Java 8 constraint explanations
- [x] 2.4 Generate the Maven BOM and verify all target versions and absence of stale/duplicate managed versions

## 3. Targeted compatibility tests

- [x] 3.1 Run JDBC/JPA/database initialization tests for PostgreSQL, Derby, H2, and HSQLDB-related paths
- [x] 3.2 Run Hazelcast cache/session tests and RabbitMQ auto-configuration tests
- [x] 3.3 Run Spring LDAP and Mail auto-configuration tests
- [x] 3.4 Run Undertow and Tomcat web server factory, request parsing, SSL, and HTTP tests
- [x] 3.5 Resolve only compatibility failures caused by this version batch and rerun affected tests

## 4. Documentation and validation

- [x] 4.1 Add or update CVE detail documents for every component in the matrix, including Derby/HSQLDB constraints and Undertow advisory evidence
- [x] 4.2 Update `VULNERABILITY_REPORT.md`, `REQUIREMENTS.md`, and `COMPONENTS_UPGRADE_HISTORY.md` with final versions and statuses
- [x] 4.3 Run `openspec validate upgrade-managed-security-baseline-2026-07 --strict`, BOM checks, formatting/nohttp checks, and the standard project test gate
- [x] 4.4 Review the final diff and confirm Spring Kafka, Reactor Netty/Netty, ActiveMQ/Artemis, and Spring Security are unchanged

### Verification notes

- Strict OpenSpec validation, generated/effective BOM checks, targeted compatibility tests, formatting, and `make test` passed.
- Java 8 verification used JVM 1.8.0_472 with Gradle 7.6.3; the relevant Spring Boot source and focused security/session/actuator tests passed on the maintained runtime baseline.
- Relevant `testRuntimeClasspath` resolutions contain a single managed version for each audited component: PostgreSQL 42.7.13, Derby 10.14.2.0, H2 2.2.220, HSQLDB 2.5.2, Hazelcast 5.2.5, RabbitMQ 5.18.0, Spring LDAP 2.4.4, Mail 1.6.8, Undertow 2.2.40.Final, and Tomcat 9.0.120.
- `make build-thin` passed in 14m 26s with 1976 actionable tasks (1957 executed, 19 up-to-date), including repository-wide compilation, assembly, architecture, prohibited-dependency, and formatting checks.
- Repository-wide `nohttp` exits 35 on pre-existing internal HTTP URLs plus generated Maven/build outputs; no added line introduces `http://`.
- `spring-boot:checkstyleMain` is blocked by two pre-existing Javadoc violations in `TomcatServletWebServerFactory.java` lines 884/894. The modified Java sources are formatter-clean, and actuator checkstyle passed.
