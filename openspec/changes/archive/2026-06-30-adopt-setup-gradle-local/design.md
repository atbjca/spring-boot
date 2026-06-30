## Context / 背景

当前 `gradle/wrapper/gradle-wrapper.properties` 中的 `distributionUrl` 被硬编码为：

```properties
distributionUrl=file\:///Volumes/LIBIAO_EX/dev/gradle-7.6.3-bin.zip
```

该路径依赖一个不存在的卷（`/Volumes/LIBIAO_EX`），且所有 gradlew 命令均通过 `./gradlew` 调用 wrapper，一旦缓存失效或换环境即失败。

spring-boot-3.5 项目已实现一套标准化方案：
- `distributionUrl` 保持标准 `https://services.gradle.org/distributions/...`
- `scripts/setup-gradle-local.sh` 将本地 zip 映射到 Gradle wrapper 缓存
- Makefile 所有目标均先执行 `setup-gradle`

## Goals / Non-Goals

**Goals:**
- 移除脆弱的 `file://` URL，恢复标准 `https://` URL
- 引入 `setup-gradle-local.sh`，将本地 zip 自动注入 Gradle wrapper 缓存
- Makefile 所有 gradlew 相关命令依赖 `setup-gradle`
- 保留 CI 友好性：无 `~/dev` 时自然回退网络下载

**Non-Goals:**
- 不修改 Gradle wrapper jar 本身
- 不改变任何子项目的构建逻辑
- 不影响 Gradle 版本（保持 7.6.3）

## Decisions / 关键决策

### Decision 1: 采用 3.5 完全一致的脚本内容
从 3.5 的 `scripts/setup-gradle-local.sh` 直接复制，不做逻辑修改。

**理由：** 该脚本已在 3.5 验证过，本质是纯函数式的 zip → wrapper 缓存映射逻辑，无环境依赖。

### Decision 2: `setup-gradle` 作为所有 gradlew 命令的前置依赖
```makefile
build: setup-gradle
build-thin: setup-gradle
install: setup-gradle
deploy: setup-gradle
test: setup-gradle
test-feedback: setup-gradle
format: setup-gradle
projects: setup-gradle
stop:  # 不依赖 gradle，无需 setup-gradle
clean: # 不依赖 gradle，无需 setup-gradle
```

**理由：** 与 3.5 保持完全一致，开发者执行任何构建命令前都会确保本地 zip 已注入缓存。

### Decision 3: `gradle-wrapper.properties` 恢复标准 URL
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.3-bin.zip
```

**理由：** 即使本地 zip 已注入缓存，`https://` URL 本身也是有效的——Gradle 会先检查缓存中是否存在对应 hash 的目录，不存在才下载。因此两种机制可以无缝并存。

### Decision 4: `LOCAL_GRADLE_DIR` 默认值设为 `~/dev`
脚本中：
```bash
LOCAL_GRADLE_DIR="${LOCAL_GRADLE_DIR:-${HOME}/dev}"
```

**理由：** 与 3.5 保持一致，开发者已有明确的约定（你的 `~/dev` 确实包含了所有 gradle zip）。

## Risks / Trade-offs

| 风险 | 级别 | 缓解措施 |
|------|------|----------|
| 开发者误删 `~/dev` 中的 zip | 低 | CI 环境无 `~/dev` 时 Gradle 自动从网络下载 |
| `setup-gradle-local.sh` 脚本错误导致缓存损坏 | 低 | 仅修改 `~/.gradle/wrapper/dists/`，可手动删除重建 |
| 不同 Gradle 版本 hash 不同，脚本误判缓存 | 低 | 脚本使用 Python MD5 计算，与 Gradle 内部逻辑一致 |

**Trade-off：** 每次 `make build-thin` 会先跑 `setup-gradle`（约 1-2 秒），换来的是配置健壮性，值得。