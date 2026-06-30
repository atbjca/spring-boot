/*
 * Copyright 2012-2023 the original author or authors.
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

package org.springframework.boot.testsupport.gradle.testkit;

import java.io.File;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Resolves Gradle distributions for {@link GradleBuild} TestKit runs without hitting
 * {@code services.gradle.org} when a local or mirror copy is available.
 *
 * @author Spring Boot fork
 */
final class GradleDistributionLocator {

	private static final String LOCAL_DIR_PROPERTY = "nes.gradle.distributions.dir";

	private static final String LOCAL_DIR_ENV = "NES_GRADLE_DISTRIBUTIONS_DIR";

	private static final String MIRROR_PROPERTY = "nes.gradle.distributions.mirror";

	private static final String MIRROR_ENV = "NES_GRADLE_DISTRIBUTIONS_MIRROR";

	private static final String DEFAULT_MIRROR = "https://mirrors.cloud.tencent.com/gradle/";

	private GradleDistributionLocator() {
	}

	static ResolvedGradleDistribution resolve(String version) {
		Path localDir = resolveLocalDir();
		File installation = resolveInstallation(localDir, version);
		if (installation != null) {
			return ResolvedGradleDistribution.installation(installation);
		}
		File zip = resolveZip(localDir, version);
		if (zip != null) {
			return ResolvedGradleDistribution.distribution(zip.toURI());
		}
		String mirror = resolveMirror();
		if (mirror != null) {
			String zipName = "gradle-" + version + "-bin.zip";
			return ResolvedGradleDistribution.distribution(URI.create(mirror + zipName));
		}
		return ResolvedGradleDistribution.version(version);
	}

	private static Path resolveLocalDir() {
		String configured = System.getProperty(LOCAL_DIR_PROPERTY);
		if (configured == null || configured.isEmpty()) {
			configured = System.getenv(LOCAL_DIR_ENV);
		}
		if (configured == null || configured.isEmpty()) {
			configured = Paths.get(System.getProperty("user.home"), "dev").toString();
		}
		return Paths.get(configured);
	}

	private static String resolveMirror() {
		String mirror = System.getProperty(MIRROR_PROPERTY);
		if (mirror == null || mirror.isEmpty()) {
			mirror = System.getenv(MIRROR_ENV);
		}
		if (mirror == null) {
			mirror = DEFAULT_MIRROR;
		}
		if (mirror.isEmpty() || "false".equalsIgnoreCase(mirror) || "none".equalsIgnoreCase(mirror)) {
			return null;
		}
		if (!mirror.endsWith("/")) {
			mirror = mirror + "/";
		}
		return mirror;
	}

	private static File resolveInstallation(Path localDir, String version) {
		Path home = localDir.resolve("gradle-" + version);
		Path gradle = home.resolve("bin").resolve("gradle");
		if (Files.isRegularFile(gradle)) {
			return home.toFile();
		}
		return null;
	}

	private static File resolveZip(Path localDir, String version) {
		File zip = localDir.resolve("gradle-" + version + "-bin.zip").toFile();
		if (zip.isFile()) {
			return zip;
		}
		return null;
	}

	static final class ResolvedGradleDistribution {

		private final String version;

		private final File installation;

		private final URI distribution;

		private ResolvedGradleDistribution(String version, File installation, URI distribution) {
			this.version = version;
			this.installation = installation;
			this.distribution = distribution;
		}

		static ResolvedGradleDistribution version(String version) {
			return new ResolvedGradleDistribution(version, null, null);
		}

		static ResolvedGradleDistribution installation(File installation) {
			return new ResolvedGradleDistribution(null, installation, null);
		}

		static ResolvedGradleDistribution distribution(URI distribution) {
			return new ResolvedGradleDistribution(null, null, distribution);
		}

		boolean hasInstallation() {
			return this.installation != null;
		}

		boolean hasDistribution() {
			return this.distribution != null;
		}

		String getVersion() {
			return this.version;
		}

		File getInstallation() {
			return this.installation;
		}

		URI getDistribution() {
			return this.distribution;
		}

	}

}
