# Spring Security patch.2 adoption evidence

## Workspace preflight

Captured on 2026-08-11 (Asia/Shanghai).

| Repository | Branch | HEAD | Upstream state | Worktree disposition |
|---|---|---|---|---|
| Spring Boot 2.7 NES | `2.7.x-bjca-patch` | `4e5c93f0099862fc132f1a1a50d75d907ada22fa` | `origin/2.7.x-bjca-patch`, ahead 0 / behind 0 | Only this active change's six initial OpenSpec files were untracked |
| Spring Security 5.8 NES | `5.8.x-bjca-patch` | `2e4c5af27922e5e51f4d164481334d76306c80b6` | `origin/5.8.x-bjca-patch`, ahead 0 / behind 0 | Only pre-existing `.claude/`, `.codex/`, and `.cursor/` tool files were untracked |

`openspec list --json` reported only `adopt-spring-security-patch-2-security-baseline` as active. No unrelated tracked file was modified or cleaned during preflight.

## Producer and release state

- Producer live version: `5.8.16-nes.patch.2-SNAPSHOT`.
- Previous immutable release: `5.8.16-nes.patch.1` / `v5.8.16-nes.patch.1`.
- Local, GitHub `origin`, and internal `gitlab` tag queries returned no `v5.8.16-nes.patch.2`.
- Nexus RELEASE POM request for `bjca-footstone-bpring-security-bom:5.8.16-nes.patch.2` returned HTTP 404.
- Producer candidate source evidence is bound to commit `9c5e51ee66dc47bc02bb25e803f5bccc71b7cd5a`; changes from that commit to current producer HEAD affect only documentation.

Formal Boot RELEASE remains blocked until the Security RELEASE POM and exact tag exist and are verified.

## Fresh Nexus SNAPSHOT identity

The snapshot was read directly from Nexus metadata and timestamped artifact URLs, bypassing Maven/Gradle caches.

| Item | Value |
|---|---|
| Repository | `http://192.168.131.36:8088/repository/snapshots/` |
| Logical version | `5.8.16-nes.patch.2-SNAPSHOT` |
| Resolved version | `5.8.16-nes.patch.2-20260811.065312-1` |
| Metadata lastUpdated | `20260811065312` |
| BOM POM SHA-256 | `57b33c93f374b9abd2c0b0c13529d9db4d709d8bf0bac83305e32e61247a6e69` |
| BOM module SHA-256 | `d210b07954de3cff6d7a4160e73dbebf047c24c2bd000c372dfedc473831e483` |
| Core JAR SHA-256 | `e57abcd893121d449ca5119ab25ce1ec89461063ee3ccb6f394fefda86c3eae9` |
| Web JAR SHA-256 | `54472c71c4a5dc30b899ea976f082c3cf66c5db3c655bfeb432e711046d9a768` |
| Crypto JAR SHA-256 | `3ef309c7ce0ee693467494110637a76581de59ad44cc87b06ca135a4ffcedc84` |
| SAML JAR SHA-256 | `4b750c007f338a2255fe01e5b8e1cf126ad91e2dbf7865897281c65a135e2e2c` |

The four downloaded JAR hashes exactly match the producer candidate report generated for source commit `9c5e51ee66`. Representative classes in core, web, crypto, and SAML all report class major 52.

## Seven-CVE producer evidence

| CVE | Upstream fix reference | Producer implementation/result | Boot disposition basis |
|---|---|---|---|
| CVE-2026-22732 | `1dae9aa45943` | `06980f11c5`; response-wrapper targeted tests/checkstyle and Java 8 passed | Candidate web JAR hash and Java 8 evidence match |
| CVE-2026-22746 | `a317a3d86639` | `06692b7982`; DAO authentication targeted tests/checkstyle and Java 8 passed | Candidate core JAR hash and Java 8 evidence match |
| CVE-2026-40988 | `9d4d9065b485` | `ff517736e7`; SAML inflate boundary suite and Java 8 passed | Candidate SAML JAR hash and Java 8 evidence match |
| CVE-2026-41003 | `356131b1ea6e` | `86b66453e4`; SAML form-injection suite/checkstyle and Java 8 passed | Candidate web/SAML artifacts and Java 8 evidence match |
| CVE-2026-41694 | `e50c2a6a74d5`, `cf0687120024` | `c538906af5`; OpenSAML 3 signature/decryptor suite and Java 8 passed | Candidate SAML JAR hash and OpenSAML 3 consumer evidence match |
| CVE-2026-41706 | `a14c9d66b159` | `c3f9feb8aa`; servlet/reactive cookie request-cache tests/checkstyle and Java 8 passed | Candidate web JAR hash and Java 8 evidence match |
| CVE-2026-47838 | `e3ad551ab337` | `13715519e7`; web/config X.509 suites/checkstyle and Java 8 passed | Candidate web artifact and Java 8 X.509 evidence match |

The producer `make verify-published-security` evidence records Amazon Corretto `1.8.0_472`, passing Maven and Gradle consumers, OpenSAML 3 initialization, OpenSAML 4 absence, Bouncy Castle AES-GCM, and LDAP/OpenID/Xerces class loading.

## Patch.1 and patch.2 Boot control runs

Before changing the two test imports, completed patch.1 and patch.2 command-line override runs produced the same result:

- 262 test executions after retry expansion;
- 56 failed executions after retry expansion;
- 14 unique failing test methods: 12 OAuth2 resource-server assertions and 2 SAML assertions;
- every failure was an `isInstance`/filter-presence mismatch caused by the deprecated old-package compatibility class;
- no failure was unique to patch.2.

The accepted fixes already exist in Boot history:

- `bf2b381387c`: use `web.authentication.BearerTokenAuthenticationFilter` and re-enable 12 OAuth2 tests;
- `541799f4147`: use `web.authentication.Saml2WebSsoAuthenticationFilter` for SAML chain assertions.

An additional 2026-08-11 attempt to repeat the control with `--rerun-tasks` was intentionally stopped during the full `compileTestJava` rebuild because it duplicated the completed evidence and had not reached test execution. It is not reported as a passing run.

## Repository-native verification design

Task 2.1 selected the repository's existing publication and assertion mechanisms rather than adding a new framework:

- generated Maven POMs use the existing `org.springframework.boot.deployed` publication task `generatePomFileForMavenPublication`, matching the `BomPluginIntegrationTests` pattern and its `build/publications/maven/pom-default.xml` output;
- Gradle Module Metadata uses the matching Maven publication task `generateMetadataFileForMavenPublication` and its generated `module.json` output;
- isolated downstream publication will reuse `publishMavenPublicationToProjectRepository` from `MavenRepositoryPlugin` instead of creating another repository/publishing implementation;
- dependency-graph evidence will come from the repository's existing Gradle configurations and dependency reporting/resolution, with executable checks for forbidden official Security modules and mixed patch.1/patch.2 implementations;
- a repository-local shell gate will orchestrate these existing tasks and inspect their outputs using standard JDK/shell facilities only. Minimal Maven and Gradle consumers will be added later as fixtures that consume publication metadata and deliberately contain no Boot root `resolutionStrategy` or source substitution.

This design adds no test framework, dependency-management plugin, or duplicate Boot BOM. The target version literal in the verification oracle is an adoption expectation, not a second build version source; production resolution and publication continue to use only `springSecurityVersion` from `gradle.properties`.

## Patch.1 publication-contract red phase

The executable gate was added at `scripts/verify-spring-security-adoption.sh` with separate `source`, `bom`, `starters`, `graph`, and `all` modes so each contract can be demonstrated independently before the version change.

For task 2.2, `./scripts/verify-spring-security-adoption.sh source` exited 1 on the patch.1 baseline. The existing official-to-NES group/artifact mapping, the mapping's use of `springSecurityVersion`, the existing BOM library's use of the same property, and its NES Security BOM import all passed. The two expected failures were:

- `springSecurityVersion` was `5.8.16-nes.patch.1`, not `5.8.16-nes.patch.2-SNAPSHOT`;
- the patch.2 target literal was consequently absent from the sole build-version-source location.

Running the same source contract with `EXPECTED_SECURITY_VERSION=5.8.16-nes.patch.1` exited 0, proving that the red result is the intended target-version delta rather than a broken mapping assertion.

For task 2.3, the existing `generatePomFileForMavenPublication` task generated `spring-boot-dependencies/build/publications/maven/pom-default.xml`, then `SKIP_GENERATION=1 ./scripts/verify-spring-security-adoption.sh bom` exited 1. Assertions confirmed that the repository still contains one Boot dependency-management project, the generated POM contains exactly one NES Security BOM dependency, and that dependency uses `pom`/`import` with `${spring-security.version}`. The expected failures were the generated property remaining `5.8.16-nes.patch.1` and the explicit patch.1 prohibition. No second Boot BOM or duplicate Security BOM import was observed.

For task 2.4, the existing publication tasks generated Maven POM and Gradle Module Metadata for `spring-boot-starter-security` and `spring-boot-starter-oauth2-resource-server`. `SKIP_GENERATION=1 ./scripts/verify-spring-security-adoption.sh starters` exited 1 with four expected failures: each POM/module pair exposed NES Security GAVs but required `5.8.16-nes.patch.1` instead of patch.2-SNAPSHOT. Re-running the same structural and coordinate assertions with `EXPECTED_SECURITY_VERSION=5.8.16-nes.patch.1` exited 0 for all four outputs, showing that no official Security GAV was present and that the red result is the version transition under test.

For task 2.5, `./scripts/verify-spring-security-adoption.sh graph` resolved both `compileClasspath` and `runtimeClasspath` for `spring-boot-starter-oauth2-resource-server`. An initial sandbox-only wrapper-lock error was excluded from the code result; the approved rerun reached both real dependency reports and exited 1 with one expected assertion failure per configuration. Every declared `org.springframework.security:spring-security-*` request showed an explicit arrow to the corresponding NES GAV, and no unmapped official implementation was selected. All selected core Security modules and the Security BOM were consistently `5.8.16-nes.patch.1`, so the target patch.2 assertion failed without observing a mixed patch.1/patch.2 graph. The independently versioned Spring Authorization Server patch.1 coordinate is explicitly excluded from the core Security-family version assertion.

Task 2.6 audited the executable assertion surface:

| Contract judgment | Executable coverage |
|---|---|
| `springSecurityVersion` exists once and equals the adoption target | `source` property count/value assertions |
| Official module requests use the existing derived NES artifact mapping and the same version property | `source` static mapping assertions plus `graph` request-to-selection arrows |
| No duplicate production version literal | `source` build-file/property search restricted to the single `gradle.properties` source |
| Existing Boot BOM imports one NES Security BOM using `pom`/`import` and the shared property | `bom` generated-POM block parser and single-import/project counts |
| Generated starter POM and Gradle metadata use NES group/artifact/version | `starters` top-level POM dependency parser and Gradle metadata dependency parser |
| Official Security GAV and patch.1 are forbidden in representative published Security dependencies | `starters` official-group rejection and exact target-version checks |
| Compile/runtime graphs contain mapped official requests and one target NES implementation family | `graph` assertions for both configurations; the independent Authorization Server coordinate is explicitly out of scope |

`bash -n scripts/verify-spring-security-adoption.sh` and `git diff --check` both exited 0. Algorithm coverage is not applicable to these declarative version/publication contracts: this change adds no vulnerability-fix algorithm or production branch whose path coverage could establish correctness. The seven vulnerability algorithms remain covered by the producer tests recorded above; Boot's executable responsibility is coordinate, metadata, graph, and integration behavior.

## Patch.2 adoption green phase

Task 3.1 changed only `gradle.properties` from `springSecurityVersion=5.8.16-nes.patch.1` to `springSecurityVersion=5.8.16-nes.patch.2-SNAPSHOT`. A scoped diff confirmed no change to root `build.gradle` or `spring-boot-dependencies/build.gradle`. `./scripts/verify-spring-security-adoption.sh source` then exited 0: the target version is present once, the official-to-NES mapping still derives the artifact and uses `springSecurityVersion`, and the existing BOM import remains driven by the same property.

Task 3.2 ran `./scripts/verify-spring-security-adoption.sh all` and exited 0. The existing publication tasks regenerated the Boot dependency-management POM and both representative starter POM/module pairs. All source, BOM, POM, Gradle metadata, compile graph, and runtime graph assertions turned green. The graphs mapped every official request to NES and selected only `5.8.16-nes.patch.2-SNAPSHOT`; Gradle displayed the actual resolved candidate as `20260811.065312-1` on direct request lines, agreeing with the fresh Nexus identity above. No core Security patch.1 selection or unmapped official implementation was present. The Security BOM remained a single property-driven `pom`/`import`, and no second Boot BOM was introduced.

Task 3.3 inspected commit `bf2b381387c` and transplanted only the relevant OAuth2 test adaptation. In the current branch the 12 target tests were already enabled and the file contained no `@Disabled`, so the only required edit was changing the import from the deprecated `...resource.web.BearerTokenAuthenticationFilter` compatibility class to the actual Spring Security 5.8 `...resource.web.authentication.BearerTokenAuthenticationFilter`. The scoped diff contains that one import line only; no historical OpenSpec files or unrelated helper changes were copied.

Task 3.4 transplanted the target-file change from `541799f4147`: `Saml2WebSsoAuthenticationFilter` now uses `org.springframework.security.saml2.provider.service.web.authentication`, with the commit's scoped FORK comment explaining that the old path is only a deprecated stub while the real chain installs the new-package class. Comparing the edited file to the target commit produced no diff. No other SAML logic or historical OpenSpec artifact was copied.

Early attempt, superseded by the successful bounded rerun below: task 3.5 had not passed at this point. The targeted command (without `--rerun-tasks`) reached `:spring-boot-project:spring-boot-autoconfigure:compileTestJava` but was terminated by the operating system with exit code 137 before either requested test class executed. The active Gradle daemon log showed sustained severe memory pressure while requesting roughly 1.6 GiB of worker memory, and the host had almost no free pages at the time. The remote build-cache HTTP 403 was a recoverable cache miss and is not classified as the test failure. No test result is claimed from this early attempt, and subsequent Gradle commands were temporarily paused at the user's request.

Task 3.5 was rerun after the user lifted the Gradle pause with a bounded command using Java 17, `--no-daemon --no-parallel --max-workers=1`, and `-Xmx2g -XX:MaxMetaspaceSize=512m`:

```text
./gradlew --no-daemon --no-parallel --max-workers=1 \
  -Dorg.gradle.jvmargs='-Xmx2g -XX:MaxMetaspaceSize=512m -Dfile.encoding=UTF-8' \
  :spring-boot-project:spring-boot-autoconfigure:test \
  --tests org.springframework.boot.autoconfigure.security.oauth2.resource.servlet.OAuth2ResourceServerAutoConfigurationTests \
  --tests org.springframework.boot.autoconfigure.security.saml2.Saml2RelyingPartyAutoConfigurationTests \
  --console=plain
```

The command exited 0 with `BUILD SUCCESSFUL in 1m 20s` and 44 actionable tasks (5 executed, 39 up-to-date). Both requested test classes reached the test task and passed. The remote build-cache HTTP 403 was reported as a recoverable cache miss; no test failure or source workaround was involved.

Task 3.6 then ran the representative Boot Security auto-configuration set with the same bounded Java 17 Gradle invocation (`--no-daemon --no-parallel --max-workers=1`, `-Xmx2g`, `MaxMetaspaceSize=512m`). The selected classes covered servlet Security auto-configuration, servlet Security filter auto-configuration, reactive Security, reactive OAuth2 client, servlet OAuth2 client registration and web security, reactive and servlet OAuth2 resource server, and SAML2 relying-party auto-configuration. The command exited 0 with `BUILD SUCCESSFUL in 39s` and 44 actionable tasks (4 executed, 40 up-to-date). No test was disabled, excluded, or weakened. The remote build-cache 403 again degraded to a cache miss only. The repository has no separate X.509 auto-configuration test class under this package; the X.509 Security path remains represented by the producer Java 8/X.509 evidence and the SAML/Security integration coverage, rather than being claimed as a standalone Boot test.

## Scoped user-document audit

Task 6.7 audited `doc/QUICK_START.md` and `doc/USER_MANUAL.md`. Neither file contains a Spring Security `5.8.16-nes.patch.1`/patch.2 coordinate, NES Security BOM/starter example, OAuth2/SAML consumption step, or Security-specific SNAPSHOT promise. Their existing SNAPSHOT guidance is scoped to the unrelated Reactor Netty development baseline. This change remains an internal candidate/publication-contract verification and does not add supported user trial consumption of Security patch.2-SNAPSHOT, so both files intentionally remain unchanged; `git diff --` for the pair is empty.

## Bouncy Castle static investigation

Early investigation, superseded by the final Maven/Gradle and Java 8 disposition recorded later: lightweight POM/JAR inspection was performed without running Gradle while the host was under memory pressure. At this stage it was input to tasks 4.1–4.4, not a completed behavioral disposition.

| SendGrid version | Java compiler target | Published BC dependency |
|---|---|---|
| `4.9.3` (current Boot baseline) | 1.8 | runtime `bcprov-jdk15on:1.70` |
| `4.10.0` | 1.8 | runtime `bcprov-jdk15on:1.70` |
| `4.10.1` | 1.8 | runtime `bcprov-jdk18on:1.76` |
| `4.10.2` | 1.8 | runtime `bcprov-jdk18on:1.76` |
| `4.10.3` | 1.8 | `bcprov-jdk18on:1.78.1` only in test scope |

Thus `4.10.1` is the smallest published SendGrid upgrade that natively changes the runtime provider family to `jdk18on`. Its downloaded JAR SHA-256 was `5a872d48c97f4a8ba7f3feb137698d00c8d2652a93eeba6663ac472fd131f983`; representative `com.sendgrid.SendGrid` bytecode has class major 52. `javap -public` showed the Boot-used constructors `SendGrid(String)`, `SendGrid(String, Boolean)`, and `SendGrid(String, Client)` and the `SendGridAPI` surface unchanged between 4.9.3 and 4.10.1. Both versions depend on the same `com.sendgrid:java-http-client:4.5.0`, which supplies `com.sendgrid.Client`.

The patch.2 Security SAML POM excludes OpenSAML's `jdk15on` artifacts and adds runtime `bcpkix-jdk18on:1.84` plus `bcprov-jdk18on:1.84`. The patch.2 Security BOM also manages both `jdk18on` artifacts at 1.84, so a Boot-managed SendGrid 4.10.1 graph should converge the shared `bcprov-jdk18on` artifact to 1.84; this still requires Maven/Gradle graph and Java 8 behavior proof.

Direct JAR entry comparison proves that the current `bcprov-jdk15on:1.70` and Security `bcprov-jdk18on:1.84` are not harmless parallel names: 1,475 class entries overlap, including 763 root (non-multi-release) class paths and `org/bouncycastle/jce/provider/BouncyCastleProvider.class`. The provider class major is 49 in 1.70 and 52 in 1.84. Classpath order can therefore choose different implementations for the same FQN even though dependency conflict resolution sees distinct artifactIds. This confirms the duplicate-class risk but does not by itself choose upgrade versus exclusion/replacement.

## Bouncy Castle Maven and Java 8 evaluation

The Maven fixtures were run with Amazon Corretto `1.8.0_472`, Maven 3.8.2 in offline mode after the candidate artifacts had been resolved, and a bounded Maven heap (`-Xmx384m`, `MaxMetaspaceSize=192m`). All commands below exited 0. At this early stage no Gradle command was run because Gradle was temporarily paused at the user's request; later sections record the resumed Gradle verification.

The current SendGrid `4.9.3` combined graph confirms the two provider families are simultaneously present:

```text
+- bjca-footstone-bpring-security-saml2-service-provider:5.8.16-nes.patch.2-SNAPSHOT
|  +- bcpkix-jdk18on:1.84
|  |  \- bcutil-jdk18on:1.84
|  \- bcprov-jdk18on:1.84
\- sendgrid-java:4.9.3
   \- bcprov-jdk15on:1.70
```

Command: `mvn -o -f tests/spring-security-adoption/bouncy-castle/maven/pom.xml -DskipTests dependency:tree -Dincludes=org.bouncycastle`. The matching Java 8 `compile exec:java` smoke verified the Boot-used `SendGrid(String, Boolean)` constructor and Authorization header, built a representative mail JSON payload, completed BC AES-GCM and Spring Security Crypto round trips, initialized OpenSAML, and loaded `OpenSamlAuthenticationProvider`. The provider selected by this particular classpath order was `BC 1.84` from `bcprov-jdk18on-1.84.jar`. That runtime selection does not remove the duplicate `jdk15on` classes and is not treated as convergence.

The minimum native-family upgrade was evaluated with `-Dsendgrid.version=4.10.1`. Its Maven graph contained only the Security-BOM-managed `jdk18on:1.84` family:

```text
\- bjca-footstone-bpring-security-saml2-service-provider:5.8.16-nes.patch.2-SNAPSHOT
   +- bcpkix-jdk18on:1.84
   |  \- bcutil-jdk18on:1.84
   \- bcprov-jdk18on:1.84
```

The Java 8 combined smoke passed with `expected.bc.artifact=bcprov-jdk18on`, `security.smoke=true`, `opensaml.initialized=true`, and provider code source `bcprov-jdk18on-1.84.jar`. Together with the static constructor/API comparison, this proves the Maven-side API and minimal mail-client behavior for SendGrid 4.10.1. At this point task 4.2 remained open because the Boot `SendGridAutoConfigurationTests` and the Gradle graph/smoke had not run; the later final BC disposition supersedes that intermediate status.

The exclusion/replacement alternative was evaluated in both required classpath shapes. The combined fixture used SendGrid `4.9.3` with `-Psendgrid-excluded`; its Maven graph retained only `bcpkix-jdk18on`, `bcutil-jdk18on`, and `bcprov-jdk18on` at 1.84, and its Java 8 SendGrid + Security Crypto + OpenSAML smoke passed. A separate `maven-sendgrid-only` fixture excluded `bcprov-jdk15on` and explicitly added `bcprov-jdk18on:1.84`; its dependency tree contained only:

```text
\- org.bouncycastle:bcprov-jdk18on:1.84
```

The standalone Java 8 smoke passed with `security.smoke=false` and provider code source `bcprov-jdk18on-1.84.jar`, proving that SendGrid construction, request headers, mail payload generation, and AES-GCM do not rely on Security supplying hidden classes. The shared smoke uses reflective Security checks only so the same source can compile on the standalone classpath; combined mode remains the default and actively executes the Spring Security Crypto and OpenSAML checks.

This completed the Maven/Java 8 evaluation required by task 4.3. At this intermediate point no final BC disposition had been selected: task 4.1 still lacked the Gradle baseline graph, task 4.2 still lacked Boot auto-configuration and Gradle evidence, and task 4.4 therefore remained gated. The later final automated-gate section supersedes this status and records the selected SendGrid 4.10.1 solution.

## Current-version and GAV documentation scope

Tasks 6.2 and 6.3 synchronized the factual development baseline without rewriting release history. `COMPONENTS_UPGRADE_HISTORY.md` now records the adoption from the immutable Security patch.1 RELEASE to the patch.2-SNAPSHOT Boot development candidate, including the resolved timestamped candidate and the remaining BC, Gradle, Boot regression, RELEASE, and tag gates. `NES_GAV_MAPPING.md` and `GAV_MAPPING.md` identify `5.8.16-nes.patch.2-SNAPSHOT` only where the text describes the current repository Security mapping, while explicitly retaining patch.1 as the published and rollback baseline. Existing Boot `2.7.18-nes.patch.1` consumption examples, the released compatibility chain, Authorization Server patch.1 coordinates, Quick Start/User Manual content, and historical records were not converted to SNAPSHOT examples.

## Seven-CVE Boot documentation disposition

Tasks 6.4 and 6.5 replaced the stale “needs NES backport” statement with seven evidence-backed candidate records. The vulnerability report now has a distinct `candidate verified` state so producer fixes are neither hidden as unresolved backport work nor overstated as released fixes. Each CVE page records the official 5.8 affected range/fix line, upstream reference, producer implementation/test result, the resolved `20260811.065312-1` candidate and representative SHA-256, Java 8 evidence, rollback identity, and the remaining Boot/RELEASE gates. Recounting the final table yields 66 fixed, 7 candidate verified, 3 deferred, 1 mitigated, 2 not applicable, and 3 immune, for 82 total records.

Task 6.1 added requirement 041 for the Boot-side Security adoption. At the time of that documentation stage it recorded the existing single-property mapping/BOM contract, producer and Boot Java 8 responsibilities, the then-unresolved Bouncy Castle decision, the temporarily paused Gradle/Boot regression work, the patch.2 RELEASE/tag gate, and patch.1 rollback/history preservation. Later verification resolved the BC and Gradle items; the RELEASE/tag gate remains. The older requirement 040 statement was narrowed to its original c3p0/lz4 scope and now points to requirement 041 instead of reading as a current repository-wide exclusion of Spring Security.

## Independent Boot consumer fixtures

Tasks 5.2 and 5.3 added `tests/spring-security-adoption/consumers/` with one Maven and one Gradle consumer plus a shared Java 8 smoke source. Both fixtures import or consume the published NES Boot dependency-management contract from the same default isolated repository, `build/spring-security-adoption/repository`, and exercise the Boot Security starter, OAuth2 resource-server starter, NES Security SAML and Crypto modules, and the managed `bcprov-jdk18on` provider. The Maven fixture imports `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-dependencies:${boot.version}` as a `pom`/`import`; the Gradle fixture consumes the same coordinate through `platform(...)`.

The consumers declare published NES coordinates only. They contain no `resolutionStrategy`, dependency substitution, `includeBuild`, or source-project dependency, so downstream resolution must come from the isolated publication metadata and repository contents. Repository locations can be overridden with Maven `-Dboot.repository.url=...` or Gradle `-PbootRepository=...`; no consumer-side coordinate mapping is provided. XML parsing of the Maven POM and `git diff --check` passed during fixture creation. At this fixture-creation stage no Maven/Gradle dependency resolution or Java 8 smoke was claimed; the later published-consumer section records their successful execution after task 5.1 publication and the lifted Gradle pause.

## Repository-wide consistency audit

Task 6.8 searched the active repository for all seven 2026 CVEs, patch.1/patch.2 identities, the NES Security BOM, and both Bouncy Castle provider families. The audit found one stale current-mechanism section in `doc/REQUIREMENTS.md` that still presented `5.8.16-nes.patch.1-SNAPSHOT` as the live Security mapping; only that Security example, compatibility-chain entry, and property value were updated to patch.2-SNAPSHOT. Remaining patch.1 references are intentionally scoped to immutable release/rollback history, the patch.1 red-phase control, historical CVE evidence, or the pre-change context in this OpenSpec change.

All seven 2026 CVEs remain consistently classified as candidate-verified rather than formally fixed/released. At the time of this intermediate audit no document claimed that the Security patch.2 RELEASE/tag existed, that the Boot target tests had passed, or that the Bouncy Castle graph had converged; the then-current `bcprov-jdk15on:1.70` and `jdk18on:1.84` statements retained the unresolved Gradle and Boot regression gates. Later sections record the successful Boot tests and converged SendGrid 4.10.1 / `jdk18on:1.84` graph, while the RELEASE/tag remains absent. `git diff --name-only -- openspec/changes/archive` produced no output, confirming that archived changes and historical release evidence were not rewritten.

Task 7.4 ran `openspec validate adopt-spring-security-patch-2-security-baseline --strict` after the consumer-fixture and documentation updates. It exited 0 with `Change 'adopt-spring-security-patch-2-security-baseline' is valid`; no format, scenario, or consistency repair was required.

Task 7.5 reviewed the generated Boot dependency-management POM and representative Security/OAuth2 starter Maven POM and Gradle Module Metadata without regenerating them. The Boot publications remain `2.7.18-nes.patch.2-SNAPSHOT`, the Security dependencies remain `5.8.16-nes.patch.2-SNAPSHOT`, and no core official Security implementation or patch.1 Security dependency is exposed. Other independently versioned patch.1 components in the BOM, including Framework and Authorization Server, are outside this Security-family transition and remain intentional.

`git status --short --untracked-files=all` contains only the approved version property, two Security test adaptations, scoped documentation/CVE records, the active OpenSpec change, its verification script, and the Security adoption fixtures. No generated `build`, `.gradle`, or `target` directory exists beneath the new fixture tree, no user tool directory is included, and archived OpenSpec changes remain untouched. Because both Boot and Security generated metadata still contain `-SNAPSHOT`, and the Security `5.8.16-nes.patch.2` RELEASE/tag remains absent, this review confirms that a formal Boot RELEASE is still blocked rather than release-ready.

## Deferred consumer execution entry point

To make tasks 5.1 and 5.4–5.6 reproducible after the Gradle pause is lifted, `scripts/verify-published-boot-security-consumers.sh` provides bounded modes for isolated publication, Maven consumer execution, Gradle consumer execution, graph comparison, and Java 8 bytecode/hash auditing. Publication reuses the repository-native `publishMavenPublicationToProjectRepository` tasks for the dependency-management POM, Boot core/autoconfigure, and the Security/OAuth2 starter path, then merges only those project repositories under `build/spring-security-adoption/repository`. Maven and Gradle use separate local caches under the same build subtree, while `JAVA_HOME` must explicitly identify Java 8.

The script writes candidate inventory, Maven/Gradle dependency trees, classpaths, runtime artifact paths, Java runtime identity, representative class-major checks, SHA-256 values, verification timestamp, and resolved Security SNAPSHOT metadata under `build/spring-security-adoption/evidence`. Gradle invocations are bounded to one worker, no parallel execution, and a 1536 MiB heap. The entry point has only undergone shell/XML/static checks in this session; no publication, consumer resolution, Gradle graph, or Java 8 consumer result is claimed until the user permits Gradle execution and task 5.1 is actually run.

The new entry point is executable (`chmod +x`), passes `bash -n`, and its Maven fixture passes `xmllint`; `git diff --check` and strict OpenSpec validation remain green. No task checkbox is advanced by these static checks because the consumer and publication tasks require actual isolated publication and runtime execution.

## Published Boot consumer execution and Java 8 evidence

Task 5.1 published seven Boot projects into the isolated repository `build/spring-security-adoption/repository` using the repository-native Maven publication tasks. The successful bounded Gradle run used Java 17, Gradle 7.6.3, `--no-daemon --no-parallel --max-workers=1`, and a 1536 MiB heap. All seven project metadata files reported the same Boot timestamp/build `20260813.054327` / `1`; the inventory and per-project metadata are in `build/spring-security-adoption/evidence/candidate-repository-files.txt` and `candidate-publication-metadata.txt`. The repository contains the Boot dependency-management POM, Boot core/autoconfigure, base/logging/security starters, and OAuth2 resource-server starter. The first assertion attempt incorrectly expected a literal `-SNAPSHOT.pom`; it was corrected to validate Maven timestamped SNAPSHOT files and then passed without republishing a mixed set.

Tasks 5.4–5.6 were executed with Amazon Corretto `1.8.0_482`. The Maven consumer uses an isolated settings file that excludes the local `boot-candidate` repository from the installation-level catch-all Nexus mirror, while third-party and Security candidate dependencies resolve from the configured Nexus. Maven dependency-tree and classpath generation exited 0; the consumer was compiled and the shared smoke was launched directly with the generated real Java classpath (rather than Maven exec's plugin classloader). The smoke exited 0 and wrote `build/spring-security-adoption/evidence/maven-smoke.txt`, reporting Java `1.8.0_482-b1`, Boot/Security/OAuth2/SAML/BC/SendGrid code sources, OpenSAML initialization, Security Crypto round-trip, BC AES-GCM round-trip, and SendGrid construction.

The Gradle consumer used the same isolated repository, local Gradle home, Java 8, Gradle 7.6.3, one worker, no parallel execution, and bounded heap. Dependency inventory and runtime smoke both exited 0; `gradle-runtime-artifacts.txt` and the Gradle dependency report show SendGrid `4.10.1`, NES Security `5.8.16-nes.patch.2-SNAPSHOT`, and `bcpkix/bcprov/bcutil-jdk18on:1.84`. The shared smoke reported the expected Boot, Security, OAuth2, SAML, BC, and SendGrid sources.

The final Maven/Gradle graph comparison passed: no official Spring Security coordinate, no NES patch.1 core Security, no `bcprov-jdk15on`, and no mixed BC family; both graphs selected the patch.2 NES Security path, SendGrid `4.10.1`, and the complete BC `jdk18on:1.84` family. Java 8 class-major checks passed with major `52` for representative Boot, Security core, OAuth2 resource server, SAML, Crypto, and Bouncy Castle classes. Representative SHA-256 values, Java runtime identity, Security timestamp/build metadata, verification timestamp, dependency trees, and classpaths were generated under `build/spring-security-adoption/evidence/`; the final `make build` clean removed that temporary untracked directory. The durable summary is this evidence record, and the scripts can regenerate the detailed files.

The earlier Gradle pause is therefore lifted for this change's bounded verification commands. `make build` remains a separate final gate and is not represented as passed by these consumer results.

## Final automated gates before the repository build

Task 7.1 reran all change-specific automation on the final implementation. `scripts/verify-spring-security-adoption.sh all` was updated to accept `GRADLE_BIN`, use the isolated Gradle home and bounded resource arguments, and pass the Nexus project properties required by this repository's settings. The final escalated run exited 0: the single version source, Boot BOM import, Security/OAuth2 Maven POM and Gradle Module Metadata, and representative compile/runtime graph assertions all passed. The selected Security artifact remained `5.8.16-nes.patch.2-20260811.065312-1`.

`scripts/verify-bouncy-castle-disposition.sh` then exited 0 under Java `1.8.0_482`. Maven and Gradle graphs selected SendGrid `4.10.1` plus only `bcpkix-jdk18on`, `bcprov-jdk18on`, and `bcutil-jdk18on` at `1.84`; both Java 8 SendGrid/Security/OpenSAML behavior smokes passed. The final published-consumer Maven/Gradle runs, graph comparison, and class-major/hash audit also passed after adding SendGrid to both consumers, proving that the published Boot BOM path has the same BC disposition and contains no `bcprov-jdk15on`.

Task 7.2 reran the final affected Boot auto-configuration set with Java 17, `--no-daemon --no-parallel --max-workers=1`, and a 2 GiB heap. The selected classes covered the OAuth2 resource-server and SAML2 target classes plus servlet Security, servlet filter auto-configuration, reactive Security, reactive OAuth2 client, servlet OAuth2 client registration/web security, and reactive OAuth2 resource-server. The command exited 0 with `BUILD SUCCESSFUL in 1m 3s` and 44 actionable tasks (4 executed, 40 up-to-date). The remote build-cache 403 remained a recoverable cache miss; no test was disabled, excluded, or weakened.

## Final repository build gate

Task 7.3 first exposed one Checkstyle import-group violation in the changed SAML test and exited 2 after 6m 22s. The violation was corrected by keeping the explanatory FORK comment outside the import block; the targeted `checkstyleTest` rerun then exited 0 (`BUILD SUCCESSFUL in 1m 26s`). The complete bounded rerun used Java 17 (`/Users/anan/.sdkman/candidates/java/17.0.17-amzn`), Gradle 7.6.3, one worker, no parallel execution, and the repository Nexus project properties. The non-test build stage exited 0 with `BUILD SUCCESSFUL in 19m 11s` and 2167 actionable tasks (1891 executed, 276 up-to-date). The Makefile then ran Tier A tests; `spring-boot`, `spring-boot-test`, and the Kafka smoke exited 0 with `BUILD SUCCESSFUL in 5m 16s` and 67 actionable tasks (6 executed, 61 up-to-date). Java 17 removal/Javadoc warnings and the unauthenticated build-scan notice were pre-existing tooling output; remote build-cache HTTP 403 responses were recoverable cache misses. The final `make build` exit code was 0.
