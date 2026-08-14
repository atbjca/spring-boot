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

package org.springframework.boot.build.classpath;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Tests for the prohibited-classpath allowlist used by the dual JSON-P runtime.
 */
class CheckClasspathForProhibitedDependenciesTests {

	@Test
	void javaxJsonApiIsAllowlisted() {
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("javax.json", "javax.json-api")).isFalse();
	}

	@Test
	void existingJavaxAllowlistEntriesRemainPermitted() {
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("javax.batch", "javax.batch-api")).isFalse();
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("javax.cache", "cache-api")).isFalse();
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("javax.money", "money-api")).isFalse();
	}

	@Test
	void unrelatedJavaxGroupsRemainProhibited() {
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("javax.servlet", "javax.servlet-api")).isTrue();
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("javax.annotation", "javax.annotation-api"))
			.isTrue();
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("javax.xml.bind", "jaxb-api")).isTrue();
	}

	@Test
	void jakartaJsonIsNotCoveredByTheJavaxProhibition() {
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("jakarta.json", "jakarta.json-api")).isFalse();
	}

	@Test
	void officialSpringRetryIsProhibited() {
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("org.springframework.retry", "spring-retry"))
			.isTrue();
	}

	@Test
	void nesSpringRetryIsAllowed() {
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("cn.bjca.footstone.bpring.retry",
				"bjca-footstone-bpring-retry"))
			.isFalse();
	}

	@Test
	void unrelatedArtifactInOfficialSpringRetryGroupIsAllowed() {
		assertThat(CheckClasspathForProhibitedDependencies.isProhibited("org.springframework.retry", "retry-support"))
			.isFalse();
	}

}
