## Context

Spring Boot currently manages Yasson 3.0.4 but does not manage Parsson directly. Yasson's published POM requests `org.eclipse.parsson:parsson:1.1.7`, while the Elasticsearch Java client requests 1.0.5, so the selected transitive version varies with the consumer graph. Maven Central identifies Parsson 1.1.9 as the latest 1.1.x release as of 2026-08-11, while OSV queries do not identify an applicable Parsson advisory.

Yasson 3.0.5 would also move Parsson to 1.1.9, but that release relocates the Yasson coordinate from `org.eclipse:yasson` to `org.eclipse.yasson:yasson`. Combining a provider patch update with a coordinate migration would enlarge the compatibility and documentation scope unnecessarily.

## Goals / Non-Goals

**Goals:**

- Manage `org.eclipse.parsson:parsson` at 1.1.9 in the Boot BOM.
- Override Yasson 3.0.4's transitive Parsson 1.1.7 consistently for downstream consumers.
- Verify the generated Maven BOM and representative JSON-B runtime graphs select 1.1.9.
- Preserve accurate security documentation: this is proactive dependency maintenance, not remediation of an identified Parsson CVE.

**Non-Goals:**

- Upgrade or relocate Yasson to 3.0.5.
- Change Jakarta JSON API or Jakarta JSON Bind API versions.
- Change application source code, JSON behavior, or public APIs.
- Publish artifacts, deploy to Nexus, promote a release, or create Git tags.

## Decisions

1. **Manage Parsson directly as a Boot library.** Add a `Parsson` library entry at 1.1.9 for group `org.eclipse.parsson` and module `parsson`. This follows existing Boot BOM ownership patterns and provides a generated `parsson.version` property.

2. **Keep Yasson at 3.0.4.** The alternative of upgrading Yasson to 3.0.5 introduces a groupId relocation and requires source dependency, documentation, and compatibility review beyond the requested Parsson maintenance.

3. **Do not create a CVE record.** OSV currently reports no advisory for Parsson 1.1.7. Documentation will record the old and new versions and the proactive-maintenance rationale without inventing an affected range or fixed-CVE claim.

4. **Verify both metadata and resolution.** Generated BOM inspection proves downstream dependency management; `dependencyInsight` on JSON-B test runtime classpaths proves that Yasson's transitive request is upgraded to 1.1.9.

5. **Use focused JSON-B tests followed by project gates.** Run representative auto-configuration and JSON-B tester tests, then the dependency-remediation clean thin build and core test targets. If an unrelated known flaky test recurs, preserve the failure evidence and isolate it before deciding whether implementation is blocked.

6. **Do not override Parsson's new parsing limit globally.** Parsson 1.1.8 introduced a default maximum of 15,000,000 parser character-consumption operations, retained by 1.1.9 and configurable with `org.eclipse.parsson.maxParsingLimit`. Normal JSON-B behavior will be tested, while applications that intentionally process very large JSON documents must evaluate or configure this provider-specific limit themselves.

## Risks / Trade-offs

- **[Parsson 1.1.9 is incompatible with Jakarta JSON API 2.1.3]** → Parsson 1.1.9 declares the Jakarta JSON API without requiring a newer API line; verify JSON-B auto-configuration and tester paths.
- **[Direct management diverges from Yasson's declared 1.1.7]** → The override is intentional and limited to a compatible 1.1.x patch line; dependencyInsight must show one selected Parsson version.
- **[Security documentation overstates the reason]** → Record the OSV result and classify the upgrade as proactive maintenance, not CVE remediation.
- **[Concurrent tests pollute captured output]** → Use focused test execution for Parsson behavior and retain any full-gate failure details separately from dependency conclusions.
- **[Large JSON documents now exceed the provider default]** → Document the 15,000,000-operation default introduced after 1.1.7; downstream applications with unusually large JSON payloads must test and, if appropriate, set `org.eclipse.parsson.maxParsingLimit` explicitly.

## Migration Plan

1. Add Parsson 1.1.9 to Boot dependency management.
2. Generate the dependency BOM and confirm the new property and managed coordinate.
3. Inspect representative test runtime graphs and run JSON-B-focused tests.
4. Update requirements, GAV mapping, vulnerability baseline, and OpenSpec evidence.
5. Run project gates and strict OpenSpec validation before archive.

Rollback removes the Parsson library entry and restores documentation to the transitive 1.1.7 state. No remote rollback is required because this change performs no publication.

## Open Questions

None.

## Implementation Evidence

Evidence captured on 2026-08-10 and refreshed on 2026-08-11:

- Maven Central metadata reports `org.eclipse.parsson:parsson` latest/release `1.1.9`; OSV Maven queries for the observed transitive versions 1.1.7 and 1.0.5 returned `{}` at the final audit.
- Parsson 1.1.8 release notes identify the provider behavior changes, including the default 15,000,000-operation JSON parsing limit; 1.1.9 release notes contain publishing automation only. The compatibility boundary and `org.eclipse.parsson.maxParsingLimit` property are documented without adding a global override.
- `./gradlew :spring-boot-project:spring-boot-dependencies:generatePomFileForMavenPublication -x :buildSrc:test --refresh-dependencies --console=plain` completed with `BUILD SUCCESSFUL in 2m 12s`. The generated POM contains `parsson.version=1.1.9` and managed `org.eclipse.parsson:parsson`, while `yasson.version=3.0.4`, `jakarta-json.version=2.1.3`, and `jakarta-json-bind.version=3.0.2` remain unchanged.
- Separate `dependencyInsight` runs on `spring-boot-test` and `spring-boot-autoconfigure` test runtime classpaths selected Parsson 1.1.9 by constraint/force. Yasson 3.0.4 requested 1.1.7 and Elasticsearch Java client 8.18.8 requested 1.0.5; both resolved to 1.1.9. An initial combined two-task command applied `--configuration` only to one report task and exited nonzero for the other missing input; it did not report a dependency failure and was replaced by the successful separate command.
- Focused compatibility tests passed: `JsonbAutoConfigurationTests` plus `JsonbAutoConfigurationWithNoProviderTests` (`BUILD SUCCESSFUL in 3m 5s`), `JsonbTesterTests` (`20s`), and `JsonTestIntegrationTests` (`31s`).
- `make clean build-thin` completed successfully: clean in 4m 26s and assemble in 3m 50s with 828 actionable tasks.
- The first `make test` run completed 5,330 `spring-boot` tests with one unrelated `ReactorClientHttpConnectorBuilderTests.redirectDefault(GET)` failure (`expected 200`, `received 405`). The exact parameterized method reran successfully in 15s. A second complete `make test` finished with `BUILD SUCCESSFUL in 9m 5s`, including `spring-boot-test`.
- `make test-gate` was not required: all Parsson/JSON-B-focused tests, the clean thin build, and the final complete core test gate passed; the only initial core failure was isolated to an unrelated HTTP redirect timing/environment path and passed immediately on exact rerun.
- No `publish`, `deploy`, remote Nexus write, release promotion, Git commit, or Git tag operation was performed. `publish...ToProjectRepository` tasks observed during `assemble` write only to the build's local project repository staging area.
