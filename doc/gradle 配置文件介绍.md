这三个文件是 Gradle 构建系统的核心配置文件，各自承担不同的职责：

## 1. `settings.gradle`（项目级配置）

**作用**：定义项目的整体结构和包含哪些子项目

```groovy
// 根项目名称
rootProject.name = 'my-application'

// 包含的子模块/子项目
include 'app'
include 'library:core'
include 'library:network'
```

**特点**：
- 在**构建开始阶段**最先执行
- 决定哪些模块参与构建
- 配置构建脚本的依赖仓库（Gradle 7.0+ 支持 `pluginManagement`）

---

## 2. `build.gradle`（构建脚本）

**作用**：定义具体的构建逻辑、依赖和任务

**项目级 build.gradle**（通常位于根目录）：
```groovy
// 所有子项目共享的配置
allprojects {
    repositories {
        mavenCentral()
    }
}

// 子项目通用依赖
subprojects {
    apply plugin: 'java'
    
    dependencies {
        testImplementation 'junit:junit:4.13.2'
    }
}
```

**模块级 build.gradle**（每个子项目一个）：
```groovy
plugins {
    id 'java'
    id 'application'
}

dependencies {
    implementation 'com.google.guava:guava:31.1-jre'
    testImplementation 'org.junit.jupiter:junit-jupiter:5.9.0'
}

// 自定义任务
task customTask {
    doLast {
        println '执行自定义任务'
    }
}
```

---

## 3. `gradle.properties`（属性配置）

**作用**：存储键值对形式的配置属性，**不包含逻辑代码**

```properties
# JVM 参数
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8

# 并行构建
org.gradle.parallel=true
org.gradle.caching=true

# 自定义属性
version=1.0.0
kotlin_version=1.7.10
```

**使用方式**：
```groovy
// 在 build.gradle 中读取
version = project.findProperty('version') ?: '1.0.0'
```

---

## 三者的执行顺序与关系

```
settings.gradle → 确定项目结构
       ↓
gradle.properties → 加载属性配置
       ↓
build.gradle → 执行构建逻辑
```

| 文件 | 执行时机 | 主要内容 | 可包含逻辑代码 |
|------|---------|---------|-------------|
| `settings.gradle` | 初始化阶段 | 项目结构、模块包含 | ✅ 是 |
| `gradle.properties` | 属性加载阶段 | 键值对配置 | ❌ 否 |
| `build.gradle` | 配置阶段 | 依赖、任务、插件 | ✅ 是 |

---

## 实际应用场景

- **`settings.gradle`**：添加新模块时必须修改
- **`build.gradle`**：日常开发中最常编辑，添加依赖、配置插件、自定义任务
- **`gradle.properties`**：优化构建性能（内存、缓存）、统一管理版本号、存储敏感信息（配合环境变量）