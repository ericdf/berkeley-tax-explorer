# taximpacts

Single-page calculator estimating what proposed Berkeley/regional tax measures would cost
a household, by assessed value and square footage. Everything lives in `index.html` —
no build step, no external data files. `specification.md` is the design spec.

## Deferred work

### Revive the "Full Plausible Ballot" preset (revisit next year)

There used to be three scenario presets: City Only, City + Transit, and "Full Plausible
2026 Ballot". The third one existed to model measures that were *anticipated but had not
yet qualified* for the ballot — the "everything, including the speculative stuff" case.

As of the 2026 cycle every measure modeled has qualified, so that preset selected exactly
the same set as the all-measures preset and was retired rather than shown as a duplicate
button. The presets are now **City Only** and **All**.

**Revive it when we are next in the run-up to qualification** and there is at least one
modeled measure that has not yet qualified. That restores the distinction users actually
want: *what is definitely on the ballot* vs. *what might also land there*.

Both the preset entry and its button are commented out in place, in `index.html` —
search for `full-plausible`.

## Conventions

- **Tiers** group measures in the sidebar and are driven purely by data. Rendering keys
  off `tierLabel` (first measure in a tier carries the label, rest are `null`), and array
  order determines display order — so moving a measure between tiers means moving its
  object, not just editing `tier`.
  - Tier 1 Council-initiated, Tier 2 Citizen-initiated, Tier 3 Regional,
    Tier 4 Informational.
  - Any preset that includes city measures includes **both** Tier 1 and Tier 2 — they are
    both city measures and are never split apart.

- **Tags** (`tag:`) mark certainty. Currently only `ballot` is in use: on the ballot, with
  rates taken from actual measure text rather than estimated. The mechanism is retained for
  future measures at a lesser stage of certainty. Add a matching `.tag-<name>` style and a
  `TAG_CLASS` entry when introducing one.

- **Informational measures** (`informational: true`, `type: 'informational'`) are real
  measures whose household cost this model cannot compute — e.g. the sugar-sweetened
  beverage tax, which is levied on distributors, so household cost depends on retailer
  pass-through and consumption rather than on AV/sqft/spending. They render **without a
  checkbox** so they can never enter any total, and give a per-unit anchor in the
  description instead of an annual figure.

- **Rates from measure text** should carry a section citation in a trailing comment
  (see `arts_parcel`). Estimated rates should say so in the description.

- The dashed baseline in the projection chart is the incumbent-only counterfactual
  (`projectCosts(..., includeProposed = false)`) — it tracks AV growth and bond
  step-downs, so it is not flat. Both it and the header delta are suppressed when the
  baseline toggle is off, since `incumbentTotal` returns 0 there.

- Bond debt service is modeled as three invented cohorts (25/40/35% at 5/12/25 years)
  splitting one published aggregate rate, not real amortization schedules. **Do not build
  bond-renewal modeling on top of this** without real per-issue debt-service data — it
  would compound one guess with another.
