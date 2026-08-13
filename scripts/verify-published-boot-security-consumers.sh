#!/usr/bin/env bash

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRADLE_BIN="${GRADLE_BIN:-${ROOT_DIR}/gradlew}"
CONSUMER_DIR="${ROOT_DIR}/tests/spring-security-adoption/consumers"
CANDIDATE_REPOSITORY="${CANDIDATE_REPOSITORY:-${ROOT_DIR}/build/spring-security-adoption/repository}"
EVIDENCE_DIR="${EVIDENCE_DIR:-${ROOT_DIR}/build/spring-security-adoption/evidence}"
MAVEN_LOCAL_REPOSITORY="${MAVEN_LOCAL_REPOSITORY:-${ROOT_DIR}/build/spring-security-adoption/maven-local}"
GRADLE_USER_HOME="${GRADLE_USER_HOME:-${ROOT_DIR}/build/spring-security-adoption/gradle-home}"
BOOT_VERSION="${BOOT_VERSION:-2.7.18-nes.patch.2-SNAPSHOT}"
SECURITY_VERSION="${SECURITY_VERSION:-5.8.16-nes.patch.2-SNAPSHOT}"
NEXUS_PUBLIC_URL="${NEXUS_PUBLIC_URL:-http://192.168.131.36:8088/repository/maven-public/}"
NEXUS_SNAPSHOT_URL="${NEXUS_SNAPSHOT_URL:-http://192.168.131.36:8088/repository/snapshots/}"
NEXUS_USERNAME="${NEXUS_USERNAME:-}"
NEXUS_PASSWORD="${NEXUS_PASSWORD:-}"
MODE="${1:-all}"

FAILURES=0
GRADLE_RESOURCE_ARGS=(
	--no-daemon
	--no-parallel
	--max-workers=1
	-Dorg.gradle.jvmargs=-Xmx1536m\ -XX:MaxMetaspaceSize=512m\ -Dfile.encoding=UTF-8
	-PnexusPublicUrl="${NEXUS_PUBLIC_URL}"
	-PnexusSnapshotUrl="${NEXUS_SNAPSHOT_URL}"
	-PnexusUsername="${NEXUS_USERNAME}"
	-PnexusPassword="${NEXUS_PASSWORD}"
)

pass() {
	printf 'PASS: %s\n' "$1"
}

fail() {
	printf 'FAIL: %s\n' "$1" >&2
	FAILURES=$((FAILURES + 1))
}

require_file() {
	local file="$1"
	local description="$2"

	if [[ -f "${file}" ]]; then
		pass "${description}"
	else
		fail "${description}; missing ${file#"${ROOT_DIR}/"}"
		return 1
	fi
}

require_snapshot_pom() {
	local artifact_id="$1"
	local description="$2"
	local artifact_dir="${CANDIDATE_REPOSITORY}/cn/bjca/footstone/bpring/boot/${artifact_id}/${BOOT_VERSION}"

	if [[ -f "${artifact_dir}/maven-metadata.xml" ]] \
		&& find "${artifact_dir}" -maxdepth 1 -type f -name "${artifact_id}-*.pom" -print -quit | grep -q .; then
		pass "${description}"
	else
		fail "${description}; missing SNAPSHOT metadata or timestamped POM below ${artifact_dir#"${ROOT_DIR}/"}"
		return 1
	fi
}

require_java8() {
	local java_output

	if [[ -z "${JAVA_HOME:-}" || ! -x "${JAVA_HOME}/bin/java" ]]; then
		fail "JAVA_HOME must point to the real Java 8 runtime"
		return 1
	fi
	java_output="$("${JAVA_HOME}/bin/java" -XshowSettings:properties -version 2>&1)"
	if printf '%s\n' "${java_output}" | grep -Eq 'java\.specification\.version = 1\.8$'; then
		pass "JAVA_HOME selects Java 8"
	else
		printf '%s\n' "${java_output}" >&2
		fail "JAVA_HOME does not select Java 8"
		return 1
	fi
	printf '%s\n' "${java_output}" >"${EVIDENCE_DIR}/java-version.txt"
}

run_gradle() {
	GRADLE_USER_HOME="${GRADLE_USER_HOME}" "${GRADLE_BIN}" "${GRADLE_RESOURCE_ARGS[@]}" "$@" --console=plain
}

validate_candidate_repository_path() {
	case "${CANDIDATE_REPOSITORY}" in
		"${ROOT_DIR}"/build/spring-security-adoption/*)
			return 0
			;;
		*)
			fail "candidate repository must remain below build/spring-security-adoption: ${CANDIDATE_REPOSITORY}"
			return 1
			;;
	esac
}

publish_candidate() {
	local project_dir project_name artifact_id repository_dir artifact_dir metadata_file snapshot_timestamp snapshot_build_number
	local projects=(
		"spring-boot-project/spring-boot-dependencies"
		"spring-boot-project/spring-boot"
		"spring-boot-project/spring-boot-autoconfigure"
		"spring-boot-project/spring-boot-starters/spring-boot-starter"
		"spring-boot-project/spring-boot-starters/spring-boot-starter-logging"
		"spring-boot-project/spring-boot-starters/spring-boot-starter-security"
		"spring-boot-project/spring-boot-starters/spring-boot-starter-oauth2-resource-server"
	)
	local tasks=()

	printf '\nPublishing the Boot candidate into an isolated Maven repository\n'
	if ! validate_candidate_repository_path; then
		return
	fi
	rm -rf -- "${CANDIDATE_REPOSITORY}"
	mkdir -p "${CANDIDATE_REPOSITORY}"
	for project_dir in "${projects[@]}"; do
		tasks+=(":${project_dir//\//:}:publishMavenPublicationToProjectRepository")
	done
	if ! run_gradle "${tasks[@]}"; then
		fail "Boot candidate publication tasks failed"
		return
	fi
	for project_dir in "${projects[@]}"; do
		repository_dir="${ROOT_DIR}/${project_dir}/build/maven-repository"
		if [[ ! -d "${repository_dir}" ]]; then
			fail "project publication repository is missing: ${repository_dir#"${ROOT_DIR}/"}"
			continue
		fi
		cp -R "${repository_dir}/." "${CANDIDATE_REPOSITORY}/"
	done
	mkdir -p "${EVIDENCE_DIR}"
	find "${CANDIDATE_REPOSITORY}" -type f -print | sort >"${EVIDENCE_DIR}/candidate-repository-files.txt"
	printf 'candidate.boot.version=%s\ncandidate.security.version=%s\n' \
		"${BOOT_VERSION}" "${SECURITY_VERSION}" >"${EVIDENCE_DIR}/candidate-versions.txt"
	: >"${EVIDENCE_DIR}/candidate-publication-metadata.txt"
	for project_dir in "${projects[@]}"; do
		project_name="${project_dir##*/}"
		artifact_id="${project_name/spring/bjca-footstone-bpring}"
		artifact_dir="${CANDIDATE_REPOSITORY}/cn/bjca/footstone/bpring/boot/${artifact_id}/${BOOT_VERSION}"
		metadata_file="${artifact_dir}/maven-metadata.xml"
		if [[ ! -f "${metadata_file}" ]]; then
			fail "publication metadata is missing for ${project_dir}"
			continue
		fi
		snapshot_timestamp="$(sed -n 's:.*<timestamp>\([^<]*\)</timestamp>.*:\1:p' "${metadata_file}" | head -1)"
		snapshot_build_number="$(sed -n 's:.*<buildNumber>\([^<]*\)</buildNumber>.*:\1:p' "${metadata_file}" | head -1)"
		printf '%s timestamp=%s buildNumber=%s\n' "${project_dir}" "${snapshot_timestamp}" "${snapshot_build_number}" >>"${EVIDENCE_DIR}/candidate-publication-metadata.txt"
		if [[ -z "${snapshot_timestamp}" || -z "${snapshot_build_number}" ]]; then
			fail "publication metadata has no timestamp/build number for ${project_dir}"
		fi
	done
	pass "isolated candidate repository inventory was written"

	for project_dir in "${projects[@]}"; do
		project_name="${project_dir##*/}"
		artifact_id="${project_name/spring/bjca-footstone-bpring}"
		require_snapshot_pom "${artifact_id}" "isolated repository contains the ${project_name} POM" || true
	done
}

run_maven_consumer() {
	local pom="${CONSUMER_DIR}/maven/pom.xml"
	local repository_url="file://${CANDIDATE_REPOSITORY}"
	local maven_args=(
		--batch-mode
		--update-snapshots
		--settings "${CONSUMER_DIR}/maven/settings.xml"
		-f "${pom}"
		-Dmaven.repo.local="${MAVEN_LOCAL_REPOSITORY}"
		-Dboot.repository.url="${repository_url}"
	)

	printf '\nRunning the independent Maven consumer\n'
	mkdir -p "${EVIDENCE_DIR}" "${MAVEN_LOCAL_REPOSITORY}"
	if ! require_java8; then
		return
	fi
	if ! require_snapshot_pom "bjca-footstone-bpring-boot-dependencies" \
		"Maven consumer sees the isolated Boot BOM"; then
		return
	fi
	if ! MAVEN_OPTS="-Xmx384m -XX:MaxMetaspaceSize=192m" mvn "${maven_args[@]}" \
		-DskipTests dependency:tree -Dverbose \
		-DoutputFile="${EVIDENCE_DIR}/maven-dependency-tree.txt"; then
		fail "Maven consumer dependency tree failed"
		return
	fi
	if ! MAVEN_OPTS="-Xmx384m -XX:MaxMetaspaceSize=192m" mvn "${maven_args[@]}" \
		-DskipTests dependency:build-classpath \
		-Dmdep.outputFile="${EVIDENCE_DIR}/maven-classpath.txt"; then
		fail "Maven consumer classpath generation failed"
		return
	fi
	if MAVEN_OPTS="-Xmx384m -XX:MaxMetaspaceSize=192m" mvn "${maven_args[@]}" compile -DskipTests; then
		local classpath
		classpath="$(tr -d '\r\n' <"${EVIDENCE_DIR}/maven-classpath.txt")"
		if "${JAVA_HOME}/bin/java" -cp "${CONSUMER_DIR}/maven/target/classes:${classpath}" \
			org.springframework.boot.tests.security.PublishedBootSecuritySmoke \
			>"${EVIDENCE_DIR}/maven-smoke.txt"; then
			pass "Maven Java 8 published-consumer smoke passed"
		else
			fail "Maven Java 8 published-consumer smoke failed"
		fi
	else
		fail "Maven Java 8 published-consumer compile failed"
	fi
}

run_gradle_consumer() {
	local consumer="${CONSUMER_DIR}/gradle"
	local repository_url="file://${CANDIDATE_REPOSITORY}"

	printf '\nRunning the independent Gradle consumer\n'
	mkdir -p "${EVIDENCE_DIR}" "${GRADLE_USER_HOME}"
	if ! require_java8; then
		return
	fi
	if ! require_snapshot_pom "bjca-footstone-bpring-boot-dependencies" \
		"Gradle consumer sees the isolated Boot platform"; then
		return
	fi
	if ! run_gradle -p "${consumer}" --refresh-dependencies \
		-PbootVersion="${BOOT_VERSION}" -PbootRepository="${repository_url}" \
		dependencies --configuration runtimeClasspath >"${EVIDENCE_DIR}/gradle-dependency-tree.txt"; then
		fail "Gradle consumer dependency tree failed"
		return
	fi
	if ! run_gradle -p "${consumer}" \
		-PbootVersion="${BOOT_VERSION}" -PbootRepository="${repository_url}" \
		-PruntimeArtifactsFile="${EVIDENCE_DIR}/gradle-runtime-artifacts.txt" \
		writeRuntimeArtifacts; then
		fail "Gradle consumer artifact inventory failed"
		return
	fi
	if run_gradle -p "${consumer}" \
		-PbootVersion="${BOOT_VERSION}" -PbootRepository="${repository_url}" run; then
		pass "Gradle Java 8 published-consumer smoke passed"
	else
		fail "Gradle Java 8 published-consumer smoke failed"
	fi
}

assert_graph() {
	local report="$1"
	local label="$2"

	if ! require_file "${report}" "${label} dependency report exists"; then
		return
	fi
	if grep -Eq 'org\.springframework\.security:spring-security-' "${report}"; then
		fail "${label} graph contains an official Spring Security coordinate"
	else
		pass "${label} graph contains no official Spring Security coordinate"
	fi
	if grep -Eq 'cn\.bjca\.footstone\.bpring\.security:bjca-footstone-bpring-security-[^ :]*:.*5\.8\.16-nes\.patch\.1' "${report}"; then
		fail "${label} graph contains patch.1 core Spring Security"
	else
		pass "${label} graph contains no patch.1 core Spring Security"
	fi
	if grep -Eq "cn\.bjca\.footstone\.bpring\.security:bjca-footstone-bpring-security-[^ :]*:.*${SECURITY_VERSION}" "${report}"; then
		pass "${label} graph selects ${SECURITY_VERSION} NES Security"
	else
		fail "${label} graph does not show ${SECURITY_VERSION} NES Security"
	fi
	if grep -Eq 'cn\.bjca\.footstone\.bpring\.security:bjca-footstone-bpring-security-saml2-service-provider:.*5\.8\.16-nes\.patch\.2' "${report}"; then
		pass "${label} graph includes the patch.2 SAML path"
	else
		fail "${label} graph is missing the patch.2 SAML path"
	fi
	if grep -Eq 'org\.bouncycastle:bcprov-jdk18on:.*1\.84' "${report}"; then
		pass "${label} graph includes bcprov-jdk18on 1.84"
	else
		fail "${label} graph is missing bcprov-jdk18on 1.84"
	fi
	if grep -Eq 'org\.bouncycastle:bcpkix-jdk18on:.*1\.84' "${report}" \
		&& grep -Eq 'org\.bouncycastle:bcutil-jdk18on:.*1\.84' "${report}"; then
		pass "${label} graph includes the complete jdk18on 1.84 family"
	else
		fail "${label} graph is missing bcpkix-jdk18on or bcutil-jdk18on 1.84"
	fi
	if grep -Eq 'org\.bouncycastle:bcprov-jdk15on:' "${report}"; then
		fail "${label} graph still contains bcprov-jdk15on"
	else
		pass "${label} graph contains no bcprov-jdk15on"
	fi
	if grep -Eq 'com\.sendgrid:sendgrid-java:.*4\.10\.1' "${report}"; then
		pass "${label} graph selects SendGrid 4.10.1"
	else
		fail "${label} graph does not select SendGrid 4.10.1"
	fi
}

compare_graphs() {
	printf '\nComparing independent Maven and Gradle graphs\n'
	assert_graph "${EVIDENCE_DIR}/maven-dependency-tree.txt" "Maven"
	assert_graph "${EVIDENCE_DIR}/gradle-dependency-tree.txt" "Gradle"
}

check_class_major() {
	local classpath="$1"
	local class_name="$2"
	local label="$3"
	local major

	major="$("${JAVA_HOME}/bin/javap" -classpath "${classpath}" -verbose "${class_name}" 2>/dev/null \
		| awk '/major version:/ { print $3; exit }')"
	if [[ -n "${major}" && "${major}" -le 52 ]]; then
		pass "${label} class major is ${major}"
	else
		fail "${label} class major is ${major:-unavailable}; expected <= 52"
	fi
}

audit_class_major_and_hashes() {
	local classpath_file="${EVIDENCE_DIR}/maven-classpath.txt"
	local classpath jar
	local classes=(
		"org.springframework.boot.SpringApplication|Boot"
		"org.springframework.security.authentication.UsernamePasswordAuthenticationToken|Security core"
		"org.springframework.security.oauth2.server.resource.web.authentication.BearerTokenAuthenticationFilter|OAuth2 resource server"
		"org.springframework.security.saml2.provider.service.authentication.OpenSamlAuthenticationProvider|Security SAML"
		"org.springframework.security.crypto.encrypt.Encryptors|Security Crypto"
		"org.bouncycastle.jce.provider.BouncyCastleProvider|Bouncy Castle provider"
	)
	local entry class_name label

	printf '\nAuditing Java 8 class major and representative artifact hashes\n'
	mkdir -p "${EVIDENCE_DIR}"
	if ! require_java8; then
		return
	fi
	if ! require_file "${classpath_file}" "Maven consumer classpath exists"; then
		return
	fi
	classpath="$(tr -d '\r\n' <"${classpath_file}")"
	for entry in "${classes[@]}"; do
		class_name="${entry%%|*}"
		label="${entry#*|}"
		check_class_major "${classpath}" "${class_name}" "${label}"
	done

	: >"${EVIDENCE_DIR}/artifact-sha256.txt"
	for jar in ${classpath//:/ }; do
		case "$(basename "${jar}")" in
			bjca-footstone-bpring-boot-[0-9]*.jar|\
			bjca-footstone-bpring-security-core-*.jar|\
			bjca-footstone-bpring-security-oauth2-resource-server-*.jar|\
			bjca-footstone-bpring-security-saml2-service-provider-*.jar|\
			bjca-footstone-bpring-security-crypto-*.jar|\
			bcprov-jdk18on-*.jar)
				shasum -a 256 "${jar}" >>"${EVIDENCE_DIR}/artifact-sha256.txt"
				;;
		esac
	done
	if [[ -s "${EVIDENCE_DIR}/artifact-sha256.txt" ]]; then
		pass "representative artifact SHA-256 evidence was written"
	else
		fail "no representative artifact SHA-256 evidence was written"
	fi
	date '+verification.timestamp=%Y-%m-%dT%H:%M:%S%z' >"${EVIDENCE_DIR}/verification-timestamp.txt"
	find "${MAVEN_LOCAL_REPOSITORY}/cn/bjca/footstone/bpring/security" -name 'maven-metadata-*.xml' -type f \
		-print -exec grep -E '<timestamp>|<buildNumber>|5\.8\.16-nes\.patch\.2-[0-9]{8}\.[0-9]{6}-[0-9]+' {} \; \
		>"${EVIDENCE_DIR}/security-snapshot-metadata.txt" 2>/dev/null || true
	if [[ -s "${EVIDENCE_DIR}/security-snapshot-metadata.txt" ]]; then
		pass "resolved Security SNAPSHOT metadata was recorded"
	else
		fail "resolved Security SNAPSHOT timestamp/build metadata is missing"
	fi
}

case "${MODE}" in
	publish)
		publish_candidate
		;;
	maven)
		run_maven_consumer
		;;
	gradle)
		run_gradle_consumer
		;;
	compare)
		compare_graphs
		;;
	bytecode)
		audit_class_major_and_hashes
		;;
	all)
		publish_candidate
		run_maven_consumer
		run_gradle_consumer
		compare_graphs
		audit_class_major_and_hashes
		;;
	*)
		printf 'Usage: %s {publish|maven|gradle|compare|bytecode|all}\n' "${0#"${ROOT_DIR}/"}" >&2
		exit 2
		;;
esac

if [[ "${FAILURES}" -ne 0 ]]; then
	printf '\nPublished Boot Security consumer verification failed with %d assertion(s).\n' "${FAILURES}" >&2
	exit 1
fi

printf '\nPublished Boot Security consumer verification passed.\n'
