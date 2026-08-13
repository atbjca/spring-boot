/*
 * Copyright 2012-present the original author or authors.
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

package org.springframework.boot.logging.log4j2;

import org.apache.logging.log4j.core.LogEvent;
import org.apache.logging.log4j.core.config.DefaultConfiguration;
import org.apache.logging.log4j.core.impl.Log4jLogEvent;
import org.apache.logging.log4j.core.layout.PatternLayout;
import org.apache.logging.log4j.core.pattern.LogEventPatternConverter;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Tests for {@link ExtendedWhitespaceThrowablePatternConverter}.
 *
 * @author Vladimir Tsanev
 * @author Phillip Webb
 */
class ExtendedWhitespaceThrowablePatternConverterTests {

	private final DefaultConfiguration configuration = new DefaultConfiguration();

	private final LogEventPatternConverter converter = ExtendedWhitespaceThrowablePatternConverter
		.newInstance(this.configuration, new String[] {});

	@Test
	void noStackTrace() {
		LogEvent event = Log4jLogEvent.newBuilder().build();
		StringBuilder builder = new StringBuilder();
		this.converter.format(event, builder);
		assertThat(builder).isEmpty();
	}

	@Test
	void withStackTrace() {
		LogEvent event = Log4jLogEvent.newBuilder().setThrown(new Exception()).build();
		assertThat(format(this.converter, event)).startsWith("\n").endsWith("\n");
	}

	@ParameterizedTest
	@ValueSource(strings = { "xwEx", "xwThrowable", "xwException" })
	void aliasesFormatThrowableOnce(String alias) {
		String output = format("%" + alias, eventWithCause());
		assertThat(output).containsOnlyOnce("java.lang.IllegalStateException: failure")
			.containsOnlyOnce("Caused by: java.lang.IllegalArgumentException: cause");
	}

	@Test
	void shortOptionFormatsFirstExtendedStackTraceElementWithoutCause() {
		String output = format(
				ExtendedWhitespaceThrowablePatternConverter.newInstance(this.configuration, new String[] { "short" }),
				eventWithCause());
		assertThat(output).startsWith("\njava.lang.IllegalStateException: failure\n\tat ")
			.contains("~[test/:?]")
			.doesNotContain("Caused by:")
			.endsWith("\n\n");
	}

	@Test
	void fullOptionFormatsExtendedStackTraceAndCause() {
		String output = format(
				ExtendedWhitespaceThrowablePatternConverter.newInstance(this.configuration, new String[] { "full" }),
				eventWithCause());
		assertThat(output).startsWith("\njava.lang.IllegalStateException: failure")
			.contains("~[test/:?]")
			.contains("Caused by: java.lang.IllegalArgumentException: cause")
			.endsWith("\n");
	}

	@Test
	void separatorOptionControlsWhitespaceAndStackTraceSeparators() {
		String output = format(ExtendedWhitespaceThrowablePatternConverter.newInstance(this.configuration,
				new String[] { "full", "separator(|)" }), eventWithCause());
		assertThat(output).startsWith("|java.lang.IllegalStateException: failure|")
			.contains("|Caused by: java.lang.IllegalArgumentException: cause|")
			.endsWith("|");
	}

	@Test
	void handlesThrowable() {
		assertThat(this.converter.handlesThrowable()).isTrue();
	}

	private String format(String pattern, LogEvent event) {
		PatternLayout layout = PatternLayout.newBuilder()
			.withConfiguration(this.configuration)
			.withPattern(pattern)
			.withAlwaysWriteExceptions(false)
			.build();
		return normalizeLineEndings(layout.toSerializable(event));
	}

	private String format(LogEventPatternConverter converter, LogEvent event) {
		StringBuilder builder = new StringBuilder();
		converter.format(event, builder);
		return normalizeLineEndings(builder.toString());
	}

	private LogEvent eventWithCause() {
		return Log4jLogEvent.newBuilder()
			.setThrown(new IllegalStateException("failure", new IllegalArgumentException("cause")))
			.build();
	}

	private String normalizeLineEndings(String value) {
		return value.replace("\r\n", "\n").replace('\r', '\n');
	}

}
