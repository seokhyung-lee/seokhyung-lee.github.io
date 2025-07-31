# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an academic website built with the **al-folio** Jekyll theme - a clean, responsive theme designed for academics to showcase their research, publications, and profile. The site belongs to Seok-Hyung Lee, a physicist specializing in quantum information and computation.

## Development Commands

### Local Development
```bash
# Using Docker (Recommended)
docker compose pull
docker compose up

# Using Docker Slim (Beta, <100MB)
docker compose -f docker-compose-slim.yml up

# Legacy method (not supported)
bundle install
pip install jupyter
bundle exec jekyll serve
```

### Building and Deployment
```bash
# Build the site
bundle exec jekyll build

# Build with production environment
export JEKYLL_ENV=production
bundle exec jekyll build

# Purge unused CSS after build
npm install -g purgecss
purgecss -c purgecss.config.js
```

### Code Quality
```bash
# Format code with Prettier
npx prettier --write .

# Update citation counts from Google Scholar
python update_citations.py
```

## Architecture Overview

### Framework Structure
- **Jekyll** static site generator with **Ruby** backend
- **Bootstrap** for responsive layout and components  
- **MathJax** for mathematical typesetting
- **Jekyll Scholar** for bibliography management
- **GitHub Actions** for automated deployment

### Key Directories
- `_config.yml` - Main Jekyll configuration with personal info, plugins, and settings
- `_pages/` - Main site pages (about, publications, CV, etc.)
- `_layouts/` - HTML templates for different page types
- `_includes/` - Reusable HTML components and partials
- `_data/` - YAML data files (CV info, citations, repositories)
- `_bibliography/` - BibTeX files for publications
- `_sass/` - SCSS stylesheets and theme customization
- `assets/` - Static assets (images, CSS, JS, PDFs, etc.)
- `_plugins/` - Custom Jekyll plugins for extended functionality

### Custom Features
This site includes several custom plugins and features:
- **Google Scholar Citations Plugin** - Automatically fetches citation counts
- **Publication Management** - BibTeX integration with thumbnails and badges  
- **Citation Count Updates** - Python script to update citation data from Google Scholar
- **Responsive Design** - Mobile-first with light/dark mode support
- **Academic Focus** - CV generation, publication lists, research profiles

### Data Flow
1. **Personal Info**: Stored in `_config.yml` and `_data/cv.yml`
2. **Publications**: Managed via `_bibliography/papers.bib` with metadata
3. **Citations**: Updated via `update_citations.py` → `_data/citations.yml`
4. **Images**: Publication previews in `assets/img/publication_preview/`
5. **PDFs**: Papers and slides in `assets/pdf/`

### Deployment Pipeline
- **Trigger**: Push to master/main branch
- **Build**: Jekyll build with Ruby + Python dependencies
- **Optimization**: CSS purging via PurgeCSS
- **Deploy**: Automated GitHub Pages deployment via Actions

## Content Management

### Adding Publications
1. Add BibTeX entry to `_bibliography/papers.bib`
2. Include metadata fields: `pdf`, `slides`, `poster`, `code`, `preview`, `google_scholar_id`
3. Add preview image to `assets/img/publication_preview/`
4. Run `python update_citations.py` to fetch citation counts

### Updating Personal Info
- Basic info: `_config.yml` (name, email, social links)
- Detailed CV: `_data/cv.yml` (education, employment, interests)
- Profile image: `assets/img/prof_pic.jpeg`

### Managing News/Announcements
- Add markdown files to `_news/` directory
- Format: `YYMMDD_brief_title.md` with YAML frontmatter

## Technical Notes

### Jekyll Configuration
- Uses `kramdown` for Markdown processing
- Extensive plugin ecosystem for academic features
- Custom liquid templates for complex layouts
- Responsive image processing via `jekyll-imagemagick`

### Styling System
- SCSS-based theming in `_sass/`
- Bootstrap foundation with custom academic styling
- Font Awesome and Tabler icons
- Color theming via CSS custom properties

### Performance Features
- Lazy loading images
- CSS/JS minification
- WebP image conversion
- Progressive enhancement patterns

### Citation Management
- Automated Google Scholar integration
- Fallback system for citation counts
- BibTeX processing with custom filters
- Publication badges (Google Scholar, etc.)

## Important Files

- `_config.yml` - Main configuration and personal information
- `_bibliography/papers.bib` - Publication database
- `_data/cv.yml` - Structured CV information
- `update_citations.py` - Citation count automation script
- `.github/workflows/deploy.yml` - Automated deployment configuration