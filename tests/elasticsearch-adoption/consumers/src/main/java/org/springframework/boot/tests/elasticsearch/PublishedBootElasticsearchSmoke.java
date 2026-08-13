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

package org.springframework.boot.tests.elasticsearch;

import java.util.ServiceLoader;

import org.elasticsearch.client.RestClientBuilder;

/**
 * Java 8 smoke for published Boot Elasticsearch consumers. Creating this fixture is not a
 * passing consumer result; isolated resolution still has to be run separately.
 */
public final class PublishedBootElasticsearchSmoke {

	private PublishedBootElasticsearchSmoke() {
	}

	public static void main(String[] args) {
		Class<?> restClientBuilder = RestClientBuilder.class;
		if (!"org.elasticsearch.client.RestClientBuilder".equals(restClientBuilder.getName())) {
			throw new IllegalStateException("Unexpected RestClientBuilder class: " + restClientBuilder.getName());
		}
		int javaxProviders = countProviders("javax.json.spi.JsonProvider");
		int jakartaProviders = countProviders("jakarta.json.spi.JsonProvider");
		System.out.println("elasticsearch.package=" + restClientBuilder.getName());
		System.out.println("javax.json.providers=" + javaxProviders);
		System.out.println("jakarta.json.providers=" + jakartaProviders);
	}

	private static int countProviders(String typeName) {
		try {
			Class<?> type = Class.forName(typeName);
			int count = 0;
			for (Object ignored : ServiceLoader.load(type)) {
				count++;
			}
			return count;
		}
		catch (ClassNotFoundException ex) {
			return 0;
		}
	}

}
