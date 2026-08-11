## Context

The fork manages ActiveMQ Classic 6.1.8 and ActiveMQ Artemis 2.40.0 through BOM library declarations. A 2026-08-06 query of the generated resolved BOM against OSV, followed by vendor-advisory review and a recursive scan of the Artemis BOM's old and new group IDs, identified 12 ActiveMQ Classic CVEs and three Artemis CVEs that are absent from the current vulnerability ledger.

The ActiveMQ set comprises CVE-2025-66168, CVE-2026-33227, CVE-2026-34197, CVE-2026-39304, CVE-2026-40046, CVE-2026-40466, CVE-2026-41043, CVE-2026-41044, CVE-2026-42253, CVE-2026-42588, CVE-2026-45505, and CVE-2026-49270. It includes an authenticated Jolokia/MBean RCE listed in CISA KEV, plus additional code-injection, denial-of-service, information-exposure, validation, integer-overflow, and XSS advisories. The highest required 6.x fixed version among the batch is 6.2.6. ActiveMQ 6.2.8 is available and the project's Docker test support already exercises an ActiveMQ 6.2.x server.

Artemis 2.40.0 is affected by Critical CVE-2026-27446 when an untrusted Core connection can cause federation to an attacker-controlled broker, by CVE-2026-32642 in the OpenWire protocol, and by CVE-2026-40914 when a STOMP user with send or consume permission but without `createAddress` permission can augment an address's routing type. The fixes are available in 2.52.0, 2.53.0, and 2.54.0 respectively. In 2.54.0 the authoritative BOM moved from `org.apache.activemq` to `org.apache.artemis`; the old BOM is only a relocation POM whose parent dependency management is not imported by the project's Gradle path. Docker test support targets Artemis 2.53.0 and must be aligned with the selected 2.54.0 dependency BOM.

Neither dependency is part of the minimal `spring-boot-starter` runtime, but the fork directly publishes ActiveMQ and Artemis starters and supports embedded brokers. The BOM therefore exposes affected versions to supported downstream configurations and must not classify them as immune merely because a particular starter is optional.

## Goals / Non-Goals

**Goals:**

- Manage ActiveMQ Classic at 6.2.8 and Artemis at 2.54.0 using the authoritative upstream BOM declarations and supported coordinates.
- Verify client-only starter paths and embedded-broker paths for both messaging implementations.
- Record all 15 findings with authoritative ranges, trigger conditions, project applicability, fixed versions, and test evidence.
- Pass generated-BOM checks, targeted messaging tests, a clean thin build, and the core test target.
- Keep requirements, vulnerability records, and OpenSpec artifacts synchronized with an audit cutoff of 2026-08-06.

**Non-Goals:**

- Upgrade ActiveMQ to 6.3.x or Artemis beyond 2.54.0 solely because newer releases exist.
- Change Spring Boot JMS APIs, configuration-property names, auto-configuration semantics, or default starter composition.
- Remediate the remaining Derby, Commons Lang, QueryDSL, OpenTelemetry, Undertow, Infinispan, Spring Integration, or Log4j2 audit findings; those belong to the dependent follow-up change.
- Change the fork version, publish artifacts, or redeploy the existing Nexus release.

## Decisions

1. **Select ActiveMQ 6.2.8.** The batch requires at least 6.2.6; 6.2.8 is the latest available 6.2.x maintenance release observed during the audit and produced no OSV findings for the broker, client, web, or MQTT modules. Using 6.2.8 avoids the additional compatibility surface of 6.3.x while covering the complete batch. Selecting only 6.2.6 was rejected because later maintenance fixes are already available on the same line.

2. **Select Artemis 2.54.0.** CVE-2026-27446 is fixed in 2.52.0, CVE-2026-32642 in 2.53.0, and CVE-2026-40914 in 2.54.0. The last advisory was exposed only after recursively scanning the 2.53.0 BOM's `org.apache.activemq` and `org.apache.artemis` managed coordinates, so 2.54.0 is the minimum version covering all three findings. A target-version OSV query returned no matches for the complete 2.54.0 module set. Moving immediately to 2.55.0 was rejected because it adds unrelated change without improving coverage of the identified findings.

3. **Import the authoritative Artemis BOM while retaining module compatibility.** Production dependency versions remain owned by `library("ActiveMQ", ...)` and `library("Artemis", ...)`, but the Artemis library group changes to `org.apache.artemis` because `org.apache.activemq:artemis-bom:2.54.0` is only a relocation POM and does not provide usable Gradle dependency management. The authoritative `org.apache.artemis:artemis-bom:2.54.0` manages both new `org.apache.artemis:artemis-*` modules and relocation-compatible `org.apache.activemq:artemis-*` modules. Existing starter and auto-configuration dependency coordinates remain on the old group for this change, with no module-specific version declarations, minimizing downstream breakage. The Docker test image is aligned separately to 2.54.0 so runtime evidence matches the selected dependency release.

4. **Treat optionality as applicability context, not immunity.** CVE records distinguish client, broker, web-console/Jolokia, Core federation, OpenWire, and STOMP triggers. Findings that require the embedded broker or web console remain affected at the BOM level even when the minimal runtime does not include those paths.

5. **Verify both compile-time API compatibility and runtime messaging behavior.** Targeted checks cover the ActiveMQ and Artemis auto-configuration tests, the client smoke tests, embedded-broker smoke tests, Docker-backed tests where available, and generated BOM contents. The existing full clean gates remain mandatory before a fixed status is recorded.

6. **Use evidence-based ledger entries rather than one aggregate status.** The overview may group the ActiveMQ batch, but every assigned CVE receives a detail record or an explicitly indexed shared record containing the authoritative advisory, affected modules/ranges, trigger, managed version, selected fix, and verification evidence.

## Risks / Trade-offs

- **[ActiveMQ crosses from 6.1.x to 6.2.x]** → Run starter, embedded broker, pooled connection, JMS auto-configuration, and smoke tests; inspect release notes if serialization, transport, or configuration behavior changes.
- **[Artemis spans multiple 2.x releases and changes BOM groupId]** → Import `org.apache.artemis:artemis-bom`, compile existing old-group consumers through its relocation management, run native/client plus embedded server tests against 2.54.0, verify both coordinate families resolve consistently, and align the Docker image.
- **[Some ActiveMQ CVEs only affect the web console or authenticated management users]** → Preserve those trigger conditions in documentation while still removing the affected managed version.
- **[The Critical Artemis issue requires two network conditions]** → Document the Core-protocol and outbound-connectivity prerequisites, but prefer the fixed dependency over relying on deployment-specific mitigation.
- **[The Artemis STOMP issue is authorization-specific]** → Preserve the send/consume-without-`createAddress` trigger and exercise supported STOMP behavior where the existing test surface permits it.
- **[A dependency regression could delay the urgent batch]** → Keep this change isolated from QueryDSL and OpenTelemetry work; roll back only the failing messaging pin and retain its CVEs as affected with mitigation evidence rather than marking them fixed.

## Migration Plan

1. Change the ActiveMQ version, change the Artemis version to 2.54.0, and switch its BOM import group to `org.apache.artemis` while retaining existing module consumers.
2. Generate and inspect the resolved BOM/POM for 6.2.8 and 2.54.0, verifying the new BOM import, both Artemis module group IDs, and no module-level version override.
3. Align the Artemis Docker test image to 2.54.0 and run targeted ActiveMQ and Artemis compile, auto-configuration, smoke, embedded-broker, protocol, and Docker tests.
4. Run clean `make build-thin` and `make test`; run `make test-gate` if required by failures or the final risk review.
5. Update requirements, the vulnerability overview, CVE details, and OpenSpec evidence only after successful verification.
6. Archive the change after strict OpenSpec validation. Release/Nexus work remains separate.

Rollback consists of restoring the two BOM pins and reverting fixed classifications. A rollback must retain the findings as affected or explicitly deferred with their deployment mitigations.

## Open Questions

None blocking proposal readiness. Implementation must confirm whether any ActiveMQ 6.2 or Artemis 2.54 release-note change requires an additional regression test beyond the existing messaging suites.

## Implementation Evidence

- Managed versions are owned only by the dependency BOM libraries: ActiveMQ Classic `6.2.8` and Artemis `org.apache.artemis:artemis-bom:2.54.0`; no module-specific override was added. Existing `org.apache.activemq:artemis-*` consumers remain managed by the new BOM's relocation-compatible entries.
- Generated dependency-management POM and resolved BOM verification found 39 `org.apache.activemq` Artemis modules and 39 `org.apache.artemis` Artemis modules, all resolving to `2.54.0`; ActiveMQ modules resolve to `6.2.8` without drift. The Artemis Docker image is aligned to `2.54.0`.
- Target-version OSV scans returned no matches for the complete ActiveMQ 6.2.8 and Artemis 2.54.0 module sets. JMS auto-configuration tests passed (ActiveMQ 19, Artemis 30); starter assembly, embedded ActiveMQ smoke, embedded Artemis startup/client paths, Actuator JMS health (2), and Compose environment checks (12) passed.
- Docker/Testcontainers/Compose-backed messaging tests were invoked. Ten tests were skipped by their documented Docker prerequisite because the host had no Docker CLI/daemon and the Podman VM repeatedly returned to `State: stopped`; these skips are recorded with the non-container compensation evidence above.
- The Artemis STOMP finding (CVE-2026-40914) has no direct negative authorization test for a send/consume user lacking `createAddress`; the record explicitly avoids claiming such coverage and relies on fixed-module resolution, OSV, embedded startup, and existing protocol tests as compensation.
- Full project gates completed against the changed dependency state: `make clean build-thin` was `BUILD SUCCESSFUL` in 19m02s, `make test` was `BUILD SUCCESSFUL` in 39m33s, and the final `make test-gate` invocation was `BUILD SUCCESSFUL` in 2m59s. The first `make test-gate` invocation had one unrelated WebFlux integration-test `PrematureCloseException`; the failed method and complete test class both passed on isolated rerun before the full gate passed on rerun.
