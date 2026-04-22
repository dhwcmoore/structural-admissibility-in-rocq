(* Unit tests for the observational kernel and refinement modules. *)

open Observational_kernel
open Types

let p_inv  = { p_btype = INV; p_carrier = Signal; p_magnitude = zero_iv; p_mode = 0 }
let p_rel  = { p_btype = REL; p_carrier = Signal; p_magnitude = zero_iv; p_mode = 0 }
let p_emg  = { p_btype = EMG; p_carrier = Signal; p_magnitude = zero_iv; p_mode = 0 }
let p_mod1 = { p_btype = INV; p_carrier = Signal; p_magnitude = zero_iv; p_mode = 1 }

let xs = [ p_inv; p_rel; p_emg; p_mod1 ]

let check label b =
  if b then Printf.printf "PASS  %s\n" label
  else begin Printf.printf "FAIL  %s\n" label; exit 1 end

(* -------------------------------------------------------------------
   Admissibility at each stage
   ------------------------------------------------------------------- *)

(* EMG predicate: not admissible at stage 0 (carrier+magnitude conflates
   p_inv and p_emg), admissible at stage 1 (btype_alg separates them). *)
let () =
  let pred p = p.p_btype = EMG in
  check "EMG pred: NOT admissible at stage 0"
    (not (Kernel.is_admissible ~observe:Obs.observe0 ~equal:Obs.equal0 ~pred xs));
  check "EMG pred: admissible at stage 1"
    (Kernel.is_admissible ~observe:Obs.observe1 ~equal:Obs.equal1 ~pred xs)

(* INV predicate: stage 1 still conflates p_inv and p_rel (both algebraic);
   stage 2 adds the full BType and separates them. *)
let () =
  let pred p = p.p_btype = INV in
  check "INV pred: NOT admissible at stage 1"
    (not (Kernel.is_admissible ~observe:Obs.observe1 ~equal:Obs.equal1 ~pred xs));
  check "INV pred: admissible at stage 2"
    (Kernel.is_admissible ~observe:Obs.observe2 ~equal:Obs.equal2 ~pred xs)

(* Mode predicate: stage 2 conflates p_inv and p_mod1 (same carrier/magnitude/btype);
   stage 3 adds the mode and separates them. *)
let () =
  let pred p = p.p_mode > 0 in
  check "mode pred: NOT admissible at stage 2"
    (not (Kernel.is_admissible ~observe:Obs.observe2 ~equal:Obs.equal2 ~pred xs));
  check "mode pred: admissible at stage 3"
    (Kernel.is_admissible ~observe:Obs.observe3 ~equal:Obs.equal3 ~pred xs)

(* Carrier predicate: depends only on carrier, which is in obs0. *)
let () =
  let pred p = p.p_carrier = Signal in
  check "carrier pred: admissible at stage 0"
    (Kernel.is_admissible ~observe:Obs.observe0 ~equal:Obs.equal0 ~pred xs)

(* -------------------------------------------------------------------
   CEGAR refinement finds the correct stage
   ------------------------------------------------------------------- *)

let () =
  let pred p = p.p_btype = EMG in
  (match Refinement.refine_until ~pred ~xs with
  | Some (1, _) -> check "CEGAR: EMG pred first admissible at stage 1" true
  | Some (n, _) ->
    Printf.printf "FAIL  CEGAR: EMG pred at stage %d (expected 1)\n" n; exit 1
  | None ->
    Printf.printf "FAIL  CEGAR: no admissible stage found\n"; exit 1)

let () =
  let pred p = p.p_btype = INV in
  (match Refinement.refine_until ~pred ~xs with
  | Some (2, _) -> check "CEGAR: INV pred first admissible at stage 2" true
  | Some (n, _) ->
    Printf.printf "FAIL  CEGAR: INV pred at stage %d (expected 2)\n" n; exit 1
  | None ->
    Printf.printf "FAIL  CEGAR: no admissible stage found\n"; exit 1)

let () =
  let pred p = p.p_mode > 0 in
  (match Refinement.refine_until ~pred ~xs with
  | Some (3, _) -> check "CEGAR: mode pred first admissible at stage 3" true
  | Some (n, _) ->
    Printf.printf "FAIL  CEGAR: mode pred at stage %d (expected 3)\n" n; exit 1
  | None ->
    Printf.printf "FAIL  CEGAR: no admissible stage found\n"; exit 1)

let () =
  let pred p = p.p_carrier = Signal in
  (match Refinement.refine_until ~pred ~xs with
  | Some (0, _) -> check "CEGAR: carrier pred first admissible at stage 0" true
  | Some (n, _) ->
    Printf.printf "FAIL  CEGAR: carrier pred at stage %d (expected 0)\n" n; exit 1
  | None ->
    Printf.printf "FAIL  CEGAR: no admissible stage found\n"; exit 1)

(* -------------------------------------------------------------------
   Projection chain: pi_i o observe_i = observe_{i-1}
   ------------------------------------------------------------------- *)

let () =
  List.iter (fun p ->
    check "pi_1 o observe_1 = observe_0"
      (Obs.equal0 (Obs.project1 (Obs.observe1 p)) (Obs.observe0 p));
    check "pi_2 o observe_2 = observe_1"
      (Obs.equal1 (Obs.project2 (Obs.observe2 p)) (Obs.observe1 p));
    check "pi_3 o observe_3 = observe_2"
      (Obs.equal2 (Obs.project3 (Obs.observe3 p)) (Obs.observe2 p))
  ) xs

(* -------------------------------------------------------------------
   Warrant debt detection
   ------------------------------------------------------------------- *)

let () =
  let empirical_tol () p = not (p.p_btype = EMG) in
  (match Kernel.find_warrant_debt ~empirical_tol () xs with
  | Some _ -> check "warrant debt detected for EMG-sensitive log" true
  | None   ->
    Printf.printf "FAIL  no warrant debt found\n"; exit 1)

(* No warrant debt when the log is carrier-only (same as stage-0 obs). *)
let () =
  let empirical_tol () p = p.p_carrier = Signal in
  (match Kernel.find_warrant_debt ~empirical_tol () xs with
  | None   -> check "no warrant debt for carrier-only log" true
  | Some _ ->
    Printf.printf "FAIL  unexpected warrant debt\n"; exit 1)

(* -------------------------------------------------------------------
   alg_equiv: both must be non-EMG
   ------------------------------------------------------------------- *)

let () =
  check "alg_equiv: INV Signal ~ REL Signal"  (Kernel.alg_equiv p_inv p_rel);
  check "alg_equiv: INV Signal !~ EMG Signal" (not (Kernel.alg_equiv p_inv p_emg));
  check "alg_equiv: EMG Signal !~ EMG Signal" (not (Kernel.alg_equiv p_emg p_emg))

let () = Printf.printf "\nAll tests passed.\n"
