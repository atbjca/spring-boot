# adopt-setup-gradle-local

采用与 spring-boot-3.5 一致的 setup-gradle-local.sh 方式，移除脆弱的 file:///Volumes/LIBIAO_EX/dev/... URL，恢复为标准 https://services.gradle.org/... URL，通过脚本将本地 zip 映射到 Gradle wrapper 缓存。
