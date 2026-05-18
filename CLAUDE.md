# CLAUDE.md

Personal site for **Anthony K GROSS** — published at https://anthonykgross.fr via GitHub Pages. Scope is the CV only; the blog was removed, and the Portfolio menu entry now links straight to the GitHub repos list.

## Stack

- **Jekyll** (Ruby) — static site generator
- **Tailwind CSS** + **PostCSS** — styling, processed at build time via `jekyll-postcss` (see `postcss.config.js`, `tailwind.config.js`)
- **Font Awesome 4.7** — served from CDN in `_layouts/default.html`
- **Docker** — all dev commands run in containers (no local Ruby/Node required)

No JS bundling step. No client-side JS framework. No inline JS anywhere.

## Common commands

All commands are wrapped in the `Makefile` and run via Docker:

```bash
make install   # Install yarn + bundler deps
make start     # Serve dev site on http://localhost:81
make build     # Build to _site/
make debug     # Shell into the Jekyll container
```

## Configs

- `_config.yml` — dev config (`url: http://localhost`, `env: dev`)
- `_config_prod.yml` — prod config (`url: https://anthonykgross.fr`, `env: prod`)

The `env` variable toggles dev-only UI (e.g. the responsive-breakpoint indicator in `_layouts/default.html`).

## Structure

- `_data/` — site data (`cv_fr.yml`, `cv_en.yml`, `menu.yml`). Drafts: `draft_*.txt`.
- `_layouts/` — `default.html` (head + scripts) and `full.html` (banner + nav + footer)
- `_includes/` — partials: `anchor/{anchor,goto}.html` (top-of-page anchor + back-to-top link)
- Pages: `cv.html` (site root, `permalink: /`) and `cv-en.html`

## Notes

- Pages use raw HTML (Liquid), not Markdown.
- Tailwind theme colors are prefixed `akg*` (`akgBlack`, `akgBlue`, `akgRed`, …) — see `tailwind.config.js`.
- `_data/menu.yml` entries support either `template:` (internal Jekyll page, rendered with `{% link %}`) or `url:` (external link, opens in a new tab) — see the loop in `_layouts/full.html`.
