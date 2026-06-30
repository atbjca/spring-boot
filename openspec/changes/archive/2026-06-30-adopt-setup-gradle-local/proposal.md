## Why / 背景与动机

当前 `gradle/wrapper/gradle-wrapper.properties` 中配置了脆弱的 hardcode 路径：

```properties
distributionUrl=file\:///Volumes/LIBIAO_EX/dev/gradle-7.6.3-bin.zip
```

存在的问题：
- `/Volumes/LIBIAO_EX` 目录不存在或不可访问，导致 Gradle wrapper 无法工作
- 换机器、换用户、删缓存后必须手动修复 URL，无法自动化恢复
- 与 spring-boot-3.5 的标准化方式不一致

spring-boot-3.5 采用 `scripts/setup-gradle-local.sh` 脚本 + 标准 `https://` URL 的方式，本地 zip 文件通过 hash 映射自动注入 Gradle wrapper 缓存，CI 环境无 `~/dev` 时自动回退网络下载。这种方式更健壮、可重复、跨环境一致。

## What Changes / 变更内容

1. **恢复 `gradle-wrapper.properties` 为标准网络 URL**
   ```properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.3-bin.zip
   ```
   移除脆弱的 `file:///Volumes/LIBIAO_EX/dev/...` 路径

2. **新增 `scripts/setup-gradle-local.sh` 脚本**
   - 从 3.5 项目适配（核心逻辑相同）
   - 扫描 `${LOCAL_GRADLE_DIR:-~/dev}/gradle-*-{bin,all}.zip`
   - 用 Python 计算 Gradle wrapper hash（MD5(url) → base36），将本地 zip 复制到 `~/.gradle/wrapper/dists/`
   - 解压并标记 `.zip.ok`，使 Gradle 视为"已下载"

3. **在 Makefile 添加 `setup-gradle` 目标**
   - 所有 gradlew 相关命令（`clean` 除外）依赖 `setup-gradle`
   - CI 环境无 `~/dev` 时自然回退网络下载

## Capabilities / 能力变化

### New Capabilities
- `gradle-local-setup`：提供本地 Gradle zip 自动注入 Gradle wrapper 缓存的能力。通过 `make setup-gradle` 命令，将 `${LOCAL_GRADLE_DIR:-~/dev}` 下的 gradle-*-{bin,all}.zip 映射到 `~/.gradle/wrapper/dists/`，使 Gradle wrapper 在无网络时也可使用本地分发包。

### Modified Capabilities
无

## Impact / 影响分析

### 涉及文件
| 文件 | 操作 | 说明 |
|------|------|------|
| `gradle/wrapper/gradle-wrapper.properties` | 修改 | 恢复标准 https URL |
| `scripts/setup-gradle-local.sh` | 新增 | 从 3.5 适配的本地 zip 安装脚本 |
| `Makefile` | 修改 | 添加 `setup-gradle` 目标及依赖 |

### 风险评估
- **低风险**：纯本地配置变更，不影响任何模块的编译结果或发布制品
- **回滚方式**：将 `gradle-wrapper.properties` 的 URL 改回 `file:///...` 即可
- **CI 影响**：无 `~/dev` 时 Gradle 自动从网络下载，行为与原来在缓存失效时一致

### 受影响模块
无。所有子项目通过 `./gradlew` 调用 wrapper，不感知 wrapper properties 的来源差异。