## Context

This change starts from the state produced by the archived `remediate-activemq-artemis-cves-august-2026` change. Its generated BOM therefore already manages ActiveMQ Classic 6.2.8 and Artemis 2.54.0 through `org.apache.artemis:artemis-bom`, retains relocation-compatible old-group Artemis modules, and its vulnerability ledger already contains the 15 messaging findings from the same 2026-08-06 audit.

The remaining audit findings fall into different categories and must not be flattened into a single scanner-result status:

- Derby 10.16.1.1 is in the Java 17 affected line for CVE-2022-46337. Apache's 10.16.1.2 source contains the fix, but Maven Central publishes none of the required Derby artifacts at 10.16.1.2. The next published release, 10.17.1.0, uses class-file major version 63 and is not consumable on the project's Java 17 baseline (major version 61), so 10.16.1.1 remains a bounded deferred risk.
- Commons Lang3 3.17.0 is affected by CVE-2025-48924; 3.18.0 is the compatible fix.
- `com.querydsl` 5.1.0 is affected by CVE-2024-49203 and has no fixed release under the original coordinates. The maintained OpenFeign lineage fixes the 5.x line in `io.github.openfeign.querydsl` 5.6.1.
- OpenTelemetry 1.49.0 is affected by CVE-2026-45292; 1.62.0 contains the W3C baggage allocation fix. The fork enables OpenTelemetry baggage propagation when tracing is present unless `management.tracing.baggage.enabled=false`, so the affected path is relevant rather than theoretical.
- Kafka clients 3.9.2 transitively selects `at.yawk.lz4:lz4-java:1.10.1`. CVE-2026-59949 affects that maintained coordinate through 1.11.0 and is fixed in 1.11.1; Maven Central publishes 1.11.2 as the latest release and OSV returns no finding for 1.11.2. The existing Spring Rabbit Stream exclusion targets archived `org.lz4:lz4-java` coordinates and does not remove Kafka's maintained-coordinate dependency path.
- Undertow 2.3.26.Final was reported for CVE-2026-3260, but the Red Hat CNA rejected the CVE on 2026-07-07 because Undertow's default maximum request entity size safely drops oversized requests. The scanner hit is therefore rejected/not applicable at the audit cutoff.
- Infinispan 15.2.6.Final manages `infinispan-cli-client`, but the Red Hat affected boundary is below 15.2.5; the managed version is outside that range. The CLI is also not part of the default cache runtime, so the candidate is recorded as fixed/not applicable with BOM-only reachability evidence.
- CVE-2026-40987 affects Spring Integration file support through 6.5.8, with 6.5.9 as the 6.5.x fix. The managed Spring Integration version is already 6.5.10, so a broad scanner association is a false positive for this baseline.
- The Log4j2 deferral ledger omits CVE-2025-68161 and the assessment says it covers three CVEs while its table contains six. The existing 2.24.3 deferral rationale remains valid, but its inventory and counts are incomplete.

The audit queried roughly 1,470 resolved managed Maven coordinates through OSV after generating PURLs. The locally available Grype database was dated 2026-07-15 and two update attempts failed with `unexpected EOF`, so Grype can corroborate results but cannot be the primary clean-state evidence for this cutoff. The scan also demonstrated that NES fork coordinates need upstream aliases; querying only private GAVs produces false negatives, while treating every upstream alias match as automatically exploitable produces false positives.

## Goals / Non-Goals

**Goals:**

- Apply the four published remediations (Commons Lang, QueryDSL, OpenTelemetry, and LZ4 Java), retain Derby 10.16.1.1 with an evidence-backed deferral, and keep the BOM as the only dependency-version source.
- Verify the fork's direct QueryDSL consumer and document the downstream Maven-coordinate migration.
- Preserve explicit, bounded statuses for Undertow, Infinispan CLI, Spring Integration, and Log4j2 instead of suppressing their scanner records; rejected or fixed/not-applicable decisions retain their source evidence.
- Add a repeatable complete resolved-BOM audit with canonical Maven PURLs, NES-to-upstream aliases, source freshness, alias deduplication, and VEX-style applicability decisions.
- Pass targeted component tests, generated-BOM checks, a clean thin build, and the core test target before fixed classifications are recorded.
- Synchronize requirements, vulnerability details and totals, GAV mapping, and OpenSpec evidence to a 2026-08-06 or later cutoff.

**Non-Goals:**

- Reimplement fixed upstream vulnerability patches locally when a compatible released dependency is available.
- Move QueryDSL to 6.x, change its Java package names, or redesign Spring Data/GraphQL QueryDSL APIs.
- Upgrade Undertow or Infinispan to an unverified version solely to make a scanner result disappear.
- Upgrade Log4j2 to 2.25.x as part of this change or introduce Log4j2 into the default Logback runtime.
- Make an online vulnerability service a prerequisite for every normal developer build.
- Change the fork version, publish artifacts, or deploy to Nexus.

## Decisions

1. **Sequence this work after the messaging remediation.** The first change is an explicit prerequisite and must be archived before implementation begins. This prevents vulnerability totals, generated-BOM assertions, and documentation from being produced against two competing baselines. Applying both changes concurrently was rejected because QueryDSL and OpenTelemetry compatibility work could delay the KEV/Critical messaging fixes.

2. **Retain Derby's published Java 17 line and upgrade Commons Lang.** Commons Lang moves from 3.17.0 to the released compatible fix 3.18.0. Derby remains at 10.16.1.1 because Maven Central does not publish the required `derby`, `derbyclient`, `derbyshared`, or `derbytools` artifacts at the source-only 10.16.1.2 fix level, while the published 10.17.1.0 `derbytools` classes use major version 63 and cannot run on Java 17's major version 61. Building and privately publishing an ad hoc Derby distribution was rejected. CVE-2022-46337 is deferred only for LDAP-authenticated Derby usage and must be reevaluated when a published Java-17-compatible fix exists or the project Java baseline increases.

3. **Move OpenTelemetry to 1.62.0 and align its exporter test runtime.** The published Maven range identifies 1.62.0 as the fix for `opentelemetry-api` and `opentelemetry-extension-trace-propagators`. OpenTelemetry 1.62.0's OkHttp exporter requires OkHttp 5.3.2; keeping the parent test library at MockWebServer/OkHttp 4.12.0 produces a mixed runtime and `okhttp3.internal.Util` linkage failure. The parent-only `OkHttp` test library therefore moves to 5.3.2 without adding OkHttp to the user dependency-management BOM or introducing a module-level override. Because baggage propagation is enabled by default when the fork's OpenTelemetry tracing auto-configuration is active, verification covers W3C trace/baggage extraction, propagation enabled and disabled modes, Micrometer bridge behavior, OTLP/Zipkin exporters, metrics/logs integrations, and service connections. Staying on 1.49.0 with a configuration workaround was rejected because the vulnerable behavior is enabled by the supported default and a released fix exists.

4. **Migrate QueryDSL to the maintained OpenFeign 5.x lineage.** The BOM import changes from `com.querydsl:querydsl-bom:5.1.0` to `io.github.openfeign.querydsl:querydsl-bom:5.6.1`, and the fork's optional `querydsl-core` dependency changes to the same group. Java packages remain `com.querydsl`, so source-level auto-configuration remains stable, but Maven consumers must migrate their GAVs. Keeping the original coordinates with an advisory suppression was rejected because 5.1.0 is the last release there and remains affected; adopting OpenFeign 6.10.1 was rejected because 5.6.1 is the smallest maintained-line fix and avoids an unnecessary major-line compatibility jump.

5. **Manage LZ4 Java directly at 1.11.2.** Kafka 3.9.2 requests the maintained `at.yawk.lz4:lz4-java:1.10.1` artifact, which is inside the CVE-2026-59949 affected range. The Boot BOM adds a single LZ4 Java library at 1.11.2 so downstream Kafka clients and Streams graphs resolve outside the affected range without changing Kafka versions or adding module-level overrides. Selecting 1.11.2 instead of the minimum 1.11.1 takes the latest compatible maintenance release, preserves Java 7 bytecode and the existing `net.jpountz` API/module identity, and currently has no OSV finding.

6. **Classify scanner findings individually.** Undertow CVE-2026-3260 is recorded as rejected/not applicable based on the 2026-07-07 CNA rejection and the default request-size constraint. Infinispan CLI CVE-2025-5731 is outside the Red Hat affected boundary at 15.2.6.Final and absent from the default cache runtime. Spring Integration CVE-2026-40987 is recorded as a scanner false positive for version 6.5.10 with module and fixed-range evidence. None of these records is silently excluded from scan output.

7. **Preserve the Log4j2 deferral but repair its inventory.** CVE-2025-68161 is added alongside the six already documented 2026 findings, the assessment count and references are corrected, and the default-Logback, affected-appender/layout, compatibility, and reevaluation boundaries remain explicit. A documentation correction is preferred to a risky 2.25.x backport because the known Boot 3.5 compile/API incompatibilities have not changed.

8. **Separate deterministic inventory from online advisory lookup.** A repository-owned audit command accepts the generated `resolved-bom.json`, enumerates every distinct dependency from direct management and imported BOMs, produces canonical Maven PURLs, and writes a normalized machine-readable report. Online OSV batch lookup is an explicit security-audit/release activity rather than a normal offline build dependency. Query failures, truncated results, stale source metadata, or an inventory-count mismatch make the audit incomplete; they cannot be interpreted as zero findings.

9. **Use an explicit alias manifest for fork identity without duplicating versions.** A machine-readable mapping records only fork-to-upstream group/artifact transformations and version-normalization rules; actual versions always come from the resolved BOM. The audit queries both private and upstream PURLs, preserves mapping provenance, deduplicates GHSA/CVE aliases, and emits candidate findings for an evidence-backed VEX classification. `doc/NES_GAV_MAPPING.md` remains the human-readable synchronized view. Parsing Markdown or hard-coding current dependency versions into the audit tool was rejected because either approach creates drift from the BOM.

10. **Treat scan output as candidate evidence, not the final decision.** Every hit must be reconciled with authoritative vendor/module ranges and project reachability, then classified as affected, fixed, immune/not applicable, false positive, or deferred with trigger conditions and audit cutoff. A target-version OSV query is useful corroboration, but a missing OSV record does not override an authoritative vendor advisory.

## Risks / Trade-offs

- **[OpenTelemetry spans thirteen minor releases and requires OkHttp 5.3.2 for exporters]** → Align only the parent test library, preserve BOM ownership, run the broader MockWebServer consumers plus tracing, baggage, exporter, metrics/logs, and service-connection tests, and inspect API/release-note changes before accepting the pin.
- **[Derby 10.16.1.1 remains in an affected line]** → Record that the vulnerable trigger requires LDAP-authenticated Derby, retain 10.16.1.1 only because no published Java-17-compatible fix exists, and reevaluate on a consumable 10.16.1.2-equivalent release or a project Java baseline increase.
- **[QueryDSL changes Maven provenance and downstream coordinates]** → Keep Java packages stable, change the BOM and the fork's direct optional dependency together, verify no `com.querydsl` dependency-management entries remain, and publish a clear consumer migration note.
- **[LZ4 maintenance changes JNI binaries used by Kafka compression]** → Preserve the same maintained coordinate and Java API, verify Kafka client/Streams graphs select only 1.11.2, run valid LZ4 compression/decompression and Kafka-focused tests, and retain the upstream invalid-range fix as advisory evidence rather than reproducing a JVM-crash payload in-process.
- **[A maintained fork may diverge from the original QueryDSL project]** → Record repository/provenance links, constrain the initial move to the fixed 5.x line, and require GraphQL plus Spring Data QueryDSL compatibility tests.
- **[Scanner metadata can lag vendor status]** → Retain the original advisory aliases, but prefer the latest CNA/vendor status and document rejection, fixed-boundary, or not-applicable decisions with timestamps.
- **[External advisory services are mutable or unavailable]** → Record query time and source metadata, retain normalized evidence for the audit, fail closed on incomplete lookup, and use a fresh secondary SCA source only as corroboration.
- **[Fork aliases can over-report upstream findings]** → Require module/range review and VEX evidence before changing status; an alias match is a candidate, not automatic exploitability.
- **[Fork aliases can drift from build substitution rules]** → Test representative Framework, Security, Boot, Data, and Kafka mappings and review the machine-readable manifest whenever `doc/NES_GAV_MAPPING.md` or resolution rules change.

## Migration Plan

1. Verify that `remediate-activemq-artemis-cves-august-2026` is archived and regenerate its resolved-BOM baseline.
2. Add the deterministic complete-BOM inventory/audit interface and the fork alias manifest, with fixtures for duplicate coordinates, alias normalization, failed lookups, and representative NES mappings.
3. Retain Derby 10.16.1.1, update the Commons Lang, OpenTelemetry, and LZ4 Java BOM pins, and replace the QueryDSL BOM group/version plus the fork's direct QueryDSL optional dependency coordinate.
4. Generate and inspect the dependency-management POM and resolved BOM for the four remediations, the retained Derby baseline, the absence of old QueryDSL management, and preservation of all other managed coordinates.
5. Run targeted retained-Derby, Commons Lang, QueryDSL/GraphQL/Spring Data, OpenTelemetry/tracing/baggage/exporter, Kafka/LZ4, Undertow, and Infinispan dependency-path tests; retain the bytecode evidence that rules out Derby 10.17.1.0 on Java 17.
6. Run the complete resolved-BOM audit, reconcile every candidate hit with authoritative evidence, confirm the four selected fixed versions have no unresolved applicable findings, and classify Derby explicitly as deferred at the recorded cutoff.
7. Run clean `make build-thin` and `make test`; use `make test-gate` if required by failures or the final risk review.
8. Update requirements, vulnerability overview and CVE details, Log4j2 assessment, GAV mapping, and OpenSpec evidence, then run strict OpenSpec validation before archive.

Rollback restores each BOM pin and the QueryDSL coordinate as an atomic unit for that dependency, reruns the resolved-BOM inventory, and changes its CVE status back to affected or deferred. Rollback must not retain a fixed classification, an OpenFeign consumer migration claim, or a scanner exclusion that no longer matches the generated BOM.

## Open Questions

None blocking proposal readiness. Implementation must confirm the exact repository command name for the opt-in audit and whether OpenTelemetry 1.62.0 release-note changes require regression tests beyond the existing tracing suites.

## Implementation Evidence

Authoritative finding review captured on 2026-08-11:

| Finding | Authoritative range/status | Baseline decision |
|---|---|---|
| CVE-2022-46337 / GHSA-rcjc-c4pj-xxrp | Apache/GHSA identify Derby 10.16.1.1 as affected and the 10.16.1.2 source as patched; Maven Central does not publish the required 10.16.1.2 artifacts, and published 10.17.1.0 uses Java 19 class files | Retain 10.16.1.1 as a bounded LDAP-authentication deferral on Java 17 |
| CVE-2025-48924 / GHSA-j288-q9x7-2f5v | Apache/GHSA identify `org.apache.commons:commons-lang3` 3.0 through versions before 3.18.0 | Upgrade 3.17.0 to 3.18.0 |
| CVE-2024-49203 / GHSA-6q3q-6v5j-h6vg | Original `com.querydsl` artifacts through 5.1.0 have no patched release; maintained OpenFeign 5.x is fixed in 5.6.1 | Migrate BOM and direct consumer to `io.github.openfeign.querydsl` 5.6.1 |
| CVE-2026-45292 / GHSA-rcgg-9c38-7xpx | `opentelemetry-api` and `opentelemetry-extension-trace-propagators` through 1.61.0; fixed in 1.62.0 | Upgrade 1.49.0 to 1.62.0 |
| CVE-2026-59949 / GHSA-xx22-p4ch-683r | `at.yawk.lz4:lz4-java` through 1.11.0; fixed in 1.11.1 | Manage 1.11.2 |
| CVE-2026-3260 / GHSA-3x3v-w654-m28m | Red Hat CNA changed the CVE to REJECTED on 2026-07-07 because Undertow's default request entity-size limit drops oversized requests; GHSA still retains the earlier candidate | Rejected/not applicable; retain both records and verify the constraint |
| CVE-2025-5731 / GHSA-cqm8-rg2p-jfcf | Red Hat CNA identifies upstream Infinispan versions below 15.2.5; GHSA's Maven range remains broader and has no patched version field | Managed 15.2.6.Final is outside the vendor range; retain alias and default-runtime reachability evidence |
| CVE-2026-40987 / GHSA-792x-6vq6-j8r9 | Spring Integration file support 6.5.0 through 6.5.8; OSS fix 6.5.9, enterprise fix 6.5.8.1 | Managed 6.5.10 is not affected; retain scanner association as false-positive evidence |
| CVE-2025-68161 / GHSA-vc5p-v9hr-52mj | `log4j-core` 2.0-beta9 through versions before 2.25.3 when TLS Socket Appender hostname verification is expected | Preserve bounded 2.24.3 deferral and add the omitted ledger entry |

LZ4 evidence captured on 2026-08-11:

- Maven Central metadata reports `at.yawk.lz4:lz4-java` latest/release `1.11.2`. OSV reports CVE-2026-59949 (GHSA-xx22-p4ch-683r), affecting the maintained coordinate through 1.11.0 and fixed in 1.11.1; the target 1.11.2 query returned `{}`.
- Baseline resolved dependency insight showed `org.apache.kafka:kafka-clients:3.9.2 -> at.yawk.lz4:lz4-java:1.10.1`; the archived `org.lz4:lz4-java` exclusion in Spring Rabbit Stream does not affect this Kafka path.
- `./gradlew :spring-boot-project:spring-boot-dependencies:createResolvedBom :spring-boot-project:spring-boot-dependencies:generatePomFileForMavenPublication --console=plain` completed with `BUILD SUCCESSFUL`. Generated metadata contains `lz4-java.version=1.11.2` and managed `at.yawk.lz4:lz4-java`.
- Post-change dependency insight selected `at.yawk.lz4:lz4-java:1.11.2` by constraint/force and recorded Kafka's 1.10.1 request as upgraded; Kafka 3.9.2, Kafka Streams 3.9.2, and Spring Kafka `3.3.16-nes.patch.1` remained unchanged.
- `./gradlew :spring-boot-project:spring-boot-autoconfigure:test --tests org.springframework.boot.autoconfigure.kafka.KafkaAutoConfigurationTests --console=plain` passed (`BUILD SUCCESSFUL in 4m 58s`) after changing the producer compression property test to `lz4`.
- `./gradlew :spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test --tests smoketest.kafka.SampleKafkaApplicationTests --console=plain` passed (`BUILD SUCCESSFUL in 1m 40s`) with the embedded Kafka producer configured for LZ4; the smoke message was successfully consumed.
- The remote Gradle build cache returned 403 during compilation and the build correctly fell back to local compilation. The later parent `make clean build-thin` completed successfully. The first parent `make test` attempt was terminated by the operating system with signal 9 under severe memory pressure and was not counted as a pass. After resources recovered, the user confirmed on 2026-08-13 that both `make test` and `make test-gate` completed successfully, so the CVE is `✅ fixed`.

Final dependency metadata and Derby evidence captured on 2026-08-11:

- Regenerated `resolved-bom.json` and the Maven publication POM contain Derby 10.16.1.1, Commons Lang3 3.18.0, OpenTelemetry 1.62.0, OpenFeign QueryDSL 5.6.1, and LZ4 Java 1.11.2. Every imported QueryDSL module uses `io.github.openfeign.querydsl`; no managed `com.querydsl` 5.1.0 coordinate remains.
- Maven Central returned HTTP 404 for the required `derby`, `derbyclient`, `derbyshared`, and `derbytools` 10.16.1.2 artifacts. `javap -verbose` against published `derbytools:10.17.1.0` reported class-file major version 63, while Java 17 supports major version 61.
- Retained Derby 10.16.1.1 passed `EmbeddedDatabaseConnectionTests`, `DatabaseDriverTests`, `DevToolsPooledDataSourceAutoConfigurationTests`, and the selected JDBC/SQL initialization test set.

Complete resolved-BOM audit evidence captured on 2026-08-11:

- The final OSV audit reconciled 1,560 input coordinate occurrences into 1,547 distinct Maven coordinates with 13 duplicate occurrences, zero malformed coordinates, and 1,560 lookup PURLs.
- Four OSV response dates were `2026-08-11T09:11:17Z`, `2026-08-11T09:11:19Z`, `2026-08-11T09:11:23Z`, and `2026-08-11T09:11:25Z`; no lookup, freshness, truncation, or inventory-count error was recorded.
- Nine normalized findings were emitted and all were classified: Derby deferred, Undertow not applicable, Infinispan fixed, and six visible Log4j findings deferred. The report status was `complete-with-known-risk`, with zero unclassified findings. The documentation ledger separately retains Log4j CVE-2026-49844 even though that OSV response did not return it.
- No unresolved applicable finding remained for Commons Lang3 3.18.0, OpenFeign QueryDSL 5.6.1, OpenTelemetry 1.62.0, or LZ4 Java 1.11.2.

Final project-gate evidence:

- `make clean build-thin` completed successfully against the final dependency state: `clean` was `BUILD SUCCESSFUL in 2m 45s`, and the full thin assemble was `BUILD SUCCESSFUL in 14m 1s` with 828 actionable tasks.
- The first `make test` attempt reached execution of `spring-boot:test` but was killed by the operating system with signal 9. System virtual-memory counters showed severe swapping; no test assertion failure was emitted. This attempt remains recorded as an incomplete environmental interruption, not a pass or a product failure.
- After resources recovered, the user confirmed on 2026-08-13 that rerun `make test` and `make test-gate` both completed successfully against the final dependency state. Commons Lang3, OpenFeign QueryDSL, OpenTelemetry, and LZ4 Java are therefore finalized as fixed.
