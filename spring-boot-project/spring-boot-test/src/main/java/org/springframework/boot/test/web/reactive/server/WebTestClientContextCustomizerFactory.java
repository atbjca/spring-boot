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

package org.springframework.boot.test.web.reactive.server;

import java.util.List;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ContextConfigurationAttributes;
import org.springframework.test.context.ContextCustomizer;
import org.springframework.test.context.ContextCustomizerFactory;
import org.springframework.test.context.TestContextAnnotationUtils;
import org.springframework.util.ClassUtils;

/**
 * {@link ContextCustomizerFactory} for {@code WebTestClient}.
 *
 * @author Stephane Nicoll
 * @author Andy Wilkinson
 */
class WebTestClientContextCustomizerFactory implements ContextCustomizerFactory {

	@Override
	public ContextCustomizer createContextCustomizer(Class<?> testClass,
			List<ContextConfigurationAttributes> configAttributes) {
		SpringBootTest springBootTest = TestContextAnnotationUtils.findMergedAnnotation(testClass,
				SpringBootTest.class);
		// FORK: 使用 testClass 的 ClassLoader 检测，避免 @ClassPathExclusions 场景下
		// 静态初始化已被其他并行测试用默认 ClassLoader 污染
		ClassLoader classLoader = testClass.getClassLoader();
		boolean reactorClientPresent = ClassUtils.isPresent("reactor.netty.http.client.HttpClient", classLoader);
		boolean jettyClientPresent = ClassUtils.isPresent("org.eclipse.jetty.client.HttpClient", classLoader);
		boolean httpComponentsClientPresent = ClassUtils
			.isPresent("org.apache.hc.client5.http.impl.async.CloseableHttpAsyncClient", classLoader)
				&& ClassUtils.isPresent("org.apache.hc.core5.reactive.ReactiveDataConsumer", classLoader);
		boolean webClientPresent = ClassUtils.isPresent("org.springframework.web.reactive.function.client.WebClient",
				classLoader);
		return (springBootTest != null && webClientPresent
				&& (reactorClientPresent || jettyClientPresent || httpComponentsClientPresent))
						? new WebTestClientContextCustomizer() : null;
	}

}
