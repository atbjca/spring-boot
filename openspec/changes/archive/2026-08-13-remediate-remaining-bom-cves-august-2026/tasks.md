## 1. Establish the Implementation Baseline

- [x] 1.1 Verify that `remediate-activemq-artemis-cves-august-2026` is completed and archived, and regenerate the resolved BOM showing ActiveMQ Classic 6.2.8 plus `org.apache.artemis:artemis-bom:2.54.0` with both supported Artemis module group IDs before making this change.
- [x] 1.2 Reconfirm authoritative vendor/GHSA/OSV/NVD evidence, affected modules and ranges, fixed versions where available, and the 2026-08-06 or later cutoff for CVE-2022-46337, CVE-2025-48924, CVE-2024-49203, CVE-2026-45292, CVE-2026-59949, CVE-2026-3260, CVE-2025-5731, CVE-2026-40987, and CVE-2025-68161. Current evidence records the 2026-07-07 CNA rejection for CVE-2026-3260, the Red Hat fixed boundary for Infinispan, and the Spring Integration 6.5.9 fix boundary.
- [x] 1.3 Capture the pre-change generated-BOM coordinates and vulnerability classifications so every later fixed, deferred, or false-positive decision can be traced to the exact baseline.

## 2. Add the Complete Resolved-BOM Audit Workflow

- [x] 2.1 Implement a repository-owned opt-in audit command that accepts `spring-boot-project/spring-boot-dependencies/build/createResolvedBom/resolved-bom.json` and emits a normalized machine-readable report without making online lookup part of the normal offline build.
- [x] 2.2 Enumerate and deduplicate all directly managed and imported-BOM Maven coordinates, create canonical PURLs, reconcile the output count with the input under a documented duplicate policy, and report every omitted or malformed coordinate as an error.
- [x] 2.3 Add a machine-readable NES-to-upstream alias manifest containing coordinate and version-normalization rules but no duplicated managed dependency versions.
- [x] 2.4 Query both private and canonical upstream PURLs in OSV batch operations, retain mapping provenance and all advisory aliases, and fail the audit as incomplete on lookup errors, truncation, stale metadata, or inventory-count mismatch.
- [x] 2.5 Normalize OSV/GHSA/CVE aliases and provide VEX-style affected, fixed, immune/not-applicable, false-positive, and deferred classification fields with source timestamp and database/advisory freshness.
- [x] 2.6 Add deterministic tests or fixtures for duplicate coordinates, Maven PURL encoding, empty and failed lookups, alias deduplication, and representative Spring Boot, Framework, Security, Data, and Kafka fork mappings.
- [x] 2.7 Document how a fresh secondary SCA source such as Grype may corroborate the audit and ensure an unavailable or stale local database cannot be used as clean-state evidence.

## 3. Remediate Four Findings and Bound Derby

- [x] 3.1 Retain the Derby BOM library pin at 10.16.1.1 and record the evidence-backed CVE-2022-46337 deferral: Maven Central has no complete 10.16.1.2 publication, Derby 10.17.1.0 requires post-Java-17 bytecode, and LDAP-authenticated Derby is the bounded trigger.
- [x] 3.2 Change only the Commons Lang3 BOM library pin from 3.17.0 to 3.18.0.
- [x] 3.3 Change the OpenTelemetry BOM library pin from 1.49.0 to 1.62.0, retain the existing `io.opentelemetry` coordinate set, and align the parent-only OkHttp test library from 4.12.0 to the exporter-required 5.3.2 without adding OkHttp to the published dependency-management BOM.
- [x] 3.4 Replace the QueryDSL BOM declaration `com.querydsl:querydsl-bom:5.1.0` with `io.github.openfeign.querydsl:querydsl-bom:5.6.1`, updating project and release-note links to the maintained lineage.
- [x] 3.5 Change the `spring-boot-autoconfigure` optional `querydsl-core` dependency to `io.github.openfeign.querydsl:querydsl-core` without changing `com.querydsl` Java imports or public auto-configuration APIs.
- [x] 3.6 Verify that no module-level version override was introduced and that the BOM remains the single source for Derby, Commons Lang3, OpenTelemetry, and QueryDSL versions.
- [x] 3.7 Regenerate the dependency-management POM and resolved BOM, verify retained Derby 10.16.1.1 plus the selected Commons Lang3, OpenTelemetry, OpenFeign QueryDSL, and LZ4 Java versions, confirm all QueryDSL managed modules use the OpenFeign group, and confirm no vulnerable `com.querydsl` 5.1.0 management remains.
- [x] 3.8 Add a single Boot BOM library for `at.yawk.lz4:lz4-java:1.11.2`, overriding Kafka 3.9.2's affected transitive 1.10.1 selection without changing Kafka or Spring Kafka versions.
- [x] 3.9 Regenerate dependency metadata and verify Kafka client and Streams graphs select only LZ4 Java 1.11.2 with no `at.yawk.lz4` 1.10.1 or archived `org.lz4` fallback.

## 4. Run Targeted Compatibility and Security Tests

- [x] 4.1 Run the relevant Derby embedded-database, JDBC, initialization, and supported Java 17 tests against retained 10.16.1.1, and retain evidence that published Derby 10.17.1.0 bytecode is incompatible with Java 17.
- [x] 4.2 Run the modules and utility paths that compile or execute with Commons Lang3, including dependency-resolution checks that prove 3.18.0 is selected.
- [x] 4.3 Run imperative and reactive GraphQL QueryDSL auto-configuration tests plus applicable Spring Data QueryDSL integration/compile checks against the OpenFeign 5.6.1 artifacts.
- [x] 4.4 Verify that representative downstream `querydsl-jpa` and `querydsl-apt` dependency-management examples resolve only after adopting the OpenFeign group and retain the expected `com.querydsl` Java packages.
- [x] 4.5 Run OpenTelemetry auto-configuration, Micrometer tracing bridge, W3C trace and baggage propagation, baggage-enabled and baggage-disabled, OTLP/Zipkin exporter, metrics/logs, and service-connection tests against 1.62.0.
- [x] 4.6 Add or run an advisory-focused W3C baggage regression that exercises the upstream bounded-allocation behavior without weakening existing propagation semantics.
- [x] 4.7 Run valid LZ4 compression/decompression plus representative Kafka client, Streams, and auto-configuration tests against 1.11.2; do not reproduce the vulnerable JNI invalid-range payload in the project test JVM.

## 5. Verify Deferred and False-Positive Classifications

- [x] 5.1 Verify Undertow 2.3.26.Final's default request entity-size constraint and reconcile CVE-2026-3260 as CNA-rejected/not applicable while retaining the original scanner alias.
- [x] 5.2 Resolve the default Infinispan cache starter/runtime graph and prove it does not include or invoke `infinispan-cli-client`; verify managed 15.2.6.Final is outside the Red Hat affected boundary and retain the original alias evidence.
- [x] 5.3 Verify from the vendor module range that CVE-2026-40987 affects Spring Integration file support through 6.5.8, is fixed in 6.5.9, and that managed Spring Integration 6.5.10 is not affected, retaining the original scanner association as false-positive evidence.
- [x] 5.4 Recheck the default logging graph and the known Log4j2 2.25.x compatibility failures before preserving the bounded Log4j2 2.24.3 deferral.

## 6. Run the Full Audit and Project Gates

- [x] 6.1 Run the complete resolved-BOM audit against the final post-change BOM, record the actual managed-coordinate count and source freshness, and reconcile every candidate advisory rather than treating scan hits as automatically exploitable.
- [x] 6.2 Confirm the selected Commons Lang3, OpenFeign QueryDSL, OpenTelemetry, and LZ4 Java targets have no unresolved applicable findings at the recorded cutoff; retain Derby CVE-2022-46337 and any unrelated hit with an explicit classification.
- [x] 6.3 Run `make clean build-thin` and retain BUILD SUCCESSFUL evidence tied to the final dependency state.
- [x] 6.4 Run `make test` and retain BUILD SUCCESSFUL evidence tied to the final dependency state.
- [x] 6.5 Run `make test-gate` when required by a targeted-test failure or the final risk review; otherwise record the evidence-based reason that the additional gate was not required.

## 7. Synchronize Requirements and Vulnerability Documentation

- [x] 7.1 Update `doc/REQUIREMENTS.md` with the implemented fixed versions, QueryDSL coordinate migration, full-BOM audit requirement, deferred-risk boundaries, and verification gates.
- [x] 7.2 Update `doc/VULNERABILITY_REPORT.md` to the final audit cutoff with correct fixed, affected/deferred, immune/not-applicable, and false-positive totals and indexes.
- [x] 7.3 Create or update `doc/CVE/` records for Derby CVE-2022-46337, Commons Lang CVE-2025-48924, QueryDSL CVE-2024-49203, OpenTelemetry CVE-2026-45292, Undertow CVE-2026-3260, Infinispan CVE-2025-5731, and Spring Integration CVE-2026-40987 with authoritative evidence and actual verification results.
- [x] 7.4 Add CVE-2025-68161 to the Log4j2 ledger and detail set, then correct `doc/CVE/Log4j2-2.25-upgrade-assessment.md` so its stated count, table, trigger matrix, wording, and seven-CVE scope agree.
- [x] 7.5 Update `doc/NES_GAV_MAPPING.md` for the OpenFeign QueryDSL migration and synchronize its fork/upstream descriptions with the machine-readable audit alias manifest.
- [x] 7.6 Update OpenSpec implementation evidence only after tests and audit results are known, and ensure rolled-back items are not left marked fixed.
- [x] 7.7 Create the CVE-2026-59949 detail record and update requirements, vulnerability totals, and GAV/dependency mapping documentation with the actual Kafka transitive path, affected range, selected LZ4 Java 1.11.2 fix, and verification evidence.

## 8. Validate the Completed Change

- [x] 8.1 Run `openspec validate remediate-remaining-bom-cves-august-2026 --type change --strict` and resolve every validation error.
- [x] 8.2 Review the final diff for BOM-only version ownership, QueryDSL coordinate completeness, scan-evidence traceability, documentation consistency, and absence of release-version, publication, or Nexus deployment changes.
