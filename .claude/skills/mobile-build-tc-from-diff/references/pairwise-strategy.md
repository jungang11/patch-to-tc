# Pairwise Strategy

When a change affects multiple **independent variables** (device × OS version × locale × account state × network), the combinatorial space explodes. Testing all combinations is wasteful; testing one is insufficient. **Pairwise testing** (a.k.a. all-pairs) gets ~90% of the defect-detection benefit with a fraction of the test count.

SKILL.md Stage 3 (Generate) consults this file. Apply pairwise reduction only when the trigger conditions below are met — Build Gate and Smoke TCs are never pairwise-reduced.

---

## When to apply pairwise

Trigger pairwise reduction when a single feature/change has **all** of the following:

- ≥ 3 axes (device class, OS version, locale, account state, network condition, etc.)
- ≥ 2 values per axis
- TC type is `Regression` or `Edge` (never `Build Gate` or `Smoke`)

If fewer than 3 axes vary, generate per-value TCs without reduction. If 3+ axes vary with ≥ 2 values each, apply the heuristic below.

---

## Algorithm (informal heuristic)

The skill does not need true pairwise math — produce a "good enough" reduced set:

1. List all axes and their values.
2. Generate one TC per value of the **most critical axis** (typically device class for mobile QA).
3. For each subsequent axis, distribute its values across the existing TCs so every pair (this axis × each prior axis) is covered at least once.
4. Cap total TCs at `N ≈ max(axis_value_count) × 2`.

For exact pairwise generation, tools like PICT or pypict exist. The skill author MAY add such an integration in a future version; for v0.1 the heuristic above is sufficient.

---

## Concrete example

Consider an `addressables-cache` change with 5 axes:

| Axis | Values |
|---|---|
| Device class | `low-end`, `high-end` |
| OS version | `Android 10`, `Android 14` |
| Locale | `en`, `ja` |
| Cache state | `empty`, `populated` |
| Network | `wifi`, `cellular` |

Full combinatorial: 2⁵ = 32 TCs. Excessive — and the cap from SKILL.md (30 per invocation) would clip it anyway.

Pairwise-reduced set (4 TCs covering all pairs at least once):

| TC | Device | OS | Locale | Cache | Network |
|---|---|---|---|---|---|
| AND-cache-001 | low-end | Android 10 | en | empty | wifi |
| AND-cache-002 | low-end | Android 14 | ja | populated | cellular |
| AND-cache-003 | high-end | Android 10 | ja | populated | wifi |
| AND-cache-004 | high-end | Android 14 | en | empty | cellular |

Every pair of axis-values appears at least once across the four rows. This is the structure the skill should produce.

---

## Documentation pattern

TCs that are part of a pairwise set must signal this in the output, so reviewers can see the matrix structure:

- Prefix the Title with `[pairwise-set: <set-name>]`, **or**
- Add the set name to the `Source/Risk` column (e.g., `pairwise-set: addressables-cache-v2.3`).

Without this signal, a reviewer might add a "missing combination" TC that the pairwise set deliberately omitted, defeating the reduction.

---

## Anti-patterns

- **Pairwise on Build Gate or Smoke.** These are mandatory single-purpose checks and are never reduced.
- **Pairwise on 2 axes.** Full combinatorial is small enough (2² = 4) to test directly. Pairwise saves nothing.
- **Hiding the matrix.** A pairwise-reduced TC without the `pairwise-set` indicator looks like a complete coverage gap to reviewers. Always document.
- **Treating pairwise as a quality replacement for focused TCs.** Pairwise is scenario coverage, not feature coverage. A bug in the happy path of `high-end / Android 14` still needs its own focused TC.
