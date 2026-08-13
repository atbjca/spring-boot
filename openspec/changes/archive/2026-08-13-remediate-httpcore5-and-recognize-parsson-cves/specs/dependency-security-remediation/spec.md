## ADDED Requirements

### Requirement: HttpCore5 HTTP parser exhaustion is remediated on a stable line

The project MUST manage `org.apache.httpcomponents.core5:httpcore5`, `httpcore5-h2`, and `httpcore5-reactive` at 5.4.3 or a newer compatible stable fixed release so that CVE-2026-54399 is outside the affected HttpCore5 ranges, without selecting a 5.5 prerelease or adding a module-level version override.

#### Scenario: Generated dependency management selects one fixed HttpCore5 version

- **WHEN** the Spring Boot dependency-management POM, resolved BOM, and representative HttpCore5 consumer graphs are generated
- **THEN** all three managed HttpCore5 modules resolve to 5.4.3 or a newer approved stable fixed release
- **AND** no HttpCore5 version through 5.4.2, 5.5-alpha through 5.5-beta1, prerelease, or consumer-specific override is selected
- **AND** the existing Apache HttpClient5 version is retained unless separate compatibility evidence requires and approves a broader upgrade

#### Scenario: HttpCore5 compatibility is verified before fixed classification

- **WHEN** CVE-2026-54399 is classified as fixed
- **THEN** representative Apache HttpClient5, reactive HTTP, CLI, buildpack, documentation, and available smoke or integration paths have passed focused verification against the final managed version
- **AND** a clean thin build and the required core project gate have completed successfully
- **AND** the independent CVE record contains the affected range, HTTP/1.1 unbounded line or header memory-exhaustion trigger, selected fix, actual commands, results, and audit cutoff

### Requirement: Parsson CVE classification follows newly available advisory evidence

The project MUST recognize managed `org.eclipse.parsson:parsson:1.1.9` as fixed for CVE-2026-9563 because the authoritative affected range ends at 1.1.7 and the fix begins at 1.1.8, while preserving the fact that the original 1.1.9 upgrade was performed as proactive maintenance before this advisory was available.

#### Scenario: Existing Parsson remediation evidence is reconciled without another version change

- **WHEN** CVE-2026-9563 is added to project security records
- **THEN** the BOM remains the single version owner for Parsson 1.1.9
- **AND** Yasson 3.0.4 requests for Parsson 1.1.7 and representative Elasticsearch Java client requests for 1.0.5 continue to resolve to 1.1.9
- **AND** the record distinguishes previously completed dependency and JSON-B verification from the later advisory-based classification

#### Scenario: Secure parsing limit remains an explicit compatibility boundary

- **WHEN** the Parsson CVE fix and compatibility impact are documented
- **THEN** the record states that Parsson 1.1.8 introduced and 1.1.9 retains a default 15,000,000 parser character-consumption limit
- **AND** unusually large JSON consumers are directed to evaluate the provider-specific `org.eclipse.parsson.maxParsingLimit` property
- **AND** the project does not apply a global override that disables or weakens the secure default

### Requirement: Newly reconciled CVE evidence remains synchronized

Project security documentation and machine-readable decisions MUST consistently classify CVE-2026-54399 and CVE-2026-9563 using authoritative ranges, final managed versions, component reachability, trigger conditions, and actual verification evidence.

#### Scenario: Human-readable and machine-readable security records agree

- **WHEN** the change is ready for archive
- **THEN** `doc/REQUIREMENTS.md`, `doc/VULNERABILITY_REPORT.md`, independent files under `doc/CVE/`, `doc/NES_GAV_MAPPING.md`, `scripts/security-audit/vex-decisions.json`, applicable audit fixtures or tests, and the OpenSpec capability report the same versions and statuses
- **AND** fixed, deferred, immune, and total counts are recalculated rather than copied from a prior audit
- **AND** no record claims an unexecuted test, a release-version change, publication, or deployment
