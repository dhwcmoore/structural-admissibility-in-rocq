#!/usr/bin/env python3
"""
residue_classifier.py

Computational classifier for finite H^1 obstruction witnesses.

This script implements the "exact rational classifier" described in Section 9
of the paper "Associator Fields and Local-to-Global Failure in Finite
Regional Cohomology".

It takes a JSON file describing a finite cochain complex and a residue,
and determines whether the residue represents a non-trivial H^1 class.

It provides two certificates for the verdict:
1. Linear System Inconsistency: Attempts to solve δb = r.
2. Cycle Pairing: Computes <z, r> for a given cycle witness z.

USAGE:
    python residue_classifier.py path/to/your_complex.json
"""

import json
import sys
from typing import Dict, List
import numpy as np
from fractions import Fraction

def matrix_from_strings(m: List[List[str]]) -> np.ndarray:
    """Convert string matrix to numpy array of Fractions."""
    if not m:
        return np.array([], dtype=object)
    return np.array([[Fraction(x) for x in row] for row in m], dtype=object)

def vector_from_strings(v: List[str]) -> np.ndarray:
    """Convert string vector to numpy array of Fractions."""
    return np.array([Fraction(x) for x in v], dtype=object)

def solve_linear_system(A: np.ndarray, b: np.ndarray) -> (bool, np.ndarray):
    """
    Attempts to solve the linear system Ax = b over rationals.
    Returns (is_exact_solution, solution_vector).
    """
    if A.size == 0 or b.size == 0:
        return False, np.array([])
        
    try:
        # Use floating-point solver for an initial guess
        x_float = np.linalg.lstsq(A.astype(float), b.astype(float), rcond=None)[0]
        
        # Convert to rationals and check for an exact solution
        x_rational = np.array([Fraction(x).limit_denominator(1_000_000) for x in x_float], dtype=object)
        
        # Verify if A * x_rational == b
        b_check = A.dot(x_rational)
        
        is_exact = np.all(b_check == b)
        return is_exact, x_rational

    except np.linalg.LinAlgError:
        return False, np.array([])

def run_classifier(file_path: str):
    """Loads a complex and residue, and runs the classification."""
    
    print(f"Loading witness file: {file_path}")
    with open(file_path, 'r') as f:
        data = json.load(f)

    # --- Load Data ---
    complex_data = data['complex']
    d0 = matrix_from_strings(complex_data['coboundary_0'])
    d1 = matrix_from_strings(complex_data['coboundary_1'])
    r = vector_from_strings(data['residue'])
    z = vector_from_strings(data['cycle_witness'])

    # --- Verification ---
    
    # 1. Check if residue is a cocycle (δ¹r = 0)
    is_cocycle = True
    d1r = None
    if d1.size > 0:
        d1r = d1.dot(r)
        is_cocycle = np.all(d1r == 0)

    # 2. Check if residue is a coboundary (r ∈ im(δ⁰))
    is_removable, b = solve_linear_system(d0, r)
    
    # 3. Cycle pairing certificate <z, r>
    pairing = z.dot(r)
    
    # --- Verdict ---
    is_obstruction = is_cocycle and not is_removable

    # --- Print Certificate ---
    print("\n" + "="*50)
    print("FINITE OBSTRUCTION CERTIFICATE")
    print("="*50)
    print(f"Witness: {data['name']}")
    print(f"Complex: {complex_data['name']}")
    print(f"Residue r: {data['residue']}")
    print("-" * 50)

    print("1. Cocycle Check (δ¹r = 0):")
    if not is_cocycle:
        print(f"  - FAIL: Residue is not a cocycle. δ¹r = {d1r}")
    else:
        print("  - PASS: Residue is a cocycle (δ¹r = 0).")

    print("\n2. Coboundary Check (r ∈ im(δ⁰)):")
    if is_removable:
        print(f"  - REMOVABLE: Residue is a coboundary.")
        print(f"    Found solution b = {[str(x) for x in b]} such that δ⁰b = r.")
    else:
        print(f"  - NOT REMOVABLE: Residue is not a coboundary.")
        print(f"    Linear system δ⁰b = r is inconsistent.")

    print("\n3. Cycle Pairing Certificate (<z, r>):")
    print(f"  Cycle witness z: {data['cycle_witness']}")
    print(f"  Pairing <z, r> = {pairing}")
    if pairing == 0:
        print("  - VERDICT: Pairing is zero. This does not prove non-exactness.")
    else:
        print(f"  - VERDICT: Pairing is non-zero, certifying r is not a coboundary.")

    print("-" * 50)
    print("FINAL VERDICT:")
    if is_obstruction:
        print("  => Nontrivial H¹ Obstruction")
    else:
        print("  => Trivial (Removable or Not a Cocycle)")
    print("="*50)
    print("="*50)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python residue_classifier.py <path_to_json_file>")
        sys.exit(1)
    
    file_path = sys.argv[1]
    run_classifier(file_path)
