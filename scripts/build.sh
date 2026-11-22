#!/usr/bin/env bash
# Single build entrypoint used locally, in GitHub Actions and by Cloudflare Workers Builds.
#
#   scripts/build.sh            # build + fail if any "TODO" placeholder is in the output
#   scripts/build.sh --preview  # build only (placeholders allowed), for PR / branch previews
#
# Hugo: uses the version pinned in .hugo-version. If `hugo` on PATH isn't that version
# (e.g. on Cloudflare's or GitHub's build machines), it downloads that release into .bin/
# and verifies it against Hugo's published SHA-256 checksums before using it.
#
# On Cloudflare, builds of any branch other than main are treated as previews automatically.
set -euo pipefail
cd "$(dirname "$0")/.."

mode="production"
if [[ "${1:-}" == "--preview" ]]; then mode="preview"; fi
branch="${WORKERS_CI_BRANCH:-${CF_PAGES_BRANCH:-}}"
if [[ -n "$branch" && "$branch" != "main" ]]; then mode="preview"; fi

# --- Hugo ------------------------------------------------------------------
want="$(tr -d '[:space:]' < .hugo-version)"
hugo_bin="hugo"
if ! command -v hugo >/dev/null || [[ "$(hugo version)" != *"v${want}"[^0-9]* ]]; then
  hugo_bin=".bin/hugo"
  if [[ ! -x "$hugo_bin" || "$("$hugo_bin" version)" != *"v${want}"[^0-9]* ]]; then
    case "$(uname -s)-$(uname -m)" in
      Linux-x86_64)  platform="linux-amd64" ;;
      Linux-aarch64) platform="linux-arm64" ;;
      *) echo "Install Hugo ${want} first (macOS: brew install hugo). Found: $(command -v hugo >/dev/null && hugo version || echo none)" >&2; exit 1 ;;
    esac
    file="hugo_extended_${want}_${platform}.tar.gz"
    base="https://github.com/gohugoio/hugo/releases/download/v${want}"
    tmp="$(mktemp -d)"
    echo "Downloading Hugo ${want} (${platform})..."
    curl -fsSL -o "$tmp/$file" "$base/$file"
    curl -fsSL -o "$tmp/checksums.txt" "$base/hugo_${want}_checksums.txt"
    expected="$(grep " ${file}\$" "$tmp/checksums.txt" | cut -d' ' -f1)"
    if command -v sha256sum >/dev/null; then actual="$(sha256sum "$tmp/$file" | cut -d' ' -f1)"
    else actual="$(shasum -a 256 "$tmp/$file" | cut -d' ' -f1)"; fi
    if [[ -z "$expected" || "$expected" != "$actual" ]]; then
      echo "ERROR: Hugo download checksum mismatch (expected '$expected', got '$actual')." >&2
      exit 1
    fi
    mkdir -p .bin
    tar -xzf "$tmp/$file" -C .bin hugo
    rm -rf "$tmp"
  fi
fi
"$hugo_bin" version

# --- Build -----------------------------------------------------------------
rm -rf public
"$hugo_bin" --gc --panicOnWarning

if [[ "$mode" == "production" ]]; then
  if grep -q "TODO" wrangler.jsonc; then
    echo "ERROR: wrangler.jsonc still has TODO values (Worker name / domain)." >&2
    exit 1
  fi
  if grep -rlI "TODO" public >/dev/null; then
    echo "ERROR: placeholder 'TODO' values found in the built site:" >&2
    grep -rohI "TODO[^<\"&]*" public | sort -u | sed 's/^/  /' >&2
    echo "Fill them in hugo.toml (or run with --preview to build anyway)." >&2
    exit 1
  fi
fi
echo "Build OK ($mode)."
