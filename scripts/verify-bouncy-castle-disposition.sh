#!/usr/bin/env bash

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_DIR="${ROOT_DIR}/tests/spring-security-adoption/bouncy-castle"
EVIDENCE_DIR="${EVIDENCE_DIR:-${ROOT_DIR}/build/spring-security-adoption/bouncy-castle-evidence}"
MAVEN_LOCAL_REPOSITORY="${MAVEN_LOCAL_REPOSITORY:-${ROOT_DIR}/build/spring-security-adoption/bouncy-castle-maven-local}"
GRADLE_USER_HOME="${GRADLE_USER_HOME:-${ROOT_DIR}/build/spring-security-adoption/bouncy-castle-gradle-home}"
GRADLE_BIN="${GRADLE_BIN:-${ROOT_DIR}/gradlew}"
SENDGRID_VERSION="${SENDGRID_VERSION:-4.10.1}"

FAILURES=0

pass() {
	printf 'PASS: %s\n' "$1"
}

fail() {
	printf 'FAIL: %s\n' "$1" >&2
	FAILURES=$((FAILURES + 1))
}

require_java8() {
	local version

	if [[ -z "${JAVA_HOME:-}" || ! -x "${JAVA_HOME}/bin/java" ]]; then
		fail "JAVA_HOME must point to Java 8"
		return 1
	fi
	version="$("${JAVA_HOME}/bin/java" -version 2>&1)"
	if printf '%s\n' "${version}" | grep -Eq 'version "1\.8\.0_'; then
		pass "JAVA_HOME selects Java 8"
		printf '%s\n' "${version}" >"${EVIDENCE_DIR}/java-version.txt"
	else
		fail "JAVA_HOME does not select Java 8"
		return 1
	fi
}

assert_maven_graph() {
	local report="${EVIDENCE_DIR}/maven-bouncy-castle-tree.txt"
	local expected artifact
	local artifacts=(
		"org.bouncycastle:bcpkix-jdk18on:jar:1.84"
		"org.bouncycastle:bcprov-jdk18on:jar:1.84"
		"org.bouncycastle:bcutil-jdk18on:jar:1.84"
	)

	if grep -Eq 'org\.bouncycastle:.*jdk15on' "${report}"; then
		fail "Maven graph contains a legacy jdk15on artifact"
	else
		pass "Maven graph contains no jdk15on artifact"
	fi
	if grep -Fq -- "com.sendgrid:sendgrid-java:jar:${SENDGRID_VERSION}" "${report}"; then
		pass "Maven graph selects SendGrid ${SENDGRID_VERSION}"
	else
		fail "Maven graph does not select SendGrid ${SENDGRID_VERSION}"
	fi
	for artifact in "${artifacts[@]}"; do
		expected="${artifact}"
		if grep -Fq -- "${expected}" "${report}"; then
			pass "Maven graph contains ${expected}"
		else
			fail "Maven graph is missing ${expected}"
		fi
	done
}

run_maven() {
	local pom="${FIXTURE_DIR}/maven/pom.xml"
	local args=(
		--batch-mode
		--update-snapshots
		-f "${pom}"
		-Dmaven.repo.local="${MAVEN_LOCAL_REPOSITORY}"
		-Dsendgrid.version="${SENDGRID_VERSION}"
	)

	printf '\nVerifying the Maven Bouncy Castle disposition\n'
	mkdir -p "${EVIDENCE_DIR}" "${MAVEN_LOCAL_REPOSITORY}"
	if ! require_java8; then
		return
	fi
	if ! MAVEN_OPTS="-Xmx384m -XX:MaxMetaspaceSize=192m" mvn "${args[@]}" \
		-DskipTests dependency:tree \
		-DoutputFile="${EVIDENCE_DIR}/maven-bouncy-castle-tree.txt"; then
		fail "Maven Bouncy Castle dependency tree failed"
		return
	fi
	assert_maven_graph
	if MAVEN_OPTS="-Xmx384m -XX:MaxMetaspaceSize=192m" mvn "${args[@]}" \
		-Dexpected.bc.artifact=bcprov-jdk18on compile exec:java; then
		pass "Maven Java 8 SendGrid/Security smoke passed"
	else
		fail "Maven Java 8 SendGrid/Security smoke failed"
	fi
}

run_gradle() {
	printf '\nVerifying the Gradle Bouncy Castle disposition\n'
	mkdir -p "${EVIDENCE_DIR}" "${GRADLE_USER_HOME}"
	if ! require_java8; then
		return
	fi
	if GRADLE_USER_HOME="${GRADLE_USER_HOME}" "${GRADLE_BIN}" \
		--no-daemon --no-parallel --max-workers=1 \
		-Dorg.gradle.jvmargs="-Xmx1536m -XX:MaxMetaspaceSize=384m -Dfile.encoding=UTF-8" \
		-p "${FIXTURE_DIR}/gradle" \
		-PsendGridVersion="${SENDGRID_VERSION}" \
		assertBouncyCastleGraph --console=plain \
		>"${EVIDENCE_DIR}/gradle-bouncy-castle-tree.txt"; then
		pass "Gradle graph contains only the approved jdk18on 1.84 family"
	else
		fail "Gradle Bouncy Castle graph assertion failed"
		return
	fi
	if GRADLE_USER_HOME="${GRADLE_USER_HOME}" "${GRADLE_BIN}" \
		--no-daemon --no-parallel --max-workers=1 \
		-Dorg.gradle.jvmargs="-Xmx1536m -XX:MaxMetaspaceSize=384m -Dfile.encoding=UTF-8" \
		-p "${FIXTURE_DIR}/gradle" \
		-PsendGridVersion="${SENDGRID_VERSION}" \
		-PexpectedBcArtifact=bcprov-jdk18on \
		run --console=plain; then
		pass "Gradle Java 8 SendGrid/Security smoke passed"
	else
		fail "Gradle Java 8 SendGrid/Security smoke failed"
	fi
}

mkdir -p "${EVIDENCE_DIR}"
printf 'sendgrid.version=%s\n' "${SENDGRID_VERSION}" >"${EVIDENCE_DIR}/selected-versions.txt"
run_maven
run_gradle

if [[ "${FAILURES}" -ne 0 ]]; then
	printf '\nBouncy Castle disposition verification failed with %d assertion(s).\n' "${FAILURES}" >&2
	exit 1
fi

printf '\nBouncy Castle disposition verification passed.\n'
