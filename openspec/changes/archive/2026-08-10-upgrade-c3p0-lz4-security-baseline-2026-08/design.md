## Context

The repository currently manages c3p0 0.9.5.5 in `spring-boot-parent` and globally substitutes legacy `org.lz4:lz4-java` requests with `at.yawk.lz4:lz4-java:1.10.1`. The vulnerability report was last recalculated before CVE-2026-55223 and CVE-2026-59949 were published, and its CVE-2026-27727 entry assumes that removing a Quartz dependency path removes c3p0 from the project. That assumption is invalid because Spring Boot still compiles and tests explicit c3p0 support and publishes c3p0 as an optional dependency surface.

c3p0 0.14.0 is the first version that covers all three known issues in scope: unsafe `userOverridesAsString` deserialization, unsafe mchange JNDI reference resolution, and JavaBean introspection of connection-producing methods. It brings mchange-commons-java 0.6.0. Both artifacts use Java 7 bytecode. A pre-proposal dependency override confirmed that Spring Boot's `DataSourceBuilderTests` pass with this pair, and the Hibernate 5.6 c3p0 integration methods inspected by the build remain present.

lz4-java 1.11.1 fixes JNI XXHash range validation. It also uses Java 7 bytecode and removes no classes relative to 1.10.1. The current Gradle substitution is repository-local and cannot be represented as a Maven BOM coordinate replacement, so published dependency management and Maven migration guidance must be handled separately.

## Goals / Non-Goals

**Goals:**

- Move the c3p0/mchange dependency pair to versions that close CVE-2026-27727, CVE-2026-27830, and CVE-2026-55223 while preserving Java 8.
- Move the active lz4 fork to 1.11.1 and ensure repository Gradle resolution converges on that artifact.
- Manage `at.yawk.lz4:lz4-java:1.11.1` in the published dependency BOM so Kafka's explicit 1.10.1 transitive declaration is overridden for consumers.
- Preserve Spring Boot's supported c3p0 integration surface and verify representative Hibernate, Kafka, and Elasticsearch paths.
- Correct the CVE documents and vulnerability totals using artifact and feature evidence.

**Non-Goals:**

- Do not backport or adopt ActiveMQ, Artemis, Spring LDAP, Spring Kafka, Spring Framework, Spring Security, Infinispan, or Jetty fixes in this change.
- Do not claim that Maven dependency management can replace `org.lz4:lz4-java` with the `at.yawk.lz4` coordinate.
- Do not restore c3p0 APIs removed upstream, such as legacy `PoolConfig`, solely for unsupported downstream code.
- Do not change the Java 8 baseline or cross Spring Boot/Spring Framework major versions.

## Decisions

### D1: Use c3p0 0.14.0 and its upstream mchange-commons-java 0.6.0 pair

c3p0 0.12.0 fixes CVE-2026-27830 and upgrades mchange beyond the CVE-2026-27727 fix line, but it does not fix CVE-2026-55223. Version 0.14.0 is therefore the minimum single target that closes the entire c3p0 batch. The build will rely on c3p0's declared mchange-commons-java 0.6.0 dependency rather than pinning the older minimum 0.4.0 independently.

Alternatives considered:

- **Upgrade only mchange-commons-java**: rejected because it leaves both c3p0 vulnerabilities open.
- **Upgrade c3p0 only to 0.12.0**: rejected because CVE-2026-55223 remains affected.
- **Remove c3p0 support**: rejected as a breaking API and dependency-surface change outside this security update.

### D2: Combine published at.yawk dependency management with Gradle coordinate substitution

`spring-boot-dependencies` will manage `at.yawk.lz4:lz4-java:1.11.1`, overriding Kafka Client's explicit 1.10.1 version for Maven and Gradle consumers that use the BOM. The root Gradle substitution will continue replacing `org.lz4:lz4-java` with the managed active fork so the repository's Elasticsearch and Kafka graphs contain one implementation.

A Maven BOM cannot express a group/artifact substitution. Documentation will therefore require Maven applications that combine Elasticsearch's legacy coordinate with Kafka's fork coordinate to exclude `org.lz4:lz4-java` from the Elasticsearch path. The change will not report Maven convergence without that exclusion evidence.

### D3: Treat compatibility probes as gates, not proof from bytecode alone

Java compatibility will be checked using class major versions and a Java 8 build. Functional compatibility will cover Spring Boot's `DataSourceBuilder` c3p0 mapping, a minimal pooled connection lifecycle, Hibernate 5.6's c3p0 integration, and representative Kafka/Elasticsearch dependency resolution. The existing pre-proposal tests reduce uncertainty but do not replace the implementation-time Java 8 and project-gate runs.

### D4: Recalculate vulnerability status from the resolved graph

CVE-2026-27727 will be removed from the pre-existing “fixed by Quartz exclusion” rationale. It may be marked fixed only after the relevant runtime/test graphs resolve mchange-commons-java 0.6.0 through c3p0 0.14.0. New documents will be added for CVE-2026-27830, CVE-2026-55223, and CVE-2026-59949, and report totals will be recalculated rather than incrementally edited from the stale count.

### D5: Validate in layers

1. Check generated dependency-management POMs and Gradle dependency insight for c3p0, mchange, and both lz4 coordinates.
2. Run focused Spring Boot c3p0 and Hibernate integration tests plus Kafka/Elasticsearch resolution or smoke tests.
3. Run Java 8 compilation/tests and the standard repository security/build gates.
4. Update all CVE and maintenance documents only with the final resolved evidence.

### D6: Use a new development coordinate for the updated baseline

Set the Spring Boot fork project version to `2.7.18-nes.patch.2-SNAPSHOT`. The previously released `2.7.18-nes.patch.1` coordinate remains immutable, while the SNAPSHOT suffix routes development publications to the snapshot repository. This version change applies only to Spring Boot artifacts; independently versioned Spring Framework, Spring Security, Spring Data, Spring Kafka, and Reactor Netty forks remain unchanged.

## Risks / Trade-offs

- **[Risk] c3p0 0.14.0 removes legacy APIs used by downstream custom code** → Validate Spring Boot and Hibernate-supported paths, call out the upstream API break in migration notes, and avoid claiming compatibility for direct use of removed APIs.
- **[Risk] A second lz4 implementation remains on Maven classpaths** → Manage the active fork version and document/test the required exclusion of the legacy Elasticsearch coordinate.
- **[Risk] Native lz4 behavior differs across operating systems** → Run safe/native XXHash smoke coverage where native loading is available and retain Java implementation fallback coverage.
- **[Risk] Updating the report by arithmetic preserves prior counting errors** → Rebuild counts from status rows and validate every new CVE document link.
- **[Trade-off] The change does not close all newly identified 2026 CVEs** → Keep this change implementation-ready and isolate external-fork or configuration-dependent remediation into follow-up changes.

## Migration Plan

1. Add the new managed versions and update the Gradle substitution.
2. Generate dependency metadata and confirm c3p0/mchange and at.yawk lz4 resolution.
3. Run focused compatibility tests, then Java 8 and standard project gates.
4. Update CVE documents, requirements, upgrade history, user guidance, and vulnerability totals.
5. Roll back by restoring the two version targets and documentation statuses independently; no persisted data migration is required.

## Open Questions

None. Maven coordinate substitution remains an explicit consumer exclusion requirement and is not treated as an unresolved implementation choice.
