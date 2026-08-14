#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="${ROOT_DIR_OVERRIDE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
GRADLE_BIN="${GRADLE_BIN:-${ROOT_DIR}/gradlew}"
CONSUMER_DIR="${ROOT_DIR}/tests/spring-retry-adoption/consumers"
EVIDENCE_DIR="${EVIDENCE_DIR:-${ROOT_DIR}/build/spring-retry-adoption/evidence}"
MAVEN_LOCAL_REPOSITORY="${MAVEN_LOCAL_REPOSITORY:-${ROOT_DIR}/build/spring-retry-adoption/maven-local}"
CONSUMER_GRADLE_USER_HOME="${CONSUMER_GRADLE_USER_HOME:-}"
CONSUMER_GRADLE_PROJECT_CACHE="${CONSUMER_GRADLE_PROJECT_CACHE:-${ROOT_DIR}/build/spring-retry-adoption/gradle-project-cache}"
BOOT_REPOSITORY="${ROOT_DIR}/spring-boot-project/spring-boot-dependencies/build/maven-repository"
BOOT_VERSION="${BOOT_VERSION:-2.7.18-nes.patch.2-SNAPSHOT}"
MODE="${1:-all}"

mkdir -p "${EVIDENCE_DIR}" "${MAVEN_LOCAL_REPOSITORY}" "${CONSUMER_GRADLE_PROJECT_CACHE}"

if [[ -n "${CONSUMER_GRADLE_USER_HOME}" ]]; then
	mkdir -p "${CONSUMER_GRADLE_USER_HOME}"
fi

invoke_gradle() {
	if [[ -n "${CONSUMER_GRADLE_USER_HOME}" ]]; then
		GRADLE_USER_HOME="${CONSUMER_GRADLE_USER_HOME}" "${GRADLE_BIN}" "$@"
	else
		"${GRADLE_BIN}" "$@"
	fi
}

publish_candidate() {
	invoke_gradle --no-daemon \
		:spring-boot-project:spring-boot-dependencies:publishMavenPublicationToProjectRepository
}

run_maven() {
	mvn --batch-mode --update-snapshots \
		--settings "${CONSUMER_DIR}/maven/settings.xml" \
		-f "${CONSUMER_DIR}/maven/pom.xml" \
		-Dmaven.repo.local="${MAVEN_LOCAL_REPOSITORY}" \
		-Dboot.repository.url="file://${BOOT_REPOSITORY}" \
		dependency:tree -Dverbose -DoutputFile="${EVIDENCE_DIR}/maven-dependency-tree.txt"
	mvn --batch-mode \
		--settings "${CONSUMER_DIR}/maven/settings.xml" \
		-f "${CONSUMER_DIR}/maven/pom.xml" \
		-Dmaven.repo.local="${MAVEN_LOCAL_REPOSITORY}" \
		-Dboot.repository.url="file://${BOOT_REPOSITORY}" \
		dependency:build-classpath -Dmdep.outputFile="${EVIDENCE_DIR}/maven-classpath.txt"
}

run_gradle() {
	local gradle_args=(
		--no-daemon
		-p "${CONSUMER_DIR}/gradle"
		--project-cache-dir "${CONSUMER_GRADLE_PROJECT_CACHE}"
		--refresh-dependencies
		-PbootVersion="${BOOT_VERSION}"
		-PbootRepository="file://${BOOT_REPOSITORY}"
		verifyRuntimeArtifacts
	)
	invoke_gradle "${gradle_args[@]}" >"${EVIDENCE_DIR}/gradle-runtime-artifacts.txt"
}

verify_graphs() {
	local classpath class_owners jar report retry_count
	for report in "${EVIDENCE_DIR}/maven-dependency-tree.txt" "${EVIDENCE_DIR}/gradle-runtime-artifacts.txt"; do
		if [[ ! -f "${report}" ]]; then
			printf 'Missing dependency evidence: %s\n' "${report}" >&2
			return 1
		fi
		if grep -Eq 'org\.springframework\.retry:spring-retry:[^ ].*(compile|runtime|$)' "${report}"; then
			printf 'Official Spring Retry leaked into %s\n' "${report}" >&2
			return 1
		fi
		retry_count="$(grep -Ec 'cn\.bjca\.footstone\.bpring\.retry:bjca-footstone-bpring-retry:.*1\.3\.4-nes\.patch\.1' "${report}")"
		if [[ "${retry_count}" -lt 1 ]]; then
			printf 'NES Spring Retry is missing from %s\n' "${report}" >&2
			return 1
		fi
		grep -Eq 'cn\.bjca\.footstone\.bpring\.kafka:bjca-footstone-bpring-kafka:.*2\.9\.13-nes\.patch\.2' "${report}"
		grep -Eq 'cn\.bjca\.footstone\.bpring\.data:bjca-footstone-bpring-data-commons:.*2\.7\.18-nes\.patch\.1' "${report}"
	done
	classpath="$(tr -d '\r\n' <"${EVIDENCE_DIR}/maven-classpath.txt")"
	class_owners=0
	: >"${EVIDENCE_DIR}/maven-retry-class-owners.txt"
	while IFS= read -r jar; do
		if unzip -l "${jar}" 'org/springframework/retry/RetryContext.class' | grep -q 'RetryContext.class'; then
			printf '%s\n' "${jar}" >>"${EVIDENCE_DIR}/maven-retry-class-owners.txt"
			class_owners=$((class_owners + 1))
		fi
	done < <(printf '%s' "${classpath}" | tr ':' '\n')
	if [[ "${class_owners}" -ne 1 ]]; then
		printf 'Expected one Maven RetryContext.class owner, found %s\n' "${class_owners}" >&2
		return 1
	fi
}

case "${MODE}" in
	publish)
		publish_candidate
		;;
	maven)
		run_maven
		;;
	gradle)
		run_gradle
		;;
	verify)
		verify_graphs
		;;
	all)
		publish_candidate && run_maven && run_gradle && verify_graphs
		;;
	*)
		printf 'Usage: %s [publish|maven|gradle|verify|all]\n' "$0" >&2
		exit 2
		;;
esac
