(* ================================================================== *)
(*  BDGI Perturbation Theory — Proof Skeleton                          *)
(*  Rocq/Coq development for rupture theorem and safety wrappers       *)
(*                                                                     *)
(*  Status: SKELETON — statements with Admitted placeholders           *)
(*  Purpose: Structure first; semantics and proofs fill in later       *)
(* ================================================================== *)

Require Import Coq.Reals.Reals.
Require Import Coq.Lists.List.
Require Import Coq.Bool.Bool.
Import ListNotations.

Open Scope R_scope.

(* ------------------------------------------------------------------ *)
(*  Section 1: Perturbation Types                                      *)
(* ------------------------------------------------------------------ *)

Inductive BType : Type :=
  | INV   (* invariant: structurally determined *)
  | REL   (* relational: bounded, variable *)
  | EMG.  (* emergent: tolerance-governed *)

Inductive CarrierClass : Type :=
  | Timing | Thermal | Signal | Control
  | Memory | Geometry | Concurrency | IO | Human.

(* Magnitude as closed interval [lo, hi] over reals *)
Record Interval := mkInterval {
  iv_lo : R;
  iv_hi : R;
  iv_wf : (iv_lo <= iv_hi)%R   (* well-formedness *)
}.

Definition zero_iv : Interval := mkInterval 0 0 (Rle_refl 0).

(* A perturbation is typed by its boundary classification,
   carrier, and magnitude interval. *)
Record Perturbation := mkPerturbation {
  p_btype    : BType;
  p_carrier  : CarrierClass;
  p_magnitude : Interval;
  p_mode     : nat;          (* index into controlled vocabulary *)
}.

(* ------------------------------------------------------------------ *)
(*  Section 2: Tolerance Predicates                                    *)
(* ------------------------------------------------------------------ *)

(* A tolerance predicate over an interface region.
   Abstractly: given a perturbation at a boundary, does the
   receiving region tolerate it? *)

Definition TolPredicate := Perturbation -> Prop.

(* Formal tolerance: decidable, proved at design time *)
Definition formal_tol (dec : Perturbation -> bool) : TolPredicate :=
  fun p => dec p = true.

(* Empirical tolerance: supported by monitor evidence *)
(* We model this as a proposition parameterised by evidence *)
Parameter Evidence : Type.
Parameter empirical_tol : Evidence -> TolPredicate.

(* ------------------------------------------------------------------ *)
(*  Section 3: Composition Operators (Abstract)                        *)
(* ------------------------------------------------------------------ *)

(* Interval arithmetic *)
Definition iv_add (a b : Interval) : Interval.
Proof.
  refine (mkInterval (iv_lo a + iv_lo b) (iv_hi a + iv_hi b) _).
  apply Rplus_le_compat; [exact (iv_wf a) | exact (iv_wf b)].
Defined.

(* Sequential composition: magnitudes add *)
Definition seq_compose (p q : Perturbation) : Perturbation :=
  mkPerturbation
    (match p_btype p, p_btype q with
     | EMG, _ | _, EMG => EMG
     | REL, _ | _, REL => REL
     | INV, INV => INV
     end)
    (p_carrier p)
    (iv_add (p_magnitude p) (p_magnitude q))
    (p_mode p).

(* Parallel composition placeholder — requires synergy lookup *)
Parameter par_compose : Perturbation -> Perturbation -> Perturbation.

(* Restriction to a guard region *)
Parameter restrict : Perturbation -> Interval -> Perturbation.

(* Projection onto an observation layer *)
Parameter project : Perturbation -> nat -> Perturbation.

(* ------------------------------------------------------------------ *)
(*  Section 4: The Closure Condition                                   *)
(* ------------------------------------------------------------------ *)

(* A region R is closed under perturbation if every perturbation
   that can reach R's boundary is tolerated by R. *)

Definition ClosedUnder (R_tol : TolPredicate) (ps : list Perturbation) : Prop :=
  Forall (fun p => R_tol p) ps.

(* ------------------------------------------------------------------ *)
(*  Section 5: The Rupture Theorem                                     *)
(* ------------------------------------------------------------------ *)

(* Rupture: a perturbation exceeds the tolerance of an interface.
   This is the negation of closure for a specific perturbation. *)

Definition Rupture (tol : TolPredicate) (p : Perturbation) : Prop :=
  ~ tol p.

(* The Rupture Lemma: if a composite perturbation exceeds the
   tolerance predicate at an interface, then either
   (a) an individual component exceeds tolerance, or
   (b) the composition introduces emergent magnitude via synergy. *)

Theorem rupture_decomposition :
  forall (tol : TolPredicate) (p q : Perturbation),
    Rupture tol (par_compose p q) ->
    (Rupture tol p) \/
    (Rupture tol q) \/
    (exists synergy_amplification : R,
       synergy_amplification > 0 /\
       tol p /\ tol q).
Proof.
  (* This is the core theorem. The third disjunct captures the case
     where individually tolerable perturbations become intolerable
     through emergent interaction — the raison d'être of EMG type. *)
Admitted.

(* ------------------------------------------------------------------ *)
(*  Section 6: Conditional Safety Wrapper                              *)
(* ------------------------------------------------------------------ *)

(* A system is conditionally safe if:
   1. All INV perturbations are proved tolerated (design-time)
   2. All REL perturbations are proved within bounds (design-time)
      AND monitored if bounds are fragile
   3. All EMG perturbations have:
      - a tolerance predicate
      - a monitor that verifies the predicate continuously
      - a safe-mode transition if predicate is violated *)

Inductive ObligationStatus :=
  | Discharged   (* proved or evidenced *)
  | Pending      (* not yet addressed *)
  | Violated.    (* known to fail *)

Record SafetyCase := mkSafetyCase {
  sc_inv_obligations : list (Perturbation * ObligationStatus);
  sc_rel_obligations : list (Perturbation * ObligationStatus);
  sc_emg_obligations : list (Perturbation * TolPredicate * ObligationStatus);
}.

Definition all_discharged (sc : SafetyCase) : Prop :=
  Forall (fun po => snd po = Discharged) (sc_inv_obligations sc) /\
  Forall (fun po => snd po = Discharged) (sc_rel_obligations sc) /\
  Forall (fun po => match po with (_, _, s) => s = Discharged end)
         (sc_emg_obligations sc).

Theorem conditional_safety :
  forall (sc : SafetyCase) (tol : TolPredicate) (all_perturbs : list Perturbation),
    all_discharged sc ->
    ClosedUnder tol all_perturbs ->
    forall p, In p all_perturbs -> tol p.
Proof.
  (* Follows from the definition of ClosedUnder and all_discharged.
     The real content is in showing that the obligation compiler
     produces the correct sc for a given catalogue. *)
Admitted.

(* ------------------------------------------------------------------ *)
(*  Section 7: Monitor Correctness (Interface)                         *)
(* ------------------------------------------------------------------ *)

(* A monitor is correct if:
   - When it says "ok", the tolerance predicate holds
   - When it says "rupture", the tolerance predicate is violated
   - It never misses a rupture (soundness) *)

Inductive MonitorDecision := MOk | MWarn | MRupture.

Parameter Monitor : Type.
Parameter monitor_decide : Monitor -> Perturbation -> MonitorDecision.

Definition monitor_sound (m : Monitor) (tol : TolPredicate) : Prop :=
  forall p, Rupture tol p -> monitor_decide m p = MRupture.

Definition monitor_complete (m : Monitor) (tol : TolPredicate) : Prop :=
  forall p, monitor_decide m p = MOk -> tol p.

(* The key property: a sound and complete monitor gives us
   runtime evidence equivalent to a proof. *)
Theorem monitor_as_evidence :
  forall (m : Monitor) (tol : TolPredicate),
    monitor_sound m tol ->
    monitor_complete m tol ->
    forall p, monitor_decide m p = MOk -> tol p.
Proof.
  intros m tol Hsound Hcomplete p Hdec.
  exact (Hcomplete p Hdec).
Qed.

(* ------------------------------------------------------------------ *)
(*  NOTE ON WARRANT FINITENESS (Section 9 of design review)           *)
(*  Evidence is parameterised, not fixed.  For the obligation-         *)
(*  discharge procedure to converge, callers should instantiate        *)
(*  Evidence with a finite lattice — a bounded list of sealed logs     *)
(*  suffices.  Monotone accumulation is sufficient; contractiveness    *)
(*  is not required by the theorems below.                             *)
(*                                                                     *)
(*  NOTE ON DISTURBANCE (Section 9)                                    *)
(*  The runtime perturbation terms (decay, refresh, disturbance) that  *)
(*  appear in the RC layer are not modelled here.  This file gives the *)
(*  static admissibility conditions.  Dynamic evolution is tracked     *)
(*  in the sealed evidence logs and the monitor runner.                *)
(* ------------------------------------------------------------------ *)

(* ================================================================== *)
(*  Section 8: Admissibility, Non-Factorisation, Warrant              *)
(*  (Direct connection to the Observational Kernel theorem)           *)
(* ================================================================== *)

(*  The identification (from design review):
      BType INV / REL  <->  algebraic boundaries (closed, no external dep)
      BType EMG        <->  geometric boundaries (irreducibly external)
      Admissible pred  <->  invariant under algebraic observation kernel
      Inadmissible     <->  sensitive to EMG / geometric contamination
      Warrant debt     <->  indistinguishable configurations under alg obs *)

(* ------------------------------------------------------------------ *)
(*  8.1  Algebraic observation map                                     *)
(* ------------------------------------------------------------------ *)

(*  The algebraic projection strips EMG information.  Two perturbations
    are algebraically equivalent (same kernel class) when they agree on
    carrier and magnitude and are both non-EMG.  An EMG perturbation
    is outside the algebraic observation domain entirely. *)

Definition btype_algebraic (b : BType) : bool :=
  match b with
  | INV => true
  | REL => true
  | EMG => false
  end.

(*  Kernel relation: algebraically indistinguishable. *)
Definition alg_equiv (p q : Perturbation) : Prop :=
  p_carrier p = p_carrier q /\
  p_magnitude p = p_magnitude q /\
  btype_algebraic (p_btype p) = true /\
  btype_algebraic (p_btype q) = true.

(*  A predicate P over perturbations is admissible w.r.t. the algebraic
    observation map if it is invariant under alg_equiv: anything the
    algebraic kernel cannot distinguish, P cannot distinguish either. *)
Definition PredAdmissible (P : Perturbation -> Prop) : Prop :=
  forall p q : Perturbation, alg_equiv p q -> (P p <-> P q).

(* ------------------------------------------------------------------ *)
(*  8.2  EMG sensitivity implies inadmissibility                       *)
(* ------------------------------------------------------------------ *)

(*  A predicate P is EMG-sensitive if it witnesses a pair (p, q) that
    are algebraically equivalent in carrier and magnitude but differ in
    BType (one INV or REL, one EMG), and P separates them. *)

Definition EMGSensitive (P : Perturbation -> Prop) : Prop :=
  exists p q : Perturbation,
    p_carrier p = p_carrier q /\
    p_magnitude p = p_magnitude q /\
    btype_algebraic (p_btype p) = true /\
    p_btype q = EMG /\
    (P p /\ ~ P q) \/ (~ P p /\ P q).

(*  Main admissibility theorem (parallel to Theorem 1 of the EWD note):
    any EMG-sensitive predicate is not admissible from algebraic
    structure alone.  The proof is immediate: alg_equiv requires both
    arguments to be algebraic (btype_algebraic = true), so an EMG
    perturbation is never in the same kernel class as an INV or REL
    one; a predicate that distinguishes them therefore witnesses a
    failure of invariance under some prospective algebraic equiv, and
    no decision procedure over the algebraic projection can decide it. *)

(*  NOTE: emg_sensitive_not_admissible is FALSE under the current definitions
    and has been removed.

    The flaw: alg_equiv requires BOTH inputs to carry btype_algebraic = true,
    so PredAdmissible imposes no constraint on a predicate's behaviour at EMG
    inputs.  Concretely, emg_sensitive_tol is simultaneously EMGSensitive and
    PredAdmissible: on every alg_equiv pair both sides are algebraic, so the
    predicate is trivially True on both, satisfying PredAdmissible; yet the
    EMG witness separates it from an algebraic input.

    The correct non-recoverability result is no_alg_factorisation (Section 8.3):
    it uses an actual map into an algebraic target type, which is the right
    notion of "factors through the algebraic observation". *)

(* ------------------------------------------------------------------ *)
(*  8.2b  Concrete witness: EMG-sensitive tolerance and witness pair   *)
(* ------------------------------------------------------------------ *)

(*  A tolerance predicate that accepts all algebraic perturbations
    and rejects all EMG perturbations.  Used as the explicit witness
    in the non-factorisation proof below. *)
Definition emg_sensitive_tol : TolPredicate :=
  fun p => match p_btype p with
           | EMG => False
           | _   => True
           end.

(*  A concrete EMG perturbation on the Signal carrier.  Its algebraic
    fields (carrier, magnitude, mode) match p_inv below, but its BType
    is EMG and therefore lies outside the algebraic subtype. *)
Definition p_emg : Perturbation := mkPerturbation EMG Signal zero_iv 0.
Definition p_inv : Perturbation := mkPerturbation INV Signal zero_iv 0.

(*  Sanity checks used in the main proof. *)
Lemma rupture_emg : Rupture emg_sensitive_tol p_emg.
Proof. unfold Rupture, emg_sensitive_tol, p_emg; simpl; tauto. Qed.

Lemma no_rupture_inv : ~ Rupture emg_sensitive_tol p_inv.
Proof. unfold Rupture, emg_sensitive_tol, p_inv; simpl; tauto. Qed.

(* ------------------------------------------------------------------ *)
(*  8.3  Non-factorisation theorem                                     *)
(* ------------------------------------------------------------------ *)

(*  There is no homomorphism f from Perturbation to an algebraic-only
    subtype that both (a) preserves the Rupture predicate and
    (b) eliminates EMG boundaries.  Formally: *)

(*  AlgPerturbation: the subtype of algebraically-typed perturbations. *)
Definition AlgPerturbation := { p : Perturbation | btype_algebraic (p_btype p) = true }.

(*  A homomorphism candidate maps every Perturbation into AlgPerturbation. *)
Definition AlgHom := Perturbation -> AlgPerturbation.

(*  Preservation of Rupture means: for any tolerance predicate tol,
    Rupture tol p <-> Rupture tol (proj (f p)), where proj extracts
    the underlying Perturbation from AlgPerturbation. *)
Definition proj_alg (ap : AlgPerturbation) : Perturbation := proj1_sig ap.

Definition RupturePreserving (f : AlgHom) (tol : TolPredicate) : Prop :=
  forall p : Perturbation,
    Rupture tol p <-> Rupture tol (proj_alg (f p)).

(*  Key lemma: every AlgPerturbation is tolerated by emg_sensitive_tol.
    Proof uses the sigma-type proof obligation: proj_alg ap carries a
    certificate that its btype is algebraic, ruling out EMG by case
    analysis and discriminate on the boolean equality. *)
Lemma alg_tol : forall ap : AlgPerturbation,
    emg_sensitive_tol (proj_alg ap).
Proof.
  intros [p Hp].
  unfold proj_alg, emg_sensitive_tol; simpl.
  destruct (p_btype p) eqn:Hbt.
  - exact I.
  - exact I.
  - unfold btype_algebraic in Hp. rewrite Hbt in Hp. discriminate.
Qed.

(*  No AlgHom is Rupture-preserving for every tolerance predicate.
    Witness: emg_sensitive_tol and p_emg.  Any f maps p_emg into an
    AlgPerturbation; alg_tol shows that image is tolerated; but p_emg
    itself is not tolerated; preservation would require both to agree. *)
Theorem no_alg_factorisation :
  forall (f : AlgHom),
    ~ (forall (tol : TolPredicate), RupturePreserving f tol).
Proof.
  intros f Hpres.
  specialize (Hpres emg_sensitive_tol).
  unfold RupturePreserving in Hpres.
  specialize (Hpres p_emg).
  assert (Hrup : Rupture emg_sensitive_tol p_emg) by apply rupture_emg.
  apply (proj1 Hpres) in Hrup.
  exact (Hrup (alg_tol (f p_emg))).
Qed.

(* ------------------------------------------------------------------ *)
(*  8.4  Warrant as observational indistinguishability                 *)
(* ------------------------------------------------------------------ *)

(*  The intuition from the design review: nontrivial warrant
    corresponds to indistinguishable configurations under algebraic
    observation.  We make this precise as follows.

    Two perturbations are warrant-equivalent if all empirical evidence
    treats them identically. *)

Definition warrant_equiv (e : Evidence) (p q : Perturbation) : Prop :=
  empirical_tol e p <-> empirical_tol e q.

(*  Key connection: if p and q are alg_equiv, any difference in their
    empirical tolerance must come from an external channel — that is,
    from information not present in the algebraic observation.  The
    warrant therefore records exactly the deficit that the algebraic
    kernel destroys. *)

Definition WarrantDebt (e : Evidence) (p q : Perturbation) : Prop :=
  alg_equiv p q /\ ~ warrant_equiv e p q.

(*  A WarrantDebt (e, p, q) witnesses that e carries information about
    the distinction between p and q that the algebraic channel cannot
    carry.  This is the formal counterpart of the independent channel
    Sigma in the EWD note: the evidence log is the constructive
    realisation of that channel. *)

Theorem warrant_debt_implies_non_admissible :
  forall (e : Evidence) (p q : Perturbation),
    WarrantDebt e p q ->
    ~ PredAdmissible (empirical_tol e).
Proof.
  intros e p q [Hequiv Hne_warrant] Hadm.
  apply Hne_warrant.
  unfold PredAdmissible in Hadm.
  exact (Hadm p q Hequiv).
Qed.
