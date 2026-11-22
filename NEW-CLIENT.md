# New client runbook

From "yes, let's do it" to a live site and a claimed Google profile. Copy this checklist into an issue in the new client repo and tick it off as you go.

## 0. Before you start: agree the basics with the client
- [ ] A short written agreement: what's included, the monthly fee (if any), what counts as extra work, and that **the client owns the domain and the Google profile**.
- [ ] Collect:
  - trading name (exactly as on the sign)
  - legal name, and company number plus registered office if it's a limited company
  - phone, email and full address
  - opening hours
  - services, with a sentence or two on each
  - the areas they cover
  - logo files (the original artwork if possible, not a screenshot)
  - brand colour
  - whether they're happy for AI companies to train on the site (default yes)

## 1. Create the repo
- [ ] On GitHub, open the template repo → **Use this template** → **Create a new repository**. Name it after the client, e.g. `acme-plumbing`. Make it **private** (free, but no branch protection) or **public** (branch protection works, and there's nothing secret in it).
- [ ] Clone it, then delete the demo gallery, which is only needed in the template: `demos/`, `scripts/build-demos.sh` and `wrangler.demos.jsonc`. CI skips the demo steps automatically once `demos/` is gone.
- [ ] Check `CLAUDE.md` and `README.md` still make sense. Replace the README's intro with a line about the client.
- [ ] Show the client the demo gallery to choose a starting style. Copy that demo's `[params.brand]` values as a starting point.

## 2. Fill in the client details
- [ ] `hugo.toml`: every `TODO`.
  - **Coordinates:** `curl -s https://api.postcodes.io/postcodes/<POSTCODE>`, using `latitude` and `longitude`.
  - **`schemaType`:** the most specific type, e.g. `AutoRepair`, `Plumber`, `HairSalon`.
  - **`seoTitle` and `headline`:** main service plus place ("Plumber in Christchurch").
- [ ] `data/services.yaml`: real services only.
- [ ] `assets/brand/`: add the logos, and set `[params.brand]` `wordmark` and `icon`, or set them to `""` if there's no logo. Then set the brand options:
  - `theme` (dark, light or warm), to suit the logo's background;
  - `font`, `corners` and `uppercase`;
  - `accent` and `accentText`.
- [ ] Optional hero photo: put it in `assets/photos/hero.jpg` and set `[params.hero] image`. Use the client's own photo or a licensed one.
- [ ] `wrangler.jsonc`: the Worker name (e.g. `acme-plumbing`) and the domain.
- [ ] `scripts/build.sh` passes in production mode. Then run `hugo server` and check the site at phone width.

## 3. GitHub
- [ ] Create labels: `change-request` (red) and `todo` (green).
- [ ] In Claude Code, run `/install-github-app` for this repo, then add the secret `CLAUDE_CODE_OAUTH_TOKEN`:
  - Run `claude setup-token` in a separate terminal, then `gh secret set CLAUDE_CODE_OAUTH_TOKEN -R <owner>/<repo>`.
  - Never paste the token into a chat.
- [ ] Public repo: protect `main` (require a PR and the `build` check).

## 4. Domain and hosting (Cloudflare)
- [ ] Register the domain **in the client's name**: Cloudflare Registrar, auto-renew on.
- [ ] Workers & Pages → **Create** → **Import a repository** → this repo.
  - Name: same as `wrangler.jsonc`
  - Build command: `scripts/build.sh`
  - Deploy command: `npx wrangler deploy`
  - Non-production branch deploy command: `npx wrangler versions upload`
  - No environment variables
- [ ] The first deploy attaches the domain and `www.` from `wrangler.jsonc`. Check:
  - `curl -sI https://<domain>/` shows the security headers;
  - `/robots.txt`, `/sitemap.xml` and `/llms.txt` load. If Cloudflare's managed robots.txt replaces ours, turn that off.
- [ ] Turn on **Crawler Hints** (Caching → Configuration).

## 5. Get found (the part that actually brings customers)
- [ ] **Google Business Profile:** the client's Google account owns it, and you're added as Manager. Claim the existing listing if there is one, and don't change the name, address or category until it's verified. Then fill in everything: categories, services, hours, photos and the website.
- [ ] Add the profile's share link to `sameAs` in `hugo.toml`.
- [ ] **Bing Places** (feeds ChatGPT and Copilot): import from Google. **Apple Business Connect** (Siri and Apple Maps).
- [ ] **Google Search Console** and **Bing Webmaster Tools:** verify via Cloudflare DNS and submit `/sitemap.xml`.
- [ ] **Directories** (Yell, Thomson Local, trade bodies, Facebook): the name, address and phone must be identical everywhere.
- [ ] **Reviews:** a QR code on the counter or a text after each job. Reply to every review.

## 6. Hand-over
- [ ] Show the owner how to file **Issues → New issue → Website change request**.
- [ ] Ask for a testimonial for your portfolio once the site is ranking.
