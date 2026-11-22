#!/usr/bin/env bash
# Builds every demo in demos/<slug>/ into public-demos/<slug>/, using the real template code with
# each demo's config layered on top:  hugo.toml → demos/common.toml → demos/<slug>/hugo.toml
#
#   scripts/build-demos.sh                    # all demos
#   DEMOS_URL=https://demo.example scripts/build-demos.sh
#
# The output is one static site (deployed by wrangler.demos.jsonc): / redirects to the first demo,
# and the switcher bar links them all. Demos are noindex and robots-disallowed: fictional businesses
# must never show up in search results.
set -euo pipefail
cd "$(dirname "$0")/.."

base="${DEMOS_URL:-https://demos.example}"
base="${base%/}"
out="public-demos"

# Reuse build.sh's pinned, checksum-verified Hugo (it builds the template in preview mode as a check).
scripts/build.sh --preview >/dev/null
hugo_bin="hugo"
[[ -x .bin/hugo ]] && hugo_bin=".bin/hugo"

rm -rf "$out"
mkdir -p "$out"
first=""
for dir in demos/*/; do
  slug="$(basename "$dir")"
  [[ -f "$dir/hugo.toml" ]] || continue
  [[ -z "$first" ]] && first="$slug"
  echo "Building demo: $slug"
  "$hugo_bin" --gc --panicOnWarning --quiet \
    --config "hugo.toml,demos/common.toml,${dir}hugo.toml" \
    --baseURL "${base}/${slug}/" \
    --destination "${out}/${slug}"
  # Cloudflare only reads _headers at the site root.
  rm -f "${out}/${slug}/_headers"
done

# The first demo in the switcher order is the landing page.
first="$(grep -m1 -A1 '^\s*\[\[params.demo.links\]\]' demos/common.toml | grep -oE 'slug = "[^"]+"' | cut -d'"' -f2 || true)"
cp static/_headers "${out}/_headers"
printf '/  /%s/  302\n' "$first" > "${out}/_redirects"
printf 'User-agent: *\nDisallow: /\n' > "${out}/robots.txt"
cp "${out}/${first}/404.html" "${out}/404.html"

if grep -rlI "TODO" "$out" >/dev/null; then
  echo "ERROR: a demo still contains TODO placeholders:" >&2
  grep -rlI "TODO" "$out" | sed 's/^/  /' >&2
  exit 1
fi
echo "Demos OK: $(ls -d ${out}/*/ | wc -l | tr -d ' ') sites in ${out}/ (landing: /${first}/)"
