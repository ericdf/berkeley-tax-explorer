# Product Requirements Specification

## Project: Berkeley Tax Bundle Calculator

---

## 1. Objective

Build a static, client-side web application that allows Berkeley-area voters to estimate the **cumulative household cost of multiple concurrent tax and bond measures**, even when they do not know their assessed value.

The tool must shift the user’s mental model from:

* “Do you support Measure X?”

to:

* “Do you support this total bundle of costs?”

---

## 2. Target User

### Primary User Profile

* College-educated
* Not financially or tax-policy sophisticated
* Proxy: **public high school teacher**

### Capabilities

* Comfortable reading tables and charts
* Understands **annual dollar cost**
* Can estimate:

  * approximate home value range
  * approximate home size
* Does NOT know:

  * assessed value (AV)
  * how bond rates work
  * marginal vs cumulative tax burden

### Design Implications

* Prioritize:

  * **$ per year**
  * **comparisons**
  * **deltas**
* Avoid:

  * technical tax terminology without translation
* Always translate:

  * “$X per $100k AV” → **“$Y per year for a typical household”**

---

## 3. Platform Constraints

* Must run on GitHub Pages
* No server-side code
* No external database
* All computation must be client-side
* Single-page application using:

  * HTML
  * CSS
  * JavaScript

---

## 4. Core Interaction Model

### Matrix-Based Estimation

The primary interface is a **2D matrix**:

* Rows: Assessed Value (AV) bands
* Columns: Square Footage (sqft) bands
* Cells: **Total annual cost of selected measures**

Users:

1. Select tax/bond measures (checkboxes)
2. Optionally enter monthly taxable spending
3. Click a matrix cell (approximate household)
4. View:

   * current annual cost
   * projected future costs

---

## 5. Critical Requirement: Sticky Cell Selection

* Clicking a matrix cell sets:

  * AV band
  * sqft band

* This selection must:

  * persist across all interactions
  * remain active when:

    * measures are toggled
    * inputs are changed

* The chart and breakdown must:

  * **update automatically**
  * **without requiring re-selection**

---

## 6. Measure Definitions (Inline Only)

All measures must be defined directly in JavaScript (no external JSON file).

Each measure definition must include:

* A human-readable `description` string explaining:
  * The rate in plain language (e.g., "$22 per year per $100k of assessed value")
  * What the tax applies to
  * Duration / expiration
  * Typical household dollar impact
* A `shortLabel` string (≤ 20 chars) for use in chart annotations

---

## 7. Measures to Include

### 7.1 Tier 1 — Active Berkeley Proposals

**(must be included and enabled by default)**

#### A. Berkeley Infrastructure Bond

* Size: ~$300M
* Type: AV-based
* Rate: ~$22 per $100k AV
* Duration: 30 years (assume)
* Label: “Berkeley Infrastructure Bond (draft)”

#### B. Berkeley Sales Tax

* Type: sales tax
* Rate: +0.5%
* Label: “Berkeley Sales Tax (draft)”

---

### 7.2 Tier 2 — Highly Probable Regional Measure

#### C. Regional Transit Tax (BART / AC Transit / MTC)

* Type: sales tax
* Rate: +0.5%
* Duration: ~14 years
* Label: “Regional Transit Tax (probable)”

---

### 7.3 Tier 3 — Plausible Additional Measures

**(included but off by default)**

#### D. BUSD Parcel Tax (placeholder)

* Type: flat parcel tax
* Default: $300/year
* Label: “BUSD Parcel Tax (placeholder)”

#### E. BUSD Bond (placeholder)

* Type: AV-based
* Default: $15 per $100k AV
* Label: “BUSD Bond (placeholder)”

#### F. Alameda County Measure (placeholder)

* Type: sales tax
* Default: +0.25%
* Label: “Alameda County Measure (placeholder)”

---

## 8. Computation Rules

### 8.1 AV-Based Measures

```
annual_cost = (AV / 100000) * rate
```

### 8.2 Sqft-Based Measures

```
annual_cost = sqft * rate
```

### 8.3 Flat Parcel Taxes

```
annual_cost = flat_amount
```

### 8.4 Sales Taxes

User input:

* monthly taxable spending

```
annual_cost = monthly_spending * 12 * rate
```

---

## 9. Matrix Specification

### AV Bands

* Range: $300k – $2.5M
* Step: $50k

### Sqft Bands

* Range: 800 – 4000 sqft
* Step: 100 sqft

### Cell Calculation

Each cell uses:

* midpoint AV
* midpoint sqft

```
total_cost = sum(all selected measures)
```

---

## 10. Chart Behavior

### Trigger

* Clicking a matrix cell

---

### Projection

* Default horizon: 30 years

---

### Growth Assumptions

#### AV Growth

* Default: 2% annually

#### Spending Inflation

* Default: 3% annually
* User configurable

---

### Yearly Logic

* AV grows at 2%
* Spending grows at inflation rate
* Measures expire after duration

---

### Output

* Line chart:

  * X: years
  * Y: annual cost

---

### Tooltip Interaction

* Tooltip must fire when the cursor is anywhere in the vertical column of a year — not just when hovering directly on a data point
* Implementation: `interaction: { mode: 'index', intersect: false }`

---

### Expiry Annotations

* For each selected measure with a finite duration that falls within the projection window:
  * Draw a vertical dashed line at the expiry year
  * Label it with the measure's `shortLabel` + " ends" (e.g., "Transit Tax ends")
  * Style: red dashed line, small white-background label at the top of the line
* Purpose: make visible why the projected cost drops at certain years

---

## 11. UI Layout

### 11.1 Top Control Panel

* Measure checkboxes (grouped by tier)
* Each checkbox row includes an expandable info toggle (▸ / ▾):
  * On click: reveals a description panel explaining the measure in plain language
  * Description includes: rate, what it applies to, duration, and a typical dollar example
  * Collapses on second click
* Monthly spending input
* AV growth input
* Inflation input
* Projection years

---

### 11.2 Matrix Panel

* Scrollable grid
* Sticky headers
* Hover highlight
* Clickable cells
* Selected cell visibly marked

---

### 11.3 Detail Panel

Displays:

* Selected AV band
* Selected sqft band
* Current annual cost
* Line chart

---

## 12. Required Sidebar

### 12.1 Scenario Summary

* Selected measures
* Total current cost
* Projected cost at end of horizon

---

### 12.2 Measure Breakdown Table

| Measure | Annual Cost | % of Total |

---

### 12.3 Assumptions

* AV growth
* Spending inflation
* Time horizon

---

### 12.4 Reset Controls

* Clear selected cell
* Reset inputs

---

## 13. Scenario Presets

Provide quick toggles:

* “City Only”
* “City + Transit”
* “Full Plausible 2026 Ballot”

---

## 14. UX Requirements

* No page reloads
* Immediate updates on all changes
* Sticky selection persists
* Matrix updates when:

  * measures change
  * spending changes
* Chart updates automatically

---

## 15. Transparency

* All assumptions visible
* All rates labeled clearly:

  * “draft”
  * “probable”
  * “placeholder”

---

## 16. Performance

* Matrix render < 200ms
* No heavy frameworks required
* Prefer vanilla JS + lightweight charting

---

## 17. Mobile / Responsive Design

* Must be usable on phones and tablets
* At ≤ 768px viewport width:
  * Layout stacks vertically: control panel → matrix → detail chart → sidebar sections
  * Sidebar sections reflow to a wrapped row grid
  * Matrix remains horizontally scrollable with sticky headers
  * Chart touch target uses column-mode interaction (same as desktop)
  * No horizontal overflow of the page itself

---

## 18. Out of Scope (formerly 17)

* Exact tax bill prediction
* Property lookup
* Accounts or persistence
* Backend services

---

## 19. Success Criteria

The tool succeeds if:

* A user who does not know their AV can still estimate cost
* Users understand cumulative burden
* Users can explore tradeoffs
* Users are not required to reselect their scenario

---

## 20. Governing Principle (Non-Optional)

The application must make visible:

* the **total stacked cost of all measures**
* not just individual measures in isolation

---

# Addendum: Incumbent Taxes & Renewal Treatment

## 21. Purpose

Extend the model to include **current (incumbent) taxes and bonds**, enabling users to view:

* Existing annual tax burden
* Incremental cost of new measures
* Total cost of ownership

---

## 22. Incumbent Tax Structure (Three-Part Model)

### 22.1 Base Property Tax (Permanent)

* California constitutional property tax (Prop 13)
* Rate: **1.0% of assessed value** (`AV * 0.01`)
* Permanent — no expiration
* Label: "Base Property Tax (1.0% AV)"

### 22.2 Existing Voter-Approved Bonds (Finite Cohorts)

Modeled as three staggered cohorts. Total baseline ≈ $80 per $100k AV.

| Cohort     | Rate ($ per $100k AV) | Expiration |
| ---------- | --------------------- | ---------- |
| Short-term | $25                   | 5 years    |
| Mid-term   | $30                   | 12 years   |
| Long-term  | $25                   | 25 years   |

* Must expire on schedule — not assumed to renew
* Label: "Existing Bonds (est., expiring over time)"
* Displayed as a single aggregated row in the breakdown table; modeled as three cohorts internally for accurate step-downs in the chart

### 22.3 Existing Taxes (Modeled as Persistent)

#### Parcel Taxes

* Flat: **$1,000/year** (estimated aggregate)
* Modeled as renewing (duration = projection horizon)

#### Local Sales Taxes (Above State Base)

* Rate: **~3.0%** on monthly taxable spending
* Based on: Alameda County measures + Berkeley city add-ons
* Formula: `monthly_spending × 12 × 0.03`
* Modeled as renewing

---

## 23. Renewal Modeling Approach

For all **tax** measures (sales tax, parcel/flat):

```
duration = projection_horizon  (modeled as renewing)
```

For **bonds**:

```
duration = stated term (finite, expires on schedule)
```

This reflects the political reality that taxes historically renew while bonds have definite terms.

---

## 24. Disclosure Requirement (Non-Optional)

The following statement must appear in the UI (sidebar Assumptions section):

> "Taxes are modeled as continuing over time, reflecting historical renewal patterns. Bonds expire as scheduled. Actual future taxes may vary."

---

## 25. UI Integration

### 25.1 Baseline Toggle

A master toggle in the control panel:

* Label: "Include current taxes & bonds"
* Default: **ON**
* When ON: all four incumbent components are included in all calculations
* When OFF: only proposed measures are shown

### 25.2 Output Breakdown (when baseline included)

The sidebar summary displays three values:

```
Current taxes:   $X/year
+ New measures:  +$Y/year
─────────────────────────
Total:           $Z/year
```

The breakdown table is split into two labeled groups:
* **Current Taxes (est.)** — four rows (base tax, bonds aggregate, parcel, sales)
* **New Proposed Measures** — per-measure rows as before

### 25.3 Chart Behavior

When baseline is included:

* Total cost line includes incumbent measures
* Bond cohort expirations (yr 5, 12, 25) appear as vertical dashed annotations on the chart
* Incumbent bond annotations use a distinct style (muted gray) vs. proposed measure annotations (red)

---

## 26. Design Implications

* Users understand current vs. incremental burden
* Long-term cost does not artificially drop due to tax expiration (taxes persist)
* Bond step-downs remain visible in projections
* No additional complexity for the user — single toggle controls the entire baseline

---

## 27. Constraints

* No user-facing renewal toggle (renewal is not configurable)
* No per-measure toggles within the incumbent group
* No parcel-specific precision required
* Bond cohorts are estimated aggregates, not itemized

---

## 28. Governing Principle (Addendum)

The application must reflect:

* **Legal structure where necessary** — bonds expire as scheduled
* **Political reality where useful** — taxes are modeled as persisting

without increasing cognitive load for the user.

---

# Addendum: Jurisdictional Rollup & Refined Incumbent Modeling

## 30. Purpose

Replace the flat four-row incumbent breakdown with a jurisdictional rollup that:

* Matches how a real Berkeley property tax bill is organized
* Uses the accurate composite AV rate (1.2323%) with homeowners' exemption
* Separates percentage-based property taxes from flat annual charges
* Makes individual line items visible on demand (expandable)
* Provides plain-language explanations via "what is this?" tooltips per category

---

## 31. Updated Incumbent Computation Model

### 31.1 Homeowners' Exemption

California grants a **$7,000 reduction** in assessed value for owner-occupied homes:

```
taxable_av = max(0, av - 7_000)
```

All AV-based incumbent measures apply this exemption (type: `av_exempt`).

### 31.2 Composite AV Rate

Total: **1.2323%** of taxable AV, broken into:

| Component              | Rate      | Duration  |
| ---------------------- | --------- | --------- |
| Prop 13 base           | 1.0000%   | Permanent |
| Bond debt overlay      | 0.2323%   | Expires   |

Bond debt overlay modeled as three staggered cohorts:

| Cohort     | Share | Rate (of 0.2323%) | Duration |
| ---------- | ----- | ----------------- | -------- |
| Short-term | 25%   | 0.058075%         | 5 years  |
| Mid-term   | 40%   | 0.09292%          | 12 years |
| Long-term  | 35%   | 0.081305%         | 25 years |

### 31.3 Fixed Annual Charges

Total: **~$4,800/year**, split into three groups:

| Group           | Amount   |
| --------------- | -------- |
| City Services   | $2,225   |
| Schools         | $1,500   |
| Regional        | $1,075   |

---

## 32. Jurisdictional Sub-Items (Named Line Items)

### 32.1 Property Taxes (AV-based, rate × taxable AV)

| Jurisdiction               | Rate      | Note        |
| -------------------------- | --------- | ----------- |
| State / County Base (Prop 13) | 1.0000% | Permanent   |
| County Admin               | ~0.01%    | Permanent   |
| City of Berkeley           | ~0.06%    | Permanent   |
| School Districts           | ~0.115%   | Permanent   |
| BART / Transit             | ~0.0473%  | Permanent   |
| Voter-Approved Bond Debt   | ~0.2323%  | Expires 5–25 yrs |

### 32.2 Fixed Charges (City Services — $2,225/yr)

| Line Item                   | Amount |
| --------------------------- | ------ |
| Library Services (City)     | $298   |
| Parks & Landscaping (City)  | $150   |
| Fire & Emergency Services   | $845   |
| Wildfire Prevention (City)  | $532   |
| Street Repair (City)        | $400   |

### 32.3 Fixed Charges (Schools — $1,500/yr)

| Line Item                   | Amount |
| --------------------------- | ------ |
| School Programs (BSEP)      | $672   |
| Teacher Support (Schools)   | $480   |
| School Facilities Maint.    | $218   |
| Community College (Peralta) | $130   |

### 32.4 Fixed Charges (Regional — $1,075/yr)

| Line Item                   | Amount |
| --------------------------- | ------ |
| AC Transit Funding          | $96    |
| Sewer & Stormwater          | $490   |
| Mosquito & Vector Control   | $29    |
| Bay Restoration Program     | $12    |
| Regional Parks Funding      | $448   |

---

## 33. Sidebar Breakdown Display

### 33.1 Two-Category Rollup Structure

The incumbent section of the breakdown table is replaced by two category rows:

1. **Property Taxes** — percentage-based, shows sum, always expanded with sub-items
2. **Fixed Annual Charges** — flat total, collapsed by default, expandable via ▸/▾ toggle

Each category row shows:
* Category label
* Total dollar amount
* Percentage of overall total
* "what is this?" link (opens floating tooltip)

### 33.2 Static Tooltip Text per Category

**Property Taxes tooltip:**
> "Berkeley property owners pay a composite rate of ~1.2323% of assessed value (after the $7,000 homeowners' exemption). This covers the California Prop 13 base (1.0%) plus the current voter-approved bond debt service overlay (~0.2323%). The bond portion steps down as existing bonds mature over the next 25 years."

**Fixed Annual Charges tooltip:**
> "In addition to percentage-based property taxes, Berkeley homeowners pay roughly $4,800 per year in flat parcel taxes and special assessments. These cover city services, school programs, and regional programs. Unlike bonds, these taxes are modeled as renewing, reflecting the historical pattern that parcel taxes are regularly extended by voters."

### 33.3 Sub-Item Display

When expanded, each sub-item row shows:
* Item name
* Note (rate/type/renewal status)
* Dollar amount

---

## 34. Technical Implementation

### 34.1 Data Structures

Two parallel arrays replace the former INCUMBENT + INCUMBENT_BREAKDOWN:

**INCUMBENT_COMPUTE** — drives all math (7 entries):
* 4 AV-based entries (type: `av_exempt`, decimal rates)
* 3 flat entries (type: `flat`, dollar amounts)

**INCUMBENT_ROLLUP** — drives display (2 category entries):
* Each has: `id`, `label`, `note`, `tooltip`, `computeIds[]`, `subitems[]`
* Fixed-charges category additionally has: `expandable: true`

### 34.2 New Measure Type: `av_exempt`

```javascript
case 'av_exempt': return Math.max(0, curAV - HO_EXEMPTION) * m.rate;
```

### 34.3 Expand State

```javascript
const expandedRollup = new Set();
```

Persists across re-renders. Toggled by clicking ▸/▾ buttons in the breakdown.

### 34.4 Floating Tooltips

One `position: fixed` panel per category, appended to `<body>` at init. Hidden by default. Shown on "what is this?" click, positioned below the trigger button. Closed by `closeAllDescs()`.

---

## 35. Bond Disclosure

The following statement must appear in the sidebar Assumptions section (in addition to the renewal disclosure from section 24):

> "Property tax rates shown are estimates based on publicly available Alameda County rate data. Bond debt service rates decline as existing bonds mature."

---

## 36. Naming Conventions

* Category labels use plain English (e.g., "Property Taxes", "Fixed Annual Charges")
* Sub-item labels identify the jurisdiction in parentheses: e.g., "Library Services (City)"
* Notes are concise: e.g., "1.0% · permanent", "parcel tax · renewing"
* No acronyms without expansion on first use in tooltips

---

## 37. Constraints

* Property Taxes sub-items are always visible (not collapsible)
* Fixed Charges sub-items are collapsed by default; user must expand to see
* No per-sub-item toggles
* Tooltip content is static — not computed from inputs

---

## 38. Governing Principle (Second Addendum)

The breakdown must give users enough detail to understand *what* they are paying without overwhelming them. The two-category structure with progressive disclosure (expandable fixed charges) achieves this without adding cognitive load.

---

## 39. Bond Modeling Disclosure (Non-Optional)

The sidebar Assumptions section must include both:

1. The renewal disclosure (section 24): taxes modeled as continuing; bonds expire as scheduled
2. A rate-precision disclaimer: property tax rates are estimates based on publicly available data; actual bills may vary

---

# Addendum: Square Footage–Based Tax Modeling

## 40. Purpose

Incorporate **square footage–dependent taxes** using **published per-square-foot rates** where available, ensuring the model reflects actual Berkeley tax structure and that changing square footage produces a material change in totals.

---

## 41. Dependency Types

Each tax or measure declares one of:

* `av_exempt` — rate × max(0, AV − $7,000 homeowners' exemption)
* `sqft_based` — rate × building sqft
* `flat` — fixed dollar amount per year
* `sales_tax` — rate × monthly spending × 12

---

## 42. Square Footage–Based Taxes (Implemented)

### 42.1 City of Berkeley (published rates)

| Measure                      | Rate ($/sqft) |
| ---------------------------- | ------------- |
| Library Services             | $0.28         |
| Library Funding Measure 2024 | $0.06         |
| Parks & Landscaping          | $0.265        |
| Street Repair & Maintenance  | $0.15         |

### 42.2 School Parcel Taxes (estimated, normalized to sqft)

| Measure                    | Rate ($/sqft) |
| -------------------------- | ------------- |
| School Programs (BSEP)     | ~$0.44 est.   |
| Teacher Support Funding    | ~$0.30 est.   |
| School Facilities Maint.   | ~$0.14 est.   |

### 42.3 Regional (linear approximation)

| Measure           | Rate ($/sqft) |
| ----------------- | ------------- |
| Sewer & Stormwater | ~$0.163 est. |

---

## 43. Flat Charges (no sqft dependency)

| Measure                     | Amount/yr |
| --------------------------- | --------- |
| Fire & Emergency Services   | $845      |
| Wildfire Prevention         | $532      |
| Community College (Peralta) | $130      |
| AC Transit Funding          | $96       |
| Mosquito & Vector Control   | $29       |
| Bay Restoration Program     | $12       |
| Regional Parks Funding      | $448      |

---

## 44. Calculation Rule

```
annual_cost = rate_per_sqft × sqft          (sqft_based)
annual_cost = flat_amount                    (flat)
total_fixed = Σ(sqft_based_items) + Σ(flat_items)
```

---

## 45. Technical Implementation

INCUMBENT_COMPUTE expanded from 7 to 19 entries. Former aggregate flat entries (`fixed_city`, `fixed_sch`, `fixed_reg`) replaced by per-item entries with correct types. INCUMBENT_ROLLUP subitems updated to reference per-item `computeIds`; `rawCost` is called with actual sqft throughout the display pipeline.

---

## 46. Constraints

* Linear formula only — no nonlinear runoff coefficients
* School rates labeled "est." to indicate normalization
* Stormwater rate labeled "est." — actual charge depends on impervious surface area

---

## 47. Success Criteria

* Changing sqft in the matrix produces materially different totals in matrix cells, detail panel, and sidebar
* Sqft affects only sqft-based measures; flat and AV-based measures are unaffected by sqft changes
