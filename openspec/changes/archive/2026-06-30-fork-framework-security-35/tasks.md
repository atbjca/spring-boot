## 1. 前置条件

- [x] 1.1 确认 Nexus 上 Framework fork BOM 可达（`cn.bjca.footstone.bpring:bjca-footstone-bpring-framework-bom:6.2.19-nes.patch.1-SNAPSHOT`）
- [x] 1.2 确认 Nexus 上 Security fork BOM 可达（`cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-bom:6.5.11-nes.patch.1-SNAPSHOT`）

## 2. gradle.properties

- [x] 2.1 设置 `springFrameworkVersion=6.2.19-nes.patch.1-SNAPSHOT`
- [x] 2.2 设置 `springSecurityVersion=6.5.11-nes.patch.1-SNAPSHOT`
- [x] 2.3 设置 `springAuthorizationServerVersion=1.5.8-nes.patch.1-SNAPSHOT`

## 3. resolutionStrategy（根 build.gradle）

- [x] 3.1 添加 `org.springframework` 组映射规则（参考 2.7 `origin/2.7.x-bjca-patch`）
- [x] 3.2 添加 `org.springframework.security` 组映射规则
- [x] 3.3 验证与 Configuration Cache 兼容（`./gradlew projects` 无报错）

## 4. spring-boot-dependencies BOM

- [x] 4.1 修改 Spring Framework 条目为 `group(forkGroupIdBase)` + `bom(forkArtifactPrefix + "-framework-bom")`
- [x] 4.2 修改 Spring Security 条目为 `group(forkGroupIdBase + ".security")` + `bom(forkArtifactPrefix + "-security-bom")`
- [x] 4.3 处理 Authorization Server 条目（若存在）

## 5. buildSrc

- [x] 5.1 切换 `buildSrc/build.gradle` Framework BOM 与模块依赖为 fork 坐标
- [x] 5.2 验证 buildSrc 独立编译通过

## 6. 文档

- [x] 6.1 更新 `doc/NES_GAV_MAPPING.md` Phase B 兼容链
- [x] 6.2 在 `doc/REQUIREMENTS.md` 添加 [需求-002] Phase B 记录

## 7. 测试基础设施

- [x] 7.1 `ModifiedClassPathClassLoader` 扩展 `@ClassPathExclusions` 以匹配 fork jar 命名（`spring-*` → `${forkArtifactPrefix}-*`）

## 8. 验证

- [x] 8.1 `make build-thin` BUILD SUCCESSFUL
- [x] 8.2 `make test` 核心模块全绿
- [x] 8.3 抽查依赖树：无未解析的 `org.springframework:` / `org.springframework.security:` 残留
- [x] 8.4 `publishToMavenLocal` 后 BOM POM 中 Framework / Security managed deps 使用 fork groupId
