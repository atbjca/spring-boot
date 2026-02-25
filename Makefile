.PHONY: clean install deploy build run tree help

help: ## 显示帮助信息
	@echo ""
	@echo "可用命令:"
	@echo "  make clean    - 清理构建产物"
	@echo "  make install  - 编译并安装到本地 Maven 仓库（~/.m2/repository）"
	@echo "  make deploy   - 发布到 Nexus 私服"
	@echo "  make build    - 编译打包（不安装、不发布）"
	@echo "  make build-thin - 编译打包（不测试、无文档、不安装、不发布）"
	@echo "  make stop     - 停止所有 Gradle Daemon ; 释放所有锁"
	@echo "  make tree     - 查看依赖树"
	@echo ""

clean: ## 清理构建产物
	./gradlew clean

build: ## 编译打包
	./gradlew clean build

build-thin: ## 编译打包
	./gradlew clean build -x test -x intTest -x checkstyleMain -x checkstyleTest -x asciidoctor -x javadoc

install: ## 编译并安装到本地 Maven 仓库
	./gradlew clean build publishToMavenLocal

deploy: ## 发布到 Nexus 私服
	./gradlew clean build publish

stop: ## 停止所有 Gradle Daemon ; 释放所有锁
	./gradlew --stop

tree: ## 查看依赖树
	./gradlew dependencies --configuration compileClasspath
