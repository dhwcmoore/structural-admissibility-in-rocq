(* 
   refinement_types.ml
   
   Finite chain and cochain complexes with admissible refinement morphisms.
   
   This module implements the mathematical foundations for the universal
   refinement theorem:
   
   For an admissible refinement ρ : N' → N with pushforward ρ_* : C_1(N') → C_1(N)
   and pullback ρ^* : C^1(N) → C^1(N'), if:
   
   1. ρ^* is a cochain map: δ'ρ^* = ρ^*δ
   2. ρ_* is a chain map: ∂ρ_* = ρ_*∂'
   3. Pairing adjointness: ⟨z', ρ^*r⟩ = ⟨ρ_*z', r⟩
   4. H_1 surjectivity: ρ_* : H_1(N') ↠ H_1(N)
   
   Then an obstruction [r] ≠ 0 ∈ H^1(N) persists to [ρ^*r] ≠ 0 ∈ H^1(N').
*)

open Core

(* Finite vector spaces over ℚ *)
module RationalVector = struct
  type t = Q.t array [@@deriving sexp]
  
  let dim v = Array.length v
  
  let zero n = Array.create ~len:n Q.zero
  
  let copy = Array.copy
  
  let add v w =
    if dim v <> dim w then
      invalid_arg "RationalVector.add: dimension mismatch"
    else
      Array.map2_exn v w ~f:Q.add
  
  let scalar_mult q v =
    Array.map v ~f:(Q.mul q)
  
  let dot_product v w =
    if dim v <> dim w then
      invalid_arg "RationalVector.dot_product: dimension mismatch"
    else
      Array.fold2_exn v w ~init:Q.zero ~f:(fun acc vi wi ->
        Q.add acc (Q.mul vi wi)
      )
  
  let to_string v =
    "(" ^ String.concat ~sep:", " (Array.to_list v |> List.map ~f:Q.to_string) ^ ")"
  
  let copy = Array.copy
end

(* Finite matrices over ℚ *)
module RationalMatrix = struct
  type t = RationalVector.t array [@@deriving sexp]
  
  let rows m = Array.length m
  let cols m = if rows m = 0 then 0 else RationalVector.dim m.(0)
  
  let zero rows cols =
    Array.init rows ~f:(fun _ -> RationalVector.zero cols)
  
  let identity n =
    let m = zero n n in
    for i = 0 to n - 1 do
      m.(i).(i) <- Q.one
    done;
    m
  
  let get m i j = m.(i).(j)
  let set m i j v = m.(i).(j) <- v
  
  (* Matrix-vector multiplication *)
  let mul_vec m v =
    if RationalVector.dim v <> cols m then
      invalid_arg "RationalMatrix.mul_vec: dimension mismatch"
    else
      Array.map m ~f:(fun row -> RationalVector.dot_product row v)
  
  (* Matrix-matrix multiplication *)
  let mul m n =
    let r = rows m in
    let c = cols n in
    let k = cols m in
    if rows n <> k then
      invalid_arg "RationalMatrix.mul: inner dimension mismatch"
    else
      let result = zero r c in
      for i = 0 to r - 1 do
        for j = 0 to c - 1 do
          let sum = ref Q.zero in
          for p = 0 to k - 1 do
            sum := Q.add !sum (Q.mul (get m i p) (get n p j))
          done;
          set result i j !sum
        done
      done;
      result
  
  (* Transpose *)
  let transpose m =
    let r = rows m in
    let c = cols m in
    let mt = zero c r in
    for i = 0 to r - 1 do
      for j = 0 to c - 1 do
        set mt j i (get m i j)
      done
    done;
    mt
  
  let to_string m =
    String.concat ~sep:"\n" (
      Array.to_list m |> List.map ~f:RationalVector.to_string
    )
end

(* Chain complex C_* over ℚ: groups C_n with boundary maps ∂_n *)
module ChainComplex = struct
  type t = {
    name: string;
    (* dimension -> group dimension *)
    dims: int array;
    (* ∂_n : C_n → C_{n-1} *)
    boundaries: RationalMatrix.t array;
  } [@@deriving sexp]
  
  let create name dims boundaries =
    if Array.length boundaries <> Array.length dims - 1 then
      invalid_arg "ChainComplex.create: mismatched dimensions and boundaries"
    else
      { name; dims; boundaries }
  
  let dim_n chain n =
    if n < 0 || n >= Array.length chain.dims then 0
    else chain.dims.(n)
  
  let boundary chain n =
    if n <= 0 || n > Array.length chain.boundaries then
      RationalMatrix.zero 0 0
    else
      chain.boundaries.(n - 1)
  
  (* Compute boundary of a chain: ∂(v) *)
  let apply_boundary chain n v =
    let boundary_map = boundary chain n in
    RationalMatrix.mul_vec boundary_map v
  
  (* Check if a chain is a cycle: ∂(z) = 0 *)
  let is_cycle chain n z =
    let b = apply_boundary chain n z in
    Array.for_all b ~f:(fun v -> Q.(v = zero))
  
  (* Kernel dimension of a boundary map *)
  let kernel_dimension_of_boundary m =
    RationalMatrix.cols m - 
    (let rref_m = RationalMatrix.transpose m in
     let rank = ref 0 in
     Array.iter rref_m ~f:(fun row ->
       let nonzero = ref false in
       Array.iter row ~f:(fun v -> if Q.(v <> zero) then nonzero := true);
       if !nonzero then incr rank
     );
     !rank)
  
  (* Compute homology H_n(C) by solving ∂_n v = 0 *)
  let homology_rank chain n =
    let kernel_dim = kernel_dimension_of_boundary (boundary chain n) in
    let image_dim = 
      let rank = ref 0 in
      let bd = boundary chain (n + 1) in
      let rref_m = RationalMatrix.transpose bd in
      Array.iter rref_m ~f:(fun row ->
        let nonzero = ref false in
        Array.iter row ~f:(fun v -> if Q.(v <> zero) then nonzero := true);
        if !nonzero then incr rank
      );
      !rank
    in
    kernel_dim - image_dim
end

(* Cochain complex C^* over ℚ: groups C^n with coboundary maps δ^n *)
module CochainComplex = struct
  type t = {
    name: string;
    (* dimension -> group dimension *)
    dims: int array;
    (* δ^n : C^n → C^{n+1} *)
    coboundaries: RationalMatrix.t array;
  } [@@deriving sexp]
  
  let create name dims coboundaries =
    if Array.length coboundaries <> Array.length dims - 1 then
      invalid_arg "CochainComplex.create: mismatched dimensions and coboundaries"
    else
      { name; dims; coboundaries }
  
  let dim_n cochain n =
    if n < 0 || n >= Array.length cochain.dims then 0
    else cochain.dims.(n)
  
  let coboundary cochain n =
    if n < 0 || n >= Array.length cochain.coboundaries then
      RationalMatrix.zero 0 0
    else
      cochain.coboundaries.(n)
  
  (* Compute coboundary of a cochain: δ(c) *)
  let apply_coboundary cochain n c =
    let coboundary_map = coboundary cochain n in
    RationalMatrix.mul_vec coboundary_map c
  
  (* Check if a cochain is closed: δ(c) = 0 *)
  let is_closed cochain n c =
    let dc = apply_coboundary cochain n c in
    Array.for_all dc ~f:(fun v -> Q.(v = zero))
  
  (* Rank computation for cohomology *)
  let cohomology_rank cochain n =
    let kernel_dim =
      let cbd = coboundary cochain n in
      RationalMatrix.cols cbd - 
      (let rref_m = RationalMatrix.transpose cbd in
       let rank = ref 0 in
       Array.iter rref_m ~f:(fun row ->
         let nonzero = ref false in
         Array.iter row ~f:(fun v -> if Q.(v <> zero) then nonzero := true);
         if !nonzero then incr rank
       );
       !rank)
    in
    let image_dim =
      let cbd_prev = coboundary cochain (n - 1) in
      let rank = ref 0 in
      let rref_m = RationalMatrix.transpose cbd_prev in
      Array.iter rref_m ~f:(fun row ->
        let nonzero = ref false in
        Array.iter row ~f:(fun v -> if Q.(v <> zero) then nonzero := true);
        if !nonzero then incr rank
      );
      !rank
    in
    kernel_dim - image_dim
end

(* Admissible refinement morphism ρ : N' → N *)
module RefinementMorphism = struct
  type t = {
    name: string;
    coarse: CochainComplex.t;
    refined: CochainComplex.t;
    
    (* Pullback ρ^* : C^n(N) → C^n(N') *)
    pullback: RationalMatrix.t array;
    
    (* Pushforward ρ_* : C_n(N') → C_n(N) *)
    pushforward: RationalMatrix.t array;
    
    (* Witnesses to admissibility *)
    is_cochain_map: bool;        (* δ'ρ^* = ρ^*δ *)
    is_chain_map: bool;           (* ∂ρ_* = ρ_*∂' *)
    is_adjoint: bool;             (* ⟨z', ρ^*r⟩ = ⟨ρ_*z', r⟩ *)
    h1_surjective: bool;          (* ρ_* : H_1(N') ↠ H_1(N) *)
  } [@@deriving sexp]
  
  let create ~name ~coarse ~refined ~pullback ~pushforward =
    {
      name;
      coarse;
      refined;
      pullback;
      pushforward;
      is_cochain_map = false;
      is_chain_map = false;
      is_adjoint = false;
      h1_surjective = false;
    }
  
  let pull_back rho c =
    (* ρ^*(c) : apply pullback matrix *)
    let P = rho.pullback in
    if Array.length P = 0 then
      invalid_arg "RefinementMorphism.pull_back: empty pullback"
    else
      RationalMatrix.mul_vec P.(0) c
  
  let push_forward rho z =
    (* ρ_*(z) : apply pushforward matrix *)
    let Q = rho.pushforward in
    if Array.length Q = 0 then
      invalid_arg "RefinementMorphism.push_forward: empty pushforward"
    else
      RationalMatrix.mul_vec Q.(0) z
end

(* Refinement certificate: proof of non-zero obstruction persistence *)
module RefinementCertificate = struct
  type t = {
    refinement: RefinementMorphism.t;
    
    (* Coarse obstruction data *)
    coarse_residue: RationalVector.t;
    coarse_cycle: RationalVector.t;
    coarse_pairing: Q.t;
    
    (* Refined obstruction data *)
    refined_residue: RationalVector.t;
    refined_cycle: RationalVector.t;
    refined_pairing: Q.t;
    
    (* Verification flags *)
    residue_closed: bool;          (* δ(r) = 0 *)
    refined_residue_closed: bool;  (* δ'(r') = 0 *)
    cycle_lifted: bool;             (* ρ_*(z') = z *)
    adjointness_verified: bool;    (* ⟨z', ρ^*r⟩ = ⟨z, r⟩ *)
    
    (* Verdict *)
    obstruction_persists: bool;
    pairing_ratio: Q.t option;     (* refined_pairing / coarse_pairing *)
  } [@@deriving sexp]
  
  let verdict cert =
    if Q.(cert.refined_pairing <> zero) then
      "nontrivial_H1_obstruction_persists"
    else
      "obstruction_may_vanish"
end
