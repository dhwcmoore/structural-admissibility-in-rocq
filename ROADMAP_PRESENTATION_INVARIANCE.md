# Beyond Refinement: Presentation-Invariant Obstruction Theory

## Strategic Vision

The **universal refinement theorem** solves one-directional persistence: an obstruction [r] survives upward under admissible refinement.

The next step is **bidirectional presentation invariance**: two different descriptions of the same boundary regime give the same obstruction verdict, regardless of how the regions are subdivided, oriented, or connected.

This transforms the work from:
- "This residue survives four refinements" (tactical)
- **to** "Obstruction is a natural invariant of admissible boundary regimes" (theoretical)

**Critical distinction**: 
- Residues and obstruction classes $[r] \in H^1(N; \mathbb{Q})$ (cohomology)
- Detecting cycles $z \in H_1(N; \mathbb{Q})$ (homology)

---

## The Core Theorem Chain

### Current (Phase 1): Universal Refinement Persistence

**Theorem 1: Witness-Specific Refinement Persistence**

Given a refined cycle $z' \in C_1(N'; \mathbb{Q})$ with $\partial' z' = 0$ and $\rho_* z' = z$, if pairing adjointness holds:
$$[r] \neq 0 \implies [\rho^* r] \neq 0$$

**Focus**: Certificate-level theorem; what the verification tools prove.

**Theorem 2: Universal Admissible-Refinement Persistence**

If a refinement $\rho : N' \to N$ satisfies the four admissibility conditions, then the pullback on cohomology is injective:
$$\rho^* : H^1(N; \mathbb{Q}) \hookrightarrow H^1(N'; \mathbb{Q})$$

Equivalently, the induced map on homology is surjective:
$$\rho_* : H_1(N'; \mathbb{Q}) \twoheadrightarrow H_1(N; \mathbb{Q})$$

**Focus**: General theorem; applies to any single admissible refinement.

### Next (Phase 2): Common-Refinement Invariance

**Theorem 3: Common-Refinement Invariance**

Let $N_1$ and $N_2$ be two admissible presentations of the same boundary regime.

Suppose there exists a common admissible refinement $N_{12}$ with refinement maps:
$$\rho_1 : N_{12} \to N_1, \quad \rho_2 : N_{12} \to N_2$$

Each $\rho_i$ is admissible, so the induced pullbacks on cohomology are injective:
$$\rho_i^* : H^1(N_i; \mathbb{Q}) \to H^1(N_{12}; \mathbb{Q})$$

If the obstruction residues satisfy:
$$[\rho_1^* r_1] = [\rho_2^* r_2] \in H^1(N_{12}; \mathbb{Q})$$

Then:
$$[r_1] \neq 0 \quad \Longleftrightarrow \quad [r_2] \neq 0$$

**Meaning**: Two models of the same boundary defect cannot disagree about whether obstruction is real, provided they are admissibly comparable via a common refinement.

**Proof**:

1. Assume $[r_1] \neq 0$ in $H^1(N_1; \mathbb{Q})$.
2. Then $\rho_1^* [r_1] \neq 0$ in $H^1(N_{12}; \mathbb{Q})$ by injectivity of $\rho_1^*$.
3. By assumption, $[\rho_1^* r_1] = [\rho_2^* r_2]$, so $\rho_2^* [r_2] \neq 0$.
4. By injectivity of $\rho_2^*$, we conclude $[r_2] \neq 0$ in $H^1(N_2; \mathbb{Q})$.
5. The reverse implication is symmetric.

**Key fact**: Injectivity of $\rho_i^*$ follows from admissibility, specifically the H₁-surjectivity condition $\rho_* : H_1(N_{12}) \twoheadrightarrow H_1(N_i)$ on the chain side.

### Beyond (Phase 3): Functorial Obstruction Assignment

**Theorem 4: Functorial Obstruction Assignment**

Define a contravariant functor:
$$\mathcal{O} : \mathbf{AdmReg}^{\text{op}} \to \mathbf{Vect}_{\mathbb{Q}}$$

where:
- $\mathbf{AdmReg}$ is the category of admissible regional presentations with admissible refinements as morphisms
- $\mathcal{O}(N) = H^1(N; \mathbb{Q})$
- Each admissible refinement $\rho : N' \to N$ induces $\rho^* : H^1(N; \mathbb{Q}) \to H^1(N'; \mathbb{Q})$

Then:
> **Presentation-invariant obstruction classes are compatible families under this functor.**

In other words: a coherent assignment of obstruction classes across all admissible presentations is equivalent to a natural transformation from the constant functor (assigning $\mathbb{Q}$) to $\mathcal{O}$.

**Slogan**: Obstruction is not an artefact of representation; it is a natural element of the functorial system $\mathcal{O}$.

---

## Mathematical Foundations

### What Counts as "The Same Boundary Regime"?

Two presentations $N_1$ and $N_2$ are admissibly equivalent if:
1. They have the same underlying boundary geometry (same number of regions, same adjoin structure, same hole/source/seam topology).
2. They admit a common admissible refinement $N_{12}$ that properly compares both.

### What Makes a Refinement "Admissible"?

Four structural conditions:
1. **Cochain map**: $\delta' \rho^* = \rho^* \delta$ (pullback respects coboundaries)
2. **Chain map**: $\partial \rho_* = \rho_* \partial'$ (pushforward respects boundaries)
3. **Pairing adjointness**: $\langle z', \rho^* r \rangle = \langle \rho_* z', r \rangle$ (pairings preserved)
4. **H₁-surjectivity**: $\rho_* : H_1(N'; \mathbb{Q}) \twoheadrightarrow H_1(N; \mathbb{Q})$ (cycles lift)

These are **not** extra assumptions; they characterize when a refinement is structure-preserving.

### Examples of Admissible Refinements (All Four Paper Witnesses)

| Refinement | Example | Conditions | Coarse Pairing | Refined Pairing |
|---|---|---|---|---|
| Edge subdivision | Subdivide $U_1$'s shared edge | ✅✅✅✅ | $-5$ | $-7/2$ |
| Full subdivision | Subdivide all edges | ✅✅✅✅ | $-5$ | $-5/4$ |
| Bridge insertion | Add bridge edge | ✅✅✅✅ | $-5$ | $-5$ |

**All four satisfy the four conditions**, making them all valid examples of the universal theorem.

### Examples of Non-Admissible Refinements

- **H₁-killing refinement**: Add an edge that creates a homology between seams (violates cond 4).
- **Broken adjointness**: Refine in a way that changes the pairing without geometric justification (violates cond 3).
- **Non-naturality**: Map that respects boundaries locally but not globally (violates cond 1 or 2).

These do **not** preserve obstruction, and the theory correctly excludes them.

---

## From Single Witness to Presentation Invariance

### Step 1: Universal Refinement (Current Paper)
$$\text{Admissible } \rho \implies [\rho^*r] \neq 0$$

**Strength**: Applies to any admissible refinement of any regional presentation.

**Limitation**: Only goes upward. Doesn't show different downward refinements agree.

### Step 2: Common Refinement Comparison (Next Paper)
$$N_1, N_2 \text{ admissibly equivalent with common refinement } N_{12} \implies [\rho_1^*r_1] = [\rho_2^*r_2] \in H^1(N_{12})$$

**Strength**: Bidirectional; shows two models agree when properly compared.

**Key insight**: Different subdivisions, orientations, or region layouts cannot change whether obstruction is real.

### Step 3: Functorial Theory (Paper After Next)
$$\mathcal{O}(N_1) \cong \mathcal{O}(N_2) \text{ when } N_1, N_2 \text{ are admissibly equivalent}$$

**Strength**: Obstruction lives in a natural, category-theoretic object independent of presentation.

**Key insight**: Analogous to homology being independent of triangulation choice.

---

## Paper 1: Clean Theorem Chain (Scope Frozen)

### What Paper 1 Includes

**Core Structure** (final form):

1. **Theorem 1: Witness-Specific Refinement Persistence**
   - Given: refined cycle lifting, pairing adjointness
   - Prove: $[r] \neq 0 \implies [\rho^* r] \neq 0$
   - Role: certificate-level theorem

2. **Theorem 2: Universal Admissible-Refinement Persistence**
   - Given: four admissibility conditions (cochain map, chain map, adjointness, H₁-surjectivity)
   - Prove: $\rho^* : H^1(N; \mathbb{Q}) \hookrightarrow H^1(N'; \mathbb{Q})$ is injective
   - Role: universal theorem

3. **Four Declared Witnesses**
   - Subdivide $U_1$: verify four conditions, compute pairings
   - Subdivide $U_2$: verify four conditions, compute pairings
   - Subdivide all: verify four conditions, compute pairings
   - Insert bridge: verify four conditions, compute pairings
   - **Conclusion**: All four are instances of Theorem 2

4. **Scope Note** (one paragraph only)
   - Statement: "The next step is to show that these obstructions are presentation-invariant via common-refinement comparison. Two presentations of the same boundary obstruction will agree on non-obstruction if they admit a common admissible refinement. This extension is the subject of the companion paper on functorial boundary obstructions."
   - Do NOT include common-refinement machinery, Theorem 3, or functorial discussion

### What Paper 1 Does NOT Include

- ❌ Common-refinement invariance (Theorem 3)
- ❌ Functorial obstruction assignment (Theorem 4)
- ❌ Higher obstruction tower ($H^2$, $H^3$)
- ❌ Any functorial or natural transformation language
- ❌ Multiple presentation comparisons

### Paper 1 Goal

Win on one clear result: *"The four declared refinement witnesses are instances of a general admissible-refinement persistence theorem."*

Keep the theorems short, the proof elegant, and the scope honest.

---

## Publication Roadmap

### Paper 1: **Current Manuscript**
**Title**: *Associator Fields and Local-to-Global Failure in Finite Regional Cohomology*

**Core Results**:
- Associator field definition and obstruction detection
- Repair equation: $D\Theta = -\mathcal{A}$ (first-order linear regime)
- **Theorem 2: Universal Admissible-Refinement Persistence** — four witnesses as instances of a single theorem
- Four witnesses (U₁ subdivide, U₂ subdivide, all subdivide, bridge) satisfy the four conditions
- Proof-carrying certificate format for verification

**Scope** (deliberately modest):
- Include universal refinement theorem (Theorem 2)
- Include brief paragraph: "The next step is to show that these obstructions are presentation-invariant via common-refinement comparison (Paper 2)."
- Do **NOT** include Theorems 3-4 (those are Paper 2 and Paper 3 material)

**Trust Level**: ✅ **Mathematically complete**; ⏳ Code scaffold; 🚫 Rocq not formally verified yet

**Audience**: Algebraic topology, categorical logic, verification communities

**Bottom line**: *This paper should say: "The four declared refinement witnesses are instances of a general admissible-refinement persistence theorem."*

---

### Paper 2: **Next Deliverable** (4-6 months)
**Title**: *Functorial Boundary Obstructions: Presentation-Invariant Certificates for Regional Gluing*

**Core Results**:
- Common-refinement comparison theorem (Theorem 3)
- Presentation-invariant obstruction classes: same verdict across admissibly comparable presentations
- Enhanced certificate format with multiple presentations + common refinement verification
- Proof-carrying obstruction records

**New Theorems**:
- **Theorem 3 (Common Refinement Invariance)**: If $N_{12}$ refines both $N_1$ and $N_2$ admissibly and pullbacks agree, then $[r_1] \neq 0 \iff [r_2] \neq 0$

**Implementation**: 
- Python certificate tracker showing two presentations + common refinement + pullback equality check
- Rocq formalization of Theorem 3 with rigorous proof
- VeriBound integration: enhanced certificates show obstruction persists across all admissible representation changes

**Trust Level**: ⏳ Awaiting implementation; 🚀 Rocq formalization to follow

**Audience**: Homological algebra, categorical informatics, formal verification

---

### Paper 3: **Longer Term** (12+ months later)
**Title**: *Higher Coherence Obstructions for Regional Gluing: From Seams to Associators to Pentagons*

**Core Results**:
- H²-level associator obstruction (triple-overlap consistency)
- H³-level coherence obstruction (pentagon/Mac Lane coherence laws)
- Obstruction tower: $\mathcal{O}^1 \to \mathcal{O}^2 \to \mathcal{O}^3 \to \cdots$
- Functorial assignment for higher tower
- Connection to higher category theory

**NOT in this paper** (defer to future):
- Nonlinear boundary regimes ($B^2 \neq 0$)
- Full deformation-theoretic analysis / Maurer-Cartan framework
- Higher categorical structures beyond three-fold coherence

**Why**: First-order linear theory is strong publication. Higher obstructions can follow. The nonlinear regime is mathematically natural but should be Paper 4 or later.

**Trust Level**: 🚀 To develop

**Audience**: Categorical coherence, higher category theory, algebraic topology

---

## Immediate Mathematical Target: Theorem 3

### Common Refinement Invariance Theorem (The Next Concrete Step)

**Statement**:

Let $N_1 = (R_1, S_1, L_1)$ and $N_2 = (R_2, S_2, L_2)$ be two admissible presentations of the same boundary regime (same topology of regions, seams, holes, and defects).

Assume there exist admissible refinements:
$$\rho_1 : N_{12} \to N_1, \quad \rho_2 : N_{12} \to N_2$$

forming a common refinement diagram:
```
      N₁₂
      / \
    ρ₁   ρ₂
    /     \
   N₁     N₂
```

Suppose the obstruction residues satisfy:
$$[\rho_1^* r_1] = [\rho_2^* r_2] \in H^1(N_{12}; \mathbb{Q})$$

Then:
$$[r_1] \neq 0 \in H^1(N_1; \mathbb{Q}) \quad \Longleftrightarrow \quad [r_2] \neq 0 \in H^1(N_2; \mathbb{Q})$$

**Proof**: 

If $[r_1] \neq 0$, then $\rho_1^* [r_1] \neq 0$ by injectivity of $\rho_1^*$. Equality gives $\rho_2^* [r_2] \neq 0$. Injectivity of $\rho_2^*$ then implies $[r_2] \neq 0$. The reverse implication is symmetric. ∎

---

## What This Means for Code and Certificates

### Current Certificate (Phase 1)

```json
{
  "verdict": "obstruction_persists",
  "coarse_obstruction_class": "[r_1] ≠ 0 in H¹(N)",
  "refined_obstruction_class": "[ρ*r] ≠ 0 in H¹(N')",
  "cochain_map_verified": true,
  "chain_map_verified": true,
  "pairing_adjointness_verified": true,
  "h1_surjectivity_verified": true,
  "cycle_lift_verified": true,
  "pairing_value_coarse": -5,
  "pairing_value_refined": -5,
  "admissible_refinement": true
}
```

**Trust**: Single witness to single refinement.

### Enhanced Certificate (Phase 2)

```json
{
  "verdict": "presentation_invariant_obstruction",
  "obstruction_is_real": true,
  "presentation_1": {
    "name": "four_cycle_subdivide_u1",
    "obstruction_class": "[r_1] ≠ 0 in H¹(N₁)",
    "cycle_pairing": -5
  },
  "presentation_2": {
    "name": "four_cycle_subdivide_u2", 
    "obstruction_class": "[r_2] ≠ 0 in H¹(N₂)",
    "cycle_pairing": -5
  },
  "common_refinement": {
    "name": "four_cycle_all_subdivisions",
    "pullback_from_1": "ρ₁*([r_1]) = [...] in H¹(N₁₂)",
    "pullback_from_2": "ρ₂*([r_2]) = [...] in H¹(N₁₂)",
    "cohomology_classes_agree": true
  },
  "admissible_transformations_checked": [
    "edge_subdivision",
    "region_refinement",
    "bridge_insertion",
    "coarse_containment"
  ],
  "verdict_invariant_under": "all_admissible_refinements"
}
```

**Trust**: Multiple presentations agree; defect is **not an artefact**.

---

## Why This Matters for VeriBound

### Current Claim (Phase 1)
> "Some fusion defects survive local refinement under specific subdivision schemes."

**Problem**: Sounds like it depends on the subdivision choice.

### Enhanced Claim (Phase 2)
> "Boundary coherence failures are **structural**: they persist across all admissible changes of regional representation, and two different models of the same failure agree."

**Strength**: Shifts from tactical ("this happens to work") to structural ("this cannot be removed").

### Operational Impact
When VeriBound detects a boundary defect:
1. Generate certificate showing defect exists in one presentation
2. Show certificate is invariant under admissible comparisons
3. Conclude: **Defect is non-removable by relabelling, aggregation, refinement, or reorientation**

That is the full story: from "we found something" to "it's structural."

---

## Implementation Priorities for Phase 2

### Immediate (Months 1-2)
1. **Prove Theorem 3 on paper** (common-refinement invariance)
2. **Formalize in Rocq** (should be short proof once Theorem 2 is done)
3. **Write Python certificate tracker** showing two presentations with common refinement

### Medium-term (Months 2-4)
4. **Test on extended examples**: 
   - Four-cycle with three different subdivision schemes
   - Different region labellings of same topology
   - Verify all pull back to same cohomology class in common refinement

5. **Rocq formalization** of functorial assignment $\mathcal{O}$

### Longer-term (Months 4-6)
6. **Begin obstruction tower** ($H^2$ for associator obstructions)
7. **Integrate with VeriBound** compliance engine

---

## Not for This Phase

### Do NOT Tackle Yet (Save for Paper 3)
- Higher cohomology ($H^2$, $H^3$) obstruction towers
- Nonlinear boundary regimes ($B^2 \neq 0$)
- Deformation theory / Maurer-Cartan framework
- Pentagon coherence equations

**Why**: These are mathematically natural but will make the paper significantly harder. First-order, presentation-invariant theory is already a strong publication. The tower can follow.

---

## The Big Picture

```
Phase 1: Universal Refinement
  ↓ [coarse r] ≠ 0  ⟹  [refined ρ*r] ≠ 0
  └─ Persistence under upward refinement (one direction)

Phase 2: Presentation Invariance
  ↓ [r₁] ≠ 0  ⟺  [r₂] ≠ 0 (when presentations admissibly comparable)
  └─ Obstruction is a natural invariant (bidirectional)

Phase 3: Higher Obstructions
  ↓ H¹ (seams) → H² (triples) → H³ (pentagons) tower
  └─ Full obstruction hierarchy (categorical structure)

VeriBound Integration
  ↓ Certificates showing structural non-removability
  └─ Operational proof of non-accidental boundary failures
```

---

## Bottom Line

> The universal refinement theorem says obstructions survive upward.
> 
> The common-refinement theorem says obstructions don't depend on which way you refine.
> 
> Together they say: **Obstruction is a structural, representation-invariant property of admissible boundary regimes.**

That is when the work stops being a clever finite example and becomes a real theory.

The next step is Theorem 3: **Common Refinement Invariance**.
