#!/usr/bin/env bash
# Install local Gradle distribution zips into ~/.gradle/wrapper/dists (no network).
# Matches Gradle Wrapper PathAssembler hash: MD5(url) as BigInteger -> base36.
set -euo pipefail

LOCAL_GRADLE_DIR="${LOCAL_GRADLE_DIR:-${HOME}/dev}"
GRADLE_USER_HOME="${GRADLE_USER_HOME:-${HOME}/.gradle}"
UNPACK="${UNPACK:-1}"

gradle_wrapper_hash() {
	python3 - "$1" <<'PY'
import hashlib, sys
url = sys.argv[1]
digest = hashlib.md5(url.encode()).digest()
n = int.from_bytes(digest, "big")
chars = "0123456789abcdefghijklmnopqrstuvwxyz"
if n == 0:
    print("0")
    sys.exit(0)
out = ""
while n:
    n, r = divmod(n, 36)
    out = chars[r] + out
print(out)
PY
}

install_zip() {
	local zip_file="$1"
	local base name version dist_type dist_name url hash dest extracted ok_marker

	base="$(basename "${zip_file}")"
	if [[ ! "${base}" =~ ^gradle-(.+)-(bin|all)\.zip$ ]]; then
		echo "跳过（文件名不匹配 gradle-*-{bin,all}.zip）: ${base}" >&2
		return 0
	fi
	version="${BASH_REMATCH[1]}"
	dist_type="${BASH_REMATCH[2]}"
	dist_name="gradle-${version}-${dist_type}"
	url="https://services.gradle.org/distributions/${dist_name}.zip"
	hash="$(gradle_wrapper_hash "${url}")"
	dest="${GRADLE_USER_HOME}/wrapper/dists/${dist_name}/${hash}"
	extracted="${dest}/gradle-${version}"
	ok_marker="${dest}/${dist_name}.zip.ok"

	if [[ -f "${ok_marker}" && -d "${extracted}" ]]; then
		echo "已就绪: ${dist_name} (${hash})"
		return 0
	fi

	mkdir -p "${dest}"
	rm -f "${dest}/${dist_name}.zip.part" "${dest}/${dist_name}.zip.lck"
	cp "${zip_file}" "${dest}/${dist_name}.zip"

	if [[ "${UNPACK}" == "1" ]]; then
		echo "解压: ${base} -> ${dest}"
		unzip -q -o "${dest}/${dist_name}.zip" -d "${dest}"
		touch "${ok_marker}"
	else
		echo "已复制 zip（未解压）: ${base} -> ${dest}"
	fi
}

shopt -s nullglob
zips=("${LOCAL_GRADLE_DIR}"/gradle-*-bin.zip "${LOCAL_GRADLE_DIR}"/gradle-*-all.zip)

if [[ ${#zips[@]} -eq 0 ]]; then
	echo "未在 ${LOCAL_GRADLE_DIR} 找到 gradle-*-{bin,all}.zip" >&2
	echo "可将发行包放到该目录，或设置 LOCAL_GRADLE_DIR" >&2
	exit 1
fi

echo "扫描 ${LOCAL_GRADLE_DIR}，共 ${#zips[@]} 个 Gradle 发行包..."
for zip_file in "${zips[@]}"; do
	install_zip "${zip_file}"
done
echo "完成。"
