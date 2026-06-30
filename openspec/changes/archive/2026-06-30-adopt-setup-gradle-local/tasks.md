## 1. 基础设施脚本

- [x] 1.1 从 `/Users/anan/Documents/GitHub/nes/spring-boot-3.5/scripts/setup-gradle-local.sh` 复制到本项目 `scripts/setup-gradle-local.sh`
- [x] 1.2 确保脚本有执行权限（`chmod +x scripts/setup-gradle-local.sh`）

## 2. Gradle Wrapper 配置

- [x] 2.1 将 `gradle/wrapper/gradle-wrapper.properties` 中的 `distributionUrl` 从 `file\:///Volumes/LIBIAO_EX/dev/gradle-7.6.3-bin.zip` 恢复为 `https\://services.gradle.org/distributions/gradle-7.6.3-bin.zip`

## 3. Makefile 改造

- [x] 3.1 在 Makefile 顶部 `.PHONY` 中添加 `setup-gradle`
- [x] 3.2 添加 `setup-gradle` 目标定义
- [x] 3.3 让以下目标依赖 `setup-gradle`：`format`、`build`、`build-thin`、`install`、`deploy`、`projects`、`test`、`test-feedback`
- [x] 3.4 在 help 文本中添加 `make setup-gradle` 说明

## 4. 验证

- [x] 4.1 执行 `make setup-gradle`，确认脚本成功运行且 `~/.gradle/wrapper/dists/gradle-7.6.3-bin/` 下有对应 hash 目录和 `.zip.ok` 标记
- [x] 4.2 执行 `make build-thin`，确认 Gradle 正常启动并完成构建（BUILD SUCCESSFUL in 3m 30s）
- [x] 4.3 确认 `clean` 目标不依赖 `setup-gradle`（`./gradlew clean` 不需要 gradle 二进制）