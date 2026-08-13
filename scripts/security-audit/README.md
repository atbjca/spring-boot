# Resolved BOM security audit

`make audit-bom-security` is an explicit security/release activity. It is not a dependency of normal offline builds. The command reads the generated `resolved-bom.json`, inventories every direct managed dependency and every dependency expanded from imported BOMs, creates canonical Maven PURLs, adds configured NES-to-upstream aliases, queries OSV in batches, and writes `build/reports/security/resolved-bom-osv.json`.

The inventory duplicate key is `groupId:artifactId:version:classifier`. Duplicate occurrences are retained as source provenance; missing or malformed coordinates and count mismatches fail the audit. Classifiers remain in inventory PURLs, while OSV lookup PURLs omit classifiers because Maven vulnerability ranges apply to the underlying release.

Run:

```bash
make audit-bom-security
```

For a deterministic, offline inventory check:

```bash
make audit-bom-inventory
make test-bom-security-audit
```

OSV failures, missing/truncated batches, stale response timestamps, inventory mismatches, or findings without an entry in `vex-decisions.json` produce an incomplete report and a non-zero exit. An empty or failed response is never clean-state evidence. Each VEX decision uses one of `affected`, `fixed`, `immune`, `not_applicable`, `false_positive`, or `deferred` and records an authority, rationale, and review timestamp.

The alias manifest stores only coordinate transformation and version-normalization rules. Versions always come from the generated BOM. Keep `nes-upstream-aliases.json` synchronized with `build.gradle` resolution rules and `doc/NES_GAV_MAPPING.md`.

## Secondary SCA corroboration

Grype may corroborate a complete OSV audit when its local vulnerability database is fresh enough for the recorded cutoff. Record `grype db status` (or equivalent version/date evidence) with the scan output. If the database is unavailable, update fails, its age predates the audit cutoff, or the scan is partial, its zero-result output must not be used as clean-state evidence. Grype corroboration does not replace module/range review or VEX classification.
