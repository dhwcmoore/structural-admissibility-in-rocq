(* Observational kernel, admissibility, and warrant debt — Section 3 and 6
   of the paper.

   Given R : X -> O, the observational kernel is
     x ~_R y  <=>  R(x) = R(y).
   A predicate P is admissible through R iff P is constant on each ~_R class
   (Corollary 3.3).  A witness pair for inadmissibility is a pair (x, y) with
   R(x) = R(y) but P(x) <> P(y) — the counterexample in the CEGAR loop.

   Warrant debt (Section 6) arises when the evidence log distinguishes two
   configurations that the verification map conflates, making any proof over
   the coarser map unsound with respect to the log (Theorem 6.2).           *)

open Types

(* A witness pair: two perturbations indistinguishable by the current
   observation map but separated by the target predicate. *)
type witness_pair = {
  wp_x : perturbation;
  wp_y : perturbation;
}

(* Find a witness for inadmissibility of pred through observe, or None
   if pred is in A(observe).  Linear scan; quadratic in |xs|. *)
let find_violation
    ~(observe : perturbation -> 'obs)
    ~(equal   : 'obs -> 'obs -> bool)
    ~(pred    : perturbation -> bool)
    (xs : perturbation list)
  : witness_pair option =
  let rec loop = function
    | [] -> None
    | x :: rest ->
      let ox = observe x in
      (match List.find_opt
               (fun y -> equal ox (observe y) && pred x <> pred y)
               rest
       with
       | Some y -> Some { wp_x = x; wp_y = y }
       | None   -> loop rest)
  in
  loop xs

let is_admissible ~observe ~equal ~pred xs =
  find_violation ~observe ~equal ~pred xs = None

(* ------------------------------------------------------------------
   Algebraic equivalence — Section 8.1.

   alg_equiv is the kernel of the stage-1 observation restricted to
   pairs where both components are non-EMG.  It is the relation that
   the algebraic observation map identifies: same carrier, same
   magnitude, both INV or REL.
   ------------------------------------------------------------------ *)
let alg_equiv (p : perturbation) (q : perturbation) : bool =
  p.p_carrier = q.p_carrier
  && p.p_magnitude = q.p_magnitude
  && btype_algebraic p.p_btype
  && btype_algebraic q.p_btype

(* ------------------------------------------------------------------
   Warrant debt — Section 6.

   A system has warrant debt when the evidence log (represented here as
   an empirical tolerance predicate parameterised by evidence e) separates
   two perturbations that the stage-0 observation (carrier + magnitude)
   conflates.  Any proof over the stage-0 map is then unsound with
   respect to the log (Theorem 6.2).
   ------------------------------------------------------------------ *)
type 'evidence warrant_debt = {
  wd_evidence : 'evidence;
  wd_pair     : witness_pair;
}

let find_warrant_debt
    ~(empirical_tol : 'evidence -> perturbation -> bool)
    (e : 'evidence)
    (xs : perturbation list)
  : 'evidence warrant_debt option =
  find_violation
    ~observe:(fun p -> (p.p_carrier, p.p_magnitude))
    ~equal:(=)
    ~pred:(empirical_tol e)
    xs
  |> Option.map (fun wp -> { wd_evidence = e; wd_pair = wp })
