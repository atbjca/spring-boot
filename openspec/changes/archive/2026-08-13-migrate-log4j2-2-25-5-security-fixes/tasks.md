## 1. Establish Advisory and Upstream Migration Baseline

- [x] 1.1 Reconfirm authoritative affected ranges, fixed versions, triggers, and references for CVE-2025-68161, CVE-2026-34477, CVE-2026-34478, CVE-2026-34479, CVE-2026-34480, CVE-2026-34481, and CVE-2026-49844.
- [x] 1.2 Capture the current Log4j2 2.24.3 BOM, default Logback graph, opt-in Log4j2 graphs, and the existing seven-CVE deferred/VEX classifications.
- [x] 1.3 Review upstream 2.25.1/2.25.2 adaptation and rollback commits file by file, map later repository paths to current `spring-boot-project` paths, and identify any 2.25.3–2.25.5 release-note changes requiring additional work.
- [x] 1.4 Inventory current Log4j2 unit, structured logging, plugin, smoke, Actuator, and AOT/GraalVM tests and define the clean verification order.

## 2. Upgrade the BOM and Build Integration

- [x] 2.1 Change only the BOM-owned `Log4j2` library version from 2.24.3 to stable 2.25.5 and retain its existing module set.
- [x] 2.2 Update `spring-boot` compile configuration to pass the correct current groupId and artifactId to `GraalVmProcessor` without globally weakening `-Werror` or annotation processing.
- [x] 2.3 Adapt `@PluginBuilderAttribute` builder setters to the 2.25.5 processor contract and add narrowly scoped Checkstyle rationale/suppressions where required.
- [x] 2.4 Generate dependency-management POM and resolved BOM evidence; confirm the imported Log4j2 BOM and all seven-CVE-relevant and representative runtime modules select 2.25.5 with no project module-level override or prerelease, while preserving upstream BOM exceptions such as `log4j-flume-ng:2.23.1`.

## 3. Migrate Log4j2 Source Compatibility

- [x] 3.1 Replace `LogEvent.getThrownProxy()` and direct `ThrowableProxy` use in ECS, GELF, Logstash, and extractor code with supported `Throwable` APIs while preserving error schema and stack-trace-printer behavior.
- [x] 3.2 Rework `WhitespaceThrowablePatternConverter` and `ExtendedWhitespaceThrowablePatternConverter` using the corrected supported converter composition and option propagation for 2.25.5.
- [x] 3.3 Update custom structured formatter and related test-support code to the current Log4j2 API without changing Boot's public structured-logging contract.
- [x] 3.4 Inspect for remaining Log4j2 deprecation warnings under `-Xlint:deprecation -Werror` and resolve only the affected 2.25.5 compatibility cases.

## 4. Run Focused Logging and Security Regression Tests

- [x] 4.1 Run focused Log4j2 unit tests for plugin builders, XML/property sources, logging system behavior, structured layout, ECS/GELF/Logstash formatters, extractors, throwable converters, custom formatters, and exception output.
- [x] 4.2 Verify `%wEx`, `%xwEx`, aliases, short/full/extended options, separator behavior, causes, no-throwable events, and normalized Windows/Unix line endings.
- [x] 4.3 Run the ordinary Log4j2, Actuator Log4j2, and structured-logging Log4j2 smoke-test modules against 2.25.5.
- [x] 4.4 Inspect generated plugin metadata, annotation-processor output, and any AOT/GraalVM-related artifacts for warnings, missing coordinates, or stale 2.24.3 cache data.
- [x] 4.5 Add or run isolated regression coverage for CVE-2026-49844 using `MapMessage` JSON with `NaN`, positive infinity, and negative infinity, asserting valid fixed output without enabling a vulnerable path by default.
- [x] 4.6 For CVE-2025-68161 and CVE-2026-34477 through CVE-2026-34481, run safe applicable upstream/project regression tests or document vendor-release evidence and configuration-level verification for each affected appender/layout trigger.

## 5. Run Clean Project Gates

- [x] 5.1 Run a clean `spring-boot` compile first so no 2.24.3 class cache can mask processor, API, or deprecation failures.
- [x] 5.2 Run `make clean build-thin` against the final 2.25.5 source and dependency state and retain the actual result.
- [x] 5.3 Run `make test` against the same clean state and retain the actual result.
- [x] 5.4 Run `make test-gate` when required by the final risk review or any focused/full-test failure; otherwise record the evidence-based reason it was not required. Required after a package-level focused failure: `Log4J2LoggingSystemTests#getLoggerConfigurationsShouldReturnAllLoggers` (1/174) because a temporary Nested logger registered through `LogManager` could be collected before `getLoggerConfigurations()` under 2.25.5. Stabilized by the upstream-derived change in `7d343204016` (register the logger through `TestLog4J2LoggingSystem#getLoggerContext()`). After that, the single method, the 59-test class, and all 174 `org.springframework.boot.logging.log4j2.*` tests passed. The first `make test-gate` was cancelled during `:spring-boot-autoconfigure:test` when the Codex session died (HTTP 429) and is not counted as a pass. Rerun `make test-gate` completed `BUILD SUCCESSFUL in 16m 6s` (114 actionable tasks: 15 executed, 6 from cache, 93 up-to-date).

## 6. Synchronize Seven CVE Classifications and Documentation

- [x] 6.1 Update the seven independent `doc/CVE/` records with Log4j2 2.25.5, actual affected modules/triggers, source migration notes, verification commands/results, and final audit cutoff.
- [x] 6.2 Update `doc/CVE/Log4j2-2.25-upgrade-assessment.md` from a deferral assessment to an implemented migration assessment, retaining the historical compatibility failures and documenting their actual fixes.
- [x] 6.3 Update `doc/REQUIREMENTS.md`, `doc/VULNERABILITY_REPORT.md`, and `doc/NES_GAV_MAPPING.md` with the final Log4j2 version, default-runtime reachability, fixed totals, and no unrelated dependency changes.
- [x] 6.4 Update `scripts/security-audit/vex-decisions.json` and audit fixtures/tests so all seven IDs classify consistently as fixed only after the final verification evidence is present.
- [x] 6.5 Update the dependency security OpenSpec capability and this change's implementation evidence only after the code, tests, and gates complete; preserve deferred status if rollback occurs.

## 7. Validate the Completed Change

- [x] 7.1 Run affected security-audit unit/fixture tests and reconcile every advisory alias, count, and status mismatch.
- [x] 7.2 Run `openspec validate migrate-log4j2-2-25-5-security-fixes --type change --strict` and resolve every validation error.
- [x] 7.3 Review the final diff for BOM-only Log4j2 ownership, default Logback preservation, public API compatibility, clean-test evidence, synchronized seven-CVE statuses, and absence of release, publication, Nexus, `.claude/`, `.codex/`, or `.cursor/` changes.

### Evidence

- `make test-bom-security-audit`: 9/9 passed (2026-08-13).
- `openspec validate migrate-log4j2-2-25-5-security-fixes --type change --strict`: valid.
- `git diff --check`: clean.
- Final `make test-gate` rerun: `BUILD SUCCESSFUL in 16m 6s` (114 actionable tasks: 15 executed, 6 from cache, 93 up-to-date). The cancelled Codex session run is not counted.
- Version remains `3.5.15-nes.patch.2-SNAPSHOT`; no publish/deploy/Nexus action.
- Untracked `.claude/`, `.codex/`, `.cursor/` were not modified or staged. Prior HttpCore5/Parsson worktree files are preserved and not attributed to this change.
