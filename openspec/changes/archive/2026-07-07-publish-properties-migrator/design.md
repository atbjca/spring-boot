## Context

The fork uses `settings.gradle` as the source of truth for which Spring Boot modules participate in the Gradle build and publish graph. A prior trim change removed several explicit modules, including `spring-boot-properties-migrator`, to reduce the published surface.

Downstream upgrade workflows now require the properties migrator from the same private Nexus coordinate family as the rest of the Boot fork. The module already applies `org.springframework.boot.deployed`, so once it is included in settings it receives the existing Maven publication and fork artifact naming behavior.

## Goals / Non-Goals

**Goals:**

- Include `:spring-boot-project:spring-boot-tools:spring-boot-properties-migrator` in the Gradle project graph.
- Publish `cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-properties-migrator:3.5.15-nes.patch.1-SNAPSHOT` to Nexus.
- Preserve the existing Nexus repository and credential configuration.
- Keep the rest of the trimmed module list unchanged.

**Non-Goals:**

- Re-enable `spring-boot-cli`, docs, antlib, changelog generator, system tests, or other previously excluded modules.
- Change the fork GAV mapping rules.
- Change application runtime behavior or public APIs.

## Decisions

### Decision 1: Re-include the existing module instead of adding a one-off publish task

`settings.gradle` will include `spring-boot-project:spring-boot-tools:spring-boot-properties-migrator` again. This lets Gradle configure the project normally and lets `org.springframework.boot.deployed` create the Maven publication.

Alternative considered: publish a manually assembled artifact outside the Gradle project graph. That would bypass the existing publication conventions, increase drift risk, and make future `make deploy` behavior inconsistent.

### Decision 2: Use the existing `DeployedPlugin` artifact renaming

The module keeps its existing `build.gradle`. `DeployedPlugin` maps `spring-boot-properties-migrator` to `bjca-footstone-bpring-boot-properties-migrator` using `forkArtifactPrefix`, and the root build assigns group `cn.bjca.footstone.bpring.boot`.

Alternative considered: set a custom artifactId in the module. That duplicates shared naming logic and would need extra maintenance if fork naming changes.

### Decision 3: Target the module publish task for immediate release

For the immediate release, run the module-specific Nexus task:
`./gradlew :spring-boot-project:spring-boot-tools:spring-boot-properties-migrator:publishMavenPublicationToNexusRepository -x test --console=plain`.

`make clean deploy` will also cover the module after it is included, but the targeted task is faster and avoids republishing the entire reactor when only this missing artifact is needed.

## Risks / Trade-offs

- [Additional build graph surface] Re-including the module increases configuration and publication scope slightly. Mitigation: only this single module is restored; unrelated trimmed modules remain excluded.
- [Missing dependencies in Nexus] The migrator depends on the fork Boot core and configuration metadata artifacts. Mitigation: verify the generated POM and publish task output; dependency resolution remains governed by the existing Nexus repository configuration.
- [Process drift] This implementation was performed before the OpenSpec artifacts were created. Mitigation: this change backfills the required proposal, design, specs, and tasks, and future edits must start with OpenSpec before implementation.
