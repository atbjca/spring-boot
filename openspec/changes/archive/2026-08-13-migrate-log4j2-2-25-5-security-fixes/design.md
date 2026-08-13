## Context

The project currently manages Log4j2 2.24.3 and explicitly defers seven findings: CVE-2025-68161, CVE-2026-34477, CVE-2026-34478, CVE-2026-34479, CVE-2026-34480, CVE-2026-34481, and CVE-2026-49844. Their triggers are narrow and Logback remains the default runtime, but 2.24.3 is still inside each authoritative affected range. Log4j2 2.25.5 is the first stable release that covers the full set.

A clean compile experiment against 2.25.4 exposed three substantive compatibility layers in the current Spring Boot 3.5 fork: stricter `PluginProcessor` validation for `@PluginBuilderAttribute`, `GraalVmProcessor` coordinate warnings promoted to errors by `-Werror`, and deprecated Log4j2 exception/converter APIs that also fail under the project's lint policy. Later upstream Spring Boot development commits contain a proven adaptation sequence, but the first 2.25.1 attempt was rolled back and then reapplied with corrected throwable-converter behavior. Those commits use a later repository layout and target a later Boot line, so they are reference implementations rather than safe blind cherry-picks.

The migration crosses dependency management, build conventions, plugin metadata, exception formatting, structured JSON logging, unit tests, smoke tests, security classification, and user-visible log output. Fixed status therefore requires a clean build and behavioral evidence, not merely a generated BOM version.

## Goals / Non-Goals

**Goals:**

- Import stable `log4j-bom:2.25.5` from the Boot BOM and preserve its authoritative module versions without project-level overrides.
- Adapt the current Spring Boot 3.5 Log4j2 integration to compile cleanly with the 2.25.x plugin processors and supported APIs.
- Preserve expected Log4j2 plugin discovery, exception output, whitespace converters, structured ECS/GELF/Logstash JSON, custom formatters, and cross-platform line endings.
- Verify CVE-2026-49844's non-finite `MapMessage` JSON behavior and retain evidence for the other six advisory paths before closing the deferral ledger.
- Synchronize all seven independent CVE records, vulnerability totals, VEX decisions, audit tests, requirements, GAV mapping, and OpenSpec artifacts using actual results.

**Non-Goals:**

- Change the default runtime from Logback or add `spring-boot-starter-log4j2` to default starters.
- Adopt Log4j2 2.26.x or 3.x, redesign Spring Boot's general structured-logging API, or intentionally change public Boot Java APIs.
- Enable or configure vulnerable Socket, SMTP, Syslog, XML, RFC5424, JSON Template, or MapMessage paths by default.
- Change the fork release version, publish artifacts, deploy to Nexus, or combine this work with the HttpCore5/Parsson change.

## Decisions

1. **Target Log4j2 2.25.5 exactly for the initial migration.** It is the minimum stable release fixing the complete seven-CVE set, including CVE-2026-49844. Selecting 2.25.3 or 2.25.4 leaves known findings open; selecting 2.26.1 broadens the compatibility surface without being required.

2. **Use the upstream 2.25.x commit sequence as a semantic reference, not a patch source of truth.** Review `b7695200a90` and `c4cace3f74c` file by file and adapt their intent to current `spring-boot-project` paths and current fork code. The earlier upgrade and rollback prove that exception-converter semantics require fresh tests.

3. **Make plugin builder setters public with the narrowest Checkstyle accommodation.** Log4j2's `PluginProcessor` requires public setters for fields annotated with `@PluginBuilderAttribute`. The affected builder methods will be public only where processor discovery requires it; Checkstyle suppressions will identify the exact classes and rationale.

4. **Provide GraalVM processor coordinates on the `spring-boot` compile task.** Supply `log4j.graalvm.groupId` and `log4j.graalvm.artifactId` compiler options so the annotation processor produces deterministic metadata without warnings becoming fatal under `-Werror`. The artifact identity will match the actual current module publication, not be copied blindly from a later layout.

5. **Move structured exception handling to `Throwable`.** Replace `LogEvent.getThrownProxy()` and direct `ThrowableProxy` dependencies with `LogEvent.getThrown()` and supported Java/Log4j2 APIs. When no custom `StackTracePrinter` is configured, generate the ordinary Java stack trace in a way that is asserted by ECS, GELF, and Logstash tests. Avoid internal Log4j2 implementation types as a new dependency boundary.

6. **Adopt the corrected whitespace converter design.** Preserve `%wEx` and `%xwEx` behavior using supported converter composition and option propagation. Validate empty/non-empty throwables, short/full/extended options, configured separators, nested causes, and Windows/Unix newlines. The final 2.25.2 upstream converter approach takes precedence over the initially reapplied 2.25.1 design where they differ.

7. **Test the selected runtime rather than only source compilation.** Focused `spring-boot` logging tests will be followed by the ordinary Log4j2, Actuator Log4j2, and structured-logging Log4j2 smoke modules. Dependency metadata and plugin cache/GraalVM output will be inspected before clean project gates.

8. **Close CVE deferrals only after the migration is proven.** Until the final dependency graph, focused tests, clean thin build, and required project gates succeed, all seven records remain deferred/in progress. If a migration regression cannot be resolved, revert the version and code together and retain the existing bounded deferral.

9. **Add direct security regression where safe and meaningful.** For CVE-2026-49844, format `MapMessage` values containing `NaN`, positive infinity, and negative infinity as JSON and assert valid fixed behavior. For the other six CVEs, use focused upstream tests or configuration-level regression where available; do not introduce unsafe external network or injection tests into the main build without isolation.

10. **Distinguish source component identity from published NES GAVs.** The default source project remains `cn.bjca.footstone.bpring.boot:spring-boot-starter-logging` inside the Gradle composite, while `DeployedPlugin` publishes it as `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-logging`. The Log4j2 alternative is published as `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-log4j2`. Gradle component replacement in smoke tests must use source component identities; consumer documentation and generated publications must use the prefixed NES GAVs.

11. **Preserve upstream BOM exceptions.** `log4j-bom:2.25.5` manages the active 2.25.x modules at 2.25.5 but deliberately retains `log4j-flume-ng` at 2.23.1. This project will not force that retired integration artifact to 2.25.5 merely for numerical uniformity. Verification instead requires the 2.25.5 BOM import, 2.25.5 for the seven-CVE-relevant and representative runtime modules, and no project-owned module-level override.

## Risks / Trade-offs

- **[Exception text changes for Log4j2 users]** → Compare exact structured fields and normalized stack-trace output in focused unit and smoke tests, including custom `StackTracePrinter` behavior and platform line endings.
- **[Whitespace converters lose an option or handle throwables twice]** → Cover converter keys, `handlesThrowable`, short/full/extended options, separators, causes, and no-throwable events using the corrected upstream implementation as reference.
- **[Public setters appear to widen Boot API]** → Keep affected builders package-private/final where already designed, expose only processor-required methods, document the compatibility purpose, and avoid treating them as new supported public API.
- **[GraalVM metadata is generated under the wrong artifact identity]** → Inspect generated metadata and native/AOT-related tests using the current `spring-boot` module coordinates.
- **[2.25.5 introduces behavior beyond the earlier 2.25.2 upstream port]** → Review 2.25.3 through 2.25.5 release notes and run all targeted Log4j2 tests against 2.25.5 rather than assuming the earlier migration is sufficient.
- **[Default applications accidentally switch logging systems]** → Verify default starter graphs still select Logback and Log4j2 remains opt-in.
- **[Security documentation is marked fixed before code is stable]** → Perform status changes last and retain the current VEX deferrals until verification tasks are complete.

## Migration Plan

1. Reconfirm all seven advisory ranges/fixed versions, Log4j2 2.25.5 artifacts, the current default logging graph, and the upstream adaptation commit sequence.
2. Apply the BOM, plugin processor, GraalVM processor, `Throwable`, structured formatter, converter, test, and smoke-test adaptations in small reviewable groups.
3. Compile from a clean state and run focused logging/plugin/structured tests, then all three Log4j2 smoke modules.
4. Run advisory-focused regression, dependency/BOM checks, clean thin build, core tests, and the final required gate.
5. Only after success, update the seven CVE records and classifications from deferred to fixed and synchronize totals and VEX.
6. Strictly validate OpenSpec and review the final diff for API, dependency ownership, and evidence consistency.

Rollback reverts the Log4j2 BOM version and all source/build/test adaptations as one unit, restores the seven bounded deferrals, and preserves their reevaluation triggers. Documentation must not claim fixed status if rollback occurs. No publication rollback is required because publication is out of scope.

## Implementation Evidence

- The generated dependency-management POM imports `log4j-bom:2.25.5`; the resolved BOM selects 2.25.5 for all seven-CVE-relevant and representative runtime modules and preserves the upstream `log4j-flume-ng:2.23.1` exception without a project override.
- Generated publications confirm `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-logging` remains Logback-based with `log4j-to-slf4j:2.25.5`, while `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-starter-log4j2` selects its runtime modules at 2.25.5.
- A clean `spring-boot:compileJava` completed in 2m 33s; the Log4j processor generated 12 plugins and GraalVM metadata for 10 classes under `cn.bjca.footstone.bpring.boot/bjca-footstone-bpring-boot` with no stale 2.24.3 data.
- Focused Log4j2 tests completed in 1m 23s. The expanded `%wEx`/`%xwEx` suite ran 18 tests covering aliases, short/full/extended output, separators, causes, no-throwable events, and normalized line endings; its final run completed in 26s.
- Ordinary Log4j2, Actuator Log4j2, and structured-logging Log4j2 smoke modules completed in 1m 31s. The CVE-2026-49844 regression verified `NaN`, `Infinity`, and `-Infinity` as JSON strings.
- `make clean build-thin` completed successfully: clean in 12s and assemble in 3m 13s with 828 actionable tasks (780 executed, 35 from cache, 13 up-to-date).
- `make test` completed successfully in 7m 35s with 42 actionable tasks (9 executed, 2 from cache, 31 up-to-date).
- A later package-level Log4j2 rerun failed 1/174: `Log4J2LoggingSystemTests#getLoggerConfigurationsShouldReturnAllLoggers`. Under 2.25.5, a Nested logger created through `LogManager` could be collected before `getLoggerConfigurations()`. The test was stabilized with the upstream-derived change from `7d343204016` (register the logger through the package-private `TestLog4J2LoggingSystem#getLoggerContext()`). The single method, the 59-test class, and all 174 package tests then passed. Because a focused failure occurred, `make test-gate` became required.
- The first `make test-gate` was cancelled during `:spring-boot-autoconfigure:test` when the Codex session died (HTTP 429) and is not counted as a pass. The rerun completed `BUILD SUCCESSFUL in 16m 6s` with 114 actionable tasks (15 executed, 6 from cache, 93 up-to-date).
- `make test-bom-security-audit` completed all 9 deterministic audit tests successfully. Remote Spring build-cache HTTP 403 responses caused Gradle to fall back to local execution and did not fail any gate.

## Open Questions

- Does Log4j2 2.25.5 require any additional adaptation beyond the known 2.25.2 source migration, particularly in plugin cache or GraalVM metadata? Resolve during the first clean compile and document only observed results.
- Which existing Log4j2 upstream tests directly exercise the six non-MapMessage CVE fixes and can be reused safely in this fork? Identify during implementation; retain vendor release/advisory evidence where a project-level exploit reproduction is not appropriate.
- Should the public plugin setters use the upstream exact visibility/checkstyle approach or a processor suppression accepted by 2.25.5? Prefer the upstream public-setter contract unless current processor evidence demonstrates an equally supported narrower option.
