# Local RELEASE verification evidence

Recorded at: `2026-07-28T04:44:30Z`

## Ownership and repository baseline

- Component: `spring-boot-3.5`
- Change: `release-3-5-15-nes-patch-1`
- Coordinator lease: `coordinator-wave8-boot-35`
- Branch: `3.5.x-bjca-patch`
- Baseline HEAD before release commit: `2ae861a304a`
- Toolchain: Amazon Corretto `17.0.17-amzn`

Credentials remain exclusively in user-level Gradle/Maven configuration and were neither read nor recorded.

## Upstream RELEASE gate

- framework `6.2.19-nes.patch.1`
- security `6.5.11-nes.patch.1`
- authorization-server `1.5.8-nes.patch.1`
- data-bom `2025.0.13-nes.patch.1` (+ data modules)
- kafka `3.3.16-nes.patch.1`

## Serialized local publication

```bash
JAVA_HOME=.../17.0.17-amzn make install
# -> ./gradlew publishToMavenLocal -x test
```

- Exit status: success (`0`)
- Gradle: `BUILD SUCCESSFUL in 5m`
- Mode: no `clean`
- Log: `/tmp/nes-boot35-install.log`

## Generated POM scan

- All local `3.5.15-nes.patch.1` POMs under `cn/bjca/footstone/bpring/boot`: clean

## Local consumer

Consumer: `/tmp/nes-boot35-local-consumer` (starter-parent + web/security/data-redis + kafka)

- Resolved Boot `3.5.15-nes.patch.1` and upstream RELEASEs
- Internal SNAPSHOT dependencies: `0`
