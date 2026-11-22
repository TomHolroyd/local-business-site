# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A one-page website for a **small local business** (garage, trades, salon, café...). It starts life as a copy of the `local-business-site` template repo, and each client gets their own copy. The site is maintained by a freelancer, often free or for a small monthly fee, so the overriding goal is **near-zero maintenance**: a static Hugo site with no JavaScript, no npm/Go dependencies, no backend and no third-party embeds, hosted free on Cloudflare.

**If this repo is the template itself** (GitHub shows "Template repository"; `gh api repos/{owner}/{repo} --jq .is_template` returns `true`), it contains only `TODO` placeholders. Changes here should be generic improvements that every client benefits from, never client-specific content. Setting up a new client is described in `NEW-CLIENT.md`.

## Commands

```sh
hugo server                    # local preview at http://localhost:1313 (live reload)
scripts/build.sh --preview     # build to public/, placeholders allowed
scripts/build.sh               # production build: also fails if any "TODO" renders or remains in wrangler.jsonc
```

The Hugo version is pinned in `.hugo-version`, which is the single source of truth. If `hugo` on PATH is a different version, `scripts/build.sh` downloads that release into `.bin/` (Linux only) and checks it against Hugo's published SHA-256 checksums. On a Mac, use `brew install hugo`. There are no unit tests. "Tests" means the build passing with `--panicOnWarning` (deprecations fail the build) and the lychee internal link check in CI.

## Where things live

Everything client-specific is in four places. Templates never hard-code business facts.
- `hugo.toml` `[params]`: business facts, SEO text, legal details, brand, contact details, address, structured opening hours, and the AI-training opt-in. **TOML gotcha:** plain `key = value` lines must come *before* the first `[params.something]` table, or they become part of that table.
- `data/services.yaml`: the services list (name and summary), rendered in order on the page, in the JSON-LD and in `llms.txt`.
- `assets/brand/`: logos (`brand.wordmark`, `brand.icon`). Both are optional; without a wordmark the header shows the title as text. Hugo resizes them, so drop in the largest decent version you have.
- `wrangler.jsonc`: the Cloudflare Worker name and custom domains.

Templates:
- `layouts/home.html` is the single page: hero, services, an optional CTA band (`[params.cta]`; delete the table to hide it), and contact/hours. `layouts/baseof.html` is the shell.
- `layouts/_partials/schema.html` builds schema.org `LocalBusiness` structured data, with the subtype from `params.schemaType`.
- `layouts/robots.txt` and `layouts/home.llms.txt` (served at `/llms.txt`) are generated from the same params.
- `assets/css/main.css` is a **Hugo template**, run through `resources.ExecuteAsTemplate`. The `:root` tokens come from `[params.brand]`:
  - `theme`: dark, light or warm;
  - `font`: a preset from `data/fonts.yaml`, with self-hosted OFL files in `assets/fonts/` (only the chosen one is published and preloaded);
  - `corners`: sharp, soft or round;
  - `uppercase`, `accent` and `accentText`.

  Components must use only `var(--...)` tokens and no literal colours or fonts. `[params.hero] image` puts a photo behind the headline as an `<img>`, not a CSS background, because the CSP blocks inline styles.
- `demos/`: the demo gallery. Each folder is a fictional business built from this same template with a config overlay, and `scripts/build-demos.sh` builds them all into `public-demos/`. Setting `[params.demo]` turns on the switcher bar, adds `noindex` and skips structured data. See `demos/README.md`. **Template changes must keep every demo building and looking right.** CI builds them all, which makes them the template's test suite.

This uses the Hugo ≥0.146 template layout (`layouts/home.html`, `layouts/_partials/`). Use `hugo.Data` (not `site.Data`) and `locale` (not `languageCode`).

## The placeholder guard

Unknown details are strings starting with `TODO`. A production build fails if `TODO` appears anywhere in `public/` or in `wrangler.jsonc`. Preview builds (PRs, non-`main` Cloudflare branches via `WORKERS_CI_BRANCH`, and the template repo itself in CI via `github.event.repository.is_template`) allow them. Don't weaken this guard, and never invent real-looking values (phone numbers, addresses, prices) to make it pass. Ask instead.

## Rules for changes

- **Business facts come only from the owner.** Don't add services, prices, hours, accreditations, warranties or claims ("cheapest", "approved", "same-day") unless an issue explicitly states them.
- **No dependencies:** no `package.json`, Hugo modules, themes, external scripts, web fonts, analytics, cookie banners or map iframes. "Get directions" is deliberately a plain Google Maps link, so the site sets no cookies and needs no consent banner.
- **Keep the CSP intact.** `static/_headers` sets a strict Content-Security-Policy (`default-src 'none'`, with self-hosted CSS, images and fonts only). Inline `style=` attributes, inline scripts and anything from another origin are **blocked in the browser** even though the build passes.
- Keep the business name, address and phone **identical** to the Google Business Profile and directories, because consistency is a local-ranking signal.
- UK English. Short, plain copy aimed at customers.
- Must work at 360px width with no horizontal scroll.
- Limited companies must show legal name, company number, place of registration and registered office; the footer does this automatically. For sole traders, the company fields are empty and the footer shows only the name.
- GitHub Actions are pinned to full commit SHAs with a `# vX.Y.Z` comment. Keep that format, because Dependabot updates both.

## Development process (agent-driven)

- **Hosting:** Cloudflare Workers **static assets only** (`wrangler.jsonc` has no `main` script, so every request is a free static-asset request; keep it that way). Workers Builds runs `scripts/build.sh` then `npx wrangler deploy` on `main`; other branches upload preview versions.
- **Workflow:** feature branch → PR → `main` (production). Never push to `main` directly.
- **`.github/workflows/claude.yml`:** the implementation agent. It runs on issues labelled `change-request` (from the issue form) or on `@claude` mentions, and opens a PR.
- **`.github/workflows/claude-review.yml`:** reviews every PR against these rules. A human approves and merges. It skips PRs that change its own workflow file; that's GitHub/Claude security and expected.
- **`.github/workflows/maintenance.yml`:** monthly. Opens a PR bumping `.hugo-version` when Hugo releases. In client repos, it also opens or updates a "Site details still missing" issue while placeholders remain.
- **`.github/workflows/ci.yml`:** builds the site and checks internal links. Dependabot updates the pinned Actions.

When implementing an issue: make the minimal change, run `scripts/build.sh --preview`, and mention in the PR description anything the owner needs to confirm.
