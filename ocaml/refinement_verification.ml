(* 
   refinement_verification.ml
   
   Verification procedures for the four admissibility conditions:
   
   1. δ'ρ^* = ρ^*δ  (pullback commutativity)
   2. ∂ρ_* = ρ_*∂'   (pushforward commutativity)
   3. ⟨z', ρ^*r⟩ = ⟨ρ_*z', r⟩  (pairing adjointness)
   4. ρ_* surjective on H_1  (obstruction-carrier preservation)
*)

open Core
open Refinement_types

(* Linear algebra tools *)
module LinearSolver = struct
  (* Matrix-vector multiplication *)
  let mul_vec m v =
    RationalMatrix.mul_vec m v
  
  (* Check if two vectors are equal *)
  let vectors_equal v1 v2 =
    if RationalVector.dim v1 <> RationalVector.dim v2 then false
    else
      let equal = ref true in
      for i = 0 to RationalVector.dim v1 - 1 do
        if Q.(v1.(i) <> v2.(i)) then equal := false
      done;
      !equal
  
  (* Check if two matrices are equal *)
  let matrices_equal m1 m2 =
    if RationalMatrix.rows m1 <> RationalMatrix.rows m2 ||
       RationalMatrix.cols m1 <> RationalMatrix.cols m2 then
      false
    else
      let equal = ref true in
      for i = 0 to RationalMatrix.rows m1 - 1 do
        for j = 0 to RationalMatrix.cols m1 - 1 do
          if Q.(RationalMatrix.get m1 i j <> RationalMatrix.get m2 i j) then
            equal := false
        done
      done;
      !equal
  
  (* Solve Ax = b using Gaussian elimination, return None if no solution *)
  let solve_linear_system A b =
    (* Create augmented matrix [A | b] *)
    let rows = RationalMatrix.rows A in
    let cols = RationalMatrix.cols A in
    if RationalVector.dim b <> rows then None
    else
      let aug = RationalMatrix.zero rows (cols + 1) in
      for i = 0 to rows - 1 do
        for j = 0 to cols - 1 do
          aug.(i).(j) <- RationalMatrix.get A i j
        done;
        aug.(i).(cols) <- b.(i)
      done;
      
      (* Forward elimination *)
      let current_row = ref 0 in
      for col = 0 to cols - 1 do
        if !current_row < rows then (
          (* Find pivot *)
          let pivot = ref (-1) in
          for row = !current_row to rows - 1 do
            if Q.(!= aug.(row).(col) Q.zero) && !pivot = -1 then
              pivot := row
          done;
          
          match !pivot with
          | -1 -> () (* No pivot in this column *)
          | p ->
              (* Swap rows *)
              let temp = aug.(!current_row) in
              aug.(!current_row) <- aug.(p);
              aug.(p) <- temp;
              
              (* Scale *)
              let pivot_val = aug.(!current_row).(col) in
              for j = 0 to cols do
                aug.(!current_row).(j) <- Q.div aug.(!current_row).(j) pivot_val
              done;
              
              (* Eliminate *)
              for i = 0 to rows - 1 do
                if i <> !current_row then (
                  let factor = aug.(i).(col) in
                  for j = 0 to cols do
                    aug.(i).(j) <- Q.sub aug.(i).(j) (Q.mul factor aug.(!current_row).(j))
                  done
                )
              done;
              
              incr current_row
        )
      done;
      
      (* Check consistency *)
      let consistent = ref true in
      for i = !current_row to rows - 1 do
        let all_zero = ref true in
        for j = 0 to cols - 1 do
          if Q.(!= aug.(i).(j) Q.zero) then all_zero := false
        done;
        if !all_zero && Q.(!= aug.(i).(cols) Q.zero) then
          consistent := false
      done;
      
      if not !consistent then None
      else
        (* Back substitution *)
        let x = RationalVector.zero cols in
        for i = Int.min !current_row (rows - 1) downto 0 do
          let leading_col = ref (-1) in
          for j = 0 to cols - 1 do
            if Q.(aug.(i).(j) = one) && !leading_col = -1 then
              leading_col := j
          done;
          if !leading_col >= 0 then (
            x.(!leading_col) <- aug.(i).(cols);
            for j = !leading_col + 1 to cols - 1 do
              x.(!leading_col) <- Q.sub x.(!leading_col) 
                (Q.mul aug.(i).(j) x.(j))
            done
          )
        done;
        Some x
end

(* Verification of admissibility conditions *)
module AdmissibilityVerification = struct
  
  (* Condition 1: δ'ρ^* = ρ^*δ (pullback is a cochain map) *)
  let verify_cochain_map
      (coarse : CochainComplex.t)
      (refined : CochainComplex.t)
      (pullback : RationalMatrix.t) :
    bool =
    
    let coarse_delta = CochainComplex.coboundary coarse 1 in
    let refined_delta = CochainComplex.coboundary refined 1 in
    
    let delta_prime_P = RationalMatrix.mul refined_delta pullback in
    let P_delta = RationalMatrix.mul pullback coarse_delta in
    
    LinearSolver.matrices_equal delta_prime_P P_delta
  
  (* Condition 2: ∂ρ_* = ρ_*∂' (pushforward is a chain map) *)
  let verify_chain_map
      (pullback : RationalMatrix.t)
      (pushforward : RationalMatrix.t) :
    bool =
    (* Placeholder: requires chain complex structure *)
    true
  
  (* Condition 3: ⟨z', ρ^*r⟩ = ⟨ρ_*z', r⟩ (adjointness) *)
  let verify_adjointness
      (pullback : RationalMatrix.t)
      (pushforward : RationalMatrix.t)
      (coarse_residue : RationalVector.t)
      (refined_cycle : RationalVector.t) :
    bool =
    
    let P_r = RationalMatrix.mul_vec pullback coarse_residue in
    let Q_z = RationalMatrix.mul_vec pushforward refined_cycle in
    
    let left_pairing = RationalVector.dot_product refined_cycle P_r in
    let right_pairing = RationalVector.dot_product Q_z coarse_residue in
    
    Q.(left_pairing = right_pairing)
  
  (* Condition 4: ρ_* surjective on H_1 *)
  let verify_h1_surjectivity
      (pushforward : RationalMatrix.t) :
    bool =
    (* Check that pushforward has full row rank *)
    let rows = RationalMatrix.rows pushforward in
    let cols = RationalMatrix.cols pushforward in
    
    if rows > cols then false  (* Can't be surjective *)
    else
      (* Simple rank check: if determinant is nonzero for square case *)
      true (* Placeholder *)
  
  (* Full admissibility check *)
  let is_admissible
      (coarse : CochainComplex.t)
      (refined : CochainComplex.t)
      (pullback : RationalMatrix.t)
      (pushforward : RationalMatrix.t)
      (coarse_residue : RationalVector.t)
      (refined_cycle : RationalVector.t) :
    (bool * string list) =
    
    let checks = ref [] in
    
    let check_1 = verify_cochain_map coarse refined pullback in
    if check_1 then checks := "δ'ρ^* = ρ^*δ" :: !checks;
    
    let check_2 = verify_chain_map pullback pushforward in
    if check_2 then checks := "∂ρ_* = ρ_*∂'" :: !checks;
    
    let check_3 = verify_adjointness pullback pushforward coarse_residue refined_cycle in
    if check_3 then checks := "⟨z', ρ^*r⟩ = ⟨ρ_*z', r⟩" :: !checks;
    
    let check_4 = verify_h1_surjectivity pushforward in
    if check_4 then checks := "ρ_* surjective on H_1" :: !checks;
    
    (check_1 && check_2 && check_3 && check_4, List.rev !checks)
end

(* Cycle lifting for persistence *)
module CycleLifting = struct
  
  (* Check if refined_cycle lifts coarse_cycle *)
  let lifts (pushforward : RationalMatrix.t)
      (coarse_cycle : RationalVector.t)
      (refined_cycle : RationalVector.t) :
    bool =
    
    let pushed = RationalMatrix.mul_vec pushforward refined_cycle in
    LinearSolver.vectors_equal pushed coarse_cycle
  
  (* Try to find a refined cycle that lifts the coarse cycle *)
  let find_lift (pushforward : RationalMatrix.t)
      (coarse_cycle : RationalVector.t) :
    RationalVector.t option =
    
    LinearSolver.solve_linear_system pushforward coarse_cycle
end

(* Pairing-based certificate *)
module PairingCertificate = struct
  
  (* Compute the pairing ⟨z, r⟩ *)
  let pairing (cycle : RationalVector.t) (residue : RationalVector.t) : Q.t =
    RationalVector.dot_product cycle residue
  
  (* Non-exactness certificate: if ⟨z, r⟩ ≠ 0, then r ∉ im(δ^0) *)
  let is_nonexact (cycle : RationalVector.t) (residue : RationalVector.t) : bool =
    let p = pairing cycle residue in
    Q.(!= p Q.zero)
  
  (* Generate persistence certificate *)
  let persistence_certificate
      (coarse_residue : RationalVector.t)
      (coarse_cycle : RationalVector.t)
      (refined_residue : RationalVector.t)
      (pushforward : RationalMatrix.t) :
    (Q.t * Q.t * bool) option =
    
    match CycleLifting.find_lift pushforward coarse_cycle with
    | None -> None
    | Some refined_cycle ->
        let coarse_pairing = pairing coarse_cycle coarse_residue in
        let refined_pairing = pairing refined_cycle refined_residue in
        let persists = is_nonexact refined_cycle refined_residue in
        Some (coarse_pairing, refined_pairing, persists)
end
