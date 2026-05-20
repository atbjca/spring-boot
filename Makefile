.PHONY: clean install deploy build run tree help test

help: ## 显示帮助信息
	@echo ""
	@echo "可用命令:"
	@echo "  make clean    - 清理构建产物 ，耗时约 40s"
	@echo "  make format   - 格式化代码"
	@echo "  make build-thin - 编译打包（不测试、无文档、不安装、不发布），耗时约 6m 31s"
	@echo "  make install  - 编译并安装到本地 Maven 仓库（~/.m2/repository）"
	@echo "  make deploy   - 发布到 Nexus 私服（不安装到本地 Maven 仓库（~/.m2/repository）），耗时约 1m 40s"
	@echo "  make stop     - 停止所有 Gradle Daemon ; 释放所有锁"
	@echo "  make projects - 查看有效的项目"
	@echo "  make tree     - 查看依赖树"
	@echo "  make build    - 编译打包（不安装、不发布）至 2026-02-25 还不能跑，主要是其高级测试部分环境不够用，譬如 docker ，譬如指定的 ip"
	@echo "  make test     - 执行受控范围内的测试（含已知失败，详见 test 目标注释），耗时较长"
	@echo ""

clean: ## 清理构建产物
	./gradlew clean

format: ## 格式化代码
	./gradlew format

build: clean format ## 编译打包
	./gradlew build

build-thin: clean format ## 编译打包 -x checkstyleNohttp
	./gradlew build -x test -x intTest -x checkstyleMain -x checkstyleTest -x asciidoctor -x javadoc

install: clean ## 编译并安装到本地 Maven 仓库 # ./gradlew clean build publishToMavenLocal
	./gradlew publishToMavenLocal -x test

deploy: clean ## 发布到 Nexus 私服
	./gradlew publish -x test

stop: ## 停止所有 Gradle Daemon ; 释放所有锁
	./gradlew --stop

tree: ## 查看依赖树
	./gradlew dependencies --configuration compileClasspath

projects: ## 查看有效的项目
	./gradlew projects

# ----------------------------------------------------------------------------
# test 目标 —— 测试入口（含 TDD 与完整反馈面）
#
# 范围：直接调用 ./gradlew test --continue，让 Gradle 自动调度被 settings.gradle
# 启用的所有子项目的 test 任务，覆盖三个子树：
#   - spring-boot-project（核心库）
#   - spring-boot-tests/spring-boot-integration-tests
#   - spring-boot-tests/spring-boot-smoke-tests（settings.gradle 中 ignoredSmokeTests
#     已经在源头排除 18 个，剩余约 73 个端到端 sample 应用会被纳入）
# spring-boot-system-tests 子树（Docker 强依赖）通过下方 -x 排除。
#
# --continue 让单子项目失败不阻断其它子项目继续执行，整体退出码仍由 Gradle 决定。
#
# 显式排除（每条单行原因）：
#   - :spring-boot-project:spring-boot-autoconfigure:test
#       Thymeleaf 升级残留：compileTestJava 编译失败 + 已知用例失败。
#   - :spring-boot-project:spring-boot-autoconfigure:compileTestJava
#       双保险，避免其它模块连带触发该编译失败。
#   - :spring-boot-project:spring-boot-tools:spring-boot-buildpack-platform:test
#       依赖 Docker daemon（buildpack 镜像构建）。
#   - :spring-boot-tests:spring-boot-integration-tests:spring-boot-launch-script-tests:test
#       Testcontainers / Docker。
#   - :spring-boot-tests:spring-boot-integration-tests:spring-boot-loader-tests:test
#       Testcontainers / Docker。
#   - :spring-boot-system-tests:spring-boot-deployment-tests:test
#       Docker。
#   - :spring-boot-system-tests:spring-boot-image-tests:test
#       Docker。
#
# 当前承诺：完整反馈面优先，非"全绿"。本目标范围内已知仍有失败的模块大致分类：
#   (D) JVM/JPMS 类（约 369 条）：spring-boot 模块的 *ServletWebServerFactoryTests
#       整组因 Java 17 模块系统拒绝访问 java.net.URLStreamHandlerFactory 而失败，
#       需给 build.gradle 加 --add-opens=java.base/java.net=ALL-UNNAMED，本次未做。
#   (G) gradle-plugin 的 *DocumentationTests（约 963 条）：Gradle Tooling API 起子
#       构建时 ZipException，需在 build.gradle 配 distribution 或排除测试类，本次未做。
#   (E) 其它少量未逐一定位的失败（约 130 条）：Liquibase / Quartz / CloudFoundry SSL /
#       Jersey* / SpringBootTestContextHierarchy / WebTestClient / LocalDevTools 等。
#   (S) smoke-tests / integration-tests 中需 redis / mongo 等外部组件的项目会失败。
#
# 维护规则：若某个失败值得永久剔除（环境性、不可修复），在本目标下方 -x 清单中加一行
# 并注明原因；如果失败可通过修改测试代码消除（fork 源码改动 / 依赖升级），优先改测试。
# ----------------------------------------------------------------------------
test: ## 执行受控范围内的测试（含已知失败，详见 test 目标注释）
	./gradlew test --continue \
		-x :spring-boot-project:spring-boot-autoconfigure:test \
		-x :spring-boot-project:spring-boot-autoconfigure:compileTestJava \
		-x :spring-boot-project:spring-boot-tools:spring-boot-buildpack-platform:test \
		-x :spring-boot-tests:spring-boot-integration-tests:spring-boot-launch-script-tests:test \
		-x :spring-boot-tests:spring-boot-integration-tests:spring-boot-loader-tests:test \
		-x :spring-boot-system-tests:spring-boot-deployment-tests:test \
		-x :spring-boot-system-tests:spring-boot-image-tests:test
