# CLAUDE.md

Personal site for **Anthony K GROSS** — published at https://anthonykgross.fr via GitHub Pages. Scope is CV + portfolio; the blog was removed.

## Stack

- **Jekyll** (Ruby) — static site generator
- **Tailwind CSS** + **PostCSS** — styling, processed at build time via `jekyll-postcss` (see `postcss.config.js`, `tailwind.config.js`)
- **Font Awesome 4.7** — served from CDN in `_layouts/default.html`
- **Docker** — all dev commands run in containers (no local Ruby/Node required)

No JS bundling step. No client-side JS framework. The only inline JS is in `_includes/github_profile.html` / `github_repositories.html` (vanilla `fetch` to the GitHub API).

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
- `_config_prod.yml` — prod config (`url: https://anthonykgross.fr`, `env: prod`, GitHub token placeholder `__GH_TOKEN__` substituted at deploy time)

The `env` variable toggles dev-only UI (e.g. the responsive-breakpoint indicator in `_layouts/default.html`).

## Structure

- `_data/` — site data (`cv_fr.yml`, `cv_en.yml`, `portfolio.yml`, `menu.yml`). Drafts: `draft_*.txt`.
- `_layouts/` — `default.html` (head + scripts) and `full.html` (banner + nav + footer)
- `_includes/` — partials: `card.html`, `github_profile.html`, `github_repositories.html`, `anchor/{anchor,goto}.html`
- `cv.html` is the site root (`permalink: /`); `cv-en.html` and `portfolio.html` are the other pages

## Notes

- Pages use raw HTML (Liquid), not Markdown.
- Tailwind theme colors are prefixed `akg*` (`akgBlack`, `akgBlue`, `akgRed`, …) — see `tailwind.config.js`.
- GitHub Pages substitutes `__GH_TOKEN__` in `_config_prod.yml` at deploy time (CI secret).
