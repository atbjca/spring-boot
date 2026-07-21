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

package org.springframework.boot.system;

import java.io.File;
import java.io.IOException;
import java.nio.file.FileSystem;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.PosixFileAttributeView;
import java.nio.file.attribute.PosixFilePermission;
import java.nio.file.attribute.PosixFilePermissions;
import java.nio.file.attribute.UserPrincipal;
import java.util.Set;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import org.springframework.util.FileSystemUtils;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatIllegalStateException;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

/**
 * Tests for {@link ApplicationTemp}.
 *
 * @author Phillip Webb
 */
class ApplicationTempTests {

	@TempDir
	Path tempDirectory;

	@BeforeEach
	@AfterEach
	void cleanup() {
		FileSystemUtils.deleteRecursively(new ApplicationTemp().getDir());
	}

	@Test
	void generatesConsistentTemp() {
		ApplicationTemp t1 = new ApplicationTemp();
		ApplicationTemp t2 = new ApplicationTemp();
		assertThat(t1.getDir()).isNotNull();
		assertThat(t1.getDir()).isEqualTo(t2.getDir());
	}

	@Test
	void differentBasedOnUserDir() {
		String userDir = System.getProperty("user.dir");
		try {
			File t1 = new ApplicationTemp().getDir();
			System.setProperty("user.dir", "abc");
			File t2 = new ApplicationTemp().getDir();
			assertThat(t1).isNotEqualTo(t2);
		}
		finally {
			System.setProperty("user.dir", userDir);
		}
	}

	@Test
	void getSubDir() {
		ApplicationTemp temp = new ApplicationTemp();
		assertThat(temp.getDir("abc")).isEqualTo(new File(temp.getDir(), "abc"));
	}

	@Test
	void posixPermissions() throws IOException {
		ApplicationTemp temp = new ApplicationTemp();
		Path path = temp.getDir().toPath();
		FileSystem fileSystem = path.getFileSystem();
		if (fileSystem.supportedFileAttributeViews().contains("posix")) {
			assertDirectoryPermissions(path);
			assertDirectoryPermissions(temp.getDir("sub").toPath());
		}
	}

	@Test
	void existingSecureDirectoryIsReused() throws Exception {
		withTempDirectory(() -> {
			File directory = new ApplicationTemp().getDir();
			assertThat(new ApplicationTemp().getDir()).isEqualTo(directory);
		});
	}

	@Test
	void existingFileIsRejected() throws Exception {
		withTempDirectory(() -> {
			Path path = new ApplicationTemp().getDir().toPath();
			Files.delete(path);
			Files.createFile(path);
			assertThatIllegalStateException().isThrownBy(() -> new ApplicationTemp().getDir())
				.withMessageContaining("is not a directory");
		});
	}

	@Test
	void symbolicLinkIsRejected() throws Exception {
		withTempDirectory(() -> {
			Path path = new ApplicationTemp().getDir().toPath();
			Files.delete(path);
			Path target = Files.createDirectory(this.tempDirectory.resolve("target"));
			try {
				Files.createSymbolicLink(path, target);
			}
			catch (IOException | UnsupportedOperationException ex) {
				assumeTrue(false, "Symbolic links are not supported by this test environment");
			}
			assertThatIllegalStateException().isThrownBy(() -> new ApplicationTemp().getDir())
				.withMessageContaining("is not a directory");
		});
	}

	@Test
	void existingDirectoryWithUnsafePosixPermissionsIsRejected() throws Exception {
		withTempDirectory(() -> {
			Path path = new ApplicationTemp().getDir().toPath();
			assumeTrue(path.getFileSystem().supportedFileAttributeViews().contains("posix"),
					"POSIX file attributes are not supported by this test environment");
			Files.setPosixFilePermissions(path, PosixFilePermissions.fromString("rwxr-xr-x"));
			assertThatIllegalStateException().isThrownBy(() -> new ApplicationTemp().getDir())
				.withMessageContaining("does not have the permissions");
		});
	}

	@Test
	void existingDirectoryWithUnexpectedOwnerIsRejected() throws Exception {
		withTempDirectory(() -> {
			Path path = new ApplicationTemp().getDir().toPath();
			try {
				Files.getOwner(path);
			}
			catch (UnsupportedOperationException ex) {
				assumeTrue(false, "File ownership is not supported by this test environment");
			}
			UserPrincipal unexpectedOwner = () -> "unexpected-owner";
			assertThatIllegalStateException().isThrownBy(() -> new ApplicationTemp(null, unexpectedOwner).getDir())
				.withMessageContaining("is not owned by unexpected-owner");
		});
	}

	private void assertDirectoryPermissions(Path path) throws IOException {
		Set<PosixFilePermission> permissions = Files.getFileAttributeView(path, PosixFileAttributeView.class)
			.readAttributes()
			.permissions();
		assertThat(permissions).containsExactlyInAnyOrder(PosixFilePermission.OWNER_READ,
				PosixFilePermission.OWNER_WRITE, PosixFilePermission.OWNER_EXECUTE);
	}

	private void withTempDirectory(ThrowingRunnable action) throws Exception {
		String previous = System.getProperty("java.io.tmpdir");
		try {
			System.setProperty("java.io.tmpdir", this.tempDirectory.toString());
			action.run();
		}
		finally {
			System.setProperty("java.io.tmpdir", previous);
		}
	}

	@FunctionalInterface
	private interface ThrowingRunnable {

		void run() throws Exception;

	}

}
