# Berkeley Tax Explorer

A static, single-page web app that lets Berkeley-area voters estimate the **cumulative annual household cost** of multiple concurrent tax and bond measures — including existing obligations.

Live at: **https://ericdf.github.io/berkeley-tax-explorer/**

---

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
