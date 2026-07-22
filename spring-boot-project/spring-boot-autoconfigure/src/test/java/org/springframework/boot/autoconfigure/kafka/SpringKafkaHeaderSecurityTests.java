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

package org.springframework.boot.autoconfigure.kafka;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

import org.apache.kafka.common.header.Headers;
import org.apache.kafka.common.header.internals.RecordHeader;
import org.apache.kafka.common.header.internals.RecordHeaders;
import org.junit.jupiter.api.Test;

import org.springframework.kafka.support.DefaultKafkaHeaderMapper;
import org.springframework.kafka.support.DefaultKafkaHeaderMapper.NonTrustedHeaderType;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Tests for the managed Spring Kafka security baseline.
 *
 * @author Libiao
 */
class SpringKafkaHeaderSecurityTests {

	@Test
	void untrustedJdkSubpackageHeaderIsNotDeserialized() {
		Object mapped = mapHeader(new DefaultKafkaHeaderMapper(), "java.util.logging.FileHandler", "not-json");

		assertThat(mapped).isInstanceOf(NonTrustedHeaderType.class);
		NonTrustedHeaderType header = (NonTrustedHeaderType) mapped;
		assertThat(header.getUntrustedType()).isEqualTo("java.util.logging.FileHandler");
		assertThat(header.getHeaderValue()).containsExactly("not-json".getBytes(StandardCharsets.UTF_8));
	}

	@Test
	void exactDefaultPackageHeaderIsDeserialized() {
		Object mapped = mapHeader(new DefaultKafkaHeaderMapper(), HashMap.class.getName(), "{}");

		assertThat(mapped).isInstanceOf(HashMap.class);
	}

	@Test
	void wildcardTrustedPackageStillDeserializesHeader() {
		DefaultKafkaHeaderMapper mapper = new DefaultKafkaHeaderMapper();
		mapper.addTrustedPackages("*");

		Object mapped = mapHeader(mapper, SampleHeader.class.getName(), "{\"value\":\"test\"}");

		assertThat(mapped).isInstanceOf(SampleHeader.class);
		assertThat(((SampleHeader) mapped).getValue()).isEqualTo("test");
	}

	private Object mapHeader(DefaultKafkaHeaderMapper mapper, String type, String json) {
		Headers kafkaHeaders = new RecordHeaders();
		kafkaHeaders.add(new RecordHeader(DefaultKafkaHeaderMapper.JSON_TYPES,
				("{\"test\":\"" + type + "\"}").getBytes(StandardCharsets.UTF_8)));
		kafkaHeaders.add(new RecordHeader("test", json.getBytes(StandardCharsets.UTF_8)));
		Map<String, Object> mappedHeaders = new HashMap<>();
		mapper.toHeaders(kafkaHeaders, mappedHeaders);
		return mappedHeaders.get("test");
	}

	public static class SampleHeader {

		private String value;

		public String getValue() {
			return this.value;
		}

		public void setValue(String value) {
			this.value = value;
		}

	}

}
