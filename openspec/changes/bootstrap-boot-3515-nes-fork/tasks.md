## 1. 基线确认

- [ ] 1.1 确认 `3.5.x-bjca-patch` 位于 3.5.15 基线 commit（`5bafd0a6bf1` 或 `v3.5.15` tag）
- [ ] 1.2 确认 `origin/3.5.x` 未被修改（只读）

## 2. fork-gav-config（gradle.properties）

- [ ] 2.1 添加 `forkArtifactPrefix=bjca-footstone-bpring` 和 `forkGroupIdBase=cn.bjca.footstone.bpring`
- [ ] 2.2 设置 `version=3.5.15-nes.patch.1-SNAPSHOT` 和 `springBootVersion=3.5.15`
- [ ] 2.3 添加 Nexus 仓库 URL 参数（`nexusPublicUrl` 等），credentials 模板不入库
- [ ] 2.4 确认 Framework/Security/Logback 保持官方版本不变

## 3. fork-gav-rebranding（buildSrc）

- [ ] 3.1 移植 `DeployedPlugin.java` artifactId 显式设置逻辑（参考 2.7 `origin/2.7.x-bjca-patch`）
- [ ] 3.2 移植 `BomPlugin.java` BOM groupId 动态传播
- [ ] 3.3 移植 `MavenPluginPlugin.java` 插件描述符 groupId 动态传播
- [ ] 3.4 验证 buildSrc 独立编译通过

## 4. fork-gav-rebranding（根构建脚本）

- [ ] 4.1 修改根 `build.gradle`：`allprojects.group = "${forkGroupIdBase}.boot"` + Nexus repositories
- [ ] 4.2 修改 `settings.gradle`：Nexus pluginManagement + 项目名动态替换
- [ ] 4.3 修改 `spring-boot-dependencies/build.gradle`：Boot 组件 group 动态引用
- [ ] 4.4 修改 `spring-boot-starter-parent/build.gradle`：Parent POM groupId 动态传播
- [ ] 4.5 修改 `spring-boot-maven-plugin` 内部 POM 模板 groupId 同步机制

## 5. nexus-publish-pipeline

- [ ] 5.1 根 `build.gradle` 添加 `subprojects` publishing 配置（Nexus release/snapshot）
- [ ] 5.2 验证 `publishToMavenLocal` 产出 fork GAV 制品
- [ ] 5.3 验证 `publish` 到 Nexus（私服可达时）

## 6. fork-build-tooling（Makefile）

- [ ] 6.1 创建根 `Makefile`（help / clean / format / build-thin / install / deploy / stop）
- [ ] 6.2 验证 `make build-thin` BUILD SUCCESSFUL

## 7. 文档

- [ ] 7.1 创建 `doc/REQUIREMENTS.md` 首条记录（[需求-001] Bootstrap 3.5.15 NES Fork Phase A）
- [ ] 7.2 创建 `doc/NES_GAV_MAPPING.md` 3.5 兼容链骨架（Boot 3.5.15 / Framework 6.2.19 官方 / Security 6.5.11 官方）
- [ ] 7.3 标注 Phase B 待办：Framework 6.2.x fork、Security 6.5.x fork

## 8. 验证

- [ ] 8.1 `./gradlew projects` 确认项目名均为 fork 前缀
- [ ] 8.2 抽查本地 Maven 仓库 artifactId 无 `spring-boot-` 残留
- [ ] 8.3 `SpringBootVersion.getVersion()` 返回 `3.5.15`
