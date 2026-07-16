.PHONY: clean format build build-thin install deploy stop projects help test test-gate setup-gradle

LOCAL_GRADLE_DIR ?= $(HOME)/dev
SETUP_GRADLE := ./scripts/setup-gradle-local.sh
TEST_ENV := env -u DOCKER_HOST -u DOCKER_CONTEXT -u DOCKER_TLS_VERIFY -u DOCKER_CERT_PATH

help: ## 显示帮助信息
	@echo ""
	@echo "可用命令:"
	@echo "  make setup-gradle - 安装并解压 $(LOCAL_GRADLE_DIR) 下全部 gradle-*-zip 到 wrapper 缓存"
	@echo "  make clean      - 清理构建产物"
	@echo "  make format     - 格式化代码"
	@echo "  make build-thin - 编译打包（跳过 test、文档、部分 checkstyle），耗时约 30-60 分钟"
	@echo "  make install    - 发布到本地 Maven 仓库（~/.m2/repository）"
	@echo "  make deploy     - 发布到 Nexus 私服"
	@echo "  make test       - Phase 1 过渡（spring-boot + spring-boot-test，已全绿）"
	@echo "  make test-gate  - Tier B 门槛（9 模块 14395 条，正式 merge 门槛）"
	@echo "  make stop       - 停止 Gradle Daemon"
	@echo "  make projects   - 查看子项目列表"
	@echo ""
	@echo "测试策略详见 doc/TESTING.md"
	@echo ""

setup-gradle: ## 安装并解压 LOCAL_GRADLE_DIR 下全部 Gradle zip（默认 ~/dev）
	LOCAL_GRADLE_DIR="$(LOCAL_GRADLE_DIR)" UNPACK=1 "$(SETUP_GRADLE)"

clean: setup-gradle ## 清理构建产物
	./gradlew clean

format: setup-gradle ## 格式化代码
	./gradlew format

build: setup-gradle ## 全量 build（含 test，本地不推荐）
	$(TEST_ENV) ./gradlew build

build-thin: setup-gradle ## 编译打包，跳过 test / intTest / 部分 checkstyle
	./gradlew assemble -x test -x intTest -x checkstyleMain -x checkstyleTest

install: setup-gradle ## 发布到本地 Maven 仓库
	./gradlew publishToMavenLocal -x test

deploy: setup-gradle ## 发布到 Nexus 私服
	./gradlew publish -x test

stop: ## 停止 Gradle Daemon
	./gradlew --stop

projects: setup-gradle ## 查看子项目列表
	./gradlew projects

# ----------------------------------------------------------------------------
# test —— Phase 1 核心测试入口（承诺全绿）
#
# 范围：仅两个核心库模块，不含 smoke / system-tests / Docker 依赖项。
#   - :spring-boot-project:spring-boot:test          （~5300 条，主库）
#   - :spring-boot-project:spring-boot-test:test       （~970 条，测试基础设施）
#
# 本地实测（2026-06-26，Java 17，3.5.15-SNAPSHOT 基线）：6308 条，0 失败。
# 首次约 1h（含编译与依赖下载）；后续有缓存会快很多。
#
# 为何不跑 ./gradlew test 全量：见 doc/TESTING.md §2。
# 定稿范围（Kafka starter 保留等）：见 doc/TESTING.md §10。
# Tier B（make test-gate）待摸底后实施；当前 make test 仅为 Phase 1 过渡。
# ----------------------------------------------------------------------------
test: setup-gradle ## Phase 1 核心模块测试（spring-boot + spring-boot-test）
	$(TEST_ENV) ./gradlew \
		:spring-boot-project:spring-boot:test \
		:spring-boot-project:spring-boot-test:test \
		-x checkstyleMain -x checkstyleTest

# ----------------------------------------------------------------------------
# test-gate —— Tier B 正式 merge 门槛（承诺全绿）
#
# Phase 1 超集：9 个模块，覆盖核心库 + 自动配置 + Actuator + 工具链。
# autoconfigure 排除 2 个 Mongo DNS 环境性失败（非 fork 问题）。
#
# 本地实测（2026-07-01，Java 17）：14395 条，0 失败，约 14 分钟。
# ----------------------------------------------------------------------------
test-gate: setup-gradle ## Tier B 正式 merge 门槛（9 模块，承诺全绿）
	$(TEST_ENV) ./gradlew \
		:spring-boot-project:spring-boot:test \
		:spring-boot-project:spring-boot-test:test \
		:spring-boot-project:spring-boot-autoconfigure:test \
		:spring-boot-project:spring-boot-actuator:test \
		:spring-boot-project:spring-boot-actuator-autoconfigure:test \
		:spring-boot-project:spring-boot-test-autoconfigure:test \
		:spring-boot-project:spring-boot-tools:spring-boot-maven-plugin:test \
		:spring-boot-project:spring-boot-tools:spring-boot-configuration-processor:test \
		:spring-boot-project:spring-boot-tools:spring-boot-autoconfigure-processor:test \
		-x checkstyleMain -x checkstyleTest
