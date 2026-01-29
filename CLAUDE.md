# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an academic personal website built with Jekyll using the [al-folio](https://github.com/alshedivat/al-folio) theme (v0.16.3). The site is deployed to GitHub Pages at https://seokhyung-lee.github.io.

**Related Repository:** Group website at `../skku-qctg.github.io` (SKKU Quantum Computing Theory Group)

## Common Commands

### Local Development with Docker (Recommended)
```bash
docker compose pull
docker compose up                              # Runs at http://localhost:8080
docker compose -f docker-compose-slim.yml up   # Smaller image variant
docker compose up --build                      # Rebuild image after changes
```

### Local Development without Docker
```bash
bundle install
pip install jupyter
bundle exec jekyll serve                       # Runs at http://localhost:4000
```

### Production Build
```bash
JEKYLL_ENV=production bundle exec jekyll build
purgecss -c purgecss.config.js                 # Remove unused CSS
```

### Code Formatting
```bash
npx prettier --write .
```

### Citation Updates
```bash
python bin/update_scholar_citations.py
```

**Google Scholar Citations:**
- The script fetches citation counts using `scholar_userid` from `_config.yml`
- Citation data is stored in `_data/citations.yml` with keys in format `{scholar_userid}:{google_scholar_id}`
- Each paper in `papers.bib` needs a `google_scholar_id` field to display citations

## Architecture

### Content Structure
- `_bibliography/papers.bib` - BibTeX publications database (auto-rendered on publications page)
- `_news/` - News announcements (markdown files with date prefixes, e.g., `250128_new_paper.md`)
- `_pages/` - Static pages (about, cv, publications, etc.)
- `_data/cv.yml` - CV data (fallback when `assets/json/resume.json` not present)
- `_data/citations.yml` - Cached Google Scholar citation counts
- `_data/coauthors.yml` - Co-author links for publications

### Configuration
- `_config.yml` - Main site configuration (URL, collections, plugins, scholar settings)
- `_sass/_themes.scss` - Theme colors (modify `--global-theme-color`)
- `_sass/_variables.scss` - Color variable definitions

### Plugins (in `_plugins/`)
- Custom Ruby plugins for external posts, inspirehep citations, and asset processing
- Note: `google-scholar-citations.rb` was removed in v0.16.3 (citation display handled differently)

## Publications

Edit `_bibliography/papers.bib` to add publications. Supported BibTeX fields:
- `abstract`, `arxiv`, `pdf`, `code`, `slides`, `poster`, `video`, `website`, `blog`
- `preview` - Thumbnail image filename (place in `assets/img/publication_preview/`)
- `bibtex_show` - Shows BibTeX button
- `google_scholar_id` - Required for citation badge display
- `prefix` - Label like "Preprint" or "Review"
- `doi` - Digital Object Identifier

Author highlighting configured in `_config.yml` under `scholar:`:
```yaml
scholar:
  last_name: [Lee]
  first_name: [Seok-Hyung, S.-H.]
```

## Creating Content

### New News Item
Create `_news/YYMMDD_title.md` with content. News items display on the about page.

## Deployment

Automatic deployment via GitHub Actions on push to master:
1. Jekyll builds site
2. CSS purging removes unused styles
3. Deploys to `gh-pages` branch

## Key Configuration Notes

- Scholar ID: `NURGJAwAAAAJ` (configured in `_config.yml`)
- Site uses fixed navbar/footer, dark mode enabled
- Publications sorted by year (most recent first) via jekyll-scholar
- Google Scholar badge enabled; Altmetric, Dimensions, InspireHEP disabled
