## 1. OpenSpec Artifacts

- [x] 1.1 Create proposal documenting the need to publish the properties migrator fork artifact
- [x] 1.2 Create design documenting the Gradle include and publish approach
- [x] 1.3 Create delta specs for `settings-module-trim` and `nexus-publish-pipeline`

## 2. Build Configuration

- [x] 2.1 Re-include `spring-boot-project:spring-boot-tools:spring-boot-properties-migrator` in `settings.gradle`
- [x] 2.2 Confirm `./gradlew projects` lists `spring-boot-properties-migrator`
- [x] 2.3 Confirm the module exposes Maven publish tasks

## 3. Publish and Verify

- [x] 3.1 Run the module-specific Nexus publish task with tests skipped
- [x] 3.2 Confirm the generated Maven POM uses groupId `cn.bjca.footstone.bpring.boot`
- [x] 3.3 Confirm the generated Maven POM uses artifactId `bjca-footstone-bpring-boot-properties-migrator`
- [x] 3.4 Confirm the generated Maven POM uses version `3.5.15-nes.patch.1-SNAPSHOT`
