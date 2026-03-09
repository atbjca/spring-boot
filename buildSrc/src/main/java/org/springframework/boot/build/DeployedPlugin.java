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

package org.springframework.boot.build;

import org.gradle.api.Plugin;
import org.gradle.api.Project;
import org.gradle.api.plugins.JavaPlatformPlugin;
import org.gradle.api.plugins.JavaPlugin;
import org.gradle.api.publish.PublishingExtension;
import org.gradle.api.publish.maven.MavenPublication;
import org.gradle.api.publish.maven.plugins.MavenPublishPlugin;
import org.gradle.api.tasks.bundling.Jar;

/**
 * A plugin applied to a project that should be deployed.
 *
 * @author Andy Wilkinson
 */
public class DeployedPlugin implements Plugin<Project> {

	/**
	 * Name of the task that generates the deployed pom file.
	 */
	public static final String GENERATE_POM_TASK_NAME = "generatePomFileForMavenPublication";

	@Override
	@SuppressWarnings("deprecation")
	public void apply(Project project) {
		project.getPlugins().apply(MavenPublishPlugin.class);
		project.getPlugins().apply(MavenRepositoryPlugin.class);
		PublishingExtension publishing = project.getExtensions().getByType(PublishingExtension.class);
		MavenPublication mavenPublication = publishing.getPublications().create("maven", MavenPublication.class);
		// ── Fork artifactId 发布修复（方案 B）──────────────────────────────
		// (1) 为什么：settings.gradle 中的项目名替换由于 Gradle 执行顺序问题，
		// 未能生效于 Maven 发布阶段。MavenPublication 默认使用 project.name
		// 作为 artifactId，而此时 project.name 仍为原始的 "spring-boot-*" 形式，
		// 因此需要在此处显式设置 artifactId，确保发布制品使用 fork 命名。
		// (2) 替换逻辑：将 project.name 中的 "spring-boot" 替换为
		// forkArtifactPrefix + "-boot"。例如当 forkArtifactPrefix = "bjca-footstone-bpring"
		// 时，
		// "spring-boot-starter-web" → "bjca-footstone-bpring-boot-starter-web"。
		// (3) 修改方法：仅需修改 gradle.properties 中的 forkArtifactPrefix 属性
		// 即可全局生效，保持单一配置源，无需修改本文件。
		Object forkArtifactPrefix = project.findProperty("forkArtifactPrefix");
		if (forkArtifactPrefix != null && !forkArtifactPrefix.toString().isEmpty()) {
			mavenPublication
				.setArtifactId(project.getName().replace("spring-boot", forkArtifactPrefix.toString() + "-boot"));
		}
		project.afterEvaluate((evaluated) -> project.getPlugins().withType(JavaPlugin.class).all((javaPlugin) -> {
			if (((Jar) project.getTasks().getByName(JavaPlugin.JAR_TASK_NAME)).isEnabled()) {
				project.getComponents()
					.matching((component) -> component.getName().equals("java"))
					.all(mavenPublication::from);
			}
		}));
		project.getPlugins()
			.withType(JavaPlatformPlugin.class)
			.all((javaPlugin) -> project.getComponents()
				.matching((component) -> component.getName().equals("javaPlatform"))
				.all(mavenPublication::from));
	}

}
