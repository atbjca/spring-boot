## 1. Dependency Contract Tests

- [x] 1.1 Add failing assertions for the 16-module NES Elasticsearch production allowlist, NES Java API Client, Barsson core, Jakarta JSON-P 2.0.2, NES JCL, and their expected versions.
- [x] 1.2 Add failing assertions that forbid the upstream Transport Client, Netty transport client, integ-test distribution, and `co.elastic.clients:elasticsearch-java` coordinates from generated production metadata.
- [x] 1.3 Add generated BOM/POM checks proving exclusions and coordinate mappings are present for Maven, Gradle dependency-management, and native Gradle platform consumption.

## 2. JSON-P Dual Runtime

- [x] 2.1 Replace the three Boot test-module declarations that use the old Jakarta 1.1.x alias with `javax.json:javax.json-api`.
- [x] 2.2 Narrowly allowlist only the `javax.json` group in the prohibited-classpath dependency check and add positive/negative tests for that boundary.
- [x] 2.3 Manage Jakarta JSON-P 2.0.2 and NES Barsson core for the Java client while retaining the Boot/Johnzon javax JSON-P and JSON-B path.
- [x] 2.4 Add ServiceLoader/provider and duplicate-class checks proving one supported provider per namespace and no Parsson/Barsson collision.

## 3. Spring Data Patch.2 Adoption

- [x] 3.1 Update the managed NES Spring Data BOM to `2021.2.18-nes.patch.2-SNAPSHOT`.
- [x] 3.2 Update the Spring Data Elasticsearch substitution/management line to `4.4.18-nes.patch.2-SNAPSHOT` without changing official unforked Spring Data modules.
- [x] 3.3 Add metadata assertions for the patch.2 BOM/SDE coordinates and the preserved Spring Data fork boundary.

## 4. Elasticsearch Client Closure

- [x] 4.1 Add explicit Boot BOM management for the verified 16-module NES Elasticsearch production closure.
- [x] 4.2 Replace official Elasticsearch Java Client management with the NES Java API Client coordinate and remove unsupported upstream managed coordinates.
- [x] 4.3 Migrate Elasticsearch dependencies in auto-configuration, actuator, actuator auto-configuration, test auto-configuration, test support, docs, and the data Elasticsearch starter to the managed NES coordinates.
- [x] 4.4 Preserve existing `org.elasticsearch.*` imports and add focused compile/test assertions for Boot integration APIs.

## 5. LZ4 Consumer Boundary

- [x] 5.1 Add BOM exclusions for `org.lz4:lz4-java` on the applicable NES Elasticsearch dependencies and manage `at.yawk.lz4:lz4-java:1.11.1`.
- [x] 5.2 Add the replacement LZ4 dependency explicitly to the Elasticsearch starter and verify the old implementation is absent from its runtime graph.
- [x] 5.3 Inspect the current NES Elasticsearch publication metadata and record whether direct SDE/HLRC consumers receive the replacement transitively.
- [x] 5.4 Keep the full-adoption gate open, with actionable evidence, if the producer POM still lacks the replacement dependency.

## 6. Focused Verification

- [x] 6.1 Run focused Elasticsearch auto-configuration, actuator, Spring Data Elasticsearch, starter, and test-support tests.
- [x] 6.2 Run JSON-B/Johnzon regressions and NES Java Client JSON-P provider tests.
- [x] 6.3 Verify the resolved graphs contain no official/NES duplicate classes, no forbidden official client coordinates, and no duplicate JSON-P providers.
- [x] 6.4 Inspect adopted production JARs and verify class major version 52 or lower.

## 7. Independent Consumer Verification

- [x] 7.1 Verify an independent Maven consumer using the generated Boot BOM and Elasticsearch starter/client graph.
- [x] 7.2 Verify an independent Gradle consumer using the Spring dependency-management plugin.
- [x] 7.3 Verify an independent Gradle consumer using native `platform(...)` constraints.
- [x] 7.4 Record resolved GAVs, LZ4 behavior, JSON-P providers, Java 8 evidence, and refreshed SNAPSHOT artifact identity for all fixtures.

## 8. Documentation and Release Boundary

- [x] 8.1 Update NES and general GAV mapping documents with the Elasticsearch closure, Java Client, Barsson, JSON-P, and patch.2 Spring Data coordinates.
- [x] 8.2 Update Quick Start and User Manual with the javax/Jakarta JSON-P migration rule, SNAPSHOT repository/refresh guidance, direct-consumer LZ4 boundary, and rollback instructions.
- [x] 8.3 Update requirements, component upgrade history, testing evidence, and vulnerability/license documents where the resolved graph changes their claims.
- [x] 8.4 Verify generated development metadata may use approved SNAPSHOTs but formal Boot RELEASE remains blocked until all internal dependencies have verified RELEASE coordinates.

## 9. Completion Review

- [x] 9.1 Review the implementation diff against all three capability specs and confirm no unrelated modules or broad coordinate substitutions were introduced.
- [x] 9.2 Record every verification command and result, including any producer-POM blocker, and leave incomplete tasks unchecked until the blocker is resolved.
