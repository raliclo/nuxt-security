#!/usr/bin/env zsh
set -euo pipefail

REPO_DIR="C:/Users/lowei/proj/nuxt-security"
RELEASE_DIR="${REPO_DIR}/.git/release-candidate"
ARTIFACT_DIR="${REPO_DIR}/release-artifacts"

UPDATE_LATEST=0
DRY_RUN=0
BUMP_TYPE=""
TARGET_VERSION=""
OTP_ARG=()

show_help() {
  cat <<'EOF'
Usage: zsh ./npm_publish.zsh [OPTIONS]

Build, pack, and publish next-security-new from the release-candidate worktree to npm.
從 release-candidate 工作樹建置、打包並發布 next-security-new 至 npm（預設 tag: next）。

Options:
  --bump[=<type>]     Automatically bump version in .git/release-candidate/package.json,
                      rebuild, pack, commit, and publish.
                      <type>: prerelease (default), patch, minor, major
                      自動遞增版本號並重新建置、打包、提交與發布（預設 prerelease，如 rc.2 -> rc.3）
  --version=<semver>  Set an explicit version (e.g. 3.0.0-rc.3 or 3.0.0), rebuild, pack,
                      commit, and publish. Cannot be combined with --bump.
                      指定明確版本號並重新建置、打包、提交與發布（不可與 --bump 併用）
  --otp=<6-digit>     Pass npm 2FA one-time password directly (otherwise browser 2FA is used)
                      直接帶入 6 位數 2FA 驗證碼（未指定時由 npm 觸發瀏覽器驗證）
  --latest            Also update the 'latest' dist-tag to the published version
                      發布後同步將 'latest' dist-tag 指向此次發布版本
  --dry-run           Preview resolved version and steps without modifying files or publishing
                      僅預覽目標版本與步驟，不改寫檔案、不提交、不發布
  -h, --help          Show this help message and exit
                      顯示此說明並結束

Default behavior (without --bump or --version):
  Uses the current version in .git/release-candidate/package.json and publishes
  ./release-artifacts/<name>-<version>.tgz (builds & packs it first if missing).

Examples:
  cd C:/Users/lowei/proj/nuxt-security && zsh ./npm_publish.zsh
  cd C:/Users/lowei/proj/nuxt-security && zsh ./npm_publish.zsh --bump
  cd C:/Users/lowei/proj/nuxt-security && zsh ./npm_publish.zsh --bump=patch --otp=123456
  cd C:/Users/lowei/proj/nuxt-security && zsh ./npm_publish.zsh --version=3.0.0-rc.3 --dry-run
  cd C:/Users/lowei/proj/nuxt-security && zsh ./npm_publish.zsh --version=3.0.0 --latest
EOF
}

for arg in "$@"; do
  case "$arg" in
    --bump)
      BUMP_TYPE="prerelease"
      ;;
    --bump=*)
      BUMP_TYPE="${arg#--bump=}"
      ;;
    --version=*)
      TARGET_VERSION="${arg#--version=}"
      ;;
    --latest)
      UPDATE_LATEST=1
      ;;
    --dry-run)
      DRY_RUN=1
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

if [[ -n "$BUMP_TYPE" && -n "$TARGET_VERSION" ]]; then
  echo "Error: Cannot use --bump and --version together." >&2
  exit 1
fi

if [[ -n "$BUMP_TYPE" ]]; then
  case "$BUMP_TYPE" in
    prerelease|patch|minor|major) ;;
    *)
      echo "Error: Unsupported --bump type '$BUMP_TYPE'. Use: prerelease, patch, minor, major." >&2
      exit 1
      ;;
  esac
fi

cd "$REPO_DIR"

if [[ ! -f "${RELEASE_DIR}/package.json" ]]; then
  echo "Error: Release worktree not found at ${RELEASE_DIR}" >&2
  exit 1
fi

PKG_NAME="$(node -p "require('${RELEASE_DIR}/package.json').name")"
CURRENT_VERSION="$(node -p "require('${RELEASE_DIR}/package.json').version")"

compute_next_version() {
  node -e '
    const current = process.argv[1];
    const bump = process.argv[2];
    const explicit = process.argv[3];
    const semverRe = /^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?$/;

    if (explicit) {
      if (!semverRe.test(explicit)) {
        console.error(`Invalid semver version: ${explicit}`);
        process.exit(1);
      }
      console.log(explicit);
      process.exit(0);
    }

    if (!bump) {
      console.log(current);
      process.exit(0);
    }

    const match = current.match(semverRe);
    if (!match) {
      console.error(`Cannot parse current version: ${current}`);
      process.exit(1);
    }
    let [, major, minor, patch, pre] = match;
    major = Number(major);
    minor = Number(minor);
    patch = Number(patch);

    if (bump === "major") {
      console.log(`${major + 1}.0.0`);
    } else if (bump === "minor") {
      console.log(`${major}.${minor + 1}.0`);
    } else if (bump === "patch") {
      console.log(`${major}.${minor}.${patch + 1}`);
    } else if (bump === "prerelease") {
      if (pre) {
        const preMatch = pre.match(/^(.*?)(\d+)$/);
        if (preMatch) {
          console.log(`${major}.${minor}.${patch}-${preMatch[1]}${Number(preMatch[2]) + 1}`);
        } else {
          console.log(`${major}.${minor}.${patch}-${pre}.1`);
        }
      } else {
        console.log(`${major}.${minor}.${patch + 1}-rc.0`);
      }
    }
  ' "$CURRENT_VERSION" "$BUMP_TYPE" "$TARGET_VERSION"
}

NEXT_VERSION="$(compute_next_version)"
TARBALL="${ARTIFACT_DIR}/${PKG_NAME}-${NEXT_VERSION}.tgz"
NEEDS_VERSION_CHANGE=0
if [[ "$NEXT_VERSION" != "$CURRENT_VERSION" ]]; then
  NEEDS_VERSION_CHANGE=1
fi

echo "==> Package:         ${PKG_NAME}"
echo "==> Current version: ${CURRENT_VERSION}"
echo "==> Target version:  ${NEXT_VERSION}"
echo "==> Tarball path:    ${TARBALL}"

if (( DRY_RUN )); then
  echo "==> [dry-run] No files modified, no commit created, nothing published."
  if (( NEEDS_VERSION_CHANGE )); then
    echo "==> [dry-run] Would update ${RELEASE_DIR}/package.json -> ${NEXT_VERSION}, rebuild, pack, and commit."
  elif [[ ! -f "$TARBALL" ]]; then
    echo "==> [dry-run] Tarball not found; would rebuild and pack ${TARBALL}."
  else
    echo "==> [dry-run] Would publish existing tarball (SHA-256: $(sha256sum "$TARBALL" | awk '{print $1}'))."
  fi
  echo "==> [dry-run] Would run: npm publish \"${TARBALL}\" --tag next --access public ${OTP_ARG[*]}"
  if (( UPDATE_LATEST )); then
    echo "==> [dry-run] Would run: npm dist-tag add \"${PKG_NAME}@${NEXT_VERSION}\" latest ${OTP_ARG[*]}"
  fi
  exit 0
fi

if (( NEEDS_VERSION_CHANGE )) || [[ ! -f "$TARBALL" ]]; then
  if (( NEEDS_VERSION_CHANGE )); then
    if [[ -n "$(git -C "$RELEASE_DIR" status --porcelain)" ]]; then
      echo "Error: ${RELEASE_DIR} has uncommitted changes. Clean or commit them before bumping version." >&2
      exit 1
    fi
    echo "==> Updating ${RELEASE_DIR}/package.json version to ${NEXT_VERSION}..."
    node -e '
      const fs = require("node:fs");
      const file = process.argv[1];
      const next = process.argv[2];
      const pkg = JSON.parse(fs.readFileSync(file, "utf8"));
      pkg.version = next;
      fs.writeFileSync(file, JSON.stringify(pkg, null, 2) + "\n");
    ' "${RELEASE_DIR}/package.json" "$NEXT_VERSION"
  fi

  echo "==> Building and packing ${PKG_NAME}@${NEXT_VERSION} in ${RELEASE_DIR}..."
  (
    cd "$RELEASE_DIR"
    yarn install --non-interactive --frozen-lockfile
    yarn dev:prepare
    yarn prepack
    mkdir -p "$ARTIFACT_DIR"
    npm pack --ignore-scripts --pack-destination "$ARTIFACT_DIR"
  )

  if (( NEEDS_VERSION_CHANGE )); then
    git -C "$RELEASE_DIR" add package.json
    git -C "$RELEASE_DIR" commit -m "release: bump ${PKG_NAME} to ${NEXT_VERSION}"
  fi
fi

if [[ ! -f "$TARBALL" ]]; then
  echo "Error: Tarball not found: $TARBALL" >&2
  exit 1
fi

echo "==> Tarball SHA-256: $(sha256sum "$TARBALL" | awk '{print $1}')"
echo "==> npm user: $(npm whoami)"
echo "==> Publishing ${PKG_NAME}@${NEXT_VERSION} (tag: next)..."
npm publish "$TARBALL" --tag next --access public "${OTP_ARG[@]}"

if (( UPDATE_LATEST )); then
  echo "==> Updating latest dist-tag to ${PKG_NAME}@${NEXT_VERSION}..."
  npm dist-tag add "${PKG_NAME}@${NEXT_VERSION}" latest "${OTP_ARG[@]}"
fi

echo "==> Verifying published package metadata..."
npm view "${PKG_NAME}@${NEXT_VERSION}" dist.integrity dist.tarball --json
npm view "${PKG_NAME}" versions dist-tags --json
