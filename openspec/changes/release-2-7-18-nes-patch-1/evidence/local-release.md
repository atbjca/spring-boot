# Local RELEASE verification evidence

Recorded at: `2026-07-28T04:38:30Z`

## Ownership and repository baseline

- Component: `spring-boot-2.7`
- Change: `release-2-7-18-nes-patch-1`
- Coordinator lease: `coordinator-wave8-boot-27`
- Branch: `2.7.x-bjca-patch`
- Baseline HEAD before release commit: `d50ab63d4c7`
- Toolchain: Temurin `11.0.30-tem` (doc/TESTING.md recommends Java 11 for `-Werror` compile; Java 8 failed on security deprecation warnings)

Credentials remain exclusively in user-level Gradle/Maven configuration and were neither read nor recorded.

## Upstream RELEASE gate

Catalog upstreams are Nexus-verified / tagged RELEASEs:

- logback `1.2.13-nes.patch.1`
- reactor-netty `1.0.48-nes.patch.1`
- framework `5.3.39-nes.patch.1`
- security `5.8.16-nes.patch.1`
- authorization-server `0.4.5-nes.patch.1`
- data-bom `2021.2.18-nes.patch.1` (+ data modules / kafka `2.9.13-nes.patch.1`)

## Serialized local publication

```bash
JAVA_HOME=.../11.0.30-tem make install
# -> ./gradlew -Dorg.gradle.caching=false publishToMavenLocal -x test
```

- Exit status: success (`0`)
- Gradle: `BUILD SUCCESSFUL in 2m 53s`
- Mode: no `clean`
- Log: `/tmp/nes-boot27-install.log`
- buildSrc tests updated for RELEASE version pins

## Generated POM scan

- Representative + dependencies BOM: clean
- All local `2.7.18-nes.patch.1` POMs under `cn/bjca/footstone/bpring/boot`: clean (`filesScanned` matches release set)

## Local consumer

Consumer: `/tmp/nes-boot27-local-consumer` (starter-parent + web/security/data-redis + kafka)

- Resolved Boot `2.7.18-nes.patch.1`, Framework/Security/Data/Kafka/logback RELEASE
- Internal SNAPSHOT dependencies: `0`
