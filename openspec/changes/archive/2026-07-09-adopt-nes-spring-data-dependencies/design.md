# Design — adopt-nes-spring-data-dependencies

## 关键决策

### 决策一：两层对接（BOM import 坐标 + resolutionStrategy 规则五），缺一不可

fork BOM 用 **NES 坐标做 dependencyManagement 的 key**（`cn.bjca...data-commons`），而 spring-boot-autoconfigure 等模块的源码声明用的是**官方坐标**（`org.springframework.data:spring-data-commons`）。两者 key 不匹配 → 仅改 BOM import 坐标（层一）无法让 commons 拿到 fork 版本，会退回传递依赖的官方 `2.7.18`（含 CVE）。因此必须叠加层二：`resolutionStrategy.eachDependency` 在解析期把官方坐标重写为 NES 坐标。这与既有 Kafka（规则三）完全同构。

```
源码声明: org.springframework.data:spring-data-commons   (官方坐标, 无版本)
   │
   ├─ 层一: fork BOM 提供版本管理, 但 key 是 NES 坐标 → 对官方坐标 key 不生效
   │
   └─ 层二: resolutionStrategy 规则五 → 重写为
            cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:2.7.18-nes.patch.1-SNAPSHOT
```

### 决策二：规则五只重写 commons/keyvalue，不用前缀通配

规则一（framework）用 `startsWith('spring-')` 通配整组，因为 framework 整组都已 fork。但 Spring Data **只有 commons/keyvalue 两个模块** fork，redis/jpa/mongodb/rest 等仍是官方坐标 + 官方制品。若对 `org.springframework.data` 整组通配重写，会把这些官方模块也改成不存在的 NES 坐标 → 解析失败。故规则五显式白名单 `spring-data-commons` / `spring-data-keyvalue`。

### 决策三：版本号硬编码，与规则三（Kafka）一致

fork BOM 的 dependencyManagement 用 NES 坐标做 key，管不到被 resolutionStrategy 重写**前**的官方坐标；重写发生在解析期，此时若不给版本，Gradle 无版本可用。故规则五硬编码 `2.7.18-nes.patch.1-SNAPSHOT`，与 Kafka 规则三、Logback 规则四同构。升级 fork data 版本时需同步此处（已在 REQUIREMENTS/GAV_MAPPING 注明）。

### 决策四：规则五兼作「传递依赖闸门」

`spring-data-redis:2.7.18`（官方）传递依赖 `spring-data-commons:2.7.18`（官方）。规则五是全局 `eachDependency`，不论 commons 从哪条传递链进来都会被重写为 NES 制品。因此不必在 BOM 层为 redis 添加 commons 的 exclusion——规则五已统一收口。

### 决策五：fork BOM 删除 commons/keyvalue 的 spring-* exclusions 是安全的

fork BOM 删掉了 commons/keyvalue 对 spring-core/beans/context/tx 的 `exclusions`。这意味着 fork data 制品会正常传递依赖 spring-core 等。本项目规则一（`org.springframework` 整组映射）会把任何传递回来的 `org.springframework:spring-core` 重写为 fork core。两条路径殊途同归，classpath 不会出现官方/fork 双份——此为验证阶段重点核对项。

## 边界与非目标

- **不 fork** redis/jpa/mongodb/rest 等模块（本期只对接 fork 已交付的 commons/keyvalue/bom）。
- **不改 Java 源码**、不改各子模块 `build.gradle` 的依赖声明（透明替换）。
- **不动** buildSrc / spring-boot-gradle-plugin 的构建期锁定依赖。
- redis 等官方模块的本体 CVE 盘点不在本期范围。

## 风险

| 风险 | 缓解 |
|------|------|
| fork data SNAPSHOT 未 deploy 到私服 | 构建验证阶段会立即暴露解析失败；如受阻则记录状态，待制品就绪补跑 |
| 官方 spring-core 经 commons 传递漏网 | 规则一兜底 + `:dependencies` 树核对 |
| 未来升级 fork data 版本遗漏规则五硬编码 | 已在 REQUIREMENTS/GAV_MAPPING/源码注释三处注明同步点 |
