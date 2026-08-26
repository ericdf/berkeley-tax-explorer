# Berkeley Tax Explorer

A static, single-page web app that lets Berkeley-area voters estimate the **cumulative annual household cost** of multiple concurrent tax and bond measures — including existing obligations.

Live at: **https://ericdf.github.io/berkeley-tax-explorer/**

---

## Role in the architecture

**A standalone tool, deployed on its own, linked *from* the Berkeley sites.**

- **Responsible for:** the cumulative household cost estimator for concurrent Berkeley tax and bond measures, including existing obligations.
- **Appears at:** <https://ericdf.github.io/berkeley-tax-explorer/>
- **Deployed by:** GitHub Actions on push to `main` (`.github/workflows/deploy.yml`), publishing to GitHub Pages.

This repository is **not** part of the publishing pipeline for the two Berkeley sites.
Those are built from the private `council` repo, which is the only repository that
publishes them. This tool stands on its own and is reached by absolute-URL links from
pages built there — currently `framework.html`, `bdp-index.html` and `quiz-ballot-cost.html`.

Two consequences of that arrangement:

**Renaming or unpublishing this repo silently breaks the live sites.** Their link
validation checks internal links only and cannot see this URL. If the address changes,
the linking pages must be updated in `council/pages/` and republished.

**Its figures are maintained here, under its own assumptions**, not under the source
repo's corpus rules. They do not update when that corpus grows, so anything cited from
here onto a Berkeley site must be re-derived from primary documents at the time of
writing.

Kept separate deliberately: this is an interactive tool with its own audience and its own
stack, usable without reference to any argument the Berkeley sites make. The full map is
in `council/CLAUDE.md` under "Repository architecture".


## What it does

- Models proposed Berkeley measures (infrastructure bond, sales tax, transit tax, school measures) alongside current incumbent taxes
- Shows costs in a 2D matrix across assessed value × square footage bands
- Projects costs over 30 years, with bond expiration step-downs visible on the chart
- Breaks down costs by jurisdiction (property tax rates, sqft-based parcel taxes, flat charges)
- Scenario presets: City Only, City + Transit, Full Plausible 2026 Ballot

## Tech

Single HTML file (`index.html`) with inline CSS and JS. No build step, no dependencies beyond Chart.js (loaded from CDN). Runs entirely in the browser.

---

## Deploying

Pushing to `main` triggers the GitHub Actions workflow (`.github/workflows/deploy.yml`), which publishes the site to GitHub Pages automatically.

To commit changes and redeploy, run:

```bash
./deploy.sh "describe what changed"
```

This stages all modified tracked files, commits with the provided message, and pushes to `main`. The Actions workflow takes care of the rest (typically live within ~30 seconds).

---

## Files

| File | Purpose |
|---|---|
| `index.html` | Entire application |
| `specification.md` | Product requirements and design decisions |
| `deploy.sh` | Commit-and-push helper |
| `.github/workflows/deploy.yml` | GitHub Actions Pages deployment |
