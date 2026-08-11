## 1. Confirm the Advisory Baseline

- [x] 1.1 Reconfirm the authoritative Apache, GitHub Advisory/OSV, NVD where available, and CISA KEV evidence for CVE-2025-66168, CVE-2026-33227, CVE-2026-34197, CVE-2026-39304, CVE-2026-40046, CVE-2026-40466, CVE-2026-41043, CVE-2026-41044, CVE-2026-42253, CVE-2026-42588, CVE-2026-45505, CVE-2026-49270, CVE-2026-27446, CVE-2026-32642, and CVE-2026-40914, including affected modules, ranges, fixed branches, and the 2026-08-06 audit cutoff.
- [x] 1.2 Record the client, broker, MQTT, web console, Jolokia, Core federation, OpenWire, and STOMP trigger conditions without treating optional starter usage as BOM-level immunity, and deduplicate GHSA/OSV aliases to the 15 assigned CVEs.

## 2. Update the Managed Messaging Versions

- [x] 2.1 Change only the ActiveMQ library pin in `spring-boot-project/spring-boot-dependencies/build.gradle` from 6.1.8 to 6.2.8.
- [x] 2.2 Change the Artemis library from `org.apache.activemq:artemis-bom:2.40.0` to the authoritative `org.apache.artemis:artemis-bom:2.54.0` without adding module-specific versions.
- [x] 2.3 Verify that no starter, module, or test introduces a second ActiveMQ or Artemis version override and that existing `org.apache.activemq:artemis-*` consumers remain managed through the new BOM's relocation entries.
- [x] 2.4 Regenerate the dependency-management POM and resolved BOM, then verify ActiveMQ resolves to 6.2.8, Artemis resolves to 2.54.0, the BOM import uses `org.apache.artemis`, and both supported Artemis module group IDs are managed without unexpected drift.

## 3. Verify ActiveMQ Compatibility

- [x] 3.1 Compile and run the relevant ActiveMQ starter, JMS auto-configuration, connection-factory, and pooled-connection tests against ActiveMQ 6.2.8.
- [x] 3.2 Run the ActiveMQ client and embedded-broker smoke/integration paths, covering supported transport and configuration behavior affected by the 6.1.x to 6.2.x transition.
- [x] 3.3 Run the available Docker-backed ActiveMQ tests; if an environment prerequisite prevents execution, record the exact prerequisite and compensating evidence rather than silently skipping the test.

## 4. Verify Artemis Compatibility

- [x] 4.1 Compile and run the relevant Artemis starter, JMS auto-configuration, native client, and connection-factory tests against Artemis 2.54.0.
- [x] 4.2 Run the Artemis client and embedded-server smoke/integration paths, including supported Core, OpenWire, and STOMP behavior exercised by the project.
- [x] 4.3 Align the Artemis Docker test image to 2.54.0 and run the available Docker-backed Artemis tests; if an environment prerequisite prevents execution, record the exact prerequisite and compensating evidence.

## 5. Run Clean Project Verification

- [x] 5.1 Run `make clean build-thin` and retain BUILD SUCCESSFUL evidence tied to the changed dependency state.
- [x] 5.2 Run `make test` and retain BUILD SUCCESSFUL evidence tied to the changed dependency state.
- [x] 5.3 Run `make test-gate` when required by a targeted-test failure or the final risk review; otherwise record the evidence-based reason that the additional gate was not required.

## 6. Synchronize Security and Project Documentation

- [x] 6.1 Update `doc/REQUIREMENTS.md` with the implemented ActiveMQ 6.2.8 and Artemis 2.54.0 minimums, compatibility boundaries, and required verification gates.
- [x] 6.2 Update `doc/VULNERABILITY_REPORT.md` to the 2026-08-06 or later audit cutoff, correct totals/indexes, and show the ActiveMQ and Artemis findings as fixed only after all required evidence succeeds.
- [x] 6.3 Create or update the applicable `doc/CVE/` records so every one of the 15 CVEs has authoritative references, affected modules/ranges, trigger conditions, applicability, selected fix, and verification evidence.
- [x] 6.4 Update `doc/NES_GAV_MAPPING.md` with the Artemis BOM groupId migration and the temporary compatibility policy for old-group module coordinates.
- [x] 6.5 Update the OpenSpec change evidence to match the actual implementation and preserve affected or deferred classifications for any dependency that must be rolled back.

## 7. Validate the Completed Change

- [x] 7.1 Run `openspec validate remediate-activemq-artemis-cves-august-2026 --type change --strict` and resolve every validation error.
- [x] 7.2 Review the final diff for BOM-only version ownership, documentation consistency, test evidence, and absence of release-version, publication, or Nexus deployment changes.
