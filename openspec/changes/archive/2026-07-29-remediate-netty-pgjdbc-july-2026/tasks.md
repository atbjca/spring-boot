## 1. Confirm fixed versions and advisory inventory

- [x] 1.1 Confirm Netty 4.1.136.Final is the 4.1.x minimum fix for CVE-2026-59901 and list all assigned CVE IDs from the official 4.1.136.Final announcement (note any `CVE-2026-XXXXX` placeholders as pending IDs)
- [x] 1.2 Confirm PostgreSQL JDBC CVE-2026-54291 affected range (`>= 42.7.4, < 42.7.12`) and select 42.7.13 as the managed target
- [x] 1.3 Confirm Tomcat CVE-2026-66299 is examples-only, 10.1.58 is not yet published on Maven Central, and 10.1.57 remains the managed version for this change

## 2. Update managed dependency versions

- [x] 2.1 Update `library("Netty", …)` from `4.1.135.Final` to `4.1.136.Final` in `spring-boot-project/spring-boot-dependencies/build.gradle`
- [x] 2.2 Update `library("Postgresql", …)` from `42.7.11` to `42.7.13` in the same file
- [x] 2.3 Verify Netty 4.2.x prohibition remains in place and no module-level overrides undo the selected versions

## 3. Verify BOM and build

- [x] 3.1 Run dependency/BOM resolution checks and confirm generated managed versions show Netty `4.1.136.Final` and PostgreSQL JDBC `42.7.13`
- [x] 3.2 Run `make clean build-thin` and record BUILD SUCCESSFUL
- [x] 3.3 Run `make test` and record BUILD SUCCESSFUL

## 4. Maintain security and project documentation

- [x] 4.1 Update `doc/VULNERABILITY_REPORT.md` with audit cutoff 2026-07-29, Netty/pgjdbc remediations, and Tomcat CVE-2026-66299 classification
- [x] 4.2 Add/update `doc/CVE/` entries for CVE-2026-54291, CVE-2026-59901, and other assigned Netty 4.1.136 batch CVEs; note pending placeholder IDs if any
- [x] 4.3 Document CVE-2026-66299 as immune/not applicable for default Boot-embedded Tomcat (examples-only; wait for published 10.1.58)
- [x] 4.4 Update `doc/REQUIREMENTS.md` with Netty 4.1.136.Final and PostgreSQL JDBC 42.7.13 requirements
- [x] 4.5 Update `doc/NES_GAV_MAPPING.md` only if it lists managed versions that changed

## 5. Validate and archive readiness

- [x] 5.1 Run `openspec validate --strict` and resolve all validation findings
- [x] 5.2 Reconcile every task checkbox with implementation/test evidence and confirm the change is ready to archive (release/deploy remains out of scope)

### Evidence

- Generated POM (`generatePomFileForMavenPublication`): `netty.version=4.1.136.Final`, `postgresql.version=42.7.13`
- `make clean build-thin`: BUILD SUCCESSFUL in 2m 22s (2026-07-29)
- `make test`: BUILD SUCCESSFUL in 6m 34s (2026-07-29)
- `doc/NES_GAV_MAPPING.md`: no Netty/pgjdbc version rows; left unchanged
- Release/Nexus redeploy: out of scope
