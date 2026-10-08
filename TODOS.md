# TODOS

## GEO / visibilité LLM

### Mesure récurrente des citations IA

**What:** Repasser chaque mois les requêtes cibles (nom, requête managériale, requête technique) dans Perplexity et ChatGPT Search, et noter les URL citées et la facette choisie.

**Why:** C'est le seul moyen de valider le critère de succès du design doc, et de savoir si le levier est sur le site ou hors site (LinkedIn, GitHub).

**Context:** Approche C des office hours (2026-10-08), retenue en eng review (D6). La ligne de base « avant » n'a pas été relevée (abandonnée au ship), donc la première mesure après déploiement servira de référence. Pour automatiser, utiliser une routine planifiée (`/schedule`). Voir `docs/designs/llm-discoverability.md`.

**Effort:** S
**Priority:** P2
**Depends on:** Mise en prod de la branche feat/llm-discoverability

### Historique daté des postes dans le JSON-LD

**What:** Publier les expériences en `OrganizationRole` (roleName, startDate, endDate, worksFor) dans `_includes/jsonld.html`.

**Why:** Permettre aux moteurs IA de calculer l'ancienneté et le poste actuel à partir de données structurées, pas seulement du texte.

**Context:** Reporté en eng review (D1, 2026-10-08). Les facettes et les compétences portent le signal de découverte, et l'historique reste lisible dans les vues `.md`. Coût : 24 entrées à migrer à la main dans les 4 YAML (`start`/`end` ISO, `company_name`/`city` séparés), à tenir à jour à chaque nouveau poste. Déclencheur : la mesure ci-dessus montre que les moteurs se trompent sur l'ancienneté ou le poste actuel. Point de départ : `experiences` dans `_data/cv_*.yml`.

**Effort:** M
**Priority:** P3
**Depends on:** Mesure récurrente des citations IA

## Infrastructure

### Durcir la CI de déploiement

**What:** Dans `.github/workflows/deploy.yml` : ajouter un groupe `concurrency` Pages, passer à `actions/checkout@v4` avec `persist-credentials: false`, épingler les actions et l'image `jekyll/builder` par SHA, utiliser `yarn install --frozen-lockfile`. Aligner `make check` (image, `JEKYLL_ENV`) sur la CI, faire tourner le contrôle de parité des configs avant le `mv` en CI, et échapper `og:description` / `twitter:description`.

**Why:** Deux push rapprochés peuvent se déployer dans le désordre (absence de `concurrency`). L'image `:latest` non maintenue et les tags mobiles rendent le build non reproductible. Un `make check` vert en local ne garantit donc pas une CI verte.

**Context:** Remonté par la revue /ship du 2026-10-08 (cycle 2 et revue adversariale). La plupart de ces points existaient avant la branche. L'utilisateur a choisi de livrer d'abord (D5). Hors code : révoquer l'ancien secret `GH_TOKEN` et le supprimer des secrets du repo, car il n'est plus utilisé et a pu être écrit dans une config publiée par le passé.

**Effort:** S
**Priority:** P2
**Depends on:** None

## Completed
