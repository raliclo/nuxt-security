#!/usr/bin/env zsh
set -euo pipefail

REPO_DIR="C:/Users/lowei/proj/nuxt-security"
PKG_NAME="next-security-new"
PKG_VERSION="3.0.0-rc.2"
TARBALL="./release-artifacts/${PKG_NAME}-${PKG_VERSION}.tgz"
EXPECTED_SHA256="3cf6cb0e4bc9454370c5d9f546b94a91353f868234a7d6940f3780506fd3522e"

UPDATE_LATEST=0
OTP_ARG=()

show_help() {
  cat <<EOF
Usage: zsh ./npm_publish.zsh [OPTIONS]

Publish verified tarball ${PKG_NAME}@${PKG_VERSION} to npm registry (tag: next).
發布已驗證的 ${PKG_NAME}@${PKG_VERSION} tarball 至 npm（預設 tag: next）。

Options:
  --otp=<6-digit>   Pass npm 2FA one-time password directly (otherwise browser 2FA is used)
                    直接帶入 6 位數 2FA 驗證碼（未指定時由 npm 觸發瀏覽器驗證）
  --latest          Also update the 'latest' dist-tag to ${PKG_VERSION} after publishing
                    發布後同步將 'latest' dist-tag 指向 ${PKG_VERSION}
  -h, --help        Show this help message and exit
                    顯示此說明並結束

Steps performed:
  1. cd ${REPO_DIR}
  2. Verify tarball exists and matches expected SHA-256:
     ${TARBALL} (${EXPECTED_SHA256})
  3. Verify npm authentication (npm whoami)
  4. Run: npm publish ${TARBALL} --tag next --access public
  5. (Optional) Run: npm dist-tag add ${PKG_NAME}@${PKG_VERSION} latest
  6. Verify published metadata via npm view

Examples:
  cd ${REPO_DIR} && zsh ./npm_publish.zsh
  cd ${REPO_DIR} && zsh ./npm_publish.zsh --otp=123456
  cd ${REPO_DIR} && zsh ./npm_publish.zsh --otp=123456 --latest
EOF
}

for arg in "$@"; do
  case "$arg" in
    --latest)
      UPDATE_LATEST=1
      ;;
    --otp=*)
      OTP_ARG=("$arg")
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "" >&2
      show_help >&2
      exit 1
      ;;
  esac
done

cd "$REPO_DIR"

if [[ ! -f "$TARBALL" ]]; then
  echo "Error: Tarball not found: $TARBALL" >&2
  exit 1
fi

ACTUAL_SHA256="$(sha256sum "$TARBALL" | awk '{print $1}')"
if [[ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]]; then
  echo "Error: SHA-256 mismatch for $TARBALL" >&2
  echo "  Expected: $EXPECTED_SHA256" >&2
  echo "  Actual:   $ACTUAL_SHA256" >&2
  exit 1
fi

echo "==> npm user: $(npm whoami)"
echo "==> Publishing ${PKG_NAME}@${PKG_VERSION} from ${TARBALL} (tag: next)..."
npm publish "$TARBALL" --tag next --access public "${OTP_ARG[@]}"

if (( UPDATE_LATEST )); then
  echo "==> Updating latest dist-tag to ${PKG_NAME}@${PKG_VERSION}..."
  npm dist-tag add "${PKG_NAME}@${PKG_VERSION}" latest "${OTP_ARG[@]}"
fi

echo "==> Verifying published package metadata..."
npm view "${PKG_NAME}@${PKG_VERSION}" dist.integrity dist.tarball --json
npm view "${PKG_NAME}" versions dist-tags --json
