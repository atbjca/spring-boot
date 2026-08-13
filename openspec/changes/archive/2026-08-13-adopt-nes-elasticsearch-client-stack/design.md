## Context

The Boot 2.7 NES fork must consume a coordinated set of forked artifacts: Elasticsearch 7.17, the Elasticsearch Java API client, Barsson/JSON-P support, Spring Data Elasticsearch 4.4.x, and the Spring Data 2021.2 BOM. The upstream graph uses overlapping package names and multiple JSON-P generations, so changing only a version property is insufficient.

The implementation must preserve Java 8 compatibility, avoid Gradle/Maven execution during planning, keep formal Boot RELEASE metadata free of internal SNAPSHOTs, and support both Maven BOM consumers and Gradle consumers using either the dependency-management plugin or native `platform(...)`.

## Goals / Non-Goals

**Goals:**

- Make the generated Boot BOM and representative starters resolve the approved NES Elasticsearch client closure.
- Keep the legacy Boot/Johnzon `javax.json.*` path functional while isolating the NES client's `jakarta.json.*` JSON-P path.
- Update the existing Spring Data dependency capability to the verified patch.2 SNAPSHOT versions.
- Cover production and test-support modules, publication metadata, LZ4 replacement behavior, duplicate-class/provider checks, Java 8, and independent consumers.
- Document migration and the distinction between development SNAPSHOT adoption and formal Boot RELEASE.

**Non-Goals:**

- Re-forking Spring Data modules that remain official.
- Migrating Boot's existing JSON-B APIs or source imports from `javax.json.bind.*` to Jakarta packages.
- Publishing or managing NES server distributions, Transport Client artifacts, or test-only Elasticsearch distributions that are not part of the supported client closure.
- Claiming complete direct-consumer LZ4 closure until the Elasticsearch producer POM itself publishes the replacement dependency.
- Running Gradle/Maven as part of proposal creation.

## Decisions

### 1. Use one coordinated client-stack change

Manage Elasticsearch, Java client, JSON-P, Barsson, and Spring Data updates together. This avoids a state where the Java client is upgraded while the BOM, JSON-P provider policy, or Spring Data Elasticsearch integration still points at official artifacts.

Alternative: split JSON-P and Elasticsearch into separate changes. Rejected because each intermediate state would be difficult to validate and could produce mixed providers or coordinates.

### 2. Manage the complete verified NES closure, not a broad group substitution

Add explicit BOM entries for the 16 production Elasticsearch modules in the verified NES allowlist, the NES Java API Client, Barsson core, Jakarta JSON-P 2.0.2, NES JCL, and the patch.2 Spring Data artifacts. Stop managing upstream `co.elastic.clients:elasticsearch-java`, Transport Client, server distributions, and integ-test distributions.

Alternative: substitute every `org.elasticsearch` or `co.elastic.clients` request by group. Rejected because unsupported NES publications do not exist for every upstream coordinate and broad substitution would silently create non-resolvable or mixed graphs.

### 3. Preserve package compatibility while separating JSON-P generations

The NES Elasticsearch JARs retain `org.elasticsearch.*` packages. The legacy Johnzon path remains `javax.json.*`; the NES Barsson core path uses `jakarta.json.*` and Jakarta JSON-P 2.0.2. Rename only the three test/build declarations that incorrectly use the old Jakarta alias for the `javax.json` API, and permit exactly the `javax.json` group in the prohibited-dependency check.

Alternative: migrate all JSON-B and JSON-P consumers to Jakarta. Rejected because Boot 2.7's existing JSON-B contract and Johnzon SPI are still javax-based, making a global migration unnecessarily breaking.

### 4. Treat LZ4 as a two-layer contract

The Boot BOM excludes the old `org.lz4:lz4-java` edge and manages `at.yawk.lz4:lz4-java:1.11.1`; the Elasticsearch starter adds the replacement explicitly for starter consumers. The design records that direct SDE/HLRC consumers still require the producer POM to publish the replacement transitively.

Alternative: rely on root Gradle substitution. Rejected because root substitutions do not propagate to downstream consumers and cannot repair published Maven metadata.

### 5. Update Spring Data through the existing capability

Extend `nes-spring-data-dependencies` for the BOM `2021.2.18-nes.patch.2-SNAPSHOT` and Elasticsearch `4.4.18-nes.patch.2-SNAPSHOT`, retaining the existing official/NES fork boundary and independent Elasticsearch version line.

Alternative: create a second Spring Data capability. Rejected because the requirement is a version-line update to an existing contract.

### 6. Make verification evidence-first and consumer-oriented

Use static metadata and classpath checks plus focused tests and independent Maven/Gradle fixtures. Required evidence includes generated BOM/POM coordinate scans, JSON-P provider uniqueness, duplicate class detection, LZ4 resolution/exclusion behavior, Java 8 class major 52, and absence of forbidden official coordinates.

## Risks / Trade-offs

- [Mixed JSON-P providers] → Keep `javax.json` and `jakarta.json` checks explicit, inspect ServiceLoader providers separately, and fail on duplicate providers within either namespace.
- [A direct consumer receives no LZ4 replacement] → Require producer-POM remediation for full closure; keep the Boot starter explicit and document the remaining boundary until verified.
- [Unsupported upstream coordinates are requested transitively] → Maintain a denylist and test representative dependency graphs rather than applying broad group substitutions.
- [SNAPSHOT cache hides an older artifact] → Record resolved artifact evidence and require refresh/metadata checks in consumer fixtures; keep formal RELEASE gates unchanged.
- [Java 8 regression from a newer fork artifact] → Inspect class major versions and run Java 8-targeted compatibility checks before adoption is considered complete.

## Migration Plan

1. Implement BOM allowlist/denylist and the dual JSON-P dependency policy.
2. Update Spring Data patch.2 versions and migrate Boot internal Elasticsearch modules.
3. Add LZ4 starter/BOM handling and producer-POM readiness checks.
4. Run focused project tests and independent Maven/Gradle consumer checks.
5. Synchronize GAV, migration, security/license, and SNAPSHOT documentation.
6. Keep the change on the development SNAPSHOT line until all internal dependencies have RELEASE coordinates; only then consider a separate Boot release change.

Rollback is a source-level revert of the coordinated change before publication. No immutable RELEASE artifact may be overwritten; if a partial publication exists, use a newly approved patch version.

## Open Questions

- Which NES Elasticsearch producer publication will first carry `at.yawk.lz4:lz4-java` transitively, and what immutable evidence will close the direct-consumer gap?
- Are all patch.2 Spring Data BOM and SDE artifacts available in the configured repository with metadata suitable for both Maven and Gradle consumers at implementation time?
- Do any downstream projects intentionally declare the old `jakarta.json:jakarta.json-api:1.1.6` coordinate while importing `javax.json.*`, requiring a migration note beyond Boot's own fixtures?
