package org.springframework.boot.tests.security;

import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.Security;
import java.util.Arrays;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import com.sendgrid.SendGrid;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.opensaml.core.config.InitializationService;

import org.springframework.boot.SpringApplication;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.encrypt.TextEncryptor;
import org.springframework.security.crypto.encrypt.Encryptors;
import org.springframework.security.oauth2.server.resource.web.authentication.BearerTokenAuthenticationFilter;
import org.springframework.security.saml2.provider.service.authentication.OpenSamlAuthenticationProvider;

public final class PublishedBootSecuritySmoke {

	private PublishedBootSecuritySmoke() {
	}

	public static void main(String[] args) throws Exception {
		requireJava8();
		requireArtifact(SpringApplication.class, "bjca-footstone-bpring-boot");
		requireArtifact(UsernamePasswordAuthenticationToken.class, "bjca-footstone-bpring-security-core");
		requireArtifact(BearerTokenAuthenticationFilter.class,
				"bjca-footstone-bpring-security-oauth2-resource-server");
		requireArtifact(OpenSamlAuthenticationProvider.class,
				"bjca-footstone-bpring-security-saml2-service-provider");
		requireArtifact(Encryptors.class, "bjca-footstone-bpring-security-crypto");
		requireArtifact(SendGrid.class, "sendgrid-java");
		require(new SendGrid("published-boot-security", false) != null,
				"SendGrid client was not constructed");

		AuthenticationManager authenticationManager = (authentication) -> authentication;
		BearerTokenAuthenticationFilter filter = new BearerTokenAuthenticationFilter(authenticationManager);
		require(filter != null, "OAuth2 resource-server filter was not constructed");

		InitializationService.initialize();
		OpenSamlAuthenticationProvider provider = new OpenSamlAuthenticationProvider();
		require(provider != null, "OpenSAML authentication provider was not constructed");

		TextEncryptor encryptor = Encryptors.text("published-boot-security", "5c0744940b5c369b");
		String encrypted = encryptor.encrypt("java-8-security-smoke");
		require("java-8-security-smoke".equals(encryptor.decrypt(encrypted)),
				"Spring Security Crypto round trip failed");

		BouncyCastleProvider bouncyCastle = new BouncyCastleProvider();
		Security.addProvider(bouncyCastle);
		requireArtifact(BouncyCastleProvider.class, "bcprov-jdk18on");
		byte[] key = new byte[16];
		byte[] iv = new byte[12];
		Arrays.fill(key, (byte) 0x2a);
		Arrays.fill(iv, (byte) 0x17);
		Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding", bouncyCastle);
		cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(key, "AES"), new GCMParameterSpec(128, iv));
		byte[] plaintext = "published-boot-security".getBytes(StandardCharsets.UTF_8);
		byte[] ciphertext = cipher.doFinal(plaintext);
		cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(key, "AES"), new GCMParameterSpec(128, iv));
		require(Arrays.equals(plaintext, cipher.doFinal(ciphertext)), "Bouncy Castle AES-GCM round trip failed");

		System.out.println("java.runtime=" + System.getProperty("java.runtime.version"));
		System.out.println("boot.source=" + codeSource(SpringApplication.class));
		System.out.println("security.source=" + codeSource(UsernamePasswordAuthenticationToken.class));
		System.out.println("oauth2.source=" + codeSource(BearerTokenAuthenticationFilter.class));
		System.out.println("saml.source=" + codeSource(OpenSamlAuthenticationProvider.class));
		System.out.println("bc.source=" + codeSource(BouncyCastleProvider.class));
		System.out.println("sendgrid.source=" + codeSource(SendGrid.class));
		System.out.println("published.boot.security.smoke=true");
	}

	private static void requireJava8() {
		require("1.8".equals(System.getProperty("java.specification.version")),
				"Expected Java 8 but found " + System.getProperty("java.runtime.version"));
	}

	private static void requireArtifact(Class<?> type, String artifactName) {
		String source = codeSource(type);
		require(source.contains(artifactName), type.getName() + " was loaded from unexpected source " + source);
	}

	private static String codeSource(Class<?> type) {
		URL location = type.getProtectionDomain().getCodeSource().getLocation();
		return location.toExternalForm();
	}

	private static void require(boolean condition, String message) {
		if (!condition) {
			throw new IllegalStateException(message);
		}
	}

}
