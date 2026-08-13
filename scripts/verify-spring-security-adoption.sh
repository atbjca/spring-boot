#!/usr/bin/env bash

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRADLEW="${GRADLE_BIN:-${ROOT_DIR}/gradlew}"
EXPECTED_SECURITY_VERSION="${EXPECTED_SECURITY_VERSION:-5.8.16-nes.patch.2-SNAPSHOT}"
PREVIOUS_SECURITY_VERSION="5.8.16-nes.patch.1"
NES_SECURITY_GROUP="cn.bjca.footstone.bpring.security"
NES_SECURITY_PREFIX="bjca-footstone-bpring-security-"
MODE="${1:-all}"
SKIP_GENERATION="${SKIP_GENERATION:-0}"
NEXUS_PUBLIC_URL="${NEXUS_PUBLIC_URL:-http://192.168.131.36:8088/repository/maven-public/}"
NEXUS_SNAPSHOT_URL="${NEXUS_SNAPSHOT_URL:-http://192.168.131.36:8088/repository/snapshots/}"
NEXUS_USERNAME="${NEXUS_USERNAME:-}"
NEXUS_PASSWORD="${NEXUS_PASSWORD:-}"

FAILURES=0
TEMP_DIR=""

pass() {
	printf 'PASS: %s\n' "$1"
}

fail() {
	printf 'FAIL: %s\n' "$1" >&2
	FAILURES=$((FAILURES + 1))
}

cleanup() {
	if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" && "${TEMP_DIR}" == "${TMPDIR:-/tmp}/spring-security-adoption."* ]]; then
		rm -rf -- "${TEMP_DIR}"
	fi
}

trap cleanup EXIT

assert_file_contains() {
	local file="$1"
	local expected="$2"
	local description="$3"

	if grep -Fq -- "${expected}" "${file}"; then
		pass "${description}"
	else
		fail "${description}; missing '${expected}' in ${file#"${ROOT_DIR}/"}"
	fi
}

run_gradle() {
	if GRADLE_USER_HOME="${GRADLE_USER_HOME:-${ROOT_DIR}/build/spring-security-adoption/gradle-home}" \
		"${GRADLEW}" --no-daemon --no-parallel --max-workers=1 \
		-Dorg.gradle.jvmargs='-Xmx1536m -XX:MaxMetaspaceSize=512m -Dfile.encoding=UTF-8' \
		-PnexusPublicUrl="${NEXUS_PUBLIC_URL}" \
		-PnexusSnapshotUrl="${NEXUS_SNAPSHOT_URL}" \
		-PnexusUsername="${NEXUS_USERNAME}" \
		-PnexusPassword="${NEXUS_PASSWORD}" \
		"$@" --console=plain; then
		return 0
	fi
	fail "Gradle command failed: ${GRADLEW} $* --console=plain"
	return 1
}

check_source_contract() {
	local properties_file="${ROOT_DIR}/gradle.properties"
	local root_build="${ROOT_DIR}/build.gradle"
	local bom_build="${ROOT_DIR}/spring-boot-project/spring-boot-dependencies/build.gradle"
	local property_count current_version version_locations version_location_count

	printf '\nChecking the single-source Security mapping contract\n'
	property_count="$(awk -F= '$1 == "springSecurityVersion" { count++ } END { print count + 0 }' "${properties_file}")"
	current_version="$(awk -F= '$1 == "springSecurityVersion" { print substr($0, index($0, "=") + 1) }' "${properties_file}")"
	if [[ "${property_count}" == "1" ]]; then
		pass "gradle.properties declares springSecurityVersion exactly once"
	else
		fail "expected one springSecurityVersion declaration, found ${property_count}"
	fi
	if [[ "${current_version}" == "${EXPECTED_SECURITY_VERSION}" ]]; then
		pass "springSecurityVersion selects ${EXPECTED_SECURITY_VERSION}"
	else
		fail "springSecurityVersion is ${current_version:-<missing>}; expected ${EXPECTED_SECURITY_VERSION}"
	fi

	assert_file_contains "${root_build}" \
		"else if (requested.group == 'org.springframework.security' && requested.name.startsWith('spring-security-'))" \
		"official Spring Security requests enter the existing NES mapping rule"
	assert_file_contains "${root_build}" \
		'def newArtifactId = requested.name.replaceFirst(/^spring-security-/, "${forkArtifactPrefix}-security-")' \
		"the mapping derives the NES artifactId from the requested module"
	assert_file_contains "${root_build}" \
		'details.useTarget("${forkGroupIdBase}.security:${newArtifactId}:${springSecurityVersion}")' \
		"the mapping takes its version from springSecurityVersion"
	assert_file_contains "${bom_build}" \
		'library("Spring Security", "${springSecurityVersion}")' \
		"the existing Boot BOM library takes its version from springSecurityVersion"
	assert_file_contains "${bom_build}" \
		'imports = [forkArtifactPrefix + "-security-bom"]' \
		"the existing Boot BOM library imports the NES Security BOM"

	version_locations="$(git -C "${ROOT_DIR}" grep -n -F -- "${EXPECTED_SECURITY_VERSION}" -- '*.gradle' '*.properties' 2>/dev/null || true)"
	version_location_count="$(printf '%s\n' "${version_locations}" | awk 'NF { count++ } END { print count + 0 }')"
	if [[ "${version_location_count}" == "1" && "${version_locations}" == gradle.properties:* ]]; then
		pass "the expected Security build version literal exists only at springSecurityVersion"
	else
		fail "expected the Security build version literal only in gradle.properties; found ${version_location_count}: ${version_locations:-<none>}"
	fi
}

generate_bom_pom() {
	if [[ "${SKIP_GENERATION}" == "1" ]]; then
		return 0
	fi
	run_gradle \
		:spring-boot-project:spring-boot-dependencies:generatePomFileForMavenPublication
}

check_bom_contract() {
	local pom="${ROOT_DIR}/spring-boot-project/spring-boot-dependencies/build/publications/maven/pom-default.xml"
	local security_bom_count bom_project_count

	printf '\nChecking generated Boot dependency-management metadata\n'
	if ! generate_bom_pom; then
		return
	fi
	if [[ ! -f "${pom}" ]]; then
		fail "generated Boot dependency-management POM is missing"
		return
	fi

	assert_file_contains "${pom}" \
		"<spring-security.version>${EXPECTED_SECURITY_VERSION}</spring-security.version>" \
		"the generated BOM property selects ${EXPECTED_SECURITY_VERSION}"
	if grep -Fq -- "<spring-security.version>${PREVIOUS_SECURITY_VERSION}</spring-security.version>" "${pom}"; then
		fail "the generated BOM still exposes the patch.1 Spring Security property"
	else
		pass "the generated BOM does not expose the patch.1 Spring Security property"
	fi

	security_bom_count="$(awk -v artifact="<artifactId>${NES_SECURITY_PREFIX}bom</artifactId>" 'index($0, artifact) { count++ } END { print count + 0 }' "${pom}")"
	if [[ "${security_bom_count}" == "1" ]]; then
		pass "the generated BOM contains exactly one NES Security BOM import"
	else
		fail "expected one NES Security BOM import, found ${security_bom_count}"
	fi

	if awk -v group="${NES_SECURITY_GROUP}" -v artifact="${NES_SECURITY_PREFIX}bom" '
		/<dependency>/ { in_dependency = 1; dependency_group = ""; dependency_artifact = ""; dependency_version = ""; dependency_type = ""; dependency_scope = ""; next }
		in_dependency && dependency_group == "" && /<groupId>/ { value = $0; sub(/^.*<groupId>/, "", value); sub(/<\/groupId>.*$/, "", value); dependency_group = value }
		in_dependency && dependency_artifact == "" && /<artifactId>/ { value = $0; sub(/^.*<artifactId>/, "", value); sub(/<\/artifactId>.*$/, "", value); dependency_artifact = value }
		in_dependency && dependency_version == "" && /<version>/ { value = $0; sub(/^.*<version>/, "", value); sub(/<\/version>.*$/, "", value); dependency_version = value }
		in_dependency && dependency_type == "" && /<type>/ { value = $0; sub(/^.*<type>/, "", value); sub(/<\/type>.*$/, "", value); dependency_type = value }
		in_dependency && dependency_scope == "" && /<scope>/ { value = $0; sub(/^.*<scope>/, "", value); sub(/<\/scope>.*$/, "", value); dependency_scope = value }
		in_dependency && /<\/dependency>/ {
			if (dependency_group == group && dependency_artifact == artifact) {
				found++
				if (dependency_version != "${spring-security.version}" || dependency_type != "pom" || dependency_scope != "import") {
					bad = 1
				}
			}
			in_dependency = 0
		}
		END { exit(found == 1 && !bad ? 0 : 1) }
	' "${pom}"; then
		pass "the NES Security BOM uses pom/import and the single spring-security.version property"
	else
		fail "the NES Security BOM dependency is not the expected pom/import property-driven block"
	fi

	bom_project_count="$(find "${ROOT_DIR}/spring-boot-project" -path '*/spring-boot-dependencies/build.gradle' -type f | awk 'END { print NR + 0 }')"
	if [[ "${bom_project_count}" == "1" ]]; then
		pass "the repository still has one Boot dependency-management project"
	else
		fail "expected one Boot dependency-management project, found ${bom_project_count}"
	fi
}

generate_starter_metadata() {
	if [[ "${SKIP_GENERATION}" == "1" ]]; then
		return 0
	fi
	run_gradle \
		:spring-boot-project:spring-boot-starters:spring-boot-starter-security:generatePomFileForMavenPublication \
		:spring-boot-project:spring-boot-starters:spring-boot-starter-security:generateMetadataFileForMavenPublication \
		:spring-boot-project:spring-boot-starters:spring-boot-starter-oauth2-resource-server:generatePomFileForMavenPublication \
		:spring-boot-project:spring-boot-starters:spring-boot-starter-oauth2-resource-server:generateMetadataFileForMavenPublication
}

check_starter_pom() {
	local pom="$1"
	local label="$2"

	if [[ ! -f "${pom}" ]]; then
		fail "${label} generated Maven POM is missing"
		return
	fi
	if awk -v expected="${EXPECTED_SECURITY_VERSION}" -v group="${NES_SECURITY_GROUP}" -v prefix="${NES_SECURITY_PREFIX}" '
		/<dependency>/ { in_dependency = 1; dependency_group = ""; dependency_artifact = ""; dependency_version = ""; next }
		in_dependency && dependency_group == "" && /<groupId>/ { value = $0; sub(/^.*<groupId>/, "", value); sub(/<\/groupId>.*$/, "", value); dependency_group = value }
		in_dependency && dependency_artifact == "" && /<artifactId>/ { value = $0; sub(/^.*<artifactId>/, "", value); sub(/<\/artifactId>.*$/, "", value); dependency_artifact = value }
		in_dependency && dependency_version == "" && /<version>/ { value = $0; sub(/^.*<version>/, "", value); sub(/<\/version>.*$/, "", value); dependency_version = value }
		in_dependency && /<\/dependency>/ {
			if (dependency_group == "org.springframework.security") {
				bad = 1
			}
			if (dependency_group == group) {
				found++
				if (index(dependency_artifact, prefix) != 1 || dependency_version != expected) {
					bad = 1
				}
			}
			in_dependency = 0
		}
		END { exit(found > 0 && !bad ? 0 : 1) }
	' "${pom}"; then
		pass "${label} Maven POM exposes only ${EXPECTED_SECURITY_VERSION} NES Security dependencies"
	else
		fail "${label} Maven POM contains an official, patch.1, missing, or malformed Security dependency"
	fi
}

check_starter_module_metadata() {
	local metadata="$1"
	local label="$2"

	if [[ ! -f "${metadata}" ]]; then
		fail "${label} generated Gradle Module Metadata is missing"
		return
	fi
	if awk -v expected="${EXPECTED_SECURITY_VERSION}" -v group="${NES_SECURITY_GROUP}" -v prefix="${NES_SECURITY_PREFIX}" '
		/"group":/ {
			value = $0
			sub(/^.*"group": "/, "", value)
			sub(/".*$/, "", value)
			if (value == "org.springframework.security") {
				bad = 1
			}
			pending = (value == group)
			next
		}
		pending && /"module":/ {
			value = $0
			sub(/^.*"module": "/, "", value)
			sub(/".*$/, "", value)
			if (index(value, prefix) != 1) {
				bad = 1
			}
			next
		}
		pending && /"requires":/ {
			value = $0
			sub(/^.*"requires": "/, "", value)
			sub(/".*$/, "", value)
			found++
			if (value != expected) {
				bad = 1
			}
			pending = 0
		}
		END { exit(found > 0 && !bad ? 0 : 1) }
	' "${metadata}"; then
		pass "${label} Gradle Module Metadata exposes only ${EXPECTED_SECURITY_VERSION} NES Security dependencies"
	else
		fail "${label} Gradle Module Metadata contains an official, patch.1, missing, or malformed Security dependency"
	fi
}

check_starter_contracts() {
	local starter_root="${ROOT_DIR}/spring-boot-project/spring-boot-starters"

	printf '\nChecking generated Security starter publication metadata\n'
	if ! generate_starter_metadata; then
		return
	fi
	check_starter_pom \
		"${starter_root}/spring-boot-starter-security/build/publications/maven/pom-default.xml" \
		"spring-boot-starter-security"
	check_starter_module_metadata \
		"${starter_root}/spring-boot-starter-security/build/publications/maven/module.json" \
		"spring-boot-starter-security"
	check_starter_pom \
		"${starter_root}/spring-boot-starter-oauth2-resource-server/build/publications/maven/pom-default.xml" \
		"spring-boot-starter-oauth2-resource-server"
	check_starter_module_metadata \
		"${starter_root}/spring-boot-starter-oauth2-resource-server/build/publications/maven/module.json" \
		"spring-boot-starter-oauth2-resource-server"
}

check_graph_configuration() {
	local configuration="$1"
	local report="${TEMP_DIR}/${configuration}.txt"

	if ! "${GRADLEW}" \
		:spring-boot-project:spring-boot-starters:spring-boot-starter-oauth2-resource-server:dependencies \
		--configuration "${configuration}" --console=plain >"${report}" 2>&1; then
		cat "${report}" >&2
		fail "could not resolve the representative ${configuration} graph"
		return
	fi
	printf '\nResolved Security lines for %s\n' "${configuration}"
	grep -E -- 'org\.springframework\.security:spring-security-|cn\.bjca\.footstone\.bpring\.security:bjca-footstone-bpring-security-' "${report}" || true
	if awk -v expected="${EXPECTED_SECURITY_VERSION}" '
		/org\.springframework\.security:spring-security-/ {
			requested++
			if (index($0, "-> cn.bjca.footstone.bpring.security:bjca-footstone-bpring-security-") == 0) {
				bad = 1
			}
		}
		/cn\.bjca\.footstone\.bpring\.security:bjca-footstone-bpring-security-/ {
			if (index($0, "bjca-footstone-bpring-security-oauth2-authorization-server:") > 0) {
				next
			}
			selected++
			if (index($0, ":" expected) == 0) {
				bad = 1
			}
		}
		END { exit(requested > 0 && selected > 0 && !bad ? 0 : 1) }
	' "${report}"; then
		pass "${configuration} maps every official request to one patch.2 NES Security implementation family"
	else
		fail "${configuration} contains an unmapped official request, patch.1/mixed NES implementation, or no representative Security modules"
	fi
}

check_graph_contract() {
	printf '\nChecking representative compile and runtime graphs\n'
	TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/spring-security-adoption.XXXXXX")"
	check_graph_configuration compileClasspath
	check_graph_configuration runtimeClasspath
}

case "${MODE}" in
	source)
		check_source_contract
		;;
	bom)
		check_bom_contract
		;;
	starters)
		check_starter_contracts
		;;
	graph)
		check_graph_contract
		;;
	all)
		check_source_contract
		check_bom_contract
		check_starter_contracts
		check_graph_contract
		;;
	*)
		printf 'Usage: %s {source|bom|starters|graph|all}\n' "${0#"${ROOT_DIR}/"}" >&2
		exit 2
		;;
esac

if [[ "${FAILURES}" -ne 0 ]]; then
	printf '\nSpring Security adoption verification failed with %d assertion(s).\n' "${FAILURES}" >&2
	exit 1
fi

printf '\nSpring Security adoption verification passed.\n'
