## Context

The Boot BOM currently manages all Apache HttpCore5 modules through one `HttpCore5` library at 5.3.6. CVE-2026-54399 identifies the 5.0-alpha through 5.4.2 line, plus 5.5-alpha through 5.5-beta1, as vulnerable to memory exhaustion because HTTP/1.1 line and header consumption has no secure default bound. Stable 5.4.3 is the smallest published fixed release; 5.5-beta2 is also fixed but would introduce a beta line and a broader compatibility change.

Parsson is already explicitly managed at 1.1.9 after a completed compatible-line upgrade from the 1.1.7 and 1.0.5 transitive requests. At that audit cutoff OSV did not identify an applicable CVE, so the project correctly documented proactive maintenance rather than inventing a vulnerability. Authoritative CVE-2026-9563 data available or updated after that cutoff identifies an affected range of 1.0.0 through 1.1.7 and a fix in 1.1.8; this change does not infer the CVE's first publication date. The existing 1.1.9 version and verification evidence are technically sufficient, but project records must now recognize the advisory and distinguish historical evidence from new classification work.

The project requires dependency versions to remain BOM-owned, security status to follow authoritative ranges, independent CVE detail records and vulnerability totals to stay synchronized, and fixed status to be supported by actual verification evidence. This change must not alter the release version or publish artifacts.

## Goals / Non-Goals

**Goals:**

- Move all BOM-managed HttpCore5 modules to stable 5.4.3 and prove representative consumers resolve that version.
- Record CVE-2026-54399 as fixed only after dependency metadata, focused compatibility tests, and required clean gates succeed.
- Recognize Parsson 1.1.9 as outside the CVE-2026-9563 affected range while preserving the original upgrade evidence and parsing-limit compatibility boundary.
- Keep requirements, independent CVE files, vulnerability totals, VEX decisions, GAV mapping, audit fixtures, and OpenSpec artifacts consistent.

**Non-Goals:**

- Adopt HttpCore5 5.5 beta releases or upgrade Apache HttpClient5 independently without evidence that 5.4.3 requires it.
- Change Parsson, Yasson, Jakarta JSON API, or Jakarta JSON Bind versions.
- Override Parsson's parser limit globally or change downstream application configuration.
- Remediate the separately scoped Log4j2 findings, change the project release version, publish, or deploy to Nexus.

## Decisions

1. **Select HttpCore5 5.4.3 as the minimum stable fixed release.** It is outside the authoritative affected range while staying on the stable 5.4 line. The alternative 5.5-beta2 is rejected because a beta dependency expands compatibility and support risk without improving CVE coverage.

2. **Retain single-point BOM ownership.** Change only the existing `HttpCore5` library version so `httpcore5`, `httpcore5-h2`, and `httpcore5-reactive` remain aligned. Module-level constraints, `resolutionStrategy` overrides, and consumer-specific version pins are prohibited.

3. **Verify the actual HttpCore5 consumption surface.** Generated Maven BOM and resolved-BOM evidence will prove the selected version. Focused tests and dependency inspection will cover Apache HttpClient5 integration, reactive HTTP use, command-line/buildpack consumers, and available smoke/integration paths before the full project gates.

4. **Treat Parsson as retrospective CVE recognition, not a second upgrade.** The BOM remains at 1.1.9. The new CVE detail and VEX entry will cite the authoritative affected and fixed ranges and link them to the archived dependency-resolution and JSON-B test evidence. Documentation must not imply that tests were rerun at the original upgrade date because of a CVE that was not known then.

5. **Preserve Parsson's compatibility warning.** CVE-2026-9563 is fixed by the secure default parsing limit introduced in 1.1.8. The documentation will retain the 15,000,000-operation limit and `org.eclipse.parsson.maxParsingLimit` as a downstream opt-in adjustment, with no global override in Boot.

6. **Use actual post-change evidence to finalize status.** CVE-2026-54399 remains affected/in progress until the final HttpCore5 graph and tests pass. CVE-2026-9563 can be classified fixed from the already-selected 1.1.9 version and retained verification evidence, supplemented by current metadata and audit reconciliation.

## Risks / Trade-offs

- **[HttpCore5 5.4.3 changes parser-limit behavior for unusual HTTP traffic]** → Run focused client, reactive, CLI/buildpack, and smoke/integration tests; document any externally observable compatibility boundary instead of disabling the secure limit globally.
- **[HttpClient5 and HttpCore5 minor lines are incompatible]** → Inspect published dependency metadata and resolved graphs, retain the existing managed HttpClient5 version unless a separate evidence-backed change is required, and stop rather than introduce an unplanned group upgrade.
- **[A transitive or module override leaves mixed HttpCore5 versions]** → Verify generated BOM and representative dependency graphs contain only 5.4.3 for all three managed modules.
- **[Retrospective Parsson wording fabricates historical intent or test evidence]** → State that 1.1.9 was originally proactive maintenance and is now recognized as fixed after advisory publication; reuse only commands and results that were actually recorded.
- **[Vulnerability totals or VEX classifications drift]** → Update machine-readable and human-readable records together and run deterministic audit tests plus strict OpenSpec validation.

## Migration Plan

1. Reconfirm advisory metadata, fixed artifacts, current BOM versions, and representative dependency paths.
2. Update the single HttpCore5 BOM library to 5.4.3 and regenerate dependency-management evidence.
3. Run focused HttpCore5 dependency and behavioral verification, followed by required clean project gates.
4. Add or update CVE-2026-54399 and CVE-2026-9563 records, totals, VEX, requirements, GAV mapping, and audit fixtures with actual results.
5. Validate the OpenSpec change strictly and review the final diff for version ownership and evidence consistency.

Rollback restores the HttpCore5 library to 5.3.6 and reclassifies CVE-2026-54399 as affected; it must not undo the independently valid Parsson CVE recognition. No remote rollback or publication action is part of this change.

## Open Questions

- Which smallest existing CLI/buildpack and reactive test tasks exercise the HttpCore5 paths without duplicating the full gate? Resolve from the current task graph during implementation and record the exact commands and results.
- Does HttpCore5 5.4.3 introduce a user-configurable parsing limit that warrants a focused release-note compatibility note? Confirm from the Apache release/advisory documentation before finalizing project documentation.
