## Why

The Boot BOM manages Log4j2 2.24.3 inside the affected ranges for seven documented CVEs, including CVE-2026-49844, while the minimum release that fixes the complete set is 2.25.5. A version-only upgrade does not compile against the current Spring Boot 3.5 Log4j2 integration, so remediation requires a bounded source migration modeled on the later upstream 2.25.x adaptations and verified for this fork.

## What Changes

- Upgrade the single Boot BOM `Log4j2` library from 2.24.3 to stable 2.25.5 without adding module-level overrides or changing the default Logback runtime. Preserve the upstream `log4j-bom:2.25.5` module versions, including its deliberate `log4j-flume-ng:2.23.1` exception.
- Port the required Log4j2 2.25.x plugin-processor adaptations: public plugin builder setters, narrow Checkstyle accommodations, and GraalVM annotation-processor coordinates.
- Migrate Boot's Log4j2 exception and structured-logging integrations away from deprecated `ThrowableProxy` and `LogEvent.getThrownProxy()` paths to the supported `Throwable` APIs.
- Rework whitespace throwable pattern converters using the corrected upstream approach so option handling, separators, stack traces, and cross-platform line endings remain compatible.
- Update focused unit and smoke tests for normal logging, Actuator Log4j2, structured logging, ECS, GELF, Logstash, custom formatters, exception rendering, plugin discovery, and GraalVM metadata.
- Add advisory-focused coverage for CVE-2026-49844 non-finite `MapMessage` JSON output and applicable tests or evidence for the other six affected appender/layout paths.
- After successful clean verification, replace the seven bounded Log4j2 deferrals with fixed classifications in requirements, vulnerability overview and independent details, VEX decisions, audit tests, and OpenSpec specifications. Failed or incomplete migration evidence leaves the findings deferred rather than falsely fixed.
- Keep release version changes, Log4j2 3.x, default logging changes, artifact publication, and Nexus deployment out of scope.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dependency-security-remediation`: Replace the bounded Log4j2 2.24.3 deferral with a verified 2.25.5 remediation requirement and define compatibility, regression, and security-evidence gates for the source migration.

## Impact

- Changes `spring-boot-project/spring-boot-dependencies/build.gradle`, `spring-boot-project/spring-boot/build.gradle`, Checkstyle suppressions, and Log4j2 integration classes and tests under `spring-boot-project/spring-boot`.
- Affects applications that opt into the published `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-log4j2`, especially custom plugin builders, structured JSON logging, exception formatters, and whitespace throwable conversion. The published default `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-logging` remains Logback-based and only receives the BOM-managed `log4j-to-slf4j` update.
- Uses later upstream Spring Boot Log4j2 2.25.x commits as reference material but requires path-aware adaptation and fresh verification against the current 3.5 fork rather than blind cherry-picking.
- Updates three Log4j2 smoke-test modules, security documentation for all seven CVEs, the VEX manifest, audit fixtures/tests, and the dependency security specification.
