## 1. Fix GradleDistributionLocator default fallback

- [x] 1.1 In `GradleDistributionLocator.java`, change the default fallback path from `~/dev` to `~/.gradle/gradle-distributions`

## 2. Configure user-side Gradle properties

- [x] 2.1 Add `systemProp.nes.gradle.distributions.dir=~/dev` to `~/.gradle/gradle.properties` (create if not exists)

## 3. Verify fix

- [x] 3.1 Run `./gradlew :spring-boot-project:spring-boot-tools:spring-boot-gradle-plugin:test --tests "*DocumentationTests"` without manually setting NES_GRADLE_DISTRIBUTIONS_DIR env var, confirm BUILD SUCCESSFUL

## 4. Sync delta spec to main spec

- [x] 4.1 Merge delta spec into `openspec/specs/make-test-target/spec.md` (update "Makefile 内自描述" requirement to remove G class from known failures)
