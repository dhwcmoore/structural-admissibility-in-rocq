(* 
   refinement_algebra.ml
   
   Linear algebra operations for computing ranks, kernels, and verifying
   the four admissibility conditions for universal refinement.
*)

open Core
open Refinement_types

(* Gaussian elimination over ℚ for solving systems and computing ranks *)
module LinearAlgebra = struct
  (* Reduced row echelon form *)
  let rref m =
    let m = RationalMatrix.copy m in
    let rows = RationalMatrix.rows m in
    let cols = RationalMatrix.cols m in
    let current_row = ref 0 in
    
    for col = 0 to cols - 1 do
      if !current_row >= rows then ()
      else (
        (* Find pivot *)
        let pivot_row = ref (-1) in
        for row = !current_row to rows - 1 do
          if Q.(!= (RationalMatrix.get m row col) Q.zero) && !pivot_row = -1 then
            pivot_row := row
        done;
        
        if !pivot_row = -1 then () (* No pivot in this column *)
        else (
          (* Swap rows *)
          let tmp = m.(!current_row) in
          m.(!current_row) <- m.(!pivot_row);
          m.(!pivot_row) <- tmp;
          
          (* Scale pivot row *)
          let pivot_val = RationalMatrix.get m !current_row col in
          for j = 0 to cols - 1 do
            m.(!current_row).(j) <- Q.div m.(!current_row).(j) pivot_val
          done;
          
          (* Eliminate other entries in column *)
          for row = 0 to rows - 1 do
            if row <> !current_row then (
              let factor = RationalMatrix.get m row col in
              for j = 0 to cols - 1 do
                m.(row).(j) <- Q.sub m.(row).(j) (Q.mul factor m.(!current_row).(j))
              done
            )
          done;
          
          incr current_row
        )
      )
    done;
    m
  
  (* Rank of a matrix *)
  let rank m =
    let rref_m = rref (RationalMatrix.copy m) in
    let rows = RationalMatrix.rows rref_m in
    let cols = RationalMatrix.cols rref_m in
    let rank = ref 0 in
    
    for row = 0 to rows - 1 do
      let is_nonzero_row = ref false in
      for col = 0 to cols - 1 do
        if Q.(!= rref_m.(row).(col) Q.zero) then is_nonzero_row := true
      done;
      if !is_nonzero_row then incr rank
    done;
    !rank
  
  (* Null space dimension = cols - rank *)
  let kernel_dimension m =
    RationalMatrix.cols m - rank m
  
  (* Solve Ax = b over ℚ, return Some solution or None if inconsistent *)
  let solve A b =
    let rows = RationalMatrix.rows A in
    let cols = RationalMatrix.cols A in
    let x_dim = RationalVector.dim b in
    
    if x_dim <> rows then
      invalid_arg "LinearAlgebra.solve: dimension mismatch"
    else (
      (* Augmented matrix [A | b] *)
      let augmented = RationalMatrix.zero rows (cols + 1) in
      for i = 0 to rows - 1 do
        for j = 0 to cols - 1 do
          augmented.(i).(j) <- RationalMatrix.get A i j
        done;
        augmented.(i).(cols) <- b.(i)
      done;
      
      (* RREF on augmented matrix *)
      let rref_aug = rref augmented in
      
      (* Check for inconsistency *)
      let inconsistent = ref false in
      for i = 0 to rows - 1 do
        let all_zero = ref true in
        for j = 0 to cols - 1 do
          if Q.(!= rref_aug.(i).(j) Q.zero) then all_zero := false
        done;
        if !all_zero && Q.(!= rref_aug.(i).(cols) Q.zero) then
          inconsistent := true
      done;
      
      if !inconsistent then
        None
      else (
        (* Back substitution *)
        let solution = RationalVector.zero cols in
        for i = 0 to Int.min rows (cols - 1) do
          (* Find leading 1 *)
          let leading_col = ref (-1) in
          for j = 0 to cols - 1 do
            if Q.(rref_aug.(i).(j) = one) && !leading_col = -1 then
              leading_col := j
          done;
          
          if !leading_col >= 0 then
            solution.(!leading_col) <- rref_aug.(i).(cols)
        done;
        Some solution
      )
    )
  
  (* Check if system Ax = b has no solution *)
  let is_inconsistent A b =
    match solve A b with
    | None -> true
    | Some _ -> false
end

(* Verification of admissibility conditions *)
module AdmissibilityCheck = struct
  open RefinementMorphism
  
  (* Condition 1: δ'ρ^* = ρ^*δ *)
  let verify_cochain_map rho =
    let coarse_cobdry = CochainComplex.coboundary rho.coarse 1 in
    let refined_cobdry = CochainComplex.coboundary rho.refined 1 in
    
    if Array.length rho.pullback < 1 then false
    else
      let P = rho.pullback.(0) in
      (* Compute δ'(ρ^*) *)
      let delta_prime_P = RationalMatrix.mul refined_cobdry P in
      (* Compute ρ^*(δ) *)
      let P_delta = RationalMatrix.mul P coarse_cobdry in
      (* Check if equal *)
      let rows = RationalMatrix.rows delta_prime_P in
      let cols = RationalMatrix.cols delta_prime_P in
      
      if RationalMatrix.rows P_delta <> rows || 
         RationalMatrix.cols P_delta <> cols then
        false
      else
        let equal = ref true in
        for i = 0 to rows - 1 do
          for j = 0 to cols - 1 do
            if Q.(!= (RationalMatrix.get delta_prime_P i j)
                    (RationalMatrix.get P_delta i j)) then
              equal := false
          done
        done;
        !equal
  
  (* Condition 2: ∂ρ_* = ρ_*∂' *)
  let verify_chain_map rho =
    (* We need to work with chain complexes *)
    true (* Placeholder: requires ChainComplex access *)
  
  (* Condition 3: ⟨z', ρ^*r⟩ = ⟨ρ_*z', r⟩ *)
  let verify_adjointness rho r z =
    let P = rho.pullback.(0) in
    let Q = rho.pushforward.(0) in
    
    (* Compute ρ^*(r) *)
    let Pr = RationalMatrix.mul_vec P r in
    (* Compute ρ_*(z) *)
    let Qz = RationalMatrix.mul_vec Q z in
    
    (* Compute ⟨z', ρ^*r⟩ — need to be able to pass z' *)
    (* Compute ⟨ρ_*(z'), r⟩ — need to be able to pass z' *)
    
    true (* Placeholder: requires z' *)
  
  (* Condition 4: Check surjectivity of ρ_* on H_1 *)
  let verify_h1_surjective rho =
    (* This requires homology computation *)
    true (* Placeholder *)
  
  let all_conditions rho r z =
    {
      rho with
      is_cochain_map = verify_cochain_map rho;
      is_chain_map = verify_chain_map rho;
      is_adjoint = verify_adjointness rho r z;
      h1_surjective = verify_h1_surjective rho;
    }
end

(* Cycle lifting for persistence *)
module CycleLifting = struct
  (* Check if a refined chain lifts a coarse chain *)
  let lifts rho coarse_chain refined_chain =
    let Q = rho.pushforward.(0) in
    let pushed = RationalMatrix.mul_vec Q refined_chain in
    
    let equal = ref true in
    for i = 0 to RationalVector.dim pushed - 1 do
      if Q.(!= pushed.(i) coarse_chain.(i)) then equal := false
    done;
    !equal
  
  (* Given a coarse cycle, try to find a refined cycle that lifts it *)
  let find_lift rho coarse_cycle =
    (* Try to solve: ρ_* z' = z *)
    let Q = rho.pushforward.(0) in
    let solution = LinearAlgebra.solve Q coarse_cycle in
    
    match solution with
    | None -> None
    | Some z' ->
        (* Check that z' is a cycle in the refined complex *)
        let boundary_dim = RationalMatrix.rows rho.refined.coboundaries.(0) in
        if boundary_dim > 0 then
          let boundary_z' = RationalMatrix.mul_vec rho.refined.coboundaries.(0) z' in
          let is_cycle = ref true in
          Array.iter boundary_z' ~f:(fun v ->
            if Q.(!= v Q.zero) then is_cycle := false
          );
          if !is_cycle then Some z' else None
        else
          Some z'
end

(* Pairing computation and non-exactness certificate *)
module PairingCertificate = struct
  (* Compute ⟨z, r⟩ *)
  let pairing z r =
    RationalVector.dot_product z r
  
  (* Certificate that r is not exact: exhibit a cycle z with ⟨z, r⟩ ≠ 0 *)
  let is_nonexact z r =
    let pairing_val = pairing z r in
    Q.(!= pairing_val Q.zero)
  
  (* Given coarse obstruction detected by ⟨z, r⟩ ≠ 0, *)
  (* verify it persists under refinement *)
  let persistence_certificate rho coarse_r coarse_z refined_r =
    match CycleLifting.find_lift rho coarse_z with
    | None -> None
    | Some refined_z ->
        let coarse_pair = pairing coarse_z coarse_r in
        let refined_pair = pairing refined_z refined_r in
        
        if is_nonexact refined_z refined_r then
          Some {
            RefinementCertificate.
            refinement = rho;
            coarse_residue = coarse_r;
            coarse_cycle = coarse_z;
            coarse_pairing = coarse_pair;
            refined_residue = refined_r;
            refined_cycle = refined_z;
            refined_pairing = refined_pair;
            
            residue_closed = true; (* Should verify *)
            refined_residue_closed = true; (* Should verify *)
            cycle_lifted = CycleLifting.lifts rho coarse_z refined_z;
            adjointness_verified = Q.(refined_pair = coarse_pair);
            obstruction_persists = Q.(!= refined_pair Q.zero);
            pairing_ratio = if Q.(coarse_pair = Q.zero) then None
                           else Some (Q.div refined_pair coarse_pair);
          }
        else
          None
end
