# Demo gallery

Seven **fictional** businesses that show prospects what their site could look like. Each one is the real template, styled through config:

| Demo | Theme | Heading font | Corners | Accent |
|---|---|---|---|---|
| `garage`: Northgate Motors | dark | Oswald, uppercase | sharp | amber |
| `hair`: Willow & Ash | light | Playfair Display | soft | sage |
| `nails`: Polished | light | Josefin Sans, uppercase | round | pink |
| `beauty`: Lumière Beauty Rooms | dark | DM Serif Display | soft | gold |
| `cafe`: The Daily Grind | warm | Nunito | round | burnt orange |
| `trades`: Fernhill Plumbing & Heating | light | Archivo | soft | blue |
| `bakery`: Crumb & Co. | warm | Playfair Display | sharp | deep green |

## How it works

Each demo is built from `hugo.toml` → `demos/common.toml` → `demos/<slug>/hugo.toml`:
- the later files override the earlier ones;
- `demos/<slug>/data/services.yaml` replaces the services list, using a Hugo module mount;
- `demos/<slug>/assets/` can hold photos, e.g. `photos/hero.jpg` with `[params.hero] image`.

`scripts/build-demos.sh` builds them all into `public-demos/<slug>/`, with `/` redirecting to the first demo, and adds a switcher bar from `[params.demo]`.

## Rules
- **Fictional only.** Use made-up names, the made-up town of Fernhill, `.example` email addresses, and Ofcom's reserved drama numbers (01632 960000–960999). Never copy a real business.
- **Kept out of search engines:** demo pages are `noindex`, `robots.txt` disallows everything, and structured data is turned off. That's automatic whenever `[params.demo]` is set.
- **Photos must be properly licensed.** Use the client's own, or free-to-use stock such as Unsplash, and note the source in the demo's `assets/photos/CREDITS.md`.

## Adding a demo

1. Copy a demo folder to `demos/<slug>/`, then change `title`, the `[params]` values, `[params.demo] current`, the mount paths, and `data/services.yaml`.
2. Add a `[[params.demo.links]]` entry for it in `common.toml`.
3. Run `scripts/build-demos.sh`, then check it with `python3 -m http.server -d public-demos`.

## Hosting

Host the demos on a separate Cloudflare Worker; the settings are in `wrangler.demos.jsonc`. To add a "Get a site like this" button to the switcher bar, set `cta` in `common.toml`.
