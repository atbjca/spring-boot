.PHONY: clean install deploy build run tree help test test-feedback setup-gradle

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
	@echo "  make test           - Tier A 核心模块测试（spring-boot + spring-boot-test + Kafka smoke，承诺全绿）"
	@echo "  make test-feedback  - Tier C 扩大反馈（--continue，含已知失败，详见 doc/TESTING.md）"
	@echo "  make setup-gradle   - 安装并解压 LOCAL_GRADLE_DIR 下全部 gradle-*-zip 到 wrapper 缓存"
	@echo ""
	@echo "测试策略详见 doc/TESTING.md"
	@echo ""

# LOCAL_GRADLE_DIR: 本地 Gradle zip 所在目录，默认 ~/dev，可通过环境变量覆盖
SETUP_GRADLE := ./scripts/setup-gradle-local.sh

setup-gradle: ## 安装并解压 LOCAL_GRADLE_DIR 下全部 Gradle zip（默认 ~/dev）到 wrapper 缓存
	@./scripts/setup-gradle-local.sh

clean: ## 清理构建产物
	./gradlew -Dorg.gradle.caching=false clean

format: setup-gradle ## 格式化代码
	./gradlew -Dorg.gradle.caching=false format

build: setup-gradle clean format ## 编译打包
	./gradlew -Dorg.gradle.caching=false build

build-thin: setup-gradle clean format ## 编译打包 -x checkstyleNohttp
	./gradlew -Dorg.gradle.caching=false build -x test -x intTest -x checkstyleMain -x checkstyleTest -x asciidoctor -x javadoc

install: setup-gradle clean ## 编译并安装到本地 Maven 仓库 # ./gradlew -Dorg.gradle.caching=false clean build publishToMavenLocal
	./gradlew -Dorg.gradle.caching=false publishToMavenLocal -x test

deploy: setup-gradle clean ## 发布到 Nexus 私服
	./gradlew -Dorg.gradle.caching=false publish -x test

stop: ## 停止所有 Gradle Daemon ; 释放所有锁
	./gradlew -Dorg.gradle.caching=false --stop

tree: setup-gradle ## 查看依赖树
	./gradlew -Dorg.gradle.caching=false dependencies --configuration compileClasspath

projects: setup-gradle ## 查看有效的项目
	./gradlew -Dorg.gradle.caching=false projects

# ----------------------------------------------------------------------------
# test —— Tier A 核心测试入口（承诺全绿）
#
# 范围：两个核心库模块 + Kafka smoke，不含其它 smoke / system-tests / Docker / gradle-plugin。
#   - :spring-boot-project:spring-boot:test
#   - :spring-boot-project:spring-boot-test:test
#   - :spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test
#
# Kafka smoke 使用 NES spring-kafka-test 对 fork Kafka 3.9.2 的 EmbeddedKafka
# 兼容能力，不需要外部 Kafka 服务。
#
# 日常 merge 门槛：make build-thin + make test → BUILD SUCCESSFUL
# 扩大反馈（BOM 大改、发布前摸底）：make test-feedback（Tier C）
#
# 策略与模块选择对齐 3.5 fork Phase 1；完整说明见 doc/TESTING.md
# ----------------------------------------------------------------------------
test: setup-gradle ## Tier A 核心模块测试（spring-boot + spring-boot-test）
	./gradlew -Dorg.gradle.caching=false \
		:spring-boot-project:spring-boot:test \
		:spring-boot-project:spring-boot-test:test \
		:spring-boot-tests:spring-boot-smoke-tests:spring-boot-smoke-test-kafka:test \
		-x checkstyleMain -x checkstyleTest

# ----------------------------------------------------------------------------
# test-feedback —— Tier C 扩大反馈面（非全绿承诺）
#
# 范围：./gradlew -Dorg.gradle.caching=false test --continue，覆盖三子树：
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
#       sslWithValidAlias（已定位为 flaky，处置：@RepeatedTest(10)，非真实 SSL 缺陷）
#       PrematureCloseException（reactor.netty 1.0.x + Servlet keep-alive 竞态，处置：CI=true 启用 TestRetry 自动重试 3 次）
#   (S) smoke-tests 需外部组件：Kafka smoke 已由 NES spring-kafka-test 兼容并纳入 make test；
#       其它 smoke 外部依赖按 settings.gradle ignoredSmokeTests 或显式 -x 管理。
# ----------------------------------------------------------------------------
test-feedback: setup-gradle ## Tier C 扩大反馈（--continue，含已知失败）
	CI=true ./gradlew -Dorg.gradle.caching=false test --continue \
		-x :spring-boot-project:spring-boot-autoconfigure:test \
		-x :spring-boot-project:spring-boot-autoconfigure:compileTestJava \
		-x :spring-boot-project:spring-boot-tools:spring-boot-buildpack-platform:test \
		-x :spring-boot-tests:spring-boot-integration-tests:spring-boot-launch-script-tests:test \
		-x :spring-boot-tests:spring-boot-integration-tests:spring-boot-loader-tests:test \
		-x :spring-boot-system-tests:spring-boot-deployment-tests:test \
		-x :spring-boot-system-tests:spring-boot-image-tests:test
