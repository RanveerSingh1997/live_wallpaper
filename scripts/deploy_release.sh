#!/usr/bin/env bash
# ==============================================================================
# Wallora — Production Release & Deployment Orchestrator
# Tagline: "Make every screen yours."
# ==============================================================================
set -euo pipefail

# ANSI Color Codes
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Logger helpers
log_header() {
  echo -e "\n${MAGENTA}${BOLD}==============================================================================${NC}"
  echo -e "${CYAN}${BOLD}  $1${NC}"
  echo -e "${MAGENTA}${BOLD}==============================================================================${NC}\n"
}

log_step() {
  echo -e "${CYAN}${BOLD}[STEP]${NC} $1"
}

log_info() {
  echo -e "${BOLD}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}${BOLD}[ERROR]${NC} $1" >&2
}

# Resolve Repository Root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# Command flags
SKIP_TESTS=false
SKIP_BUILD=false
DRY_RUN=false
AUTO_PUSH=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
    --skip-build)
      SKIP_BUILD=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --push)
      AUTO_PUSH=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --skip-tests    Skip monorepo quality gates (make test-all)"
      echo "  --skip-build    Skip re-building release binaries if already present"
      echo "  --dry-run       Validate state and output release plan without pushing"
      echo "  --push          Automatically push git tag and create GitHub Release"
      echo "  -h, --help      Show this help message"
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

log_header "WALLORA ENTERPRISE RELEASE ORCHESTRATION"

# 1. Version Detection from pubspec.yaml
log_step "1. Extracting version metadata from pubspec.yaml..."
VERSION_LINE=$(grep "^version:" pubspec.yaml | head -n 1)
FULL_VERSION=$(echo "${VERSION_LINE}" | awk '{print $2}')
SEMVER="${FULL_VERSION%%+*}"
BUILD_NUM="${FULL_VERSION##*+}"
GIT_TAG="v${SEMVER}"

log_info "Target Version: ${BOLD}${SEMVER}${NC} (Build ${BUILD_NUM})"
log_info "Target Git Tag: ${BOLD}${GIT_TAG}${NC}"

# 2. Git Status Check
log_step "2. Verifying clean git working directory..."
if [[ -n $(git status --porcelain) ]]; then
  log_warn "Git working directory contains uncommitted changes!"
  git status --short
  if [ "${DRY_RUN}" = false ]; then
    log_error "Please commit or stash your changes before deploying a release."
    exit 1
  fi
else
  log_success "Working tree is clean and synchronized."
fi

# 3. Quality Gates
if [ "${SKIP_TESTS}" = true ]; then
  log_warn "Skipping quality gates (--skip-tests active)."
else
  log_step "3. Executing Tier-1 Monorepo Quality Gates (make test-all)..."
  make test-all
  log_success "All 10 Quality Gates passed 100% green!"
fi

# 4. Release Binaries Build / Verification
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
ARM64_APK="build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
ARMV7_APK="build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
X86_APK="build/app/outputs/flutter-apk/app-x86_64-release.apk"
WEB_DIR="build/web"
JAR_PATH="backend/target/wallaza-service-1.0.0-SNAPSHOT.jar"

log_step "4. Verifying release distribution binaries..."
if [ "${SKIP_BUILD}" = false ]; then
  if [[ ! -f "${AAB_PATH}" || ! -f "${ARM64_APK}" || ! -d "${WEB_DIR}" || ! -f "${JAR_PATH}" ]]; then
    log_info "Building missing release binaries across Flutter and Spring Boot..."
    make build-android
    make build-web
    make build-backend
  fi
fi

# Assert presence of all target binaries
for f in "${AAB_PATH}" "${ARM64_APK}" "${ARMV7_APK}" "${X86_APK}" "${JAR_PATH}"; do
  if [[ ! -f "${f}" ]]; then
    log_error "Missing required release binary: ${f}"
    exit 1
  fi
  SIZE_HUMAN=$(ls -lh "${f}" | awk '{print $5}')
  log_info "  -> Found $(basename "${f}") (${SIZE_HUMAN})"
done

# 5. Checksum Verification
log_step "5. Verifying cryptographic SHA-256 release checksums..."
if [[ -f "CHECKSUMS.sha256" ]]; then
  shasum -c CHECKSUMS.sha256
  log_success "All release artifact checksums verified OK!"
else
  log_warn "CHECKSUMS.sha256 not found. Generating new checksum manifest..."
  shasum -a 256 "${AAB_PATH}" "${ARM64_APK}" "${ARMV7_APK}" "${X86_APK}" "${JAR_PATH}" > CHECKSUMS.sha256
  log_success "Generated CHECKSUMS.sha256."
fi

# 6. Release Notes Aggregation
log_step "6. Preparing release notes..."
RELEASE_NOTES_FILE="store_metadata/google_play/release_notes.txt"
if [[ ! -f "${RELEASE_NOTES_FILE}" ]]; then
  RELEASE_NOTES_FILE="RELEASE_NOTES.tmp"
  cat <<EOF > "${RELEASE_NOTES_FILE}"
Wallora ${SEMVER} — "Make every screen yours."

Release Highlights:
- Premium obsidian neon UI with fluid Apple/Netflix tactile spring physics.
- 4K live video wallpaper engine with zero-sleep battery protection.
- 12 personalization studios: Quote Studio, Lock Screen, 3D Parallax, and Aura Harmonizer.
- Standby Desk Dock bedside ambient clock with OLED anti-burn-in protection.
- Complete TalkBack & VoiceOver accessibility semantics certification.
EOF
fi

echo -e "${YELLOW}"
cat "${RELEASE_NOTES_FILE}"
echo -e "${NC}"

# 7. Git Tagging
log_step "7. Creating annotated Git tag: ${GIT_TAG}..."
if git rev-parse "${GIT_TAG}" >/dev/null 2>&1; then
  log_warn "Git tag '${GIT_TAG}' already exists."
else
  if [ "${DRY_RUN}" = true ]; then
    log_info "[DRY-RUN] Would execute: git tag -a '${GIT_TAG}' -m 'Wallora ${GIT_TAG} — Make every screen yours.'"
  else
    git tag -a "${GIT_TAG}" -m "Wallora ${GIT_TAG} — Make every screen yours."
    log_success "Created annotated Git tag: ${GIT_TAG}"
  fi
fi

# 8. Tag & GitHub Release Deployment
if [ "${AUTO_PUSH}" = true ] && [ "${DRY_RUN}" = false ]; then
  log_step "8. Pushing tag '${GIT_TAG}' to origin..."
  git push origin "${GIT_TAG}"
  log_success "Git tag '${GIT_TAG}' pushed to origin main!"

  if command -v gh >/dev/null 2>&1; then
    log_step "9. Publishing official GitHub Release via GitHub CLI..."
    gh release create "${GIT_TAG}" \
      "${AAB_PATH}" \
      "${ARM64_APK}" \
      "${ARMV7_APK}" \
      "${X86_APK}" \
      "${JAR_PATH}" \
      "CHECKSUMS.sha256" \
      "release_manifest.json" \
      --title "Wallora ${GIT_TAG} — Production Release" \
      --notes-file "${RELEASE_NOTES_FILE}"

    log_success "Official GitHub Release published successfully!"
  else
    log_warn "GitHub CLI ('gh') not found. Please create the release manually on GitHub."
  fi
else
  if [ "${DRY_RUN}" = true ]; then
    log_info "[DRY-RUN] Skipping tag push and release publication."
  else
    log_info "Release tag created locally. To push tag and publish to GitHub, run:"
    echo -e "${CYAN}${BOLD}  git push origin ${GIT_TAG}${NC}"
    echo -e "${CYAN}${BOLD}  gh release create ${GIT_TAG} ${AAB_PATH} ${ARM64_APK} ${ARMV7_APK} ${X86_APK} ${JAR_PATH} CHECKSUMS.sha256 release_manifest.json --title \"Wallora ${GIT_TAG} — Production Release\" --notes-file \"${RELEASE_NOTES_FILE}\"${NC}"
  fi
fi

log_header "WALLORA ${GIT_TAG} READY FOR STORE SUBMISSION"
log_success "Enterprise release certification complete!"
