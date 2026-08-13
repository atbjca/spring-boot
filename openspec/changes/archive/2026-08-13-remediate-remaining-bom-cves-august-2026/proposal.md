## Why

After the ActiveMQ and Artemis remediation is completed, the 2026-08-11 full resolved-BOM audit still leaves four managed or resolved dependency findings that can be remediated with published version or coordinate changes, one Derby finding whose Java 17 fix is not published to Maven Central, plus several findings whose deferred, immune, or false-positive status is not documented completely. The audit also showed that scanning only familiar direct dependencies can miss vulnerabilities in the roughly 1,470 managed coordinates and in NES-prefixed forks unless every resolved Maven component is mapped to a canonical PURL and checked against its upstream identity.

## What Changes

- Require `remediate-activemq-artemis-cves-august-2026` to be completed and archived before this change is applied, so the generated BOM and vulnerability totals use the remediated messaging baseline.
- Retain Derby 10.16.1.1 and document a bounded CVE-2022-46337 deferral: Apache backported the fix as 10.16.1.2 source, but Maven Central publishes neither `derby` nor `derbytools` at that version, while the published 10.17.1.0 artifacts require a post-Java-17 class-file level. Reevaluate when a consumable Java 17 fix is published or the project Java baseline changes.
- Upgrade Commons Lang3 from 3.17.0 to 3.18.0 for CVE-2025-48924 and OpenTelemetry from 1.49.0 to 1.62.0 for CVE-2026-45292; align the parent-only OkHttp test library to 5.3.2 because the OpenTelemetry 1.62.0 exporters require that runtime line.
- Explicitly manage Kafka's transitive `at.yawk.lz4:lz4-java` dependency at 1.11.2, replacing the affected 1.10.1 selection for CVE-2026-59949 without changing Kafka or Spring Kafka versions.
- **BREAKING** Replace the unmaintained `com.querydsl` 5.1.0 BOM and managed artifacts with `io.github.openfeign.querydsl` 5.6.1, update the fork's direct QueryDSL consumer coordinate, and document the downstream GAV migration required to remediate CVE-2024-49203.
- Reconcile CVE-2026-3260 against the 2026-07-07 CNA rejection and classify the scanner hit as rejected/not applicable for Undertow 2.3.26.Final, retaining the rejection rationale and a regression check for the request-size constraint.
- Record CVE-2025-5731 as an Infinispan CLI finding that is absent from the default runtime and outside the vendor affected boundary at managed 15.2.6.Final; retain the BOM-only reachability and vendor evidence rather than treating an old scanner hit as exploitable.
- Record CVE-2026-40987 as a scanner alias/mapping false positive for this baseline because the vendor-affected Spring Integration file-support range ends at 6.5.8 and managed Spring Integration 6.5.10 is newer than the 6.5.9 fix.
- Preserve the existing bounded Log4j2 2.24.3 deferral, add omitted CVE-2025-68161 to the ledger, and repair the upgrade assessment's inconsistent vulnerability count without broadening default Log4j2 usage.
- Add a repeatable complete-BOM security check that converts every generated resolved Maven coordinate to a PURL, queries the selected OSV/SCA sources, maps NES private GAVs back to upstream GAVs, deduplicates aliases, and requires evidence-backed affected, fixed, immune, false-positive, or deferred classifications.
- Run targeted retained-Derby, Commons Lang, QueryDSL/GraphQL, OpenTelemetry/tracing/baggage, Kafka/LZ4, BOM-generation, web-server, and cache-related verification plus the clean project gates before statuses or documentation are finalized.
- Synchronize requirements, vulnerability overview and details, GAV mappings, audit evidence, and OpenSpec artifacts to an audit cutoff of 2026-08-06 or later; release/version changes and Nexus deployment remain out of scope.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `dependency-security-remediation`: Extend managed-version and coordinate requirements, deferred/immune/false-positive classification rules, targeted verification, and exhaustive resolved-BOM scanning with NES-to-upstream identity mapping.

## Impact

- Changes dependency declarations in `spring-boot-project/spring-boot-dependencies/build.gradle`, the QueryDSL optional dependency consumed by `spring-boot-autoconfigure`, and the generated dependency-management POM/resolved BOM. Derby remains at the published Java 17 baseline 10.16.1.1; LZ4 remains on the maintained `at.yawk.lz4` coordinate selected by Kafka.
- Downstream users relying on dependency management for `com.querydsl:*` must adopt the maintained `io.github.openfeign.querydsl:*` coordinates; Java package names remain `com.querydsl`, but Maven coordinates and provenance change.
- OpenTelemetry crosses multiple minor releases and the affected baggage path is enabled by the fork's tracing configuration, so tracing propagation, baggage, exporters, metrics, logs, and service-connection paths require targeted compatibility checks.
- Undertow and Infinispan versions are not changed solely to silence scanner output; their ledger entries retain the latest CNA/vendor status, original aliases, and applicability evidence.
- Security-audit tooling or scripts, `doc/REQUIREMENTS.md`, `doc/VULNERABILITY_REPORT.md`, applicable `doc/CVE/` files, `doc/NES_GAV_MAPPING.md`, and the dependency security specification are updated. Fork versioning, artifact publication, and Nexus deployment are not affected.
