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
		assertThat(build).contains("cn.bjca.footstone.bpring.kafka:${newArtifactId}:2.9.13-nes.patch.1-SNAPSHOT");
	}

	@Test
	void springDataCommonsKeyValueRedisAreSubstitutedToNesCoordinates() throws IOException {
		String build = readRootBuildGradle();
		assertThat(build).contains("requested.group == 'org.springframework.data'");
		assertThat(build).contains("requested.name == 'spring-data-commons'");
		assertThat(build).contains("requested.name == 'spring-data-keyvalue'");
		assertThat(build).contains("requested.name == 'spring-data-redis'");
		assertThat(build).contains("cn.bjca.footstone.bpring.data:${newArtifactId}:2.7.18-nes.patch.1-SNAPSHOT");
	}

	@Test
	void springDataElasticsearchIsSubstitutedOnItsOwnVersionLine() throws IOException {
		String build = readRootBuildGradle();
		assertThat(build).contains("requested.name == 'spring-data-elasticsearch'");
		assertThat(build).contains("cn.bjca.footstone.bpring.data:${newArtifactId}:4.4.18-nes.patch.1-SNAPSHOT");
	}

	private String readRootBuildGradle() throws IOException {
		File projectDir = new File(System.getProperty("user.dir"));
		File buildGradle = new File(projectDir.getParentFile(), "build.gradle");
		return new String(Files.readAllBytes(buildGradle.toPath()), StandardCharsets.UTF_8);
	}

}
