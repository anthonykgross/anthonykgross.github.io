# CLAUDE.md

Personal site for **Anthony K GROSS** — published at https://anthonykgross.fr via GitHub Pages. Scope is the CV only; the blog and portfolio were removed. Two CV variants are served per language: **Hands-off** (managerial/CTO) and **Hands-on** (technical/architect), switchable via tabs at the top of each page.

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
make build-prod # Build to _site/ with _config_prod.yml only (as CI does)
make check     # Build exactly like CI (prod config) and check the machine-readable views
make debug     # Shell into the Jekyll container
```

## Configs

- `_config.yml` — dev config (`url: http://localhost`, `env: dev`)
- `_config_prod.yml` — prod config (`url: https://anthonykgross.fr`, `env: prod`)

The `env` variable toggles dev-only UI (e.g. the responsive-breakpoint indicator in `_layouts/default.html`).

CI (`.github/workflows/deploy.yml`) **replaces** `_config.yml` with `_config_prod.yml` (no merge): any plugin, `exclude` or `defaults` entry must be in both files. Global facts go in `_data/`, not in a config. Pull requests build and run `bin/check-machine-views.rb`; only pushes to `main` deploy.

## Structure

- `_data/` — site data:
  - `person.yml` — name, location, spoken languages, photo (shared by every page and machine view)
  - `cv_hands_off_{fr,en}.yml` — managerial/CTO variant (has `management_skills:` block)
  - `cv_hands_on_{fr,en}.yml` — technical/architect variant
- `_layouts/` — `default.html` (head + scripts; on CV pages also canonical, hreflang and JSON-LD), `full.html` (banner + header + footer) and `cv-markdown.html` (Markdown view of a CV)
- `_includes/` — partials: `anchor/{anchor,goto}.html` (top-of-page anchor + back-to-top link), `jsonld.html` (Schema.org JSON-LD)
- `cv-md/` — sources of the 4 Markdown views (`layout: cv-markdown`)
- `robots.txt`, `llms.txt` — Liquid sources at the repo root
- `bin/check-machine-views.rb` — checks a prod build in `_site/` (run by `make check` and CI)
- `docs/designs/` — design docs (excluded from the build, like `bin/` and `TODOS.md`)
- Pages (4 CV variants):
  - `cv-hands-off-fr.html` → `/` (site root, redirects `/cv`, `/fr/cv`, `/cv/hands-off`)
  - `cv-hands-on-fr.html` → `/cv/hands-on`
  - `cv-hands-off-en.html` → `/en/cv` (redirects `/en/cv/hands-off`)
  - `cv-hands-on-en.html` → `/en/cv/hands-on`

## Machine-readable views (LLM / AI search)

Design: `docs/designs/llm-discoverability.md`. Everything is generated from `_data/` at build time:
- `_includes/jsonld.html` — Schema.org JSON-LD in each CV page. The `Person` node must stay identical on all 4 pages (reads only `person.yml`, `site.socials` and the EN YAMLs).
- `_layouts/cv-markdown.html` + `cv-md/*.md` — plain Markdown view of each CV (`/cv/hands-off.md`, …). Whitelist: never expose `profile.status` / `profile.interests`.
- `robots.txt` (AI training crawlers blocked, search crawlers allowed), `llms.txt`, `sitemap.xml` (`jekyll-sitemap`).
- CV pages carry `lang`, `cv_lang`, `variant`, `cv_data`, `md_url` in front matter; hreflang pairs pages by `variant`.

## Notes

- Pages use raw HTML (Liquid), not Markdown.
- Tailwind theme colors are prefixed `akg*` (`akgBlack`, `akgBlue`, `akgRed`, …) — see `tailwind.config.js`.
