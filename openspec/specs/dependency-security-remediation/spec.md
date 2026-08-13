## Purpose

Define evidence-based dependency security maintenance, compatible-line upgrade constraints, verification gates, and synchronized project documentation.
## Requirements
### Requirement: Managed vulnerable dependencies are remediated on compatible patch lines
The project MUST manage Jackson at 2.21.5 or newer compatible 2.21.x, Logback at 1.5.37 or newer compatible 1.5.x, Tomcat at 10.1.57 or newer compatible 10.1.x, Undertow at 2.3.26.Final or newer compatible 2.3.x while CVE-2026-3260 remains explicitly classified against the CNA rejection, Netty at 4.1.136.Final or newer compatible 4.1.x without adopting 4.2.x, PostgreSQL JDBC at 42.7.13 or newer compatible 42.7.x, ActiveMQ Classic at 6.2.8 or newer compatible 6.2.x, ActiveMQ Artemis at 2.54.0 or newer compatible 2.x verified by the project's messaging tests, Derby at the published Java 17 baseline 10.16.1.1 with CVE-2022-46337 explicitly deferred, Commons Lang3 at 3.18.0 or newer compatible 3.x, OpenTelemetry at 1.62.0 or newer compatible 1.x, OpenFeign QueryDSL at 5.6.1 or newer compatible 5.x, and `at.yawk.lz4:lz4-java` at 1.11.2 or newer compatible 1.x.

#### Scenario: Generated BOM contains remediated versions
- **WHEN** the Spring Boot dependency-management POM and resolved BOM are generated
- **THEN** their managed Jackson, Logback, Tomcat, Undertow, Netty, PostgreSQL JDBC, ActiveMQ Classic, ActiveMQ Artemis, Derby, Commons Lang3, OpenTelemetry, QueryDSL, and LZ4 Java versions satisfy the stated requirements
- **AND** the coordinates remain consistent with the project's official/fork GAV policy
- **AND** Netty remains on 4.1.x and ActiveMQ Classic remains on the selected 6.2.x line unless separate compatibility decisions approve broader upgrades
- **AND** Artemis imports `org.apache.artemis:artemis-bom:2.54.0` and manages both new-group and relocation-compatible old-group Artemis modules without module-specific version overrides
- **AND** QueryDSL management uses `io.github.openfeign.querydsl:querydsl-bom` and contains no managed `com.querydsl` 5.1.0 BOM or artifacts
- **AND** Kafka clients and Streams resolve `at.yawk.lz4:lz4-java:1.11.2` with no selected 1.10.1 or archived-group fallback

### Requirement: Security classification is evidence based
Every CVE entry changed by this work MUST record the managed component version, authoritative affected range or vendor advisory, affected module, project applicability, status, and audit cutoff date of 2026-08-06 or later.

#### Scenario: False-positive CVE is classified correctly
- **WHEN** CVE-2024-53241 is reviewed in the vulnerability documentation
- **THEN** it is classified as not applicable to Netty because the CVE concerns Linux/Xen
- **AND** report totals and indexes reflect the corrected classification

#### Scenario: Newly affected dependency is documented
- **WHEN** an advisory includes the project's managed version
- **THEN** the vulnerability report and a CVE detail entry identify the affected range, fixed version if one exists, remediation decision, trigger conditions, and verification evidence

#### Scenario: Netty 4.1.136 security batch is documented
- **WHEN** Netty is upgraded to 4.1.136.Final
- **THEN** assigned CVE IDs from the official 4.1.136.Final security announcement are recorded as remediated
- **AND** any announcement placeholders without a public CVE ID are noted as pending identity rather than invented

#### Scenario: Tomcat examples-only advisory is classified without upgrade
- **WHEN** CVE-2026-66299 is reviewed
- **THEN** it is classified as not applicable or immune for the default Boot-embedded Tomcat runtime because it affects only the examples WebSocket chat application
- **AND** Tomcat remains on 10.1.57 until a published 10.1.x fix is deliberately adopted in a later change

#### Scenario: ActiveMQ advisory batch records module-specific applicability
- **WHEN** the ActiveMQ Classic 6.1.8 advisory batch is documented
- **THEN** the batch explicitly covers CVE-2025-66168, CVE-2026-33227, CVE-2026-34197, CVE-2026-39304, CVE-2026-40046, CVE-2026-40466, CVE-2026-41043, CVE-2026-41044, CVE-2026-42253, CVE-2026-42588, CVE-2026-45505, and CVE-2026-49270
- **AND** each assigned CVE identifies whether it affects client, broker, MQTT, web console, Jolokia, or aggregate modules
- **AND** optional starter or console usage is recorded as a trigger condition rather than used to classify an affected managed version as immune
- **AND** ActiveMQ 6.2.8 verification evidence is recorded before the findings are marked fixed

#### Scenario: Artemis advisories record protocol prerequisites
- **WHEN** CVE-2026-27446, CVE-2026-32642, and CVE-2026-40914 are documented
- **THEN** the Core federation, OpenWire, and STOMP authorization trigger conditions are recorded with the affected 2.40.0 managed version
- **AND** Artemis 2.54.0 verification evidence is recorded before all three findings are marked fixed

#### Scenario: Directly remediated remaining findings record their fixed ranges
- **WHEN** CVE-2025-48924, CVE-2024-49203, CVE-2026-45292, and CVE-2026-59949 are documented
- **THEN** the records identify Commons Lang3 3.18.0, OpenFeign QueryDSL 5.6.1, OpenTelemetry 1.62.0, and LZ4 Java 1.11.2 respectively as the selected fixed versions
- **AND** each record preserves its long-input, HQL `orderBy`, W3C baggage, or native XXHash invalid-range trigger and affected-module evidence

#### Scenario: Spring Integration scanner association is rejected with version evidence
- **WHEN** CVE-2026-40987 is reconciled against the generated BOM
- **THEN** the record identifies `spring-integration-file` remote-file support used by FTP/SFTP/SMB adapters as the vendor-affected module and 6.5.9 as the 6.5.x open-source fix
- **AND** managed Spring Integration 6.5.10 is classified as not affected by this CVE
- **AND** the scanner alias or package association that produced the candidate is retained as false-positive evidence rather than silently discarded

### Requirement: Log4j2 seven-CVE remediation is verified and bounded
The project MUST manage stable `log4j-bom:2.25.5` and classify CVE-2025-68161, CVE-2026-34477, CVE-2026-34478, CVE-2026-34479, CVE-2026-34480, CVE-2026-34481, and CVE-2026-49844 as fixed only after completing the required Spring Boot 3.5 processor/API migration and verification while retaining Logback as the default runtime.

#### Scenario: Default logging remains Logback after remediation
- **WHEN** the default starter dependency graph and generated publication are inspected
- **THEN** `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-logging` retains `logback-classic` as its logging implementation and uses `log4j-to-slf4j:2.25.5` only as a bridge
- **AND** `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-log4j2` remains opt-in and is not introduced into the default runtime

#### Scenario: Generated BOM preserves authoritative Log4j versions
- **WHEN** the dependency-management POM and resolved BOM are generated
- **THEN** the imported Log4j BOM and all seven-CVE-relevant and representative runtime modules select stable 2.25.5 without project module-level overrides
- **AND** upstream BOM exceptions such as `log4j-flume-ng:2.23.1` retain the version selected by `log4j-bom:2.25.5`

#### Scenario: Boot Log4j2 compatibility and security behavior are verified
- **WHEN** the seven Log4j2 findings are classified as fixed
- **THEN** plugin processing, GraalVM metadata, structured throwable formatting, `%wEx`/`%xwEx` options and aliases, ordinary/Actuator/structured Log4j2 smoke modules, clean thin build, and core tests have passed
- **AND** `make test-gate` has passed when a focused or full-test failure required it
- **AND** a direct CVE-2026-49844 regression verifies that `MapMessage` values `NaN`, `Infinity`, and `-Infinity` are emitted as JSON strings
- **AND** the seven independent CVE records retain their actual appender/layout triggers and authoritative affected/fixed ranges rather than relying on default-runtime unreachability as the fix

### Requirement: Spring Boot Log4j2 integration is compatible with the 2.25 processor and API contracts
The project MUST adapt its Log4j2 plugin builders, compiler configuration, structured exception handling, and throwable pattern converters to supported Log4j2 2.25.5 contracts without weakening the project's warning-as-error policy or introducing internal Log4j2 implementation APIs as a new dependency boundary.

#### Scenario: Plugin and GraalVM annotation processors complete without suppressed build warnings
- **WHEN** `spring-boot` is compiled cleanly against Log4j2 2.25.5
- **THEN** every `@PluginBuilderAttribute` field has a processor-compatible public setter with narrowly documented Checkstyle handling
- **AND** `GraalVmProcessor` receives the current module groupId and artifactId through compiler options
- **AND** compilation completes under the existing `-Werror` and deprecation lint policy without globally disabling processor checks or warnings

#### Scenario: Structured logging uses supported throwable APIs
- **WHEN** ECS, GELF, and Logstash structured formatters render an event with an exception
- **THEN** Boot obtains the exception through `LogEvent.getThrown()` or another supported public Log4j2 2.25.5 API
- **AND** error type, message, full message, and stack trace retain the expected schema and custom `StackTracePrinter` semantics
- **AND** production code does not depend on deprecated `LogEvent.getThrownProxy()` or `org.apache.logging.log4j.core.impl.ThrowableProxy`

#### Scenario: Throwable pattern converters preserve observable behavior
- **WHEN** `%wEx`, `%xwEx`, and their alias keys format events with and without exceptions using supported options
- **THEN** short, full, extended, cause, separator, and whitespace behavior matches the documented Boot behavior
- **AND** a throwable is neither omitted nor rendered twice
- **AND** assertions pass with normalized Windows and Unix line endings

### Requirement: Log4j2 security and migration documentation stays synchronized
Project documentation and machine-readable security decisions MUST reflect the actual final Log4j2 migration state and MUST NOT report the seven CVEs as fixed before their required compatibility and security verification succeeds.

#### Scenario: Completed migration updates every security ledger consistently
- **WHEN** the change is ready for archive after successful verification
- **THEN** `doc/REQUIREMENTS.md`, `doc/VULNERABILITY_REPORT.md`, all seven applicable `doc/CVE/` records, `doc/CVE/Log4j2-2.25-upgrade-assessment.md`, `doc/NES_GAV_MAPPING.md`, `scripts/security-audit/vex-decisions.json`, audit fixtures/tests, and OpenSpec report Log4j2 2.25.5 as fixed
- **AND** fixed, deferred, immune, and total counts are recalculated from the final audit
- **AND** the compatibility assessment records the implemented adaptations and actual commands/results rather than retaining the obsolete conclusion that 2.25.x is unconditionally deferred
- **AND** no record claims a release-version change, publication, Nexus deployment, or unexecuted test

### Requirement: Security upgrades pass clean verification
Dependency remediation MUST pass targeted dependency/BOM checks, affected-component regression tests, a clean thin build, and the project's core Phase 1 test target before CVEs are marked fixed or immune.

#### Scenario: Clean build and tests succeed
- **WHEN** the dependency and coordinate changes are complete
- **THEN** `make clean build-thin` completes with BUILD SUCCESSFUL
- **AND** `make test` completes with BUILD SUCCESSFUL
- **AND** generated dependency/BOM evidence shows Netty 4.1.136.Final, PostgreSQL JDBC 42.7.13, ActiveMQ Classic 6.2.8, ActiveMQ Artemis 2.54.0, retained Derby 10.16.1.1, Commons Lang3 3.18.0, OpenTelemetry 1.62.0, OpenFeign QueryDSL 5.6.1, and LZ4 Java 1.11.2

#### Scenario: Messaging regression tests succeed
- **WHEN** ActiveMQ Classic and ActiveMQ Artemis are upgraded
- **THEN** relevant client starter, auto-configuration, embedded-broker, smoke, and available Docker-backed tests complete successfully
- **AND** any skipped environment-dependent test is recorded with its prerequisite and compensating evidence

#### Scenario: Remaining dependency regression tests succeed
- **WHEN** retained Derby 10.16.1.1 and the changed Commons Lang3, OpenTelemetry, QueryDSL, and LZ4 Java dependencies are verified
- **THEN** relevant database, utility, GraphQL/Spring Data QueryDSL, tracing, W3C baggage, exporter, metrics/logs, service-connection, Kafka, and LZ4 compression tests complete successfully
- **AND** OpenTelemetry propagation is verified with baggage enabled and disabled
- **AND** OpenTelemetry 1.62.0 exporter tests resolve a consistent OkHttp/MockWebServer 5.3.2 test runtime without adding OkHttp to the published dependency-management BOM
- **AND** the default Infinispan cache runtime is verified not to resolve `infinispan-cli-client`

### Requirement: Project documentation stays synchronized
The implementation MUST update the project requirements, vulnerability overview, individual CVE records, OpenSpec artifacts, audit evidence, and GAV mapping when dependency versions, coordinates, aliases, or classifications change.

#### Scenario: Documentation reflects implemented state
- **WHEN** the change is ready for archive
- **THEN** `doc/REQUIREMENTS.md` and `doc/VULNERABILITY_REPORT.md` match the implemented versions, statuses, totals, mitigations, and 2026-08-06 or later audit cutoff
- **AND** applicable files under `doc/CVE/` contain authoritative references, applicability, trigger conditions, selected fixes or deferrals, and verification evidence for the ActiveMQ, Artemis, Derby, Commons Lang3, QueryDSL, OpenTelemetry, LZ4 Java, Undertow, Infinispan, Spring Integration, and Log4j2 findings
- **AND** `doc/NES_GAV_MAPPING.md` describes the QueryDSL migration and remains synchronized with any machine-readable NES-to-upstream audit aliases
- **AND** existing Netty and PostgreSQL JDBC remediation evidence remains intact

### Requirement: Parsson JSON-P provider is explicitly managed

The project MUST manage `org.eclipse.parsson:parsson` at version 1.1.9 in the Spring Boot dependency BOM while preserving Yasson 3.0.4, Jakarta JSON API 2.1.3, and Jakarta JSON Bind API 3.0.2.

#### Scenario: Generated BOM manages Parsson 1.1.9

- **WHEN** the `spring-boot-dependencies` Maven POM is generated
- **THEN** it defines `parsson.version` as `1.1.9`
- **AND** dependency management contains `org.eclipse.parsson:parsson` using that property
- **AND** the Yasson and Jakarta JSON API versions remain unchanged

#### Scenario: Yasson transitive Parsson is upgraded consistently

- **WHEN** a representative JSON-B test runtime graph resolves `org.eclipse:yasson:3.0.4`
- **THEN** Yasson's transitive `org.eclipse.parsson:parsson:1.1.7` request resolves to `1.1.9`
- **AND** representative Elasticsearch Java client requests for Parsson 1.0.5 also resolve to 1.1.9
- **AND** the graph contains no selected Parsson 1.1.7 or alternate Parsson coordinate

### Requirement: Parsson maintenance rationale is evidence based

Project documentation MUST describe the Parsson 1.1.9 change as proactive compatible-line maintenance when it was originally performed, and MUST additionally recognize CVE-2026-9563 as fixed when authoritative advisory evidence identifies the applicable vulnerability and the managed version is above the fixed boundary.

#### Scenario: Documentation does not invent a Parsson CVE

- **WHEN** the Parsson upgrade is documented
- **THEN** the current and previous resolved versions and the transitive Yasson path are recorded
- **AND** the documentation does not claim a CVE, affected range, or fixed vulnerability absent authoritative evidence

#### Scenario: Later advisory is reconciled without rewriting history

- **WHEN** an authoritative advisory later identifies Parsson 1.1.7 or earlier as affected and 1.1.8 as fixed
- **THEN** managed Parsson 1.1.9 is classified as fixed
- **AND** the project retains the historical fact that the original audit query did not return the advisory and the 1.1.9 upgrade was therefore documented as proactive maintenance
- **AND** the later classification does not infer the advisory's first publication date from when its data became available to or changed in the audit source

### Requirement: HttpCore5 HTTP parser exhaustion is managed on a stable fixed line

The project MUST manage `org.apache.httpcomponents.core5:httpcore5`, `httpcore5-h2`, and `httpcore5-reactive` through one BOM-owned `HttpCore5` library at stable 5.4.3 or a newer approved stable fixed release for CVE-2026-54399, without selecting a 5.5 prerelease or adding module-level overrides.

#### Scenario: HttpCore5 BOM ownership remains centralized

- **WHEN** the generated dependency-management POM and resolved BOM are inspected
- **THEN** all three HttpCore5 modules resolve to the same stable fixed version
- **AND** HttpClient5 remains managed independently at its existing compatible version
- **AND** no module build, consumer, or resolution strategy introduces a second HttpCore5 version source

#### Scenario: HttpCore5 fixed status awaits project verification

- **WHEN** CVE-2026-54399 is classified as fixed
- **THEN** the final dependency graph, focused synchronous/reactive HttpComponents tests, selected CLI/buildpack or integration paths, clean thin build, and core project gate have passed
- **AND** the CVE record identifies the unbounded HTTP/1.1 header/line memory-exhaustion trigger, authoritative range, selected version, commands, results, and audit cutoff

### Requirement: PostgreSQL JDBC channel-binding downgrade is remediated
The project MUST manage `org.postgresql:postgresql` at 42.7.13 or newer on the 42.7.x line so that CVE-2026-54291 is outside the affected range.

#### Scenario: Managed pgjdbc meets fixed version
- **WHEN** the Spring Boot dependency BOM POM is generated
- **THEN** the managed PostgreSQL JDBC version is 42.7.13 or a newer compatible 42.7.x release
- **AND** CVE-2026-54291 is recorded as fixed with authoritative affected range `>= 42.7.4, < 42.7.12`

### Requirement: Derby deferral is explicit and bounded
The project MUST retain Derby 10.16.1.1 as a deferred risk for CVE-2022-46337 while the Java baseline remains 17 and no complete Java-17-compatible fixed Derby release is available from Maven Central.

#### Scenario: Derby remains consumable on Java 17 with a bounded risk decision
- **WHEN** Derby dependency management and CVE-2022-46337 are documented
- **THEN** the generated BOM retains Derby 10.16.1.1 and does not claim the finding is fixed
- **AND** the record states that Maven Central does not publish the required Derby artifacts at 10.16.1.2
- **AND** it records that published Derby 10.17.1.0 uses class-file major version 63, which is incompatible with Java 17's supported major version 61
- **AND** it identifies LDAP-authenticated Derby as the trigger boundary
- **AND** it requires reevaluation when a published Java-17-compatible fix becomes available or the project Java baseline increases

### Requirement: QueryDSL remediation uses the maintained coordinate lineage
The project MUST replace dependency management and direct build consumers of vulnerable `com.querydsl` 5.1.0 artifacts with the compatible `io.github.openfeign.querydsl` 5.6.1 lineage while preserving the `com.querydsl` Java API packages used by Spring Boot auto-configuration.

#### Scenario: QueryDSL consumers use the fixed Maven coordinates
- **WHEN** dependency management and `spring-boot-autoconfigure` are resolved
- **THEN** `querydsl-bom` and the direct optional `querydsl-core` dependency use group `io.github.openfeign.querydsl` at 5.6.1
- **AND** GraphQL QueryDSL auto-configuration compiles and its imperative and reactive tests pass without Java package or public API changes
- **AND** downstream documentation states that applications using `querydsl-jpa`, `querydsl-apt`, or other managed modules must migrate their Maven group from `com.querydsl` to `io.github.openfeign.querydsl`

### Requirement: Kafka's transitive LZ4 Java dependency is explicitly managed
The project MUST manage `at.yawk.lz4:lz4-java` at 1.11.2 in the Boot dependency BOM so Kafka clients and Streams no longer select the CVE-2026-59949-affected transitive version 1.10.1.

#### Scenario: Kafka resolves the maintained fixed LZ4 coordinate
- **WHEN** representative Kafka client and Streams runtime graphs are resolved
- **THEN** `at.yawk.lz4:lz4-java` is selected at 1.11.2 by the Boot BOM constraint
- **AND** Kafka 3.9.2 and the NES Spring Kafka version remain unchanged
- **AND** no `at.yawk.lz4:lz4-java:1.10.1`, `org.lz4:lz4-java`, or `net.jpountz.lz4:lz4` artifact is selected

#### Scenario: LZ4 compatibility and advisory behavior are bounded
- **WHEN** the LZ4 upgrade is verified
- **THEN** valid compression, decompression, XXHash, Kafka client, and Kafka Streams paths complete successfully
- **AND** documentation records that CVE-2026-59949 requires attacker influence over invalid JNI array references or bounds rather than only compressed byte contents
- **AND** project tests do not execute the vulnerable invalid-range payload in the main test JVM

### Requirement: Scanner findings remain visible and evidence classified
Findings MUST remain visible with reachability, source status, and audit timestamps; a scanner hit MUST NOT be classified as exploitable merely because an advisory alias exists, nor as clean merely because the module is optional or absent from the default runtime.

#### Scenario: Undertow denial of service is reconciled with CNA rejection
- **WHEN** CVE-2026-3260 is documented for Undertow 2.3.26.Final
- **THEN** the record states that the Red Hat CNA rejected the CVE on 2026-07-07 because Undertow's default request entity size limit drops oversized requests
- **AND** the original GHSA/scanner alias and rejection rationale remain visible
- **AND** a future vendor re-issuance or contradictory exploit evidence triggers reevaluation

#### Scenario: Infinispan CLI finding records fixed boundary and non-default reachability
- **WHEN** CVE-2025-5731 is documented for `org.infinispan:infinispan-cli-client` 15.2.6.Final
- **THEN** the record distinguishes BOM management from the default cache starter/runtime dependency graph
- **AND** it records the Red Hat affected boundary below 15.2.5 and classifies 15.2.6.Final as outside that range
- **AND** the original GHSA/scanner alias remains visible for future advisory reconciliation

### Requirement: Complete resolved-BOM security audit is repeatable
The project MUST provide a repository-owned audit workflow that inventories every distinct Maven coordinate in the generated resolved BOM, converts it to a canonical PURL, checks configured advisory sources, maps NES fork identities to upstream identities, and emits normalized evidence suitable for CVE classification.

#### Scenario: Complete inventory is scanned
- **WHEN** the audit runs against `spring-boot-project/spring-boot-dependencies/build/createResolvedBom/resolved-bom.json`
- **THEN** it enumerates direct managed dependencies and dependencies expanded from imported BOMs
- **AND** its distinct-coordinate count reconciles with the generated input under a documented duplicate policy
- **AND** every coordinate has a canonical Maven PURL and a lookup result or an explicit lookup failure
- **AND** a failed, truncated, stale, or count-mismatched lookup cannot be reported as a clean audit

#### Scenario: NES fork aliases preserve upstream visibility
- **WHEN** a managed coordinate matches a configured NES fork mapping
- **THEN** the audit queries both its private PURL and its normalized upstream PURL without storing a second dependency version outside the generated BOM
- **AND** output records the mapping rule and provenance used for the alias
- **AND** representative Spring Boot, Framework, Security, Data, and Kafka mappings are covered by deterministic tests
- **AND** an upstream alias match is emitted as a candidate requiring VEX/applicability review rather than automatically marked exploitable

#### Scenario: Advisory aliases and classifications are traceable
- **WHEN** OSV, GHSA, NVD, vendor, or corroborating SCA records refer to the same vulnerability
- **THEN** the audit evidence deduplicates aliases to the assigned CVE where one exists while retaining all source identifiers
- **AND** the recorded decision is one of affected, fixed, immune/not applicable, false positive, or deferred with authoritative rationale and audit cutoff
- **AND** source query time and database/advisory freshness are recorded
