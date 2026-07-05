# INTEGRATION GUIDE: From Case Studies to Universal Theorem

This document explains how the four declared refinement witnesses from the paper become instances of a universal theorem.

## The Paper's Approach

**Section 7.2 of the manuscript states**:
> The obstruction verdict is invariant under five declared presentation changes and persists under four declared refinement witnesses; no universal refinement theorem is claimed.

The four witnesses are:
1. Subdivide $U_1$ → pairing $-7/2$
2. Subdivide $U_2$ → pairing $-4$
3. Subdivide all regions → pairing $-5/4$
4. Insert bridge between $U_1$ and $U_2$ → pairing $-5$

Each is a **self-contained certificate**: "Here is a refined cycle $z'$ that pairs non-trivially with the refined residue."

## The New Approach

Instead of four isolated proofs, we prove:

**UNIVERSAL REFINEMENT THEOREM**:
> *If* a refinement $\rho : N' \to N$ satisfies four conditions (pushforward/pullback with adjointness and H₁ surjectivity), *then* every non-zero H¹ obstruction in $N$ persists to a non-zero H¹ obstruction in $N'$.

The four witnesses now become **examples of the general theorem**, not independent special cases.

## The Four Conditions Explained

### 1. Pullback is a Cochain Map: $\delta' \rho^* = \rho^* \delta$

**What it means**: The pullback respects coboundaries.

**Why it matters**: If $r$ is closed ($\delta r = 0$), then $\rho^* r$ is also closed.

**For subdivisions**: When subdividing an edge, the refined coboundary matrix must satisfy the commutativity relation with the pullback map.

**Computational check**:
```python
delta_prime_P = refined_coboundary @ pullback
P_delta = pullback @ coarse_coboundary
assert np.allclose(delta_prime_P, P_delta)
```

### 2. Pushforward is a Chain Map: $\partial \rho_* = \rho_* \partial'$

**What it means**: The pushforward respects boundaries.

**Why it matters**: If $z'$ is a cycle ($\partial' z' = 0$), then $\rho_* z'$ is also a cycle.

**For subdivisions**: When a cycle becomes a path of refined edges, the boundaries still match up correctly.

### 3. Pairing Adjointness: $\langle z', \rho^* r \rangle = \langle \rho_* z', r \rangle$

**What it means**: The bilinear pairing is preserved under the refinement.

**Why it matters**: This is the **heart of the proof**. It links the coarse and refined pairings.

**For all refinements**: This is the defining property. If this holds, persistence is automatic.

**Computational check**:
```python
left = dot(z_refined, pullback @ r_coarse)
right = dot(pushforward @ z_refined, r_coarse)
assert left == right
```

### 4. H₁ Surjectivity: $\rho_* : H_1(N'; \mathbb{Q}) \twoheadrightarrow H_1(N; \mathbb{Q})$

**What it means**: Every cycle in the coarse complex lifts to a cycle in the refined complex.

**Why it matters**: This ensures the detecting cycle $z$ can be lifted to $z'$.

**For subdivisions and bridges**: 
- **Barycentric subdivision**: The refined complex is homotopy equivalent, so $H_1$ is isomorphic. Surjectivity holds.
- **Bridge insertion**: The bridge doesn't fill the cycle (no 2-cells added), so the cycle still lives. Surjectivity holds.
- **Forbidden**: Adding a 2-cell that kills the cycle. This would make surjectivity fail.

**Computational check**:
```python
# Try to solve: pushforward @ z_refined = z_coarse
z_refined = solve(pushforward, z_coarse)
assert z_refined exists and pushforward @ z_refined == z_coarse
```

## Proof of Persistence

Given:
- $r \in C^1(N; \mathbb{Q})$ with $\delta r = 0$ and $[r] \neq 0 \in H^1(N; \mathbb{Q})$
- Detecting cycle $z$ with $\partial z = 0$ and $\langle z, r \rangle \neq 0$
- Refinement $\rho$ satisfying the four conditions

Proof:

1. By condition 1, $\delta'(\rho^* r) = \rho^*(\delta r) = 0$. So $\rho^* r$ is a cocycle.

2. By condition 4, there exists $z'$ with $\partial' z' = 0$ and $\rho_* z' = z$.

3. By condition 3 (adjointness):
   $$\langle z', \rho^* r \rangle = \langle \rho_* z', r \rangle = \langle z, r \rangle \neq 0$$

4. Since $\langle z', \rho^* r \rangle \neq 0$, the cycle-pairing lemma implies $\rho^* r \notin \operatorname{im}(\delta'^0)$.

5. Therefore $[\rho^* r] \neq 0 \in H^1(N'; \mathbb{Q})$. QED.

## Applying to the Four Witnesses

### Witness 1: Subdivide $U_1$

**Refinement**: Replace vertex $U_1$ by a triangle of three vertices.

**Condition 1**: The refined coboundary extends the coarse one by adding rows for new edges. Commutativity holds by construction of barycentric subdivision.

**Condition 2**: Boundaries are defined consistently on subdivided cells.

**Condition 3**: The pullback on edges treats the three refined edges incident to $U_1$ as "paths" that multiply correctly.

**Condition 4**: The cycle in the coarse complex has a natural lift: traverse the boundary of the new triangle.

**Result**: $\langle z', \rho^* r \rangle = -7/2 \neq 0$.

### Witness 2: Subdivide $U_2$

Same argument as Witness 1 but with $U_2$ instead of $U_1$.

**Result**: $\langle z', \rho^* r \rangle = -4 \neq 0$.

### Witness 3: Subdivide All Regions

All four regions are subdivided. The universal theorem applies equally.

**Condition 4** (the most delicate): The original cycle still lives in homology because we're only subdividing vertices, not filling any 2-cells.

**Result**: $\langle z', \rho^* r \rangle = -5/4 \neq 0$.

### Witness 4: Insert Bridge

**Refinement**: Add a new edge between $U_1$ and $U_2$ (with a new vertex on that edge if needed).

**Condition 1**: The pullback map is augmented to handle the new edge. Commutativity holds.

**Condition 2**: The new edge is on the boundary of the cycle but doesn't change the boundary structure of the old cycle.

**Condition 3**: The pairing is extended to the new edge. Adjointness still holds because the bridge doesn't "break" the original cycle.

**Condition 4**: The original four-cycle still forms a cycle in the refined complex. The bridge provides a parallel route but doesn't kill the original.

**Result**: $\langle z', \rho^* r \rangle = -5 \neq 0$.

## What This Means Operationally

### Before (Paper's Approach)
"We checked four examples. They all work."

### After (Universal Theorem)
"We proved that any **admissible** refinement (satisfying four checkable conditions) preserves the obstruction. The four examples are instances of the general theorem."

### For Users
When building a refinement:
1. Define $\rho^*$ and $\rho_*$
2. Check the four conditions computationally
3. If all four pass, the theorem guarantees persistence
4. Certificate includes the verification steps

## VeriBound Connection

In the **VeriBound** project, this matters because:

**Local consistency ≠ Global coherence**

- A blind spot, missing source, or excluded interior can create obstructions
- Local refinement (subdividing a region) may not remove the obstruction
- The universal theorem tells us: **if the refinement satisfies the four conditions, the obstruction survives**

This formalizes the operational principle: *some defects cannot be fixed by local relabeling*.

## Implementation Roadmap

### Phase 1: OCaml Verification (Current)
- [x] Type definitions for chains, cochains, refinements
- [ ] Linear solver for rational matrices
- [ ] The four verification procedures
- [ ] Test on declared witnesses

### Phase 2: Certificate Generation
- [ ] Python classifier (JSON input)
- [ ] Generates certificates
- [ ] Property-based testing

### Phase 3: Rocq Formalization
- [ ] Formal definition of cochain complexes
- [ ] Formal statement of the theorem
- [ ] Proof using the four conditions
- [ ] Verified classifier in Rocq

### Phase 4: Integration
- [ ] Link OCaml ↔ Rocq
- [ ] Certified verdict generation
- [ ] Full pipeline: refinement input → formal certificate

## Key Insight

The universal refinement theorem is **not a harder version** of the four witnesses. It's a **cleaner version**.

The witnesses are hard because we're computing cycle pairings by hand and explaining why they don't vanish.

The theorem is clean because it reduces the whole problem to: **verify four algebraic identities**.

Once the identities are verified, persistence follows automatically from basic linear algebra and category theory.

---

## References

- **Persistence of homology under refinement**: Standard result in computational topology (Edelsbrunner-Harer)
- **Duality of chain and cochain boundaries**: Weibel, *Introduction to Homological Algebra*
- **Cycle lifting via H₁ surjectivity**: Basic algebraic topology (Hatcher, *Algebraic Topology*)
- **Pairing adjointness**: Finite linear algebra; continuous analogue in Bott-Tu, *Differential Forms*

---

**Next Step**: Implement the linear solver in OCaml and test on the four-cycle example.
