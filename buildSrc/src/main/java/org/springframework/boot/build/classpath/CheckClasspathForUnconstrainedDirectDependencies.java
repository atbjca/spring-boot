/*
 * Copyright 2023-2023 the original author or authors.
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

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.gradle.api.DefaultTask;
import org.gradle.api.GradleException;
import org.gradle.api.artifacts.Configuration;
import org.gradle.api.artifacts.component.ModuleComponentIdentifier;
import org.gradle.api.artifacts.component.ModuleComponentSelector;
import org.gradle.api.artifacts.result.DependencyResult;
import org.gradle.api.artifacts.result.ResolutionResult;
import org.gradle.api.artifacts.result.ResolvedDependencyResult;
import org.gradle.api.file.FileCollection;
import org.gradle.api.tasks.Classpath;
import org.gradle.api.tasks.TaskAction;

/**
 * Tasks to check that none of classpath's direct dependencies are unconstrained.
 *
 * @author Andy Wilkinson
 */
public class CheckClasspathForUnconstrainedDirectDependencies extends DefaultTask {

	private Configuration classpath;

	public CheckClasspathForUnconstrainedDirectDependencies() {
		getOutputs().upToDateWhen((task) -> true);
	}

	@Classpath
	public FileCollection getClasspath() {
		return this.classpath;
	}

	public void setClasspath(Configuration classpath) {
		this.classpath = classpath;
	}

	@TaskAction
	void checkForUnconstrainedDirectDependencies() {
		ResolutionResult resolutionResult = this.classpath.getIncoming().getResolutionResult();
		Set<? extends DependencyResult> dependencies = resolutionResult.getRoot().getDependencies();
		Set<String> unconstrainedDependencies = dependencies.stream()
			.map(DependencyResult::getRequested)
			.filter(ModuleComponentSelector.class::isInstance)
			.map(ModuleComponentSelector.class::cast)
			.map((selector) -> selector.getGroup() + ":" + selector.getModule())
			.collect(Collectors.toSet());
		Set<String> constraints = resolutionResult.getAllDependencies()
			.stream()
			.filter(DependencyResult::isConstraint)
			.map(DependencyResult::getRequested)
			.filter(ModuleComponentSelector.class::isInstance)
			.map(ModuleComponentSelector.class::cast)
			.map((selector) -> selector.getGroup() + ":" + selector.getModule())
			.collect(Collectors.toSet());
		unconstrainedDependencies.removeAll(constraints);
		// GAV 映射兼容：当 resolutionStrategy.eachDependency 将原始坐标（如
		// org.springframework:spring-core）
		// 重写为 fork 坐标（如 cn.bjca.footstone.bpring:bjca-footstone-bpring-core）时，
		// BOM 约束仅覆盖 fork 坐标，导致原始坐标被误判为无约束。
		// 此处构建"请求坐标 → 解析坐标"的映射，若解析后的坐标已被 BOM 约束，则视为已约束。
		if (!unconstrainedDependencies.isEmpty()) {
			Map<String, String> requestedToResolved = buildRequestedToResolvedMapping(dependencies);
			unconstrainedDependencies.removeIf((requested) -> {
				String resolved = requestedToResolved.get(requested);
				// 解析后的坐标与请求坐标不同（说明经过了 resolutionStrategy 重写），且解析后的坐标被 BOM 约束
				return resolved != null && !resolved.equals(requested) && constraints.contains(resolved);
			});
		}
		if (!unconstrainedDependencies.isEmpty()) {
			throw new GradleException("Found unconstrained direct dependencies: " + unconstrainedDependencies);
		}
	}

	/**
	 * 构建从请求坐标（group:module）到解析坐标（group:module）的映射.
	 * <p>
	 * 当 resolutionStrategy 重写了依赖坐标时，请求坐标与解析坐标会不同。
	 * @param dependencies 需要构建映射的依赖结果集合
	 * @return 请求坐标到解析坐标的映射
	 */
	private Map<String, String> buildRequestedToResolvedMapping(Set<? extends DependencyResult> dependencies) {
		Map<String, String> mapping = new HashMap<>();
		for (DependencyResult dep : dependencies) {
			if (dep instanceof ResolvedDependencyResult && dep.getRequested() instanceof ModuleComponentSelector) {
				ModuleComponentSelector requested = (ModuleComponentSelector) dep.getRequested();
				String requestedKey = requested.getGroup() + ":" + requested.getModule();
				ResolvedDependencyResult resolved = (ResolvedDependencyResult) dep;
				if (resolved.getSelected().getId() instanceof ModuleComponentIdentifier) {
					ModuleComponentIdentifier selectedId = (ModuleComponentIdentifier) resolved.getSelected().getId();
					String resolvedKey = selectedId.getGroup() + ":" + selectedId.getModule();
					mapping.put(requestedKey, resolvedKey);
				}
			}
		}
		return mapping;
	}

}
