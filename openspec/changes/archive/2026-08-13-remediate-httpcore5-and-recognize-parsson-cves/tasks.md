## 1. Confirm Advisory and Dependency Baselines

- [x] 1.1 Reconfirm authoritative CVE, Apache/Eclipse advisory, fix-commit or release-note, and Maven Central evidence for CVE-2026-54399 and CVE-2026-9563, including affected modules, ranges, fixed versions, publication timestamps, and the final audit cutoff.
- [x] 1.2 Capture the current BOM and representative dependency graphs showing HttpCore5 5.3.6 across `httpcore5`, `httpcore5-h2`, and `httpcore5-reactive`, plus Parsson 1.1.9 overriding the Yasson 1.1.7 and Elasticsearch Java client 1.0.5 requests.
- [x] 1.3 Identify the smallest existing Apache HttpClient5, reactive HTTP, CLI, buildpack, documentation, smoke, and integration test tasks that exercise the HttpCore5 consumption surface, recording any environment prerequisites before implementation.

## 2. Upgrade the BOM-Owned HttpCore5 Line

- [x] 2.1 Change only the existing `HttpCore5` BOM library version from 5.3.6 to stable 5.4.3, retaining its current modules and adding no module-level, `resolutionStrategy`, or consumer-specific version override.
- [x] 2.2 Generate the dependency-management Maven POM and resolved BOM and verify all managed HttpCore5 modules select 5.4.3, no affected or prerelease HttpCore5 version remains, and the existing HttpClient5 line remains internally consistent.
- [x] 2.3 Inspect representative dependency graphs for optional HttpClient5 and `httpcore5-reactive` consumers, CLI/buildpack paths, documentation tests, and smoke/integration modules to prove a single selected HttpCore5 version.

## 3. Verify HttpCore5 Compatibility

- [x] 3.1 Run focused `spring-boot` and auto-configuration tests that cover Apache HttpClient5 and reactive HttpCore5 behavior against 5.4.3.
- [x] 3.2 Run the selected CLI, buildpack, documentation, smoke, and integration tests whose runtime graphs use HttpCore5, recording unavailable environment-dependent tasks and compensating evidence rather than claiming they passed.
- [x] 3.3 Review Apache 5.4.3 parser-limit and HTTP behavior changes and add a focused regression or compatibility note if an existing Boot-supported path is not adequately covered.

## 4. Reconcile CVE-2026-9563 Against Existing Parsson Evidence

- [x] 4.1 Verify the final generated BOM and representative JSON-B and Elasticsearch Java client graphs still select Parsson 1.1.9 while Yasson 3.0.4 and the Jakarta JSON API versions remain unchanged.
- [x] 4.2 Reconcile the archived Parsson 1.1.9 dependency, JSON-B, clean-build, and core-test evidence with the newly available or updated CVE-2026-9563 affected and fixed ranges without rewriting the historical upgrade rationale, inferring the first publication date, or inventing a CVE-driven test run.
- [x] 4.3 Confirm documentation retains the default 15,000,000 parser character-consumption limit and downstream `org.eclipse.parsson.maxParsingLimit` compatibility boundary, with no global override added to the project.

## 5. Run Clean Project Gates

- [x] 5.1 Run `make clean build-thin` against the final HttpCore5 5.4.3 and Parsson 1.1.9 dependency state and retain the actual result.
- [x] 5.2 Run `make test` against the same clean dependency state and retain the actual result.
- [x] 5.3 Run `make test-gate` when required by the final risk review or any focused/full-test failure; otherwise record the evidence-based reason it was not required.

## 6. Synchronize Security and Dependency Documentation

- [x] 6.1 Add an independent `doc/CVE/CVE-2026-54399.md` record with component, affected range, fixed version, trigger, reachability, selected stable remediation, authoritative references, and actual verification results.
- [x] 6.2 Add an independent `doc/CVE/CVE-2026-9563.md` record that recognizes Parsson 1.1.9 as fixed, preserves the original proactive-maintenance chronology, and documents the secure parser limit.
- [x] 6.3 Update `doc/REQUIREMENTS.md`, `doc/VULNERABILITY_REPORT.md`, and `doc/NES_GAV_MAPPING.md` with the final versions, status totals, transitive paths, compatibility boundaries, audit cutoff, and executed verification evidence.
- [x] 6.4 Update `scripts/security-audit/vex-decisions.json` and applicable audit fixtures/tests so both CVEs are classified consistently from the generated BOM, with no unrelated Log4j2 deferral change.
- [x] 6.5 Update the OpenSpec implementation evidence only after the relevant commands complete, ensuring no unexecuted test, release-version change, publication, or Nexus deployment is claimed.

## 7. Validate the Completed Change

- [x] 7.1 Run the security-audit unit/fixture tests affected by the new CVE and VEX records and resolve every deterministic classification or count mismatch.
- [x] 7.2 Run `openspec validate remediate-httpcore5-and-recognize-parsson-cves --type change --strict` and resolve every validation error.
- [x] 7.3 Review the final diff for BOM-only version ownership, stable HttpCore5 selection, Parsson chronology accuracy, synchronized vulnerability totals, preserved Log4j2 decisions, and absence of release, publication, Nexus, `.claude/`, `.codex/`, or `.cursor/` changes.

## Implementation Evidence

- `make clean build-thin`: `BUILD SUCCESSFUL in 1m 56s`; the thin assemble reported 828 actionable tasks after the clean phase completed 149 tasks.
- `make test`: `BUILD SUCCESSFUL in 10m 11s`; 42 actionable tasks (9 executed, 2 from cache, 31 up-to-date).
- Focused synchronous/reactive HttpComponents and auto-configuration tests passed. Buildpack-platform HTTP transport passed 25/25 after removing an externally supplied `DOCKER_HOST`; the CLI module is excluded from this fork's root settings and was recorded as unavailable rather than passed.
- `make test-gate` was not required for this change: the representative dependency graphs, focused tests, clean thin build, and core project gate all passed without a relevant failure, and the change is limited to the BOM-owned HttpCore5 stable patch/minor line. No release version, publication, or Nexus deployment action was performed.
- Security-audit unit/fixture tests passed 9/9. Strict OpenSpec validation and `git diff --check` passed. Final review confirmed the only production dependency edit is the BOM-owned HttpCore5 5.3.6 to 5.4.3 change; Parsson remains 1.1.9, Log4j2 deferrals remain unchanged, and `.claude/`, `.codex/`, and `.cursor/` stay untracked and outside the change.
