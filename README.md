# Structural Admissibility for Verification Systems

Formal verification of observational admissibility: Rocq proofs of warrant debt,
non-factorisation, and rupture decomposition with OCaml type-level realisation.

This repository accompanies the paper:

**Structural Admissibility for Verification Systems: Warrant Debt and Observational
Quotients in Rocq**  
Duston Moore — Independent Researcher

`paper/admissibility_fmsd.tex` — LaTeX source for the Springer FMSD submission  
`paper/admissibility_fmsd.pdf` — compiled manuscript  
`rocq/bdgi_perturbation_proved.v` — canonical Rocq/Coq proof file

---

## Central claim

A predicate `Φ` is admissible with respect to observation map `M` if and only if
it factors through the equivalence relation induced by `M`. When it does not, no
argument within the observational regime can certify `Φ`: the quotient has already
destroyed the distinction `Φ` requires.

Warrant debt is the operational witness of this failure: the evidence record
distinguishes two perturbations that the algebraic kernel conflates. The Warrant
Debt Theorem proves that warrant debt implies non-admissibility. It is fully
mechanised in Rocq.

---

## What is proved in Rocq

The central mechanised results are in `rocq/bdgi_perturbation_proved.v`.

| Theorem | Identifier in file | Paper |
|---|---|---|
| Warrant Debt Theorem | `warrant_debt_implies_non_admissible` | §4.4 |
| Non-Factorisation Theorem | `no_alg_factorisation` | §7 |
| Rupture Decomposition (concrete, `SimpleSynergyCompose`) | `rupture_decomposition_proved` | §6.2 |
| Rupture bridge lemma | `SimpleSynergyCompose.rupture_synergy_bridge` | §6.2 |

### Additional supporting lemmas

The file also contains supporting lemmas not claimed as central results of the paper:

| Lemma | Identifier |
|---|---|
| Monitor-as-Evidence | `monitor_as_evidence` |
| Conditional Safety | `conditional_safety` |
| Every algebraic perturbation satisfies `emg_sensitive_tol` | `alg_tol` |

Key definitions:

| Definition | Lines | Paper |
|---|---|---|
| `BType`, `Perturbation` | 23–48 | §3 |
| `alg_equiv`, `PredAdmissible` | 258–268 | §4.1 |
| `WarrantDebt` | 377–378 | §4.3 |
| `AlgPerturbation`, `AlgHom`, `RupturePreserving` | 312–324 | §7 |
| `COMPOSITION_SIG` | 412–439 | §6.1 |
| `SimpleSynergyCompose` | 450–526 | §6.2 |

---

## What is specified but not mechanised

### Abstract rupture decomposition

The abstract statement `rupture_decomposition` is intentionally left at the
interface level. It is stated over an opaque `Parameter par_compose` and is not
counted among the proved results claimed in the paper. The concrete version is
fully proved for `SimpleSynergyCompose`.

### Higher-Order Warrant Debt (paper §6.3, Conjecture 6.5)

The generalisation to `k`-component systems, including dependency families,
minimal support sets, and powerset-lattice structure, is stated as a conjectural
mathematical extension. It is not mechanised in the present development. The
binary case (`k = 2`) is the content of `rupture_decomposition_proved`.

---

## Repository structure

```
paper/
  admissibility_fmsd.tex        LaTeX source (Springer FMSD submission)

rocq/
  bdgi_perturbation_proved.v   canonical proof file (no unintended Admitted)

ocaml/
  types.ml       domain types mirroring the Rocq development;
                 btype_algebraic, btype_join, seq_compose, par_compose
  kernel.ml      observational kernel: find_violation, is_admissible,
                 alg_equiv, find_warrant_debt
  obs.ml         staged observation types obs0–obs3 and projection
                 functions π₁–π₃ (product-decomposition chain)
  refinement.ml  CEGAR refinement loop: refine_with (product construction),
                 refine_until, four concrete stages

bin/
  main.ml        runnable demo: four predicates at increasing observational
                 depth, plus a warrant debt detection example

test/
  test_kernel.ml unit tests for kernel, staged observations, projection
                 chain, CEGAR refinement, and warrant debt detection
```

---

## Paper–code correspondence

| Paper section | Rocq (bdgi_perturbation_proved.v) | OCaml |
|---|---|---|
| §3 Perturbation types, BType, Interval | lines 23–67 | `types.ml` |
| §4.1 Algebraic observation, `alg_equiv` | lines 250–268 | `kernel.ml`: `alg_equiv` |
| §4.3 `WarrantDebt` | lines 377–378 | `kernel.ml`: `find_warrant_debt` |
| §4.4 Warrant Debt Theorem | lines 386–395 | — |
| §5 Observational refinement, product construction | — | `obs.ml` (obs0–obs3), `refinement.ml`: `refine_with` |
| §6.1 `COMPOSITION_SIG` | lines 412–439 | — |
| §6.2 `SimpleSynergyCompose`, rupture decomposition | lines 450–547 | — |
| §7 `no_alg_factorisation` | lines 307–355 | — |

---

## Building

**Rocq / Coq**  
Tested with Coq 8.18.0 and OCaml 4.14.1.

```sh
cd rocq && coqc bdgi_perturbation_proved.v
```

**OCaml** (≥ 4.08, dune ≥ 3.0):

```sh
dune build && dune test
```

**Paper** (requires Springer `sn-jnl.cls` template files in `paper/`):

```sh
cd paper && pdflatex admissibility_fmsd.tex && pdflatex admissibility_fmsd.tex
```

---

## Citation

```bibtex
@unpublished{moore2026admissibility,
  author = {Duston Moore},
  title  = {Structural Admissibility for Verification Systems: Warrant Debt and Observational
            Quotients in {Rocq}},
  year   = {2026},
  note   = {Available at \url{https://github.com/dhwcmoore/structural-admissibility-in-rocq}}
}
```