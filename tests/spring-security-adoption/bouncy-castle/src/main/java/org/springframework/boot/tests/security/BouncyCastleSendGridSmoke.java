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

package org.springframework.boot.tests.security;

import java.nio.charset.StandardCharsets;
import java.security.Provider;
import java.security.Security;
import java.util.Arrays;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

/**
 * Java 8 smoke for SendGrid and Bouncy Castle, optionally combined with Spring
 * Security SAML/Crypto.
 */
public final class BouncyCastleSendGridSmoke {

	private BouncyCastleSendGridSmoke() {
	}

	public static void main(String[] args) throws Exception {
		boolean includeSecurity = Boolean.parseBoolean(System.getProperty("include.security", "true"));
		verifySendGridApiAndMailPayload();
		Provider provider = verifyBouncyCastleAesGcm();
		if (includeSecurity) {
			verifySpringSecurityCrypto();
			verifyOpenSaml();
		}
		System.out.println("java.version=" + System.getProperty("java.version"));
		System.out.println("sendgrid.version=" + SendGrid.class.getPackage().getImplementationVersion());
		System.out.println("bc.provider=" + provider.getName() + " " + provider.getVersion());
		System.out.println("bc.codeSource=" + provider.getClass().getProtectionDomain().getCodeSource().getLocation());
		System.out.println("security.smoke=" + includeSecurity);
		System.out.println("opensaml.initialized=" + includeSecurity);
	}

	private static void verifySendGridApiAndMailPayload() throws Exception {
		SendGrid sendGrid = new SendGrid("SG.TEST", true);
		assertEquals("Bearer SG.TEST", sendGrid.getRequestHeaders().get("Authorization"),
				"SendGrid Authorization header");
		Mail mail = new Mail(new Email("from@example.com"), "Security smoke", new Email("to@example.com"),
				new Content("text/plain", "ok"));
		String payload = mail.build();
		assertContains(payload, "from@example.com", "SendGrid mail payload sender");
		assertContains(payload, "to@example.com", "SendGrid mail payload recipient");
	}

	private static Provider verifyBouncyCastleAesGcm() throws Exception {
		Provider provider = new BouncyCastleProvider();
		String expectedArtifact = System.getProperty("expected.bc.artifact", "");
		String codeSource = provider.getClass().getProtectionDomain().getCodeSource().getLocation().toString();
		if (!expectedArtifact.isEmpty()) {
			assertContains(codeSource, expectedArtifact, "Bouncy Castle provider code source");
		}
		Security.removeProvider(provider.getName());
		Security.addProvider(provider);
		SecretKeySpec key = new SecretKeySpec("0123456789abcdef".getBytes(StandardCharsets.US_ASCII), "AES");
		GCMParameterSpec parameters = new GCMParameterSpec(128,
				"0123456789ab".getBytes(StandardCharsets.US_ASCII));
		Cipher encrypt = Cipher.getInstance("AES/GCM/NoPadding", provider);
		encrypt.init(Cipher.ENCRYPT_MODE, key, parameters);
		byte[] encrypted = encrypt.doFinal("spring-security".getBytes(StandardCharsets.UTF_8));
		Cipher decrypt = Cipher.getInstance("AES/GCM/NoPadding", provider);
		decrypt.init(Cipher.DECRYPT_MODE, key, parameters);
		byte[] decrypted = decrypt.doFinal(encrypted);
		if (!Arrays.equals("spring-security".getBytes(StandardCharsets.UTF_8), decrypted)) {
			throw new IllegalStateException("Bouncy Castle AES-GCM round trip failed");
		}
		return provider;
	}

	private static void verifySpringSecurityCrypto() throws Exception {
		Class<?> encryptors = Class.forName("org.springframework.security.crypto.encrypt.Encryptors");
		Object encryptor = encryptors.getMethod("text", CharSequence.class, CharSequence.class)
			.invoke(null, "password", "5c0744940b5c369b");
		Class<?> textEncryptor = Class.forName("org.springframework.security.crypto.encrypt.TextEncryptor");
		String encrypted = (String) textEncryptor.getMethod("encrypt", String.class)
			.invoke(encryptor, "security-crypto");
		String decrypted = (String) textEncryptor.getMethod("decrypt", String.class).invoke(encryptor, encrypted);
		assertEquals("security-crypto", decrypted, "Spring Security crypto round trip");
	}

	private static void verifyOpenSaml() throws Exception {
		Class<?> initializationService = Class.forName("org.opensaml.core.config.InitializationService");
		initializationService.getMethod("initialize").invoke(null);
		Class.forName("org.springframework.security.saml2.provider.service.authentication.OpenSamlAuthenticationProvider");
	}

	private static void assertContains(String actual, String expected, String description) {
		if (actual == null || !actual.contains(expected)) {
			throw new IllegalStateException(description + " did not contain '" + expected + "': " + actual);
		}
	}

	private static void assertEquals(String expected, String actual, String description) {
		if (!expected.equals(actual)) {
			throw new IllegalStateException(description + " expected '" + expected + "' but was '" + actual + "'");
		}
	}

}
