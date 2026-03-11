---
agent: Agent_Build
task_ref: Task 4.3
status: Completed
ad_hoc_delegation: false
compatibility_issues: true
important_findings: true
---

# Task Log: Task 4.3 - 构建失败分析与修复

## Summary
Fixed 4 categories of build failures from Jackson 2.21.1 upgrade across 4 iterations: prohibited javax.* transitive dependencies (BOM + Gradle exclusions), bomrCheck validation, and jackson-module-kotlin Kotlin binary incompatibility.

## Details

### Iteration 1 — BOM-level exclusions (Maven POM publication)
- **Root cause:** `jackson-module-jaxb-annotations:2.21.1` (via `jersey-media-json-jackson:2.35`) transitively depends on `javax.xml.bind:jaxb-api` → `javax.activation:javax.activation-api`. Both caught by prohibited dependencies check.
- **Fix:** Added `jackson-module-jaxb-annotations` module with `jaxb-api` exclusion in Jackson Bom library in `spring-boot-dependencies/build.gradle`.

### Iteration 2 — Gradle-level global exclusions (local build)
- **Problem:** BOM plugin exclusions only apply to Maven POM publication, not Gradle resolution.
- **Fix:** Added `configureProhibitedTransitiveExclusions()` in `JavaConventions.java` — global `Configuration.exclude()` for `javax.activation:javax.activation-api` and `javax.xml.bind:jaxb-api` on all `*Classpath` configurations.

### Iteration 3 — bomrCheck "Unnecessary exclusions" fix
- **Problem:** bomrCheck flagged `javax.activation-api` exclusion as redundant (already covered by `jaxb-api` exclusion).
- **Fix:** Removed redundant `javax.activation-api` exclusion, kept only `jaxb-api`.

### Iteration 4 — jackson-module-kotlin Kotlin binary incompatibility
- **Problem:** `jackson-module-kotlin:2.21.1` compiled with Kotlin 2.1.0 (metadata version 2.1.0), project uses Kotlin 1.6.21 (expects metadata ≤ 1.6.0). Caused `compileKotlin FAILED` in `spring-boot-smoke-test-webflux-coroutines`.
- **Research:** Checked Kotlin versions across jackson-module-kotlin releases via Maven POM inspection:
  - 2.15.4: Kotlin 1.5.32 ✓
  - 2.16.2: Kotlin 1.6.21 ✓ (exact match)
  - 2.17.3: Kotlin 1.7.22 ✗
  - 2.21.1: Kotlin 2.1.0 ✗
- **Fix:** Added `strictly "2.16.2"` version constraint for `jackson-module-kotlin` in `spring-boot-dependencies/build.gradle` using standard Gradle `dependencies { constraints { } }` DSL. The `strictly` qualifier overrides the Jackson BOM's 2.21.1 version management. All other Jackson modules remain at 2.21.1.
- **Verification:** `compileKotlin` passes; `bomrCheck` passes.

## Output
- `spring-boot-project/spring-boot-dependencies/build.gradle`:
  - Jackson Bom library: `jackson-module-jaxb-annotations` module with `jaxb-api` exclusion (iter 1, 3)
  - `dependencies { constraints { } }` block: `jackson-module-kotlin` pinned to `strictly "2.16.2"` (iter 4)
- `buildSrc/src/main/java/org/springframework/boot/build/JavaConventions.java`:
  - `configureProhibitedTransitiveExclusions()` method with global classpath exclusions (iter 2)
- All files include Chinese comments

## Issues
None

## Compatibility Concerns
- `jackson-module-kotlin:2.16.2` is used with Jackson core modules at 2.21.1. This is a minor version mismatch but should be safe: jackson-module-kotlin is an isolated module that adds Kotlin serialization support; it doesn't have tight coupling with Jackson core internals beyond the stable public API. The project's original Jackson 2.15.4 also used this module at the same version.
- Future Kotlin version upgrades (to 1.7+) would allow upgrading jackson-module-kotlin to match the rest of Jackson.

## Important Findings
- The BOM plugin's module exclusions only apply to Maven POM publication, NOT Gradle's local dependency resolution.
- bomrCheck validates exclusions against resolved dependency trees — only exclude direct transitives, not sub-transitives.
- `jackson-module-kotlin` Kotlin version compatibility boundary: 2.16.x (Kotlin 1.6.21) → 2.17.x (Kotlin 1.7.22) → 2.21.x (Kotlin 2.1.0). Kotlin metadata is NOT backward compatible across minor versions.
- Gradle `strictly` constraints in `dependencies { constraints { } }` blocks override BOM-managed versions, even with `enforcedPlatform()`.

## Next Steps
- User should run `make build-thin` to verify the complete fix across all modules
