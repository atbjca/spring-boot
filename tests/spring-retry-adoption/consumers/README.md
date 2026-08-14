# Published Boot Spring Retry consumers

These independent Maven and Gradle fixtures verify the published Spring Boot NES dependency-management contract for Spring Retry. They resolve NES Kafka patch.2 together with Spring Batch Infrastructure, Spring AMQP, Spring Integration Core, and NES Spring Data Commons.

The Maven fixture has no Gradle substitution and proves the generated Boot BOM exclusions prevent the ecosystem dependencies from leaking `org.springframework.retry:spring-retry`. The Kafka dependency supplies the managed NES Retry module.

The Gradle fixture imports the published Boot platform and contains the same exact official Retry substitution used by the Boot build. Its `verifyRuntimeArtifacts` task requires exactly one Retry implementation, Kafka patch.2, and NES Spring Data Commons.

Publish the Boot BOM before resolving either fixture:

```bash
./gradlew :spring-boot-project:spring-boot-dependencies:publishMavenPublicationToProjectRepository
```

Then run:

```bash
mvn -f tests/spring-retry-adoption/consumers/maven/pom.xml \
  --settings tests/spring-retry-adoption/consumers/maven/settings.xml \
  --update-snapshots dependency:tree

./gradlew -p tests/spring-retry-adoption/consumers/gradle \
  --refresh-dependencies verifyRuntimeArtifacts
```

Both consumers target Java 8 metadata. The Retry and Kafka coordinates remain mutable SNAPSHOTs, so verification must record their resolved timestamped identities separately.
