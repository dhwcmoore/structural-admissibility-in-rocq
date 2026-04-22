(* Demo: observational kernel and CEGAR refinement on the perturbation domain.

   Shows four predicates at increasing observational depth, followed by
   a warrant debt example.  Each run of `demo` reports the first stage at
   which the predicate becomes admissible and the witness pairs that
   blocked earlier stages.                                                   *)

open Observational_kernel
open Types

let pp_btype = function
  | INV -> "INV" | REL -> "REL" | EMG -> "EMG"

let pp_carrier = function
  | Timing -> "Timing" | Thermal -> "Thermal" | Signal -> "Signal"
  | Control -> "Control" | Memory -> "Memory" | Geometry -> "Geometry"
  | Concurrency -> "Concurrency" | IO -> "IO" | Human -> "Human"

let pp_iv iv = Printf.sprintf "[%g,%g]" iv.iv_lo iv.iv_hi

let pp_p p =
  Printf.sprintf "{%s|%s|%s|mode=%d}"
    (pp_btype p.p_btype) (pp_carrier p.p_carrier)
    (pp_iv p.p_magnitude) p.p_mode

(* Sample space — covers all three BTypes, several carriers, and multiple modes.
   Entries on the same carrier+magnitude row exercise mode-sensitivity. *)
let xs = [
  { p_btype = INV; p_carrier = Signal;      p_magnitude = zero_iv;              p_mode = 0 };
  { p_btype = REL; p_carrier = Signal;      p_magnitude = zero_iv;              p_mode = 0 };
  { p_btype = EMG; p_carrier = Signal;      p_magnitude = zero_iv;              p_mode = 0 };
  (* Same carrier+magnitude as Signal/zero_iv above, different mode — exercises P3. *)
  { p_btype = INV; p_carrier = Signal;      p_magnitude = zero_iv;              p_mode = 3 };
  { p_btype = INV; p_carrier = Thermal;     p_magnitude = interval 0.0 5.0;     p_mode = 1 };
  { p_btype = REL; p_carrier = Thermal;     p_magnitude = interval 0.0 5.0;     p_mode = 1 };
  { p_btype = EMG; p_carrier = Thermal;     p_magnitude = interval 0.0 5.0;     p_mode = 2 };
  { p_btype = REL; p_carrier = Timing;      p_magnitude = interval 0.005 0.2;   p_mode = 3 };
  { p_btype = EMG; p_carrier = Concurrency; p_magnitude = interval 1e-18 1e-6;  p_mode = 4 };
]

let demo label pred =
  Printf.printf "=== %s ===\n" label;
  (* Report witness pairs at stages before the admissible one. *)
  List.iteri (fun i s ->
    let module S = (val s : Refinement.STAGE) in
    (match Kernel.find_violation ~observe:S.observe ~equal:S.equal ~pred xs with
    | None    -> ()
    | Some wp ->
      Printf.printf "  stage %d (%s): witness  %s  vs  %s\n"
        i S.name (pp_p wp.wp_x) (pp_p wp.wp_y))
  ) Refinement.default_stages;
  (match Refinement.refine_until ~pred ~xs with
  | None ->
    Printf.printf "  not admissible at any built-in stage\n"
  | Some (i, s) ->
    let module S = (val s : Refinement.STAGE) in
    Printf.printf "  => first admissible at stage %d (%s)\n" i S.name);
  print_newline ()

let () =
  (* P1: EMG-sensitive.  Not admissible at stage 0 (carrier+magnitude
     conflates INV/REL/EMG Signal at zero interval).  Admissible at stage 1
     once the btype_alg flag separates EMG from algebraic perturbations. *)
  demo "P1: is_emg  (EMG-sensitive, paper Section 4)"
    (fun p -> p.p_btype = EMG);

  (* P2: INV-sensitive.  Stage 1 still conflates INV and REL (both algebraic).
     Requires stage 2 where the full BType is recorded. *)
  demo "P2: is_inv  (INV vs REL, requires full btype)"
    (fun p -> p.p_btype = INV);

  (* P3: mode-sensitive.  Carrier, magnitude, and BType do not distinguish
     mode; stage 3 is required. *)
  demo "P3: mode > 2  (requires mode field)"
    (fun p -> p.p_mode > 2);

  (* P4: carrier-only predicate.  Admissible already at stage 0 because
     the carrier field is included in obs0. *)
  demo "P4: carrier = Signal  (admissible at stage 0)"
    (fun p -> p.p_carrier = Signal);

  (* Warrant debt example.
     The empirical tolerance log accepts all algebraic (INV/REL) perturbations
     and rejects EMG ones.  The stage-0 observation (carrier + magnitude)
     conflates {INV,Signal,zero_iv} and {EMG,Signal,zero_iv}, while the log
     distinguishes them.  Any proof of tolerance constructed over stage-0 is
     therefore unsound with respect to this log (Theorem 6.2 of the paper). *)
  Printf.printf "=== Warrant debt (paper Section 6) ===\n";
  let empirical_tol () p = not (p.p_btype = EMG) in
  (match Kernel.find_warrant_debt ~empirical_tol () xs with
  | None ->
    Printf.printf "  no warrant debt detected\n"
  | Some wd ->
    Printf.printf "  warrant debt: %s  vs  %s\n"
      (pp_p wd.wd_pair.wp_x) (pp_p wd.wd_pair.wp_y);
    Printf.printf "  stage-0 obs conflates these; the evidence log separates them.\n";
    Printf.printf "  Any proof over stage-0 is unsound w.r.t. this log.\n";
    Printf.printf "  Correct response: refine to stage 1 (adds btype_alg flag).\n");
  print_newline ()
