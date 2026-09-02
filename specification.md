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

### 7.1 Tier 1 — Council-initiated

**(must be included and enabled by default)**

#### A. Berkeley Infrastructure Bond

* Size: ~$300M
* Type: AV-based
* Rate: ~$22 per $100k AV
* Duration: 30 years (assume)
* Label: “Berkeley Infrastructure Bond (ballot)”

#### B. Berkeley Sales Tax

* Type: sales tax
* Rate: +0.5%
* Label: “Berkeley Sales Tax (ballot)”

---

### 7.2 Tier 2 — Citizen-initiated

**(enabled by default)**

#### C. Public Bank Parcel Tax

* Type: sqft-based
* Default: $0.06/sqft (dwelling units; other property types pay $0.09/sqft, not modeled)
* Duration: 6 years
* Label: “Public Bank Parcel Tax (ballot)”

#### D. Arts and Creative Economy Parcel Tax

The “2026 Berkeley Arts and Creative Economy Rescue and Sustainability Ballot Measure,”
a citizens’ initiative (Ord. §7.30.040) enacting Chapter 7.30. Rates and duration below
are taken from the ordinance text, not estimated.

* Type: sqft-based
* Rate: $0.07/sqft of improvements — the **same rate** for dwelling units and all other
  property including parking structures (§7.30.140(C))
* Duration: 12 years, commencing January 1, 2027 (§7.30.140(D))
* Proceeds: 75% performing arts rescue/sustainability, 10% capital projects, 5% arts
  organizations and individual artists, 5% community festivals, 5% administration
* Exemptions (**not** reflected in modeled figures; each requires annual petition):
  low-income owner-occupiers 65+, very-low-income owner-occupiers, tax-exempt religious
  organizations and schools, qualifying affordable and transitional housing
* Label: “Arts and Creative Economy Parcel Tax (ballot)”

---

### 7.3 Tier 3 — Regional

#### E. Regional Transit Tax (BART / AC Transit / MTC)

Multi-county measure raising an estimated $14 billion for mass transit over 14 years.

* Type: sales tax
* Rate: **+0.5% in Alameda County** (also Contra Costa, San Mateo, Santa Clara);
  San Francisco is +1%. Only the Alameda rate is modeled, since this tool models a
  Berkeley household.
* Duration: 14 years
* Label: “Regional Transit Tax (ballot)”

---

### 7.4 Tier 4 — Informational (not modeled)

**(listed for completeness; no checkbox, never included in any total)**

Real measures whose household cost this model cannot compute. They are shown so the
ballot picture is complete, but they have `type: 'informational'` and are rendered
without a checkbox so they can never enter the matrix or the projections.

#### F. Sugar-Sweetened Beverage Tax Increase

* Type: informational — not modeled
* Replaces the existing $0.01/fl oz general tax with a $0.02/fl oz special tax on
  distribution of sugar-sweetened beverages
* Exemptions retained: small retailers, milk products, baby formula, alcoholic
  beverages, medical and weight-loss products
* Estimated revenue: ~$2.2M annually; runs until repealed by the voters
* Label: “Sugar-Sweetened Beverage Tax Increase (ballot)”

**Why it is not modeled:** it taxes distributors, not property or general taxable
spending. Household impact depends on retailer pass-through (which varies by product
and store) and on household beverage consumption — none of which are model inputs.
The description gives a per-unit anchor (+$0.01/oz ≈ $0.12 per 12-oz can if fully
passed through) instead of a household annual figure.

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
* “All”

Any preset that includes city measures includes **both** Tier 1 (Council-initiated) and
Tier 2 (Citizen-initiated) — they are both city measures and are never split apart.

A third preset, “Full Plausible Ballot,” is commented out in `index.html`. It modeled
measures anticipated but not yet qualified; with every modeled measure now qualified it
duplicated “All”. Revive it during the next run-up to qualification — see `CLAUDE.md`.

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

  * “ballot” — approved for / filed for the ballot; rates come from actual measure text

All measures currently modeled are “ballot”. The tag mechanism is retained so a future
measure at a lesser stage of certainty can be distinguished.

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


---

# Addendum: Incumbent Levy Rebuild (September 2026)

## 48. Provenance

Sections 22, 32, 42 and 43 above are superseded for all incumbent (existing) charges.
Those figures were estimates that had been back-fit to round category subtotals
(City $2,225 / Schools $1,500 / Regional $1,075 = $4,800). Two were materially wrong:
a flat "$845 Fire & Emergency Services" and a flat "$532 Wildfire Prevention" charge,
neither of which exists — Berkeley assesses fire by square foot under Measures GG (2008)
and FF (2020). "Regional Parks $448" was wrong by roughly 37x.

The rebuilt values come from two primary sources:

* **City and BUSD rates** — the City of Berkeley published schedule, "City of Berkeley
  Property Tax Assessments & Fees for Tax Year 2026-2027"
  (https://berkeleyca.gov/city-services/report-pay/property-taxes). Residential rates,
  $/sqft of improvements, with each levy's published annual rate increase.
* **County and special-district flat charges** — line items on an Alameda County secured
  property tax bill for a Berkeley parcel, tax year 2025-2026. The bill is not archived
  in this repo (it identifies a specific parcel and owner); only the levy names and
  per-parcel dollar amounts, which are uniform across parcels, are carried here.

## 49. Reconciliation

Validated against that bill for a 2,192 sqft home at AV $625,042:

| | Model | Bill | Delta |
| --- | --- | --- | --- |
| Ad valorem @ 1.2323% | $7,616.13 | $7,616.12 | $0.01 |
| Fixed charges (adjusted to FY25-26 rates) | $4,808.91 | $4,787.90 | 0.4% |

The 0.4% residual is rounding of flat charges to whole dollars plus the estimated
stormwater charge. The building square footage backs out consistently at 2,192 across
every City levy, and 2,234 across the three BUSD levies (BUSD assesses a slightly
different footprint).

**The SAFE STREETS line on a FY2025-26 bill is 1.5x the annual rate.** Measure FF (2024)
took effect January 1, 2025, so that bill carries 18 months. The model uses the 12-month
annual rate, which is correct going forward.

## 50. Escalators

`rawCost()` takes an optional `yr` argument and compounds a levy's own published annual
rate increase. Year 0 is the current bill, so escalators have no effect on the headline
number — only on the projection. Most City levies escalate at 4.95%/yr; the Paramedic
Supplemental tax at 3.7975%. BUSD levies, county and special-district flat charges are
modeled as level, having no published escalator.

## 51. Known remaining estimates

* **Storm water** is modeled as a flat ~$91 (the sum of the bill's Clean Storm Water and
  2018 Storm Water lines). The real Clean Storm Water formula is
  `(lot sqft x $50.00 x runoff factor) / 2,196`, factor 0.4 for single residential — it
  depends on *lot* area, which this model does not collect. It is not a function of
  building square footage.
* **Bond debt cohorts** remain a synthetic 25/40/35 split of the observed 0.2323% overlay
  into 5/12/25-year maturities, so the chart steps down. Not derived from an actual bond
  schedule.
* **Refuse/Zero Waste** is billed on the property tax bill but varies by receptacle size
  and service frequency. Not modeled.
* Flat charges are rounded to whole dollars.

---

# Addendum: Measure U Tranche Model & Rate Sensitivity (September 2026)

## 52. Why Measure U is not a flat rate

Measure U was previously modeled as `av_based` at $44 per $100k AV for 30 years. That is
wrong in four ways, all traceable to the City's own Council report of December 2, 2025
(archived at `../council/sources/bonds/`):

1. **$44 is an average of the new bond AND existing authorizations**, not Measure U's
   marginal cost.
2. **It is a 40-year average (2027-2067)**, not a 30-year one.
3. **The bond ramps.** The City assumes "$100 million is issued every five years
   commencing in 2027," so only a third of the authorization is outstanding at first.
4. **Year one is the cheapest year**, which is precisely the number a flat model puts in
   the headline.

Measure U is now `type: 'av_tranches'` — three $100M tranches at offsets 0/5/10, each a
30-year obligation at ~$14 per $100k AV, calibrated so all three outstanding together
reproduce the ~$41-42/$100k peak visible in the City's published chart.

## 53. Interest rate sensitivity

GO bond debt service passes through to the secured roll "without limitation as to rate or
amount" (Official Notice of Sale, July 14, 2026). The coupon fixes at each sale — but
Measure U has three sale dates spread over a decade, so two thirds of the cost is priced
years after the election.

`bondRateFactor()` scales tranche rates by the ratio of level 30-year debt service at the
selected coupon to that at `BOND_RATE_BASE` (5.7%). The base is not arbitrary: it is the
coupon implied by the City's own $44 projection.

| Coupon | Factor | Peak on a $625k AV home |
| --- | --- | --- |
| 4.00% | 0.822 | $354/yr |
| 5.70% (base) | 1.000 | $431/yr |
| 8.00% | 1.263 | $544/yr |

## 54. The larger undisclosed assumption is assessed-value growth

Berkeley's net secured assessed value was $28.2B in FY2025 (ACFR FY2025, audited).
Solving the City's projection for the coupon at various AV growth assumptions:

| AV growth | AV by 2040 | Implied coupon |
| --- | --- | --- |
| none | $28.2B | 1.05% (impossible) |
| 4%/yr | $50.8B | 5.69% (plausible) |
| 6.39%/yr (FY25 actual) | $71.4B | 9.17% (implausible) |

The projection coheres only near 4%/yr AV growth with a ~5.7% coupon. **The $44 holds
because the tax base is assumed to nearly double by 2040, not because the borrowing is
cheap.** At 2%/yr growth the rate per $100k runs roughly a third higher at any coupon.
The report states neither assumption.

## 55. Communicating the ramp

Three changes, because a ramping cost inside a falling total is invisible:

* **Ramp warning** (`.ramp-warn`) — names the year-1 figure, the peak figure and the year
  it arrives, in plain language, whenever an `av_tranches` measure is selected.
* **Split summary rows** — the bond is separated from level parcel taxes, since blending
  them hides the only component that behaves differently.
* **Stacked chart** — existing taxes, level new measures, and the bond are drawn as
  stacked areas. The total falls as existing bonds mature; only stacking shows the new
  burden climbing underneath that decline. This is the same presentation the City's own
  chart uses, for the same reason.

---

# Addendum: Escalators, Renewal, and the Year Stepper (September 2026)

## 56. Every levy's trajectory is now determined

Section 48 rebuilt the incumbent levies from published rates but modeled twelve of them
as level, on the absence of a published rate increase rather than on evidence. That was
the same error as the invented $845 fire charge, in the other direction. Each has now
been checked against its own measure or district.

**Escalating** — rate rises every year:

| Levy | Rate | Source |
| --- | --- | --- |
| City: parks, library, library relief, emergency svcs, fire GG, fire FF, SAFE STREETS | 4.95% | City published rate increase |
| City: paramedic supplemental | 3.80% | City published rate increase |
| City: street lighting | 3.00% | rises; no published rate |
| City: 2018 Clean Stormwater Fee | 3.00% cap | CPI or 3%, whichever is lower |
| BUSD: Berkeley School Tax (Measure H 2024) | 3.00% | $0.5400 (FY25-26) to $0.55620 (FY26-27) |
| BUSD: School Maintenance (Measure H 2020) | 3.16% | $0.0910 to $0.10969 over six adjustments |
| BUSD: Educator Recruitment (Measure E 2020) | 3.16% | $0.1240 to $0.14944 over six adjustments |
| EBMUD Wet Weather | 4.00% | EBMUD published increase |
| Mosquito/vector (2008 assessment) | 3.00% cap | ACMAD Engineer's Report, Resolution 937-1 |
| Household hazardous waste | 3.00% | rises; no published rate |
| **Measure Z (public bank)** | **2.18%** | see below |

**Verified fixed** — no cost-of-living adjustment:

Peralta (Measure E 2018, $48/parcel for eight years), AC Transit (Measure VV, $96),
CSA Paramedic ($41), Regional Parks/EBRPD ($17), Bay Restoration/SFBRA AA ($12).
Measure Y (arts) is also fixed: the ordinance sets $0.07/sqft flat at §7.30.140(C) with
no adjustment clause, confirmed by reading the full initiative text.

The three BUSD rates are derived arithmetic, not assumptions: each measure's ballot text
confirms an annual cost-of-living adjustment, and the rate falls out of the starting rate
in the measure and the rate Berkeley publishes for tax year 2026-27. The two 2020
measures landing independently on 3.16% is the corroboration.

**Measure Z carries an escalator that was missed on the first pass.** The City Attorney's
impartial analysis states "The City Council would annually increase the tax rate based on
inflation." Neither the index nor a cap is given, so the rate is derived from the City's
own revenue estimates: $9.2M in the first year against $58.3M over six years reconciles
only at 2.18% annual growth.

Two amounts were also corrected against the county bill: household hazardous waste from
$18 to $8 (bill line $7.80) and mosquito/vector from $17 to $11 (three lines totaling
$11.20). Both had been rounded up when first transcribed.

## 57. Renewal is the default

Parcel taxes continue past their stated sunset dates unless the reader unchecks "Assume
taxes renew". Berkeley's record supports the default: Measure P (2018) carried a hard
sunset of January 1, 2029, and in November 2024 — four years early — Measure W removed
the expiration date entirely and raised the rates.

`effectiveDuration()` returns `statedDuration` only when the box is unchecked. Bond debt
service is exempt from the toggle: it repays a fixed principal and ends either way.

## 58. The year stepper

The tool's subject is the bill over time, so `state.viewYear` is first-class: the summary,
every per-measure row, and all 27 incumbent line items re-render at the selected year with
assessed value grown, spending inflated, escalators compounded and bond tranches phased in.
`costAtYear()` is the single entry point; stepper totals are verified to reconcile with
`projectCosts()` at every year.

Line items carry their trajectory — an up marker for anything that grows (rate escalator
or assessed-value based), a down marker for the maturing bond cohorts, nothing for a levy
that is fixed by its own terms. Once the reader steps off the current year each marked row
shows its growth to that point.

**All amounts are nominal** — the dollars of the year shown, not inflation-adjusted. This
is labeled in the bar and in the assumptions, along with which levies outpace inflation
and which do not.

## 59. Layout

The grid is a chooser: once a cell is picked it is replaced by the line-item breakdown in
three columns, under a sticky bar carrying the selection, a Change button, the year
stepper and the change against today. Fixed widths on the year label, the amount and the
delta keep the step buttons from moving under the cursor between clicks.
