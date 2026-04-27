(* Staged observation types — Section 8 of the paper.

   Each stage i has the form
     type obs_i = { base : obs_{i-1}; new_field : fi_type }
   so that the mandatory `base` field enforces, at the type level, that no
   refinement step can discard the observational content of its predecessor.

   The canonical projection  pi_i : obs_i -> obs_{i-1}  is simply
     let project_i o = o.base
   which the OCaml type checker verifies has type obs_i -> obs_{i-1}.
   This is the compile-time certificate of the kernel-refinement condition
     sim_{R_i} subseteq sim_{R_{i-1}}
   stated as Proposition 8.2 of the paper.                               *)

open Types

(* ------------------------------------------------------------------
   Stage 0: algebraic projection — carrier and magnitude only.

   Two perturbations are indistinguishable at this stage iff they have
   the same carrier class and magnitude interval, regardless of BType
   or mode.  Admissible predicates are those depending only on
   carrier/magnitude.
   ------------------------------------------------------------------ *)
type obs0 = {
  o_carrier   : carrier_class;
  o_magnitude : interval;
}

let observe0 (p : perturbation) : obs0 = {
  o_carrier   = p.p_carrier;
  o_magnitude = p.p_magnitude;
}

let equal0 a b =
  a.o_carrier = b.o_carrier && a.o_magnitude = b.o_magnitude

(* ------------------------------------------------------------------
   Stage 1: adds the algebraic BType flag (INV/REL -> true, EMG -> false).

   This is the first refinement step, separating EMG perturbations from
   algebraic ones that share the same carrier and magnitude.
   Corresponds to phi_1(p) = btype_algebraic(p.p_btype).
   ------------------------------------------------------------------ *)
type obs1 = {
  base      : obs0;
  btype_alg : bool;
}

let observe1 (p : perturbation) : obs1 = {
  base      = observe0 p;
  btype_alg = btype_algebraic p.p_btype;
}

let project1 (o : obs1) : obs0 = o.base   (* pi_1 : obs1 -> obs0 *)

let equal1 a b =
  equal0 a.base b.base && Bool.equal a.btype_alg b.btype_alg

(* ------------------------------------------------------------------
   Stage 2: adds the full BType value (distinguishes INV from REL).

   Refines stage 1 by exposing which of the three boundary types the
   perturbation carries.  Corresponds to phi_2(p) = p.p_btype.
   ------------------------------------------------------------------ *)
type obs2 = {
  base       : obs1;
  btype_full : btype;
}

let observe2 (p : perturbation) : obs2 = {
  base       = observe1 p;
  btype_full = p.p_btype;
}

let project2 (o : obs2) : obs1 = o.base   (* pi_2 : obs2 -> obs1 *)

let equal2 a b =
  equal1 a.base b.base && a.btype_full = b.btype_full

(* ------------------------------------------------------------------
   Stage 3: adds the mode index — the fully identifying observation.

   At this stage observe3 is injective over the perturbation record: every
   predicate on perturbations is admissible.  Corresponds to phi_3(p) = p.p_mode.
   ------------------------------------------------------------------ *)
type obs3 = {
  base : obs2;
  mode : int;
}

let observe3 (p : perturbation) : obs3 = {
  base = observe2 p;
  mode = p.p_mode;
}

let project3 (o : obs3) : obs2 = o.base   (* pi_3 : obs3 -> obs2 *)

let equal3 a b =
  equal2 a.base b.base && Int.equal a.mode b.mode
