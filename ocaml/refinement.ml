(* Counterexample-guided refinement — Section 5 of the paper.

   The procedure iteratively refines an observation map R_i until every
   predicate in a target class K is admissible.  At each step:
     1. Check:   if K subseteq A(R_i), halt.
     2. Witness: find P in K and (x, y) with R_i(x) = R_i(y), P(x) <> P(y).
     3. Refine:  construct N : X -> O' with N(x) <> N(y);
                 set R_{i+1}(z) = (R_i(z), N(z)).

   Step 3 is realised as the product construction
     type obs_{i+1} = { base : obs_i; new_field : F_type }
   whose mandatory `base` field is the compile-time certificate that the
   kernel only shrinks: sim_{R_{i+1}} subseteq sim_{R_i}.

   The `refine_with` functor-style function below builds a new first-class
   STAGE module by pairing any two STAGE modules, corresponding exactly to
   the R_{i+1}(z) = (R_i(z), N(z)) construction in Section 8.                *)

(* A first-class observation stage.  The abstract type `t` is the observation
   type O_i; `observe` is R_i; `equal` is equality on O_i. *)
module type STAGE = sig
  type t
  val observe : Types.perturbation -> t
  val equal   : t -> t -> bool
  val name    : string
end

(* Result of one check-and-refine step. *)
type step_result =
  | Admissible of { stage : (module STAGE); index : int }
  | Violated   of { stage : (module STAGE); witness : Kernel.witness_pair; index : int }

let check_step
    (type o)
    (module S : STAGE with type t = o)
    ~(pred : Types.perturbation -> bool)
    ~(xs   : Types.perturbation list)
    ~(index : int)
  : step_result =
  match Kernel.find_violation ~observe:S.observe ~equal:S.equal ~pred xs with
  | None    -> Admissible { stage = (module S); index }
  | Some wp -> Violated   { stage = (module S); witness = wp; index }

(* Build the next stage by pairing S with F.  The resulting observation type
     { base : S.t; feature : F.t }
   is the product construction of Section 8.  The projection `fun o -> o.base`
   has type obs_{i+1} -> obs_i, enforced by the record field type. *)
let refine_with
    (type s f)
    (module S : STAGE with type t = s)
    (module F : STAGE with type t = f)
    ~(stage_name : string)
  : (module STAGE) =
  (module struct
    type t = { base : s; feature : f }
    let observe p = { base = S.observe p; feature = F.observe p }
    let equal a b = S.equal a.base b.base && F.equal a.feature b.feature
    let name = stage_name
  end)

(* ------------------------------------------------------------------
   Concrete refinement stages for the perturbation domain.

   The four stages correspond to the obs0..obs3 types in obs.ml and
   form the natural refinement sequence for BType/CarrierClass/Interval/mode.
   Each stage is packaged as a first-class STAGE module.
   ------------------------------------------------------------------ *)

let stage0 : (module STAGE) =
  (module struct
    type t = Obs.obs0
    let observe = Obs.observe0
    let equal   = Obs.equal0
    let name    = "stage0(carrier,magnitude)"
  end)

let stage1 : (module STAGE) =
  (module struct
    type t = Obs.obs1
    let observe = Obs.observe1
    let equal   = Obs.equal1
    let name    = "stage1(+btype_alg)"
  end)

let stage2 : (module STAGE) =
  (module struct
    type t = Obs.obs2
    let observe = Obs.observe2
    let equal   = Obs.equal2
    let name    = "stage2(+btype_full)"
  end)

let stage3 : (module STAGE) =
  (module struct
    type t = Obs.obs3
    let observe = Obs.observe3
    let equal   = Obs.equal3
    let name    = "stage3(+mode)"
  end)

(* Ordered refinement sequence for the perturbation domain. *)
let default_stages : (module STAGE) list =
  [ stage0; stage1; stage2; stage3 ]

(* Run the refinement procedure over the pre-built stage sequence.
   Returns the index and stage module of the first stage at which pred
   is admissible, or None if none of the built-in stages suffice.

   Theorem 5.4 (Termination under Finiteness): since each step strictly
   shrinks sim_{R_i}, termination is guaranteed when |X| is finite.
   Here the stage count (4) is the finiteness bound for this domain. *)
let refine_until
    ~(pred : Types.perturbation -> bool)
    ~(xs   : Types.perturbation list)
  : (int * (module STAGE)) option =
  List.find_map (fun (i, s) ->
    let module S = (val s : STAGE) in
    match check_step (module S) ~pred ~xs ~index:i with
    | Admissible { stage; index } -> Some (index, stage)
    | Violated _                  -> None
  ) (List.mapi (fun i s -> (i, s)) default_stages)
