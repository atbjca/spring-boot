.PHONY: clean format build build-thin install deploy stop projects help test

help: ## 显示帮助信息
	@echo ""
	@echo "可用命令:"
	@echo "  make clean      - 清理构建产物"
	@echo "  make format     - 格式化代码"
	@echo "  make build-thin - 编译打包（跳过 test、文档、部分 checkstyle），耗时约 30-60 分钟"
	@echo "  make install    - 发布到本地 Maven 仓库（~/.m2/repository）"
	@echo "  make deploy     - 发布到 Nexus 私服"
	@echo "  make test       - Phase 1 过渡（spring-boot + spring-boot-test，已全绿）"
	@echo "                  目标门槛见 doc/TESTING.md §10 Tier B（make test-gate，待实施）"
	@echo "  make stop       - 停止 Gradle Daemon"
	@echo "  make projects   - 查看子项目列表"
	@echo ""
	@echo "测试策略详见 doc/TESTING.md"
	@echo ""

clean: ## 清理构建产物
	./gradlew clean

format: ## 格式化代码
	./gradlew format

build: ## 全量 build（含 test，本地不推荐）
	./gradlew build

build-thin: ## 编译打包，跳过 test / intTest / 文档 / 部分 checkstyle
	./gradlew assemble -x test -x intTest -x checkstyleMain -x checkstyleTest \
		-x :spring-boot-project:spring-boot-docs:assemble \
		-x :spring-boot-project:spring-boot-tools:spring-boot-cli:assemble \
		-x :spring-boot-system-tests:spring-boot-deployment-tests:assemble \
		-x :spring-boot-system-tests:spring-boot-image-tests:assemble

install: ## 发布到本地 Maven 仓库
	./gradlew publishToMavenLocal -x test

deploy: ## 发布到 Nexus 私服
	./gradlew publish -x test

stop: ## 停止 Gradle Daemon
	./gradlew --stop

projects: ## 查看子项目列表
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
test: ## Phase 1 核心模块测试（spring-boot + spring-boot-test）
	./gradlew \
		:spring-boot-project:spring-boot:test \
		:spring-boot-project:spring-boot-test:test \
		-x checkstyleMain -x checkstyleTest
