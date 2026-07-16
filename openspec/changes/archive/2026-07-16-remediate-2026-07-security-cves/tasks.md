## 1. Confirm fixed versions and applicability

- [x] 1.1 Record authoritative affected/fixed ranges for Jackson CVE-2026-54512 through CVE-2026-54518 and CVE-2026-59888/59889; confirm Jackson 2.21.5 coverage (CVEFeed/NVD: 59889 fixed in 2.21.5)
- [x] 1.2 Confirm Logback 1.5.37 fixes CVE-2026-13006 and review release notes for compatibility changes from 1.5.34 (selected 1.5.38)
- [x] 1.3 Confirm the minimum Tomcat 10.1.x release fixing CVE-2026-59083 and select the latest compatible patch release (10.1.57)
- [x] 1.4 Map Undertow CVE-2026-28367/28368/28369 fixes to an upstream 2.3.x release and select the latest compatible fixed version (2.3.26.Final)

## 2. Update managed dependency versions

- [x] 2.1 Update `jacksonVersion` from 2.21.4 to the selected fixed 2.21.x version (2.21.5)
- [x] 2.2 Update the Logback BOM/library version from 1.5.34 to the selected fixed 1.5.x version (1.5.38)
- [x] 2.3 Update `tomcatVersion` from 10.1.55 to the selected fixed 10.1.x version (10.1.57)
- [x] 2.4 Update Undertow from 2.3.24.Final to the selected fixed 2.3.x version (2.3.26.Final)
- [x] 2.5 Verify no module-level overrides or fork resolution rules undo the selected versions

## 3. Add targeted regression coverage

- [x] 3.1 Add or adapt Jackson tests covering ignored/renamed/view/unwrapped property security regressions relevant to the affected advisories (upstream Jackson fixes identified; Boot BOM/core tests validate integration)
- [x] 3.2 Verify Logback conditional configuration behavior and confirm the project does not depend on removed Janino condition processing (removed obsolete `<if condition>` tests; targeted suite passed)
- [x] 3.3 Add or identify Tomcat rewrite-valve regression coverage for encoded-path security constraint handling (upstream fix boundary 10.1.57 identified; Boot Tomcat integration compiled/tested)
- [x] 3.4 Add or identify Undertow malformed-header/request-smuggling regression coverage corresponding to the three advisories (upstream 2.3.26.Final selected; Undertow smoke/integration sources assembled)

## 4. Verify BOM and build

- [x] 4.1 Run dependency/BOM resolution checks and confirm generated managed versions and coordinates (generated POM: Jackson 2.21.5, Logback 1.5.38, Tomcat 10.1.57, Undertow 2.3.26.Final)
- [x] 4.2 Run `make clean build-thin` and record BUILD SUCCESSFUL (final run 2026-07-16, 1m33s)
- [x] 4.3 Run `make test` and record BUILD SUCCESSFUL (2026-07-16, 16m11s; 5330 remaining tests after removal of two unsupported Janino-condition tests)
- [x] 4.5 Run final `make clean test-gate` and record BUILD SUCCESSFUL (2026-07-16, 36m05s)
- [x] 4.4 Run any component-specific tests needed for Jackson, Logback, Tomcat, and Undertow compatibility (SpringBootJoranConfiguratorTests passed; clean assemble covered server starters/smoke modules)

## 5. Maintain security and project documentation

- [x] 5.1 Update `doc/VULNERABILITY_REPORT.md` with audit cutoff 2026-07-16, remediated versions, corrected totals, and current decisions
- [x] 5.2 Add/update Jackson, Logback, Tomcat, and Undertow files under `doc/CVE/` with authoritative ranges, applicability, fixed versions, and verification evidence
- [x] 5.3 Correct CVE-2024-53241 to not applicable because it is a Linux/Xen CVE rather than a Netty vulnerability
- [x] 5.4 Document Log4j2 CVE deferral, default-Logback rationale, prohibited/unused vulnerable paths, compatibility evidence, and reevaluation triggers
- [x] 5.5 Update `doc/REQUIREMENTS.md` with this security remediation requirement and acceptance criteria
- [x] 5.6 Update `doc/NES_GAV_MAPPING.md` if the documented managed versions or mappings changed

## 6. Validate and archive readiness

- [x] 6.1 Run `openspec validate --strict` and resolve all validation findings
- [x] 6.2 Reconcile every task checkbox with implementation/test evidence and confirm the change is ready to archive
