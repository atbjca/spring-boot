# gradle-local-setup Specification

## Purpose

提供本地 Gradle 分发包自动注入 Gradle wrapper 缓存的能力，使开发者无需手动下载 Gradle 即可完成构建，同时保持 CI 环境网络回退的兼容性。

## Requirements
### Requirement: `scripts/setup-gradle-local.sh` 可执行且逻辑正确

`scripts/setup-gradle-local.sh` MUST 满足以下条件：
- 文件存在且有执行权限（`chmod +x`）
- 默认扫描 `${LOCAL_GRADLE_DIR:-${HOME}/dev}/gradle-*-{bin,all}.zip`
- 用 Python 计算 MD5(https://services.gradle.org/distributions/gradle-<ver>-{bin,all}.zip) 并转为 base36，作为 Gradle wrapper 缓存目录名
- 将匹配的 zip 文件复制到 `~/.gradle/wrapper/dists/gradle-<ver>-{bin,all}/<hash>/`
- 解压 zip 并在同目录创建 `<dist-name>.zip.ok` 标记文件

#### Scenario: 本地 zip 已注入缓存
- **WHEN** `~/dev/gradle-7.6.3-bin.zip` 存在
- **AND** `~/.gradle/wrapper/dists/gradle-7.6.3-bin/<hash>/gradle-7.6.3` 目录存在
- **AND** `.zip.ok` 标记文件存在
- **THEN** 脚本输出"已就绪: gradle-7.6.3-bin (<hash>)"并以 0 退出

#### Scenario: 本地 zip 未注入缓存
- **WHEN** `~/dev/gradle-7.6.3-bin.zip` 存在
- **AND** 缓存目录不存在或无 `.zip.ok` 标记
- **THEN** 脚本复制 zip 到目标目录、解压、创建 `.zip.ok`，输出"解压: gradle-7.6.3-bin.zip -> ..."

#### Scenario: 无匹配的本地 zip
- **WHEN** `${LOCAL_GRADLE_DIR}` 目录下不存在任何 `gradle-*-{bin,all}.zip`
- **THEN** 脚本提示未找到本地发行包
- **AND** 以 0 退出，让 Gradle wrapper 按 `distributionUrl` 联网下载

### Requirement: `make setup-gradle` 调用脚本

根目录 `Makefile` MUST 提供名为 `setup-gradle` 的 `.PHONY` 目标，执行 `./scripts/setup-gradle-local.sh`。

#### Scenario: 调用 `make setup-gradle`
- **WHEN** 开发者执行 `make setup-gradle`
- **THEN** Make 调用 `./scripts/setup-gradle-local.sh`
- **AND** 脚本输出扫描结果和每个 zip 的处理状态

### Requirement: Gradle wrapper properties 使用标准网络 URL

`gradle/wrapper/gradle-wrapper.properties` 中的 `distributionUrl` MUST 为标准 https URL，格式为 `https\://services.gradle.org/distributions/gradle-<version>-bin.zip`，不得使用 `file://` 协议。

#### Scenario: wrapper properties 为 https URL
- **WHEN** 读取 `gradle/wrapper/gradle-wrapper.properties`
- **THEN** `distributionUrl` 以 `https://services.gradle.org/distributions/` 开头
- **AND** 不包含 `file://` 协议

### Requirement: 关键 Make 目标依赖 `setup-gradle`

以下 Make 目标 MUST 在执行前先完成 `setup-gradle`：`format`、`build`、`build-thin`、`install`、`deploy`、`projects`、`test`、`test-feedback`。

`clean` 和 `stop` 目标 MUST NOT 依赖 `setup-gradle`（`./gradlew clean` 和 `./gradlew --stop` 不需要 Gradle 二进制）。

#### Scenario: `make build-thin` 自动先跑 setup-gradle
- **WHEN** 开发者执行 `make build-thin`
- **THEN** Make 先调用 `setup-gradle`
- **AND** 然后调用 `./gradlew assemble ...`

#### Scenario: `make clean` 不调用 setup-gradle
- **WHEN** 开发者执行 `make clean`
- **THEN** Make 直接调用 `./gradlew clean`
- **AND** 不调用 `setup-gradle`

### Requirement: CI 环境网络回退

在无 `${LOCAL_GRADLE_DIR}` 目录或目录中无匹配 zip 的环境中，Gradle wrapper MUST 通过 `distributionUrl` 中的 https 地址从网络下载 Gradle 分发包。

#### Scenario: CI 环境无本地 zip
- **WHEN** CI 环境中 `~/dev/` 不存在任何 `gradle-*.zip`
- **AND** 执行任意 Make 目标（如 `make build-thin`）
- **THEN** Gradle wrapper 尝试从 `https://services.gradle.org/distributions/gradle-7.6.3-bin.zip` 下载
- **AND** 构建流程正常完成