/*
 * Copyright 2012-2026 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.springframework.boot.build;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Tests for fork dependency substitution rules in the root build.
 */
class ForkDependencySubstitutionTests {

	@Test
	void springKafkaDependenciesAreSubstitutedToNesCoordinates() throws IOException {
		String build = readRootBuildGradle();
		assertThat(build).contains("requested.group == 'org.springframework.kafka'");
		assertThat(build).contains("requested.name.startsWith('spring-kafka')");
		assertThat(build).contains("cn.bjca.footstone.bpring.kafka:${newArtifactId}:2.9.13-nes.patch.1");
	}

	@Test
	void springDataCommonsKeyValueRedisAreSubstitutedToNesCoordinates() throws IOException {
		String build = readRootBuildGradle();
		assertThat(build).contains("requested.group == 'org.springframework.data'");
		assertThat(build).contains("requested.name == 'spring-data-commons'");
		assertThat(build).contains("requested.name == 'spring-data-keyvalue'");
		assertThat(build).contains("requested.name == 'spring-data-redis'");
		assertThat(build).contains("cn.bjca.footstone.bpring.data:${newArtifactId}:2.7.18-nes.patch.1");
	}

	@Test
	void springDataElasticsearchIsSubstitutedOnItsOwnVersionLine() throws IOException {
		String properties = readRootFile("gradle.properties");
		assertThat(properties).contains("springDataElasticsearchNesVersion=4.4.18-nes.patch.2-SNAPSHOT");
		assertThat(properties).contains("springDataBomNesVersion=2021.2.18-nes.patch.2-SNAPSHOT");
		String build = readRootBuildGradle();
		assertThat(build).contains("requested.name == 'spring-data-elasticsearch'");
		assertThat(build)
			.contains("cn.bjca.footstone.bpring.data:${newArtifactId}:${springDataElasticsearchNesVersion}");
		assertThat(build).doesNotContain("cn.bjca.footstone.bpring.data:${newArtifactId}:4.4.18-nes.patch.1");
	}

	@Test
	void reactorNettyDependenciesAreSubstitutedToNesCoordinates() throws IOException {
		String properties = readRootFile("gradle.properties");
		assertThat(properties).contains("reactorNettyNesVersion=1.0.48-nes.patch.1");
		String build = readRootBuildGradle();
		assertThat(build).contains("requested.group == 'io.projectreactor.netty'");
		assertThat(build).contains("requested.name == 'reactor-netty'");
		assertThat(build).contains("requested.name == 'reactor-netty-core'");
		assertThat(build).contains("requested.name == 'reactor-netty-http'");
		assertThat(build).contains("requested.name == 'reactor-netty-http-brave'");
		assertThat(build).contains("cn.bjca.footstone.beactor.netty:${newArtifactId}:${reactorNettyNesVersion}");
	}

	@Test
	void reactorNettyNesModulesAndNetty136AreManagedByTheBom() throws IOException {
		String bom = readRootFile("spring-boot-project/spring-boot-dependencies/build.gradle");
		assertThat(bom).contains("library(\"Netty\", \"4.1.136.Final\")");
		assertThat(bom).contains("library(\"Reactor Netty NES\", reactorNettyNesVersion)");
		assertThat(bom).contains("group(\"cn.bjca.footstone.beactor.netty\")");
		assertThat(bom).contains("\"bjca-footstone-beactor-netty\"");
		assertThat(bom).contains("\"bjca-footstone-beactor-netty-core\"");
		assertThat(bom).contains("\"bjca-footstone-beactor-netty-http\"");
		assertThat(bom).contains("\"bjca-footstone-beactor-netty-http-brave\"");
	}

	@Test
	void reactorNettyStarterPublishesTheNesHttpCoordinate() throws IOException {
		String starter = readRootFile(
				"spring-boot-project/spring-boot-starters/spring-boot-starter-reactor-netty/build.gradle");
		assertThat(starter).contains(
				"api(\"cn.bjca.footstone.beactor.netty:bjca-footstone-beactor-netty-http:${reactorNettyNesVersion}\")");
		assertThat(starter).doesNotContain("api(\"io.projectreactor.netty:reactor-netty-http\")");
	}

	@Test
	void nesElasticsearchProductionAllowlistAndSupportArtifactsAreManaged() throws IOException {
		String properties = readRootFile("gradle.properties");
		assertThat(properties).contains("elasticsearchNesVersion=7.17.29-nes.patch.1-SNAPSHOT");
		assertThat(properties).contains("barssonNesVersion=1.0.5-nes.patch.1-SNAPSHOT");
		assertThat(properties).contains("springFrameworkVersion=5.3.39-nes.patch.1");
		String bom = readBom();
		assertThat(bom).contains("library(\"Elasticsearch\", elasticsearchNesVersion)");
		assertThat(bom).contains("library(\"Barsson NES\", barssonNesVersion)");
		assertThat(bom).contains("library(\"Jakarta Json\", \"2.0.2\")");
		assertThat(bom).contains("library(\"Javax Json\", \"1.1.4\")");
		assertThat(bom).contains("group(\"cn.bjca.footstone.blasticsearch\")");
		assertThat(bom).contains("group(\"cn.bjca.footstone.blasticsearch.client\")");
		assertThat(bom).contains("group(\"cn.bjca.footstone.blasticsearch.plugin\")");
		assertThat(bom).contains("group(\"cn.bjca.footstone.barsson\")");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-core\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-secure-sm\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-x-content\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-geo\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-lz4\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-cli\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-plugin-classloader\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-rest-high-level-client\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-rest-client\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-rest-client-sniffer\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-mapper-extras-client\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-parent-join-client\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-aggs-matrix-stats-client\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-rank-eval-client\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-lang-mustache-client\"");
		assertThat(bom).contains("\"bjca-footstone-blasticsearch-java\"");
		assertThat(bom).contains("\"bjca-footstone-barsson\"");
		assertThat(bom).contains("\"jakarta.json-api\"");
		assertThat(readRootFile("gradle.properties")).contains("springFrameworkVersion=5.3.39-nes.patch.1");
		assertThat(readRootFile("doc/NES_GAV_MAPPING.md")).contains("bjca-footstone-bpring-jcl");
		assertThat(readRootBuildGradle()).contains("elasticsearchNesAllowlist");
		assertThat(readRootBuildGradle()).contains(
				"'org.elasticsearch:elasticsearch': 'cn.bjca.footstone.blasticsearch:bjca-footstone-blasticsearch'");
	}

	@Test
	void forbiddenOfficialElasticsearchCoordinatesAreNotManaged() throws IOException {
		String bom = readBom();
		assertThat(bom).doesNotContain("group(\"org.elasticsearch.distribution.integ-test-zip\")");
		assertThat(bom).doesNotContain("group(\"co.elastic.clients\")");
		assertThat(bom).doesNotContain("\"transport-netty4-client\"");
		assertThat(bom).doesNotContain("\t\t\t\t\"transport\",");
		assertThat(bom).doesNotContain("\"elasticsearch-java\"");
		String starter = readRootFile(
				"spring-boot-project/spring-boot-starters/spring-boot-starter-data-elasticsearch/build.gradle");
		assertThat(starter).doesNotContain("org.elasticsearch.client:transport");
		assertThat(starter).doesNotContain("co.elastic.clients:elasticsearch-java");
		String build = readRootBuildGradle();
		assertThat(build).doesNotContain("'org.elasticsearch.client:transport'");
		assertThat(build).doesNotContain("'org.elasticsearch.plugin:transport-netty4-client'");
		assertThat(build).doesNotContain("'org.elasticsearch.distribution.integ-test-zip:elasticsearch'");
	}

	@Test
	void generatedBomDeclaresNesMappingsAndExclusionsForMavenAndGradleConsumers() throws IOException {
		String bom = readBom();
		assertThat(bom).contains("exclude group: \"org.lz4\", module: \"lz4-java\"");
		assertThat(bom).contains("exclude group: \"commons-logging\", module: \"commons-logging\"");
		assertThat(bom).contains("library(\"LZ4 Java\", \"1.11.1\")");
		assertThat(bom).contains("group(\"at.yawk.lz4\")");
		assertThat(bom).contains("library(\"Spring Data Bom\", springDataBomNesVersion)");
		assertThat(bom).doesNotContain("group(\"org.springframework.data\")");
		assertThat(readRootFile("tests/elasticsearch-adoption/consumers/maven/pom.xml"))
			.contains("bjca-footstone-bpring-boot-dependencies");
		assertThat(readRootFile("tests/elasticsearch-adoption/consumers/gradle/build.gradle"))
			.contains("platform(\"cn.bjca.footstone.bpring.boot:bjca-footstone-bpring-boot-dependencies");
		assertThat(readRootFile("tests/elasticsearch-adoption/consumers/gradle-dm/build.gradle"))
			.contains("id \"io.spring.dependency-management\"");
	}

	@Test
	void jsonpDualRuntimeUsesJavaxApiForLegacyTestsAndJakartaApiForTheNesClient() throws IOException {
		assertThat(readRootFile("spring-boot-project/spring-boot-autoconfigure/build.gradle"))
			.contains("testImplementation(\"javax.json:javax.json-api\")")
			.doesNotContain("testImplementation(\"jakarta.json:jakarta.json-api\")");
		assertThat(readRootFile("spring-boot-project/spring-boot-test/build.gradle"))
			.contains("testImplementation(\"javax.json:javax.json-api\")")
			.doesNotContain("testImplementation(\"jakarta.json:jakarta.json-api\")");
		assertThat(readRootFile("spring-boot-project/spring-boot-test-autoconfigure/build.gradle"))
			.contains("testImplementation(\"javax.json:javax.json-api\")")
			.doesNotContain("testImplementation(\"jakarta.json:jakarta.json-api\")");
		String bom = readBom();
		assertThat(bom).doesNotContain("org.eclipse.parsson");
		assertThat(bom).contains("\"bjca-footstone-barsson\"");
		assertThat(bom).contains("library(\"Johnzon\"");
		assertThat(readRootFile(
				"tests/elasticsearch-adoption/consumers/src/main/java/org/springframework/boot/tests/elasticsearch/PublishedBootElasticsearchSmoke.java"))
			.contains("javax.json.spi.JsonProvider")
			.contains("jakarta.json.spi.JsonProvider")
			.contains("ServiceLoader.load");
	}

	@Test
	void elasticsearchModulesPublishNesClientCoordinatesAndKeepElasticsearchImports() throws IOException {
		assertThat(readRootFile("spring-boot-project/spring-boot-autoconfigure/build.gradle"))
			.contains("cn.bjca.footstone.blasticsearch.client:bjca-footstone-blasticsearch-rest-client")
			.contains("cn.bjca.footstone.blasticsearch.client:bjca-footstone-blasticsearch-rest-high-level-client");
		assertThat(readRootFile("spring-boot-project/spring-boot-actuator/build.gradle"))
			.contains("cn.bjca.footstone.blasticsearch:bjca-footstone-blasticsearch")
			.contains("cn.bjca.footstone.blasticsearch.client:bjca-footstone-blasticsearch-rest-client");
		assertThat(readRootFile("spring-boot-project/spring-boot-actuator-autoconfigure/build.gradle"))
			.contains("cn.bjca.footstone.blasticsearch:bjca-footstone-blasticsearch");
		assertThat(readRootFile("spring-boot-project/spring-boot-tools/spring-boot-test-support/build.gradle"))
			.contains("cn.bjca.footstone.blasticsearch:bjca-footstone-blasticsearch");
		String starter = readRootFile(
				"spring-boot-project/spring-boot-starters/spring-boot-starter-data-elasticsearch/build.gradle");
		assertThat(starter).contains(
				"api(\"cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:${springDataElasticsearchNesVersion}\")");
		assertThat(starter).contains("api(\"at.yawk.lz4:lz4-java\")");
		assertThat(starter).doesNotContain("api(\"org.springframework.data:spring-data-elasticsearch\")");
		assertThat(starter).doesNotContain("org.lz4:lz4-java");
		String autoConfig = readRootFile(
				"spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/elasticsearch/ElasticsearchRestClientAutoConfiguration.java");
		assertThat(autoConfig).contains("import org.elasticsearch.client.RestClientBuilder;");
	}

	private String readBom() throws IOException {
		return readRootFile("spring-boot-project/spring-boot-dependencies/build.gradle");
	}

	private String readRootBuildGradle() throws IOException {
		return readRootFile("build.gradle");
	}

	private String readRootFile(String path) throws IOException {
		File projectDir = new File(System.getProperty("user.dir"));
		File file = new File(projectDir.getParentFile(), path);
		return new String(Files.readAllBytes(file.toPath()), StandardCharsets.UTF_8);
	}

}
