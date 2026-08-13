## Why

The NES Elasticsearch 7.17, Elasticsearch Java client, Parsson/Barsson, Spring Data Elasticsearch, and Spring Data BOM updates are ready to be consumed by the Spring Boot 2.7 development line. Boot currently manages upstream coordinates for part of this graph, which can leave consumers with mixed official/NES artifacts, duplicate JSON-P providers, or an incomplete LZ4 runtime.

This change aligns Boot's dependency management, internal modules, published metadata, runtime-provider rules, and consumer-facing documentation with the verified NES client stack while keeping the existing Java 8 and SNAPSHOT release boundaries.

## What Changes

- Add explicit management for the NES Elasticsearch client dependency closure, including the NES Elasticsearch modules, NES Java API Client, NES Barsson core, Jakarta JSON-P 2.0.2, and the approved NES support artifacts.
- **BREAKING** Stop managing upstream Elasticsearch Java client and unsupported server/transport publication coordinates that are not part of the NES consumer closure.
- Update the Spring Data BOM and Spring Data Elasticsearch managed versions to the verified NES patch.2 SNAPSHOT line.
- Migrate Boot's Elasticsearch-related internal modules and test fixtures to the NES coordinates while retaining the original `org.elasticsearch.*` Java packages.
- Define the JSON-P dual-runtime contract: existing Boot/Johnzon users continue using `javax.json.*`, while the NES Java client uses `jakarta.json.*`; add a narrowly scoped `javax.json` classpath allowlist where the repository's dependency check requires it.
- Manage the LZ4 exclusion/replacement boundary and record the remaining producer-POM requirement when direct NES Elasticsearch consumers do not receive the replacement transitively.
- Add static and independent Maven/Gradle consumer checks, duplicate-provider checks, Java 8/class-major checks, and documentation for GAV mapping, migration, SNAPSHOT use, and release boundaries.

## Capabilities

### New Capabilities

- `nes-elasticsearch-client-dependencies`: Defines the NES Elasticsearch 7.17 client dependency closure, managed versions, allowlist/denylist, internal-module adoption, LZ4 boundary, and consumer verification requirements.
- `dual-jsonp-runtime`: Defines coexistence of the Boot/Johnzon `javax.json.*` runtime and the NES client `jakarta.json.*` runtime, including provider uniqueness, dependency-check allowlisting, and migration behavior.

### Modified Capabilities

- `nes-spring-data-dependencies`: Update the managed Spring Data BOM and Spring Data Elasticsearch NES coordinates from the previous patch line to the verified patch.2 SNAPSHOT line, while preserving the existing fork boundary for unforked Spring Data modules.

## Impact

- `spring-boot-project/spring-boot-dependencies` and the root Gradle dependency-management/substitution rules.
- Elasticsearch auto-configuration, actuator, test-autoconfigure, test-support, documentation, and the Elasticsearch starter modules that consume the managed client graph.
- Classpath prohibition checks for the precise `javax.json` API coordinate.
- Generated Maven BOM/POM and Gradle metadata, independent Maven and Gradle consumer fixtures, and Java 8 compatibility evidence.
- GAV, quick-start, user-manual, component-history, vulnerability/license, and migration documentation.
- No change to `component-release` requirements: formal Boot RELEASE publication remains blocked while approved internal dependencies are SNAPSHOTs.
