/*
 * Copyright 2026 the original author or authors.
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

package org.springframework.boot.autoconfigure.retry;

import org.junit.jupiter.api.Test;

import org.springframework.retry.context.RetryContextSupport;
import org.springframework.retry.policy.MapRetryContextCache;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;

/**
 * Tests for the managed Spring Retry cache security baseline.
 *
 * @author Libiao
 */
class SpringRetryCacheSecurityTests {

	@Test
	void recentlyUsedEntryIsRetainedWhenCapacityIsReached() {
		MapRetryContextCache cache = new MapRetryContextCache(2);
		cache.put("A", new RetryContextSupport(null));
		cache.put("B", new RetryContextSupport(null));

		cache.get("A");

		assertThatCode(() -> cache.put("C", new RetryContextSupport(null))).doesNotThrowAnyException();
		assertThat(cache.containsKey("A")).isTrue();
		assertThat(cache.containsKey("B")).isFalse();
		assertThat(cache.containsKey("C")).isTrue();
	}

}
