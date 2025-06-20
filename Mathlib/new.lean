import Mathlib.RingTheory.IntegralClosure.IsIntegralClosure.Basic

theorem Module.finite_of_algebra_finiteType_of_noZeroSMulDivisors_finite {A B : Type*} (C : Type*)
    [CommRing A] [CommRing B] [CommRing C] [Nontrivial C] [Algebra A B]
    [Algebra A C] [Algebra B C] [IsScalarTower A B C] [Algebra.FiniteType A B] [Module.Finite A C]
    [NoZeroSMulDivisors B C] : Module.Finite A B :=
  have : Algebra.IsIntegral A B := by
    apply Algebra.IsIntegral.tower_bot C
  Algebra.IsIntegral.finite
