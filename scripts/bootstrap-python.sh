#!/usr/bin/env bash
# 下载并放置 iOS 内嵌 CPython（Beeware python-apple-support）
# 用法：先跑本脚本，再 xcodegen generate
set -euo pipefail

PYVER="3.11"
TAG="3.11-b13"                       # 3.11 最新构建（含 Python 3.11.18）
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

FW="$(find "${TMP}" -type d -name 'Python.xcframework' | head -1)"
DYNLOAD="$(find "${TMP}" -type d -name 'lib-dynload' -path '*lib/python3.11*' | head -1)"

[ -n "$FW" ] || { echo "未找到 Python.xcframework"; exit 1; }
[ -n "$DYNLOAD" ] || { echo "未找到 stdlib/lib-dynload"; exit 1; }

# stdlib 根目录：.../python/lib/python3.11/lib-dynload 的上两级 = .../python
STDLIB_ROOT="$(dirname "$(dirname "$DYNLOAD")")"

echo "==> 放置 Python.xcframework -> Frameworks/"
rm -rf "${ROOT}/Frameworks/Python.xcframework"
mkdir -p "${ROOT}/Frameworks"
cp -R "${FW}" "${ROOT}/Frameworks/Python.xcframework"

echo "==> 放置 stdlib -> Resources/python/"
rm -rf "${ROOT}/Resources/python"
cp -R "${STDLIB_ROOT}" "${ROOT}/Resources/python"

echo "==> 完成"
du -sh "${ROOT}/Frameworks/Python.xcframework" "${ROOT}/Resources/python"
