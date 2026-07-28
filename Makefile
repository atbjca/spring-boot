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
	@echo "  make build          - 稳定绿灯门禁：全量编译打包/checkstyle + Tier A 测试"
	@echo "  make test           - Tier A 核心模块测试（spring-boot + spring-boot-test + Kafka smoke，承诺全绿）"
	@echo "  make test-feedback  - Tier C 扩大反馈（--continue，含已知失败，详见 doc/TESTING.md）"
	@echo "  make setup-gradle   - 安装并解压 LOCAL_GRADLE_DIR 下全部 gradle-*-zip 到 wrapper 缓存；缺包则回退联网下载"
	@echo ""
	@echo "测试策略详见 doc/TESTING.md"
	@echo ""

# LOCAL_GRADLE_DIR: 本地 Gradle zip 所在目录，默认 ~/dev，可通过环境变量覆盖
SETUP_GRADLE := ./scripts/setup-gradle-local.sh

# -----------------------------------------------------------------------------
# setup-gradle：构建前预热 Gradle 发行包（几乎所有 target 的前置依赖）
#
# 为什么这么做：
#   Gradle Wrapper 首次运行会按 gradle-wrapper.properties 里的 distributionUrl
#   联网从 services.gradle.org 下载发行包。在内网/离线/弱网环境下这一步很慢或
#   直接失败。本 target 调用 scripts/setup-gradle-local.sh，把本地已备好的
#   gradle-*-{bin,all}.zip 按 Wrapper 的缓存命名规则（MD5(url)->base36）直接
#   复制解压到 ~/.gradle/wrapper/dists/，模拟“首次下载已完成”，从而免联网。
#   因为用的是官方 URL 算 hash，gradle-wrapper.properties 无需改成 file://。
#
# 从哪里找包：
#   默认扫描 LOCAL_GRADLE_DIR（缺省 ~/dev）下的 gradle-*-{bin,all}.zip。
#   可覆盖：LOCAL_GRADLE_DIR=/path/to/zips make <target>
#
# 会产生什么效果：
#   - 找到本地包：免网络注入 Wrapper 缓存，构建直接用本地发行包（幂等，已就绪则跳过）。
#   - 找不到本地包：不再中断构建，仅打印提示并以退出码 0 继续，交回 Gradle Wrapper
#     按官方 distributionUrl 联网下载。（旧行为是 exit 1 直接让 make 失败。）
#
# 注意：
#   “缺包回退联网下载”依赖能访问 services.gradle.org。若既无本地包又完全离线，
#   下载会在 Gradle 自身阶段失败——此时请补齐本地包或设置 LOCAL_GRADLE_DIR。
# -----------------------------------------------------------------------------
setup-gradle: ## 安装并解压 LOCAL_GRADLE_DIR 下全部 Gradle zip（默认 ~/dev）到 wrapper 缓存
	@./scripts/setup-gradle-local.sh

clean: ## 清理构建产物
	./gradlew -Dorg.gradle.caching=false clean

format: setup-gradle ## 格式化代码
	./gradlew -Dorg.gradle.caching=false format

# ----------------------------------------------------------------------------
# build —— 稳定绿灯门禁
#
# Phase 1：全仓库编译/打包/checkstyle（不含测试与 asciidoctor 文档）
# Phase 2：Tier A 测试（复用 make test，承诺全绿）
#
# 扩大摸底（actuator 全量 / 插件 / Docker / 文档测试）用 make test-feedback
# ----------------------------------------------------------------------------
build: setup-gradle clean format ## 稳定绿灯门禁（编译打包 + Tier A 测试）
	./gradlew -Dorg.gradle.caching=false build \
		-x test -x intTest -x documentationTest \
		-x asciidoctor -x asciidoctorPdf \
		-x syncDocumentationSourceForAsciidoctor -x syncDocumentationSourceForAsciidoctorPdf
	$(MAKE) test

build-thin: setup-gradle clean format ## 编译打包 -x checkstyleNohttp
	./gradlew -Dorg.gradle.caching=false build -x test -x intTest -x checkstyleMain -x checkstyleTest -x asciidoctor -x javadoc

install: setup-gradle ## 编译并安装到本地 Maven 仓库 # ./gradlew -Dorg.gradle.caching=false clean build publishToMavenLocal
	./gradlew -Dorg.gradle.caching=false publishToMavenLocal -x test

deploy: setup-gradle ## 发布到 Nexus 私服
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
