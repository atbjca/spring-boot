## MODIFIED Requirements

### Requirement: Log4j2 deferral is explicit and bounded
The project MUST replace the bounded Log4j2 2.24.3 deferral with a verified stable Log4j2 2.25.5 remediation for CVE-2025-68161, CVE-2026-34477, CVE-2026-34478, CVE-2026-34479, CVE-2026-34480, CVE-2026-34481, and CVE-2026-49844 while retaining Logback as the default runtime. Until the 2.25.5 source migration, dependency verification, focused logging regressions, clean thin build, and required project gates succeed, the findings MUST remain deferred or in progress rather than fixed.

#### Scenario: Default logging remains Logback after remediation
- **WHEN** the default starter dependency graph is inspected after the Log4j2 migration
- **THEN** Logback remains the default logging implementation
- **AND** the published `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-logging` remains Logback-based
- **AND** the published `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-log4j2` remains opt-in and is not introduced into the default runtime
- **AND** the imported `log4j-bom` and the seven-CVE-relevant and representative runtime modules resolve to stable 2.25.5 without project module-level overrides
- **AND** upstream BOM exceptions such as `log4j-flume-ng:2.23.1` remain at the version selected by `log4j-bom:2.25.5`

#### Scenario: Seven Log4j2 findings close only with verified evidence
- **WHEN** the Log4j2 CVE decisions are changed from deferred to fixed
- **THEN** the generated dependency-management POM and representative opt-in Log4j2 graphs select 2.25.5
- **AND** plugin processing, GraalVM metadata, normal logging, Actuator, structured ECS/GELF/Logstash logging, custom formatters, exception output, and whitespace throwable converter tests have passed from a clean dependency state
- **AND** CVE-2026-49844 regression coverage verifies valid fixed JSON output for `MapMessage` values containing `NaN`, positive infinity, and negative infinity
- **AND** the seven independent CVE records identify their affected module, trigger, authoritative affected and fixed ranges, final version, executed verification, and audit cutoff

#### Scenario: Failed migration preserves bounded deferral
- **WHEN** Log4j2 2.25.5 cannot pass the required compatibility or project gates
- **THEN** the version and source migration are rolled back together or left explicitly in progress
- **AND** none of the seven findings is classified as fixed solely from a proposed BOM version
- **AND** default Logback usage, affected appender or layout adoption, upstream compatibility, severity change, and exploit evidence remain documented reevaluation triggers

## ADDED Requirements

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
