# GAV 构建机制说明

> 本文档面向**维护者**，说明构建期如何将原始 GAV 自动替换为 fork GAV，
> 以及如何新增一个独立 fork 组件的 GAV 映射规则。
>
> 下游消费者视角的 GAV 映射表，请参阅 [NES_GAV_MAPPING.md](./NES_GAV_MAPPING.md)。

---

## 1. 概述：eachDependency 自动替换机制

### 1.1 机制说明

Spring Boot fork 项目通过 `resolutionStrategy.eachDependency` 在**依赖解析阶段**自动将原始 GAV 替换为 fork GAV，使所有子模块无需手动修改依赖声明即可使用 fork 依赖。

核心代码位于 `build.gradle` 的 `configurations.all` 块中：

```groovy
resolutionStrategy.eachDependency { details ->
    def requested = details.requested
    // 根据 requested.group / requested.name 判断并替换
    details.useTarget("fork-group-id:fork-artifact-id:fork-version")
}
```

**工作流程**：

```
子模块声明依赖（如 ch.qos.logback:logback-classic）
         │
         ▼
Gradle 依赖解析阶段
         │
         ▼
eachDependency 拦截请求
         │
         ▼
匹配规则 → 替换为 fork GAV
（如 cn.bjca.footstone.bogback:bjca-footstone-bogback-classic:1.2.13-nes.patch.1）
         │
         ▼
解析后的依赖传入子模块构建脚本
```

### 1.2 为什么需要自动替换

- **透明迁移**：子模块无需修改任何 `build.gradle`，原有依赖声明自动解析到 fork 制品
- **集中管理**：映射规则集中在 `build.gradle` 一处，版本升级时只需改一处
- **CI 友好**：CI 环境无需额外配置，规则对所有构建环境一致生效

---

## 2. 两种命名空间处理方式

根据 fork 项目的命名空间是否与 `forkGroupIdBase`（`cn.bjca.footstone.bpring`）属于同一系列，处理方式分为两类：

### 2.1 同系列 fork（使用变量动态计算）

适用于与 Spring Framework/Security 同一系列的项目，命名空间自然对应 `forkGroupIdBase`。

**判断标准**：fork 项目的 GroupId 以 `cn.bjca.footstone.bpring` 开头。

| Fork 组件 | 原始 GAV | Fork GAV | 处理方式 |
| :--- | :--- | :--- | :--- |
| Spring Framework | `org.springframework:spring-xxx` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-xxx` | 变量计算 |
| Spring Security | `org.springframework.security:spring-security-xxx` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-xxx` | 变量计算 |

**代码示例**（`build.gradle`）：

```groovy
// 规则一：org.springframework 组映射
// 将 org.springframework:spring-xxx 替换为
//   ${forkGroupIdBase}:${forkArtifactPrefix}-xxx:${springFrameworkVersion}
if (requested.group == 'org.springframework' && requested.name.startsWith('spring-')) {
    def newArtifactId = requested.name.replaceFirst(/^spring-/, "${forkArtifactPrefix}-")
    details.useTarget("${forkGroupIdBase}:${newArtifactId}:${springFrameworkVersion}")
}

// 规则二：org.springframework.security 组映射
// 将 org.springframework.security:spring-security-xxx 替换为
//   ${forkGroupIdBase}.security:${forkArtifactPrefix}-security-xxx:${springSecurityVersion}
else if (requested.group == 'org.springframework.security' && requested.name.startsWith('spring-security-')) {
    def newArtifactId = requested.name.replaceFirst(/^spring-security-/, "${forkArtifactPrefix}-security-")
    details.useTarget("${forkGroupIdBase}.security:${newArtifactId}:${springSecurityVersion}")
}
```

**特点**：
- GroupId 通过 `forkGroupIdBase` + 后缀（如 `.security`）动态计算
- ArtifactId 通过 `forkArtifactPrefix` 替换前缀（如 `spring-` → `bjca-footstone-bpring-`）
- 版本统一使用 `gradle.properties` 中的变量（如 `springFrameworkVersion`）

### 2.2 独立 fork（硬编码规则）

适用于与 Spring Framework 完全无关的独立 fork 项目，其命名空间无法通过 `forkGroupIdBase` 计算得到。

**判断标准**：fork 项目有自己的独立 GroupId（如 `cn.bjca.footstone.bogback`），与 `cn.bjca.footstone.bpring` 无命名空间继承关系。

| Fork 组件 | 原始 GAV | Fork GAV | 处理方式 |
| :--- | :--- | :--- | :--- |
| Logback | `ch.qos.logback:logback-classic` | `cn.bjca.footstone.bogback:bjca-footstone-bogback-classic` | 硬编码 |
| Logback | `ch.qos.logback:logback-core` | `cn.bjca.footstone.bogback:bjca-footstone-bogback-core` | 硬编码 |

**代码示例**（`build.gradle`）：

```groovy
// 规则三：ch.qos.logback 组映射
// 将 ch.qos.logback:logback-{classic,core} 替换为
//   cn.bjca.footstone.bogback:bjca-footstone-bogback-{classic,core}:1.2.13-nes.patch.1
// Logback fork 仓库仅发布了 bjca-footstone-bogback-* 制品，
// 原始 ch.qos.logback 坐标在私有仓库中不存在，必须通过此规则透明替换。
else if (requested.group == 'ch.qos.logback') {
    if (requested.name == 'logback-classic' || requested.name == 'logback-core') {
        def artifactSuffix = requested.name.replace('logback-', '')
        details.useTarget("cn.bjca.footstone.bogback:bjca-footstone-bogback-${artifactSuffix}:1.2.13-nes.patch.1")
    }
}
```

**特点**：
- GroupId 和 ArtifactId 均硬编码，无法复用 `forkGroupIdBase` 变量
- 版本号硬编码（与 BOM 中的 `library()` 版本保持一致）
- 需要在注释中说明原因，避免后续维护者误以为是临时方案

### 2.3 两类方式的对比

| 维度 | 同系列 fork | 独立 fork |
| :--- | :--- | :--- |
| GroupId 来源 | `forkGroupIdBase` + 后缀动态计算 | 独立命名空间，硬编码 |
| ArtifactId 来源 | `forkArtifactPrefix` 替换前缀 | 独立前缀，硬编码 |
| 版本号来源 | `gradle.properties` 变量 | 硬编码（需与 BOM 保持一致） |
| 新增工作流 | 简单：只需加 else if 分支 | 稍复杂：需确认命名空间映射关系 |
| 漏改风险 | 低：变量升级时一处改动全局生效 | 中：版本升级时需同步改两处（eachDependency + BOM） |

---

## 3. 新增独立 Fork 组件的 Checklist

当需要将一个新的独立 fork 组件（如 `SomeLibrary`）纳入自动替换时，按以下步骤操作：

### Step 1：确认命名空间映射关系

在 fork 仓库中确认以下信息：

```
原始 GroupId       : com.example.somelib
原始 ArtifactId    : somelib-core, somelib-common, ...
Fork GroupId       : cn.bjca.footstone.XXX
Fork ArtifactId 前缀: bjca-footstone-XXX-
Fork 版本号        : X.Y.Z-nes.patch.1
```

> **重要**：如果 fork GroupId 以 `cn.bjca.footstone.bpring` 开头，应使用**同系列 fork** 方式处理（参考 2.1 节），而非本 Checklist。

### Step 2：在 `build.gradle` 添加 else if 分支

在 `resolutionStrategy.eachDependency` 块中，在规则二（或上一条独立 fork 规则）之后添加新的 else if：

```groovy
// 规则 N：com.example.somelib 组映射
// 将 com.example.somelib:somelib-{core,common} 替换为
//   cn.bjca.footstone.XXX:bjca-footstone-XXX-{core,common}:X.Y.Z-nes.patch.1
// [说明为什么要替换，以及为什么这是独立 fork 而非同系列]
else if (requested.group == 'com.example.somelib') {
    if (requested.name == 'somelib-core' || requested.name == 'somelib-common') {
        def artifactSuffix = requested.name.replace('somelib-', '')
        details.useTarget("cn.bjca.footstone.XXX:bjca-footstone-XXX-${artifactSuffix}:X.Y.Z-nes.patch.1")
    }
}
```

> **注意**：artifactId 映射务必确认正确，常见的映射错误是将 `somelib-core` 错误映射为 `bjca-footstone-XXX-somelib-core`（多了 `somelib-` 前缀），正确映射应为 `bjca-footstone-XXX-core`。

### Step 3：在 BOM 中添加或确认 library 条目

在 `spring-boot-project/spring-boot-dependencies/build.gradle` 中，确认已有对应的 library 定义：

```groovy
library("SomeLibrary", "X.Y.Z-nes.patch.1") {
    group("cn.bjca.footstone.XXX") {
        modules = [
            "bjca-footstone-XXX-core",
            "bjca-footstone-XXX-common"
        ]
    }
}
```

如果该 library 不存在，需新增定义。

### Step 4：验证构建

```bash
make build-thin
```

确认构建成功，无依赖解析错误。

### Step 5：在 NES_GAV_MAPPING.md 中更新映射表

在 `doc/NES_GAV_MAPPING.md` 的对应章节添加新的映射行：

```markdown
| `com.example.somelib` | `somelib-core` | `cn.bjca.footstone.XXX` | `bjca-footstone-XXX-core` | `X.Y.Z-nes.patch.1` |
```

---

## 4. 常见问题与风险提示

### Q1：为什么不所有 fork 都用变量计算？

因为独立 fork 项目（如 Logback）的命名空间（`cn.bjca.footstone.bogback`）与 `forkGroupIdBase`（`cn.bjca.footstone.bpring`）毫无关系，无法通过简单的字符串替换得到。如果强行用 `forkGroupIdBase + ".bogback"` 计算，会得到错误的 `cn.bjca.footstone.bpring.bogback`。

### Q2：版本升级时需要注意什么？

独立 fork 组件的版本号在 `eachDependency` 规则中是硬编码的。版本升级时需要同步修改两处：

1. `build.gradle` 中的 `details.useTarget("...:版本号")`
2. `spring-boot-dependencies/build.gradle` 中的 `library("SomeLibrary", "版本号")`

建议在修改前搜索 `X.Y.Z-nes.patch.1` 确认所有出现位置。

### Q3：遗漏 artifactId 前缀怎么办？

常见错误是映射 `somelib-core` 时生成了 `bjca-footstone-XXX-somelib-core`（多了 `somelib-`），正确应为 `bjca-footstone-XXX-core`。

验证方法：在 `build.gradle` 中临时打印解析后的坐标，或直接执行 `make build-thin` 观察错误信息中的实际查找路径。

### Q4：哪些组件不适合自动替换？

- **未 fork 的组件**：仍在使用原始坐标，不应添加替换规则
- **仅部分模块 fork 的组件**：如 `logback-access` 暂未 fork，此时不应替换该 artifact，只替换已 fork 的模块

---

## 5. 相关文件索引

| 文件 | 说明 |
| :--- | :--- |
| `build.gradle` | `resolutionStrategy.eachDependency` 规则定义 |
| `gradle.properties` | `forkGroupIdBase`、`forkArtifactPrefix` 等变量定义 |
| `spring-boot-project/spring-boot-dependencies/build.gradle` | BOM library 定义 |
| `doc/NES_GAV_MAPPING.md` | 下游消费者视角的 GAV 映射表 |
| `doc/GAV 构建机制说明.md` | 本文档，维护者视角的构建机制说明 |