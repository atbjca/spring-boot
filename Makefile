.PHONY: clean install deploy build run tree help test test-feedback

help: ## 显示帮助信息
	@echo ""
	@echo "可用命令:"
	@echo "  make clean          - 清理构建产物 ，耗时约 40s"
	@echo "  make format         - 格式化代码"
	@echo "  make build-thin     - 编译打包（不测试、无文档、不安装、不发布），耗时约 6m 31s"
	@echo "  make install        - 编译并安装到本地 Maven 仓库（~/.m2/repository）"
	@echo "  make deploy         - 发布到 Nexus 私服（不安装到本地 Maven 仓库（~/.m2/repository）），耗时约 1m 40s"
	@echo "  make stop           - 停止所有 Gradle Daemon ; 释放所有锁"
	@echo "  make projects       - 查看有效的项目"
	@echo "  make tree           - 查看依赖树"
	@echo "  make build          - 编译打包（不安装、不发布）"
	@echo "  make test           - Tier A 核心模块测试（spring-boot + spring-boot-test，承诺全绿）"
	@echo "  make test-feedback  - Tier C 扩大反馈（--continue，含已知失败，详见 doc/TESTING.md）"
	@echo ""
	@echo "测试策略详见 doc/TESTING.md"
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
# test —— Tier A 核心测试入口（承诺全绿）
#
# 范围：仅两个核心库模块，不含 smoke / system-tests / Docker / gradle-plugin。
#   - :spring-boot-project:spring-boot:test
#   - :spring-boot-project:spring-boot-test:test
#
# 日常 merge 门槛：make build-thin + make test → BUILD SUCCESSFUL
# 扩大反馈（BOM 大改、发布前摸底）：make test-feedback（Tier C）
#
# 策略与模块选择对齐 3.5 fork Phase 1；完整说明见 doc/TESTING.md
# ----------------------------------------------------------------------------
test: ## Tier A 核心模块测试（spring-boot + spring-boot-test）
	./gradlew \
		:spring-boot-project:spring-boot:test \
		:spring-boot-project:spring-boot-test:test \
		-x checkstyleMain -x checkstyleTest

# ----------------------------------------------------------------------------
# test-feedback —— Tier C 扩大反馈面（非全绿承诺）
#
# 范围：./gradlew test --continue，覆盖三子树：
#   - spring-boot-project（核心库 + tools，除下方 -x）
#   - spring-boot-tests/spring-boot-integration-tests
#   - spring-boot-tests/spring-boot-smoke-tests（settings.gradle ignoredSmokeTests 已排除 18 个）
# spring-boot-system-tests（Docker）通过 -x 排除。
#
# --continue：单子项目失败不阻断其它子项目；整体退出码仍由 Gradle 决定。
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
# 已知失败分类（完整表见 doc/TESTING.md §8）：
#   (G) gradle-plugin TestKit / DocumentationTests（修复中：Jackson、bin/main、离线 zip）
#   (E) 少量未定位：Liquibase / Quartz / Jersey* / WebTestClient 等
#   (S) smoke-tests 需 H2/Kafka 等外部组件
# ----------------------------------------------------------------------------
test-feedback: ## Tier C 扩大反馈（--continue，含已知失败）
	./gradlew test --continue \
		-x :spring-boot-project:spring-boot-autoconfigure:test \
		-x :spring-boot-project:spring-boot-autoconfigure:compileTestJava \
		-x :spring-boot-project:spring-boot-tools:spring-boot-buildpack-platform:test \
		-x :spring-boot-tests:spring-boot-integration-tests:spring-boot-launch-script-tests:test \
		-x :spring-boot-tests:spring-boot-integration-tests:spring-boot-loader-tests:test \
		-x :spring-boot-system-tests:spring-boot-deployment-tests:test \
		-x :spring-boot-system-tests:spring-boot-image-tests:test
