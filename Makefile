.PHONY: clean install deploy build run tree help

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
	@echo ""

clean: ## 清理构建产物
	./gradlew clean

format: ## 格式化代码
	./gradlew :spring-boot-project:spring-boot:formatMain

build: clean ## 编译打包
	./gradlew build

build-thin: clean format ## 编译打包
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
