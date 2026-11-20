#!/usr/bin/env bash
# 下载并放置 iOS 内嵌 CPython（Beeware python-apple-support）
# 结构与 bundle 对应：Resources/python/lib/python3.11/{stdlib, lib-dynload}
set -euo pipefail

PYVER="3.11"
TAG="3.11-b13"
B="b13"
BASE="https://github.com/beeware/Python-Apple-support/releases/download/${TAG}"
TARBALL="Python-${PYVER}-iOS-support.${B}.tar.gz"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> 下载 ${TARBALL}"
curl -fL -o "${TMP}/${TARBALL}" "${BASE}/${TARBALL}"

echo "==> 解压"
tar -xzf "${TMP}/${TARBALL}" -C "${TMP}"

FW="$(find "${TMP}" -maxdepth 2 -type d -name 'Python.xcframework' | head -1)"
[ -n "$FW" ] || { echo "未找到 Python.xcframework"; exit 1; }

STDLIB_SRC="${FW}/lib/python${PYVER}"
DYNLOAD_SRC="$(find "${FW}/ios-arm64" -type d -name 'lib-dynload' | head -1)"
SYSCONF="$(find "${FW}/ios-arm64" -name '_sysconfigdata__ios_arm64-iphoneos.py' | head -1)"

[ -d "$STDLIB_SRC" ] || { echo "未找到标准库: $STDLIB_SRC"; exit 1; }
[ -n "$DYNLOAD_SRC" ] || { echo "未找到 lib-dynload"; exit 1; }

echo "==> Python.xcframework -> Frameworks/"
rm -rf "${ROOT}/Frameworks/Python.xcframework"
mkdir -p "${ROOT}/Frameworks"
cp -R "${FW}" "${ROOT}/Frameworks/Python.xcframework"

echo "==> 标准库 -> Resources/python/lib/python${PYVER}/"
DST="${ROOT}/Resources/python/lib/python${PYVER}"
rm -rf "${ROOT}/Resources/python"
mkdir -p "${DST}"
cp -R "${STDLIB_SRC}/." "${DST}/"
cp -R "${DYNLOAD_SRC}" "${DST}/lib-dynload"
[ -n "$SYSCONF" ] && cp "$SYSCONF" "${DST}/"

echo "==> 完成"
du -sh "${ROOT}/Frameworks/Python.xcframework" "${ROOT}/Resources/python"
echo "stdlib 模块数: $(find "${DST}" -name '*.py' | wc -l)"
echo "扩展模块数: $(find "${DST}/lib-dynload" -name '*.so' | wc -l)"
