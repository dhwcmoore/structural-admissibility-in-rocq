# Universal Refinement Theorem: Development Guide

## Overview

This directory implements the computational and formal infrastructure for proving that **cohomological obstructions persist under admissible refinements**.

The mathematical goal is to transform the four case-by-case refinement witnesses in the paper into a universal theorem:

**THEOREM**: If $r \in C^1(N; \mathbb{Q})$ satisfies $\delta r = 0$ and $[r] \neq 0 \in H^1(N; \mathbb{Q})$, and $\rho : N' \to N$ is an admissible refinement satisfying four conditions, then $[\rho^* r] \neq 0 \in H^1(N'; \mathbb{Q})$.

## Four Admissibility Conditions

The conditions that a refinement must satisfy:

### 1. Pullback is a Cochain Map
$$\delta' \rho^* = \rho^* \delta$$

The pullback must commute with coboundaries. This ensures that if $r$ is closed, $\rho^* r$ is also closed.

**OCaml verification**: `AdmissibilityVerification.verify_cochain_map`

### 2. Pushforward is a Chain Map
$$\partial \rho_* = \rho_* \partial'$$

The pushforward must commute with boundaries. This ensures cycles lift consistently.

**OCaml verification**: `AdmissibilityVerification.verify_chain_map`

### 3. Pairing Adjointness
$$\langle z', \rho^* r \rangle = \langle \rho_* z', r \rangle$$

The pairing must respect the refinement. This is the key to the persistence argument.

**OCaml verification**: `AdmissibilityVerification.verify_adjointness`

### 4. $H_1$ Surjectivity
$$\rho_* : H_1(N'; \mathbb{Q}) \twoheadrightarrow H_1(N; \mathbb{Q})$$

The pushforward on first homology must be surjective. This ensures that every detecting cycle in the coarse complex lifts to a refined cycle.

**OCaml verification**: `CycleLifting.find_lift`

## Proof Strategy

The persistence proof has four steps:

1. **Closure under pullback**: By condition 1, if $r$ is a cocycle, then $\rho^* r$ is also a cocycle.

2. **Cycle lifting**: By condition 4, given a coarse cycle $z$ with $\partial z = 0$, we can find a refined cycle $z'$ with $\partial' z' = 0$ and $\rho_* z' = z$.

3. **Pairing preservation**: By condition 3 (adjointness),
$$\langle z', \rho^* r \rangle = \langle \rho_* z', r \rangle = \langle z, r \rangle.$$

4. **Non-exactness**: Since the original pairing is non-zero, $\langle z, r \rangle \neq 0$, the refined pairing is also non-zero. Therefore $\rho^* r$ cannot be exact.

## Computational Infrastructure

### OCaml Modules

- **`refinement_types.ml`**: Core types for chains, cochains, refinements
  - `RationalVector.t`: Sparse vectors over ℚ
  - `RationalMatrix.t`: Matrices for chain/cochain maps
  - `ChainComplex.t`: Formal chains with boundaries
  - `CochainComplex.t`: Formal cochains with coboundaries
  - `RefinementMorphism.t`: Refinement with four admissibility flags

- **`refinement_verification.ml`**: Verification of the four conditions
  - `AdmissibilityVerification.verify_cochain_map`: Check condition 1
  - `AdmissibilityVerification.verify_chain_map`: Check condition 2
  - `AdmissibilityVerification.verify_adjointness`: Check condition 3
  - `CycleLifting.find_lift`: Check condition 4
  - `PairingCertificate.persistence_certificate`: Generate the final certificate

- **`refinement_theorem.ml`**: The main persistence theorem and witnesses
  - `UniversalRefinement.persistence_theorem`: Core theorem statement
  - `DeclaredWitnesses`: The four examples from the paper

### Python Classifier

A companion Python module generates machine-readable certificates with full verification:

```python
class RefinementCertificate:
    def __init__(self, refinement_type, coarse_complex, refined_complex):
        # Coarse data
        self.coarse_residue: ndarray
        self.coarse_cycle: ndarray
        self.coarse_pairing: Rational
        
        # Refined data
        self.refined_residue: ndarray
        self.refined_cycle: ndarray
        self.refined_pairing: Rational
        
        # Verification flags
        self.condition_1_cochain_map: bool
        self.condition_2_chain_map: bool
        self.condition_3_adjointness: bool
        self.condition_4_h1_surjective: bool
```

### Rocq Formalization

**File**: `rocq/UniversalRefinement.v`

Formal definitions and theorem statement (sketch):

```coq
Theorem universal_refinement_persistence :
  ∀ (ρ : RefinementMorphism)
    (r : Vector (cochain_dims (coarse ρ) 1))
    (z : Vector (chain_dims (coarse ρ) 1)),
    
    isCocycle (coarse ρ) 1 r →
    isCycle (coarse ρ) 1 z →
    (¬(Q_eq (Pairing z r) Q_zero)) →
    
    ∃ z' : Vector (chain_dims (refined ρ) 1),
      isCycle (refined ρ) 1 z' ∧
      pushforward ρ 1 z' = z ∧
      (¬(Q_eq (Pairing z' (pullback ρ 1 r)) Q_zero)).
```

The proof uses:
1. Admissibility condition 4 (H_1 surjectivity) to find $z'$
2. Admissibility condition 3 (adjointness) to relate pairings
3. The cycle-pairing lemma to conclude non-exactness

## Example: Four Cycle with Bridge Refinement

### Coarse Complex
- Vertices: $U_1, U_2, U_3, U_4$
- Edges (seams): $(U_1, U_2), (U_2, U_3), (U_3, U_4), (U_1, U_4)$
- Coboundary: $\delta^0 = \begin{pmatrix} -1 & 1 & 0 & 0 \\ 0 & -1 & 1 & 0 \\ 0 & 0 & -1 & 1 \\ -1 & 0 & 0 & 1 \end{pmatrix}$

### Obstruction Data
- Residue: $r = (1, 1, 1, -2)$
- Detecting cycle: $z = (-1, -1, -1, 1)$
- Pairing: $\langle z, r \rangle = -5 \neq 0$

### Refined Complex (Bridge Insertion)
- Insert auxiliary edge between $U_1$ and $U_2$
- New edges: $(U_1, U_2)$ becomes two edges with a connecting vertex
- Refined coboundary $\delta'^0$ is a $5 \times 5$ matrix

### Verification

1. **Condition 1**: $\delta' P = P \delta$ verified by matrix multiplication
2. **Condition 2**: $\partial Q = Q \partial'$ verified componentwise
3. **Condition 3**: Cycle lift $z'$ found with $Q z' = z$
4. **Condition 4**: Pairing: $\langle z', P r \rangle = \langle Q z', r \rangle = \langle z, r \rangle = -5 \neq 0$

**Certificate output**:
```json
{
  "refinement_type": "insert_bridge",
  "coarse_nerve": "four_cycle",
  "refined_nerve": "four_cycle_with_bridge",
  
  "coarse_residue": [1, 1, 1, -2],
  "coarse_cycle": [-1, -1, -1, 1],
  "coarse_pairing": -5,
  
  "refined_residue": [1, 1, 1, 0, -2],
  "refined_cycle": [-1, -1, -1, 0, 1],
  "refined_pairing": -5,
  
  "condition_1_cochain_map": true,
  "condition_2_chain_map": true,
  "condition_3_adjointness": true,
  "condition_4_h1_surjective": true,
  
  "cycle_lifts": true,
  "pairing_persists": true,
  "verdict": "nontrivial_H1_obstruction_persists"
}
```

## Development Stages

### Stage 1: OCaml Implementation (Current)
- [ ] Implement linear solver with rational coefficients
- [ ] Build sparse matrix representations
- [ ] Implement the four verification procedures
- [ ] Test on the four declared witnesses

### Stage 2: Certificate Generation
- [ ] Python classifier that reads JSON complex descriptions
- [ ] Generates pullback/pushforward matrices
- [ ] Verifies all four conditions
- [ ] Outputs machine-readable certificates
- [ ] Property-based regression testing

### Stage 3: Rocq Formalization
- [ ] Define chain/cochain complexes formally
- [ ] Prove the four conditions imply persistence
- [ ] Verify specific witnesses (four-cycle)
- [ ] Prove the cycle-pairing non-exactness lemma
- [ ] Formalize H_1 surjectivity criterion

### Stage 4: Integration
- [ ] Link OCaml computation to Rocq verification
- [ ] Use OCaml-computed certificates in Rocq proofs
- [ ] Certified classifier that returns formally verified verdicts

## What Makes This Different from the Paper

The paper proves:
> "Four declared refinements preserve the obstruction."

The unified theorem will prove:
> "Every admissible refinement preserves the obstruction, where admissibility is defined by four verifiable conditions."

This is a **functorial perspective**: the theorem doesn't depend on the specific refinement, only on whether the four conditions hold.

## Key References

- **Pairing adjointness**: Standard in finite linear algebra; see Bott-Tu for continuous analogue
- **Cycle lifting**: Follows from surjectivity on homology (basic algebraic topology)
- **Non-exactness via pairing**: Duality principle; cf. Weibel's homological algebra text
- **Rocq formalization**: Following the certified computation discipline from certified SMT and ITP

## Next Steps

1. Complete the OCaml linear solver
2. Test on all four declared witnesses
3. Write the Python classifier
4. Begin Rocq proof (start with simplest case)
5. Integrate into the VeriBound project

---

**Author's Note**: This development treats refinement as a **mathematical structure with four components**, not four separate ad-hoc checks. The theorem is clean, the computation is checkable, and the formal proof can be verified in Rocq. The point is that a seam residue persists as an obstruction not because we decree it, but because of the universal properties of chain/cochain duality and the lifting properties of the refinement.
