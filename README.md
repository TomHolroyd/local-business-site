# Local business site template

A one-page website for a small local business: a garage, tradesperson, salon, café and so on. It costs **£0 to host** and almost nothing to maintain.

- **Static [Hugo](https://gohugo.io) site:** no JavaScript, no npm, no database and no server, so there's nothing to patch.
- **Hosted free on Cloudflare** (Workers static assets: unlimited requests and bandwidth). The only cost is the client's domain.
- **Local SEO built in:** schema.org `LocalBusiness` structured data, opening hours, service area, `robots.txt`, a sitemap and `llms.txt` for AI assistants.
- **Hardened:** a strict Content-Security-Policy and security headers, a checksum-verified Hugo download, and SHA-pinned GitHub Actions.
- **Agent-driven maintenance:** the owner files a change request as a GitHub issue, Claude opens a PR, a Cloudflare preview appears, and you approve. A monthly agent keeps Hugo current.
- **Can't go live half-finished:** production builds fail while any `TODO` placeholder remains.

Example in production: an independent car repair garage in Bournemouth.

## Start a new client

Click **Use this template**, then follow **[NEW-CLIENT.md](NEW-CLIENT.md)**.

## Customising

| What | Where |
|---|---|
| Name, contact, address, hours, legal details, SEO text | `hugo.toml` `[params]` |
| Services | `data/services.yaml` |
| Logos | `assets/brand/` and `[params.brand]` |
| Colours and light/dark theme | `[params.brand]` (`theme`, `accent`, `accentText`) |
| Cloudflare Worker name and domain | `wrangler.jsonc` |

Preview locally with `brew install hugo`, then `hugo server`.

## Improving the template

Make generic improvements here, not in client repos. Client repos are copies, so they don't receive template changes automatically. Port worthwhile fixes to them with a small PR; the Claude agent in each client repo can do it from an issue.
