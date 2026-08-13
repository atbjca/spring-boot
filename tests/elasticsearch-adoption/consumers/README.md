# Published Boot Elasticsearch consumers

These fixtures verify the downstream contract of the published NES Spring Boot BOM and Elasticsearch starter. They are intentionally separate from the Spring Boot source build and contain no repository `resolutionStrategy`, dependency substitution, or included build.

Three consumers share the same Java 8 smoke:

- `maven/`: import the generated Boot BOM
- `gradle/`: native `platform(...)` constraints
- `gradle-dm/`: Spring `io.spring.dependency-management` plugin

Two additional Maven fixtures prove the producer POM, not the Boot starter/BOM LZ4 exclusion, supplies the replacement:

- `direct-hlrc/`: only NES HLRC `7.17.29-nes.patch.1-SNAPSHOT`
- `direct-sde/`: only NES Spring Data Elasticsearch `4.4.18-nes.patch.2-SNAPSHOT`

Run them with `--update-snapshots` after a producer SNAPSHOT refresh:

```bash
mvn -f tests/elasticsearch-adoption/consumers/direct-hlrc/pom.xml -U dependency:tree
mvn -f tests/elasticsearch-adoption/consumers/direct-sde/pom.xml -U dependency:tree
```

Expected: `at.yawk.lz4:lz4-java:1.11.1` is present and `org.lz4:lz4-java` is absent.

Creating these fixtures does not constitute a passing consumer result. Isolated publication, dependency trees, LZ4/JSON-P/Java 8 checks, and SNAPSHOT identity still have to be recorded when Gradle/Maven execution is allowed.

The default candidate repository is `build/elasticsearch-adoption/repository` at the repository root.
