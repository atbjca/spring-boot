# GAV 构建机制说明

> 本文档面向**维护者**，说明构建期如何将原始 GAV 自动替换为 fork GAV，
> 以及如何新增一个 A 类生态组件的 GAV 排除规则。
>
> 下游消费者视角的 GAV 映射表，请参阅 [NES_GAV_MAPPING.md](./NES_GAV_MAPPING.md)。

---

## 1. 概述：eachDependency 自动替换机制

### 1.1 机制说明

Spring Boot fork 项目通过 `resolutionStrategy.eachDependency` 在**依赖解析阶段**自动将原始 GAV 替换为 fork GAV，使所有子模块无需手动修改依赖声明即可使用 fork 依赖。

核心代码位于根 `build.gradle` 的 `configurations.all` 块中：

```groovy
configurations.all {
    resolutionStrategy.eachDependency { details ->
        def requested = details.requested
        if (requested.group == 'org.springframework' && requested.name.startsWith('spring-')) {
            def newArtifactId = requested.name.replaceFirst(/^spring-/, "${forkArtifactPrefix}-")
            details.useTarget("${forkGroupIdBase}:${newArtifactId}:${springFrameworkVersion}")
        }
        else if (requested.group == 'org.springframework.security' && requested.name.startsWith('spring-security-')) {
            def newArtifactId = requested.name.replaceFirst(/^spring-security-/, "${forkArtifactPrefix}-security-")
            details.useTarget("${forkGroupIdBase}.security:${newArtifactId}:${springSecurityVersion}")
        }
    }
}
```

**工作流程**：

```
子模块声明依赖（如 org.springframework:spring-context）
         │
         ▼
Gradle 依赖解析阶段
         │
         ▼
eachDependency 拦截请求
         │
         ▼
匹配规则 → 替换为 fork GAV
（cn.bjca.footstone.bpring:bjca-footstone-bpring-context:6.2.19-nes.patch.1-SNAPSHOT）
         │
         ▼
解析后的依赖传入子模块构建脚本
```

### 1.2 为什么需要自动替换

- **透明迁移**：子模块无需修改任何 `build.gradle`，原有依赖声明自动解析到 fork 制品
- **集中管理**：映射规则集中在根 `build.gradle` 一处，版本升级时只需改一处
- **CI 友好**：CI 环境无需额外配置，规则对所有构建环境一致生效

### 1.3 局限性

`resolutionStrategy` 作用于**构建期**，仅影响当前 Gradle 项目的解析。发布的 BOM POM 文件中 dependencyManagement 条目本身仍含原始 groupId，下游消费者（Maven 项目）从 BOM 中解析到的仍是原始坐标。因此，需要同时在 BOM 的 `library()` 定义中使用 `exclude group: "org.springframework"` 阻止传递依赖传播。

---

## 2. 两种命名空间处理方式

根据组件类型，处理方式分为三类：

### 2.1 同系列 fork（使用变量动态计算）

适用于与 Spring Framework 同一系列的组件，命名空间自然对应 `forkGroupIdBase`。

**判断标准**：组件的 groupId 以 `org.springframework` 开头。

| 组件 | 原始 GAV | Fork GAV | 处理方式 |
| :--- | :--- | :--- | :--- |
| Spring Framework | `org.springframework:spring-xxx` | `cn.bjca.footstone.bpring:bjca-footstone-bpring-xxx` | 变量计算 |
| Spring Security | `org.springframework.security:spring-security-xxx` | `cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-xxx` | 变量计算 |

**代码示例**（`build.gradle`）：

```groovy
// 规则一：org.springframework 组映射
if (requested.group == 'org.springframework' && requested.name.startsWith('spring-')) {
    def newArtifactId = requested.name.replaceFirst(/^spring-/, "${forkArtifactPrefix}-")
    details.useTarget("${forkGroupIdBase}:${newArtifactId}:${springFrameworkVersion}")
}

// 规则二：org.springframework.security 组映射
else if (requested.group == 'org.springframework.security' && requested.name.startsWith('spring-security-')) {
    def newArtifactId = requested.name.replaceFirst(/^spring-security-/, "${forkArtifactPrefix}-security-")
    details.useTarget("${forkGroupIdBase}.security:${newArtifactId}:${springSecurityVersion}")
}
```

**特点**：
- groupId 通过 `forkGroupIdBase` + 后缀（如 `.security`）动态计算
- artifactId 通过 `forkArtifactPrefix` 替换前缀（如 `spring-` → `bjca-footstone-bpring-`）
- 版本统一使用 `gradle.properties` 中的变量（如 `springFrameworkVersion`）

### 2.2 Authorization Server 独立处理（3.5 新增）

Spring Authorization Server 在 3.5 中使用独立的版本变量和 groupId，不走同系列模式。

```groovy
else if (requested.group == 'org.springframework.security'
        && requested.name == 'spring-security-oauth2-authorization-server') {
    details.useTarget("${forkGroupIdBase}.security:${forkArtifactPrefix}-security-oauth2-authorization-server:${springAuthorizationServerVersion}")
}
```

**特点**：
- 独立版本 `springAuthorizationServerVersion`
- 独立 groupId 后缀 `.security`
- 单独的 else if 分支（不走同系列前缀匹配，避免 artifactId 映射错误）

### 2.3 独立 fork（Phase C exclusion 模式）

适用于未 fork 的 A 类生态组件，使用 `exclude group: "org.springframework"` 阻止传递依赖传播，而非替换坐标。

**判断标准**：组件未被 fork，且需要防止 SCA 扫描到官方 Spring 传递依赖。

| 组件 | 原始 GAV | Fork | 处理方式 |
| :--- | :--- | :--- | :--- |
| Spring AMQP | `org.springframework.amqp:spring-amqp-*` | 官方 | exclusion |
| Spring Batch | `org.springframework.batch:spring-batch-*` | 官方 | exclusion |
| Spring WS | `org.springframework.ws:spring-ws-*` | 官方 | exclusion + security exclusion |
| Spring RESTDocs | `org.springframework.restdocs:spring-restdocs-*` | 官方 | exclusion |
| Spring Data Redis 链路 | `org.springframework.data:spring-data-{commons,keyvalue,redis}` | 官方 | bom import + 独立 module libraries exclusion |

**代码示例**（`spring-boot-dependencies/build.gradle`）：

```groovy
library("Spring AMQP", "3.2.12") {
    considerSnapshots()
    group("org.springframework.amqp") {
        modules = [
            "spring-amqp" {
                exclude group: "org.springframework", module: "*"
            },
            "spring-rabbit" {
                exclude group: "org.springframework", module: "*"
            },
            "spring-rabbit-stream" {
                exclude group: "org.springframework", module: "*"
            },
            "spring-rabbit-junit" {
                exclude group: "org.springframework", module: "*"
            },
            "spring-rabbit-test" {
                exclude group: "org.springframework", module: "*"
            }
        ]
    }
}
```

**WS security 额外排除**：

```groovy
library("Spring WS", "4.1.4") {
    group("org.springframework.ws") {
        modules = [
            "spring-ws-security" {
                exclude group: "org.springframework", module: "*"
                exclude group: "org.springframework.security", module: "*"
            },
            // ... 其他模块
        ]
    }
}
```

### 2.4 三类方式对比

| 维度 | 同系列 fork | Auth Server 独立 | 独立 fork（exclusion） |
| :--- | :--- | :--- | :--- |
| groupId 来源 | `forkGroupIdBase` + 后缀 | `forkGroupIdBase.security` | 官方（不变） |
| artifactId 来源 | `forkArtifactPrefix` 替换前缀 | 硬编码 | 不变 |
| 版本号来源 | `gradle.properties` 变量 | 独立变量 | 官方 |
| 目的 | 替换坐标 | 替换坐标 | 阻止传递依赖传播 |
| 作用层次 | resolutionStrategy | resolutionStrategy | BOM exclusion |

---

## 3. 新增 A 类组件 exclusion 的 Checklist

当需要将一个新的 A 类生态组件纳入 exclusion 时，按以下步骤操作：

### Step 1：确认组件类型

在 `spring-boot-dependencies/build.gradle` 中找到该组件的 `library()` 定义：

```
# 情况 A：该组件使用 bom() import，且需要全量覆盖
library("Spring XXX", "x.y.z") {
    group("org.springframework.xxx") {
        bom("spring-xxx-bom")  # ← 需要改为显式 modules
    }
}

# 情况 B：该组件使用 bom() import，但仅确认局部链路泄露
library("Spring XXX", "x.y.z") {
    group("org.springframework.xxx") {
        bom("spring-xxx-bom")  # ← 保留 BOM import 管理全量版本
    }
}
library("Spring XXX Core", "a.b.c") {
    group("org.springframework.xxx") {
        modules = [ "spring-xxx-core", ... ]  # ← 使用真实模块版本显式覆盖已确认泄露链路
    }
}

# 情况 C：该组件已使用显式 modules
library("Spring XXX", "x.y.z") {
    group("org.springframework.xxx") {
        modules = [ "spring-xxx-core", ... ]  # ← 直接加 exclusion
    }
}
```

### Step 2：确认模块列表

从 Maven 本地仓库的 BOM POM 或上游源码中获取所有模块名：

```bash
# 从本地 BOM POM 获取
find ~/.m2/repository/org/springframework/xxx -name "spring-xxx-bom-*.pom" \
  | sort | tail -1 \
  | xargs grep '<artifactId>' | grep -v 'spring-xxx-bom'
```

### Step 3：判断是否需要 bom→modules 转换

如果组件使用 `bom()`，通常需要改为显式 `modules` 列表才能添加 per-module exclusion。若只确认某条局部链路泄露，可以保留 `bom()` import，并额外用独立 library 声明该链路涉及的显式 `modules`，例如 Spring Data Redis 链路。注意：独立 library 的版本必须是模块真实版本，不能使用 release train BOM 版本。

### Step 4：添加 exclusion

在 `modules` 列表的每个模块中，添加：

```groovy
"spring-xxx-core" {
    exclude group: "org.springframework", module: "*"
}
```

**注意**：如果该组件传递依赖 Spring Security（如 `spring-ws-security`），额外添加：

```groovy
exclude group: "org.springframework.security", module: "*"
```

### Step 5：验证

```bash
./gradlew :spring-boot-project:spring-boot-dependencies:generatePomFileForMavenPublication
# 检查生成的 POM 中该组件的 dependencyManagement 条目含 <exclusions>
```

### Step 6：在本文档和 NES_GAV_MAPPING.md 中更新

在本文档 §2.3 表格中添加新组件行；在 `NES_GAV_MAPPING.md` Phase C 表格中标注 ✅。

---

## 4. bom→modules 转换模式

### 4.1 何时需要转换

3.5 上游将多个组件从显式 `modules` 改为 `bom()` import，导致 per-module exclusion 丢失。如果组件使用 `bom()` 且需要全量 exclusion，常规方式是将 `bom()` 改回显式 modules。

对于 Spring Data 这类模块数量较多、但只确认 Redis 链路泄露的组件，可以使用“保留 BOM import + 独立 module libraries”模式：

```groovy
library("Spring Data Bom", "2025.0.13") {
    group("org.springframework.data") {
        bom("spring-data-bom")
    }
}
library("Spring Data Commons", "3.5.13") {
    group("org.springframework.data") {
        modules = [
            "spring-data-commons" {
                exclude group: "org.springframework", module: "*"
            }
        ]
    }
}
library("Spring Data KeyValue", "3.5.13") {
    group("org.springframework.data") {
        modules = [
            "spring-data-keyvalue" {
                exclude group: "org.springframework", module: "*"
            }
        ]
    }
}
library("Spring Data Redis", "3.5.13") {
    group("org.springframework.data") {
        modules = [
            "spring-data-redis" {
                exclude group: "org.springframework", module: "*"
            }
        ]
    }
}
```

### 4.2 操作步骤

1. 在 `spring-boot-dependencies/build.gradle` 中找到对应的 `library()` 块
2. 如果要全量覆盖，将 `bom("spring-xxx-bom")` 替换为 `modules = [ ... ]`
3. 如果只覆盖局部链路，保留 `bom("spring-xxx-bom")`，并额外用独立 library 声明该链路涉及的 modules 及真实模块版本
4. 列出 BOM 中的所有目标模块，逐个添加 exclusion
5. 保留原有的 `links {}` 块不变
6. 如果某个模块在组件中无引用（如 `spring-restdocs-restassured` 在 RESTDocs BOM 中不存在但被其他模块可选依赖），检查组件是否真的引用它，引用则必须加入 modules

### 4.3 风险：上游新增模块遗漏

当上游版本升级时，如果 BOM 中新增了模块，该模块不会自动加入 modules 列表，可能导致：
- 构建失败（可选依赖找不到）
- 新模块的 Spring 传递依赖未被排除

**缓解**：对照新版本 BOM POM 检查模块列表变化。

---

## 5. 常见问题与风险提示

### Q1：为什么不所有组件都用 resolutionStrategy 替换？

`resolutionStrategy` 只在 Gradle 构建期生效，不影响 BOM 中发布的 dependencyManagement。Maven 下游消费者仍会从 BOM 中解析到原始坐标，因此需要 exclusion 阻止传递依赖传播。两者缺一不可。

### Q2：遗漏 artifactId 前缀怎么办？

常见错误是映射 `spring-rabbit` 时生成了 `bjca-footstone-bpring-spring-rabbit`（多了 `spring-`），正确应为 `bjca-footstone-bpring-rabbit`。

验证方法：查看 BOM POM 中实际的 `<artifactId>` 是否正确。

### Q3：版本升级时需要注意什么？

独立 fork 组件（Auth Server）和 exclusion 组件的版本在 `build.gradle` 中是硬编码的。升级时需要同步修改：
- `gradle.properties` 中的 `springAuthorizationServerVersion`
- `spring-boot-dependencies/build.gradle` 中各组件的 library 版本号

### Q4：bom() 组件如何加 exclusion？

不能在 `bom()` import 本身上直接加 per-module exclusion。可选做法有两种：全量覆盖时将 `bom()` 改回显式 `modules = [...]`；局部覆盖时保留 `bom()` import，并额外用独立 library 声明需要 exclusion 的显式 modules。具体见本文档 §4。

### Q5：哪些组件不适合 exclusion？

- **已 fork 的组件**（Framework/Security）：已有 resolutionStrategy 透明替换，不需要 exclusion
- **无 Spring 传递依赖的组件**（如 `spring-restdocs-asciidoctor`）：无需 exclusion

---

## 6. 相关文件索引

| 文件 | 说明 |
| :--- | :--- |
| `build.gradle`（根） | `resolutionStrategy.eachDependency` 规则定义 |
| `gradle.properties` | `forkGroupIdBase`、`forkArtifactPrefix`、各版本变量 |
| `spring-boot-project/spring-boot-dependencies/build.gradle` | library 定义（含 exclusion） |
| `doc/NES_GAV_MAPPING.md` | 下游消费者视角的 GAV 映射表 |
| `doc/GAV_BUILD_MECHANISM.md` | 本文档，维护者视角的构建机制说明 |
