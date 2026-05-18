# CLAUDE.md

Personal site for **Anthony K GROSS** — published at https://anthonykgross.fr via GitHub Pages. Scope is the CV only; the blog was removed, and the Portfolio menu entry now links straight to the GitHub repos list. Two CV variants are served per language: **Hands-off** (managerial/CTO) and **Hands-on** (technical/architect), switchable via tabs at the top of each page.

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

- `_data/` — site data:
  - `cv_hands_off_{fr,en}.yml` — managerial/CTO variant (has `management_skills:` block)
  - `cv_hands_on_{fr,en}.yml` — technical/architect variant
  - `menu.yml` — nav entries
- `_layouts/` — `default.html` (head + scripts) and `full.html` (banner + nav + footer)
- `_includes/` — partials: `anchor/{anchor,goto}.html` (top-of-page anchor + back-to-top link)
- Pages (4 CV variants):
  - `cv-hands-off-fr.html` → `/` (site root, redirects `/cv`, `/fr/cv`, `/cv/hands-off`)
  - `cv-hands-on-fr.html` → `/cv/hands-on`
  - `cv-hands-off-en.html` → `/en/cv` (redirects `/en/cv/hands-off`)
  - `cv-hands-on-en.html` → `/en/cv/hands-on`

## Notes

- Pages use raw HTML (Liquid), not Markdown.
- Tailwind theme colors are prefixed `akg*` (`akgBlack`, `akgBlue`, `akgRed`, …) — see `tailwind.config.js`.
- `_data/menu.yml` entries support either `template:` (internal Jekyll page, rendered with `{% link %}`) or `url:` (external link, opens in a new tab) — see the loop in `_layouts/full.html`.
