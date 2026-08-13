# Published Boot Security consumers

These fixtures verify the downstream contract of the published NES Spring Boot BOM and starters. They are intentionally separate from the Spring Boot source build and contain no repository `resolutionStrategy`, dependency substitution, or included build.

Both consumers use the same dependency set:

- the published NES Spring Boot dependency-management BOM/platform;
- the published NES Spring Boot Security starter;
- the published NES OAuth2 resource-server starter;
- the NES Spring Security SAML and Crypto modules whose versions come from the Security BOM imported by the Boot BOM;
- the Bouncy Castle `jdk18on` provider managed by that imported Security BOM.

The default candidate repository is `build/spring-security-adoption/repository` at the repository root. Task 5.1 must publish the required Boot candidate artifacts there before either consumer is resolved. Override the location with `-Dboot.repository.url=...` for Maven or `-PbootRepository=...` for Gradle. External release and SNAPSHOT dependencies continue to resolve from the NES repositories.

The shared smoke is designed to run on Java 8. It checks the runtime identity of representative Boot and NES Security artifacts, OAuth2 filter construction, OpenSAML initialization, Spring Security Crypto, and Bouncy Castle AES-GCM. Creating these fixtures does not constitute a passing consumer result; the isolated publication, dependency trees, Java 8 executions, and class-major audit remain separate gates.

`scripts/verify-published-boot-security-consumers.sh` orchestrates those later gates without writing to the user's normal Maven or Gradle caches. Its modes are:

- `publish`: publish the minimum required Boot modules with the repository-native `publishMavenPublicationToProjectRepository` tasks and merge them into the isolated candidate repository;
- `maven`: use an isolated Maven local repository, save the dependency tree/classpath, and run the shared smoke on the Java 8 selected by `JAVA_HOME`;
- `gradle`: use an isolated Gradle user home, save the runtime graph/artifact inventory, and run the same smoke;
- `compare`: assert both graphs contain patch.2 NES Security, SAML and Bouncy Castle 1.84 without official or patch.1 core Security;
- `bytecode`: check representative class majors, artifact SHA-256 values, Java identity, verification time and resolved Security SNAPSHOT metadata;
- `all`: execute the complete sequence.

The Gradle invocations are deliberately bounded to one worker, no parallel execution, a 1536 MiB heap and a 512 MiB metaspace. The script must not be run while Gradle is paused for host resource protection.
