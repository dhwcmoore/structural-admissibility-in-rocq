(* Domain types, mirroring the Rocq development in rocq/bdgi_perturbation_proved.v.
   BType / CarrierClass / Interval / Perturbation are the OCaml counterparts
   of the inductive and record types in Section 1 of that file. *)

type btype = INV | REL | EMG

type carrier_class =
  | Timing | Thermal | Signal | Control
  | Memory | Geometry | Concurrency | IO | Human

type interval = { iv_lo : float; iv_hi : float }

let interval lo hi =
  if lo > hi then
    invalid_arg (Printf.sprintf "interval: lo=%g > hi=%g" lo hi);
  { iv_lo = lo; iv_hi = hi }

let zero_iv = { iv_lo = 0.0; iv_hi = 0.0 }

type perturbation = {
  p_btype     : btype;
  p_carrier   : carrier_class;
  p_magnitude : interval;
  p_mode      : int;
}

(* Counterpart of btype_algebraic in Section 8.1 of the Rocq file. *)
let btype_algebraic = function
  | INV | REL -> true
  | EMG       -> false

(* Interval arithmetic — counterparts of iv_add and iv_envelope in the Rocq file. *)
let iv_add a b =
  interval (a.iv_lo +. b.iv_lo) (a.iv_hi +. b.iv_hi)

let iv_envelope a b =
  interval (Float.min a.iv_lo b.iv_lo) (Float.max a.iv_hi b.iv_hi)

(* BType dominance: EMG > REL > INV.  Counterpart of btype_join in
   SimpleSynergyCompose (Section 9.2 of the proved Rocq file). *)
let btype_join b1 b2 =
  match b1, b2 with
  | EMG, _ | _, EMG -> EMG
  | REL, _ | _, REL -> REL
  | INV, INV        -> INV

(* Sequential composition: magnitudes add, BType dominates.
   Counterpart of seq_compose in Section 3 of the Rocq file. *)
let seq_compose p q = {
  p_btype     = btype_join p.p_btype q.p_btype;
  p_carrier   = p.p_carrier;
  p_magnitude = iv_add p.p_magnitude q.p_magnitude;
  p_mode      = p.p_mode;
}

(* Parallel composition: envelope magnitude, BType dominates.
   Counterpart of SimpleSynergyCompose.par_compose (Section 9.2). *)
let par_compose p q = {
  p_btype     = btype_join p.p_btype q.p_btype;
  p_carrier   = p.p_carrier;
  p_magnitude = iv_envelope p.p_magnitude q.p_magnitude;
  p_mode      = p.p_mode;
}
