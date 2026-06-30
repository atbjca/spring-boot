# 使用自定义的 gradle-bin

修改 [gradle/wrapper/gradle-wrapper.properties](../gradle/wrapper/gradle-wrapper.properties)

示例：

```text
-distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-bin.zip
+distributionUrl=file\:///Volumes/LIBIAO_EX/dev/gradle-7.6.3-bin.zip
```

## Gradle TestKit 多版本测试（`gradle-plugin:test`）

`BuildInfoDslIntegrationTests` 等兼容性测试会通过 TestKit 拉取 Gradle 6.8.3、7.0.2 等**旧版分发包**。默认走 `services.gradle.org`，国内易超时。

fork 已在 `GradleBuild` 中按以下顺序解析（见 `GradleDistributionLocator`）：

1. **本地已解压目录**：`{dir}/gradle-{version}/bin/gradle`（如 `~/dev/gradle-7.6.3/`）
2. **本地 zip**：`{dir}/gradle-{version}-bin.zip`（如 `~/dev/gradle-6.8.3-bin.zip`）
3. **镜像**（默认腾讯云）：`https://mirrors.cloud.tencent.com/gradle/gradle-{version}-bin.zip`
4. **官方**：`withGradleVersion` → `services.gradle.org`

### 配置项

| 变量 | 作用 | 默认 |
|---|---|---|
| `NES_GRADLE_DISTRIBUTIONS_DIR` / `-Dnes.gradle.distributions.dir` | 本地 zip/解压目录 | `~/dev` |
| `NES_GRADLE_DISTRIBUTIONS_MIRROR` / `-Dnes.gradle.distributions.mirror` | 镜像根 URL；设为 `none` 关闭镜像 | 腾讯云镜像 |

### 建议准备的 zip（Java 11 下 `GradleVersions.allCompatible()`）

`6.8.3`、`6.9.4`、`7.0.2`、`7.6.3`（当前构建版本）、`8.0.2`、`8.3`、`8.4`

放入 `~/dev/` 后 TestKit **零外网**；缺的版本会走镜像，首次下载后缓存在 `~/.gradle/wrapper/dists/`。