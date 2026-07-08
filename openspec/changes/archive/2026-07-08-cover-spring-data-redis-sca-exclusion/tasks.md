## 1. Test Coverage

- [x] 1.1 Add BomPlugin integration coverage proving `bom()` import and explicit `modules` with exclusions can coexist in one generated POM.
- [x] 1.2 Verify the new test proves the imported BOM remains and the explicit module receives `<exclusions>`.

## 2. Spring Data Redis Exclusion

- [x] 2.1 Update `spring-boot-dependencies/build.gradle` so Spring Data keeps `spring-data-bom` import and explicitly manages `spring-data-commons`, `spring-data-keyvalue`, and `spring-data-redis` with their real module version.
- [x] 2.2 Add `exclude group: "org.springframework", module: "*"` to the three explicit Spring Data Redis chain modules.

## 3. Documentation

- [x] 3.1 Update `doc/NES_GAV_MAPPING.md` to mark Spring Data Redis / KeyValue / Commons as covered while keeping other Spring Data modules待评估.
- [x] 3.2 Update `doc/GAV_BUILD_MECHANISM.md` with the Spring Data partial BOM import + modules pattern and upgrade notes.
- [x] 3.3 Update `doc/REQUIREMENTS.md` if its non-goal list still says all Spring Data import entries are excluded from scope.

## 4. Verification

- [x] 4.1 Run the focused BomPlugin test.
- [x] 4.2 Generate the `spring-boot-dependencies` Maven publication POM.
- [x] 4.3 Confirm generated dependencyManagement contains `org.springframework.data:spring-data-bom` import.
- [x] 4.4 Confirm generated dependencyManagement contains `org.springframework.data:spring-data-redis`, `spring-data-keyvalue`, and `spring-data-commons` exclusions for `org.springframework:*`.
- [x] 4.5 Run `openspec validate cover-spring-data-redis-sca-exclusion --strict`.
