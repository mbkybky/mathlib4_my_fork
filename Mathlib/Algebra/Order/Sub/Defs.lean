/-
Copyright (c) 2021 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn
-/
import Mathlib.Algebra.Group.Basic
import Mathlib.Algebra.Order.Monoid.Unbundled.Basic
import Mathlib.Order.Lattice

/-!
# Ordered Subtraction

This file proves lemmas relating (truncated) subtraction with an order. We provide a class
`OrderedSub` stating that `a - b ≤ c ↔ a ≤ c + b`.

The subtraction discussed here could both be normal subtraction in an additive group or truncated
subtraction on a canonically ordered monoid (`ℕ`, `Multiset`, `PartENat`, `ENNReal`, ...)

## Implementation details

`OrderedSub` is a mixin type-class, so that we can use the results in this file even in cases
where we don't have a `CanonicallyOrderedAdd` instance
(even though that is our main focus). Conversely, this means we can use
`CanonicallyOrderedAdd` without necessarily having to define a subtraction.

The results in this file are ordered by the type-class assumption needed to prove it.
This means that similar results might not be close to each other. Furthermore, we don't prove
implications if a bi-implication can be proven under the same assumptions.

Lemmas using this class are named using `tsub` instead of `sub` (short for "truncated subtraction").
This is to avoid naming conflicts with similar lemmas about ordered groups.

We provide a second version of most results that require `[AddLeftReflectLE α]`. In the
second version we replace this type-class assumption by explicit `AddLECancellable` assumptions.

TODO: maybe we should make a multiplicative version of this, so that we can replace some identical
lemmas about subtraction/division in `Ordered[Add]CommGroup` with these.

TODO: generalize `Nat.le_of_le_of_sub_le_sub_right`, `Nat.sub_le_sub_right_iff`,
  `Nat.mul_self_sub_mul_self_eq`
-/


variable {α : Type*}

/-- `OrderedSub α` means that `α` has a subtraction characterized by `a - b ≤ c ↔ a ≤ c + b`.
In other words, `a - b` is the least `c` such that `a ≤ b + c`.

This is satisfied both by the subtraction in additive ordered groups and by truncated subtraction
in canonically ordered monoids on many specific types.
-/
class OrderedSub (α : Type*) [LE α] [Add α] [Sub α] : Prop where
  /-- `a - b` provides a lower bound on `c` such that `a ≤ c + b`. -/
  tsub_le_iff_right : ∀ a b c : α, a - b ≤ c ↔ a ≤ c + b

section Add

@[simp]
theorem tsub_le_iff_right [LE α] [Add α] [Sub α] [OrderedSub α] {a b c : α} :
    a - b ≤ c ↔ a ≤ c + b :=
  OrderedSub.tsub_le_iff_right a b c

variable [Preorder α] [Add α] [Sub α] [OrderedSub α] {a b : α}

/-- See `add_tsub_cancel_right` for the equality if `AddLeftReflectLE α`. -/
theorem add_tsub_le_right : a + b - b ≤ a :=
  tsub_le_iff_right.mpr le_rfl

theorem le_tsub_add : b ≤ b - a + a :=
  tsub_le_iff_right.mp le_rfl

end Add

/-! ### Preorder -/


section OrderedAddCommSemigroup

section Preorder

variable [Preorder α]

section AddCommSemigroup

variable [AddCommSemigroup α] [Sub α] [OrderedSub α] {a b c d : α}
/- TODO: Most results can be generalized to [Add α] [@Std.Commutative α (· + ·)] -/

theorem tsub_le_iff_left : a - b ≤ c ↔ a ≤ b + c := by rw [tsub_le_iff_right, add_comm]

theorem le_add_tsub : a ≤ b + (a - b) :=
  tsub_le_iff_left.mp le_rfl

/-- See `add_tsub_cancel_left` for the equality if `AddLeftReflectLE α`. -/
theorem add_tsub_le_left : a + b - a ≤ b :=
  tsub_le_iff_left.mpr le_rfl

theorem tsub_le_tsub_right (h : a ≤ b) (c : α) : a - c ≤ b - c :=
  tsub_le_iff_left.mpr <| h.trans le_add_tsub

theorem tsub_le_iff_tsub_le : a - b ≤ c ↔ a - c ≤ b := by rw [tsub_le_iff_left, tsub_le_iff_right]

/-- See `tsub_tsub_cancel_of_le` for the equality. -/
theorem tsub_tsub_le : b - (b - a) ≤ a :=
  tsub_le_iff_right.mpr le_add_tsub

section Cov

variable [AddLeftMono α]

theorem tsub_le_tsub_left (h : a ≤ b) (c : α) : c - b ≤ c - a :=
  tsub_le_iff_left.mpr <| le_add_tsub.trans <| add_le_add_right h _

@[gcongr] theorem tsub_le_tsub (hab : a ≤ b) (hcd : c ≤ d) : a - d ≤ b - c :=
  (tsub_le_tsub_right hab _).trans <| tsub_le_tsub_left hcd _

theorem antitone_const_tsub : Antitone fun x => c - x := fun _ _ hxy => tsub_le_tsub rfl.le hxy

/-- See `add_tsub_assoc_of_le` for the equality. -/
theorem add_tsub_le_assoc : a + b - c ≤ a + (b - c) := by
  rw [tsub_le_iff_left, add_left_comm]
  exact add_le_add_left le_add_tsub a

/-- See `tsub_add_eq_add_tsub` for the equality. -/
theorem add_tsub_le_tsub_add : a + b - c ≤ a - c + b := by
  rw [add_comm, add_comm _ b]
  exact add_tsub_le_assoc

theorem add_le_add_add_tsub : a + b ≤ a + c + (b - c) := by
  rw [add_assoc]
  exact add_le_add_left le_add_tsub a

theorem le_tsub_add_add : a + b ≤ a - c + (b + c) := by
  rw [add_comm a, add_comm (a - c)]
  exact add_le_add_add_tsub

theorem tsub_le_tsub_add_tsub : a - c ≤ a - b + (b - c) := by
  rw [tsub_le_iff_left, ← add_assoc, add_right_comm]
  exact le_add_tsub.trans (add_le_add_right le_add_tsub _)

theorem tsub_tsub_tsub_le_tsub : c - a - (c - b) ≤ b - a := by
  rw [tsub_le_iff_left, tsub_le_iff_left, add_left_comm]
  exact le_tsub_add.trans (add_le_add_left le_add_tsub _)

theorem tsub_tsub_le_tsub_add {a b c : α} : a - (b - c) ≤ a - b + c :=
  tsub_le_iff_right.2 <|
    calc
      a ≤ a - b + b := le_tsub_add
      _ ≤ a - b + (c + (b - c)) := add_le_add_left le_add_tsub _
      _ = a - b + c + (b - c) := (add_assoc _ _ _).symm

/-- See `tsub_add_tsub_comm` for the equality. -/
theorem add_tsub_add_le_tsub_add_tsub : a + b - (c + d) ≤ a - c + (b - d) := by
  rw [add_comm c, tsub_le_iff_left, add_assoc, ← tsub_le_iff_left, ← tsub_le_iff_left]
  refine (tsub_le_tsub_right add_tsub_le_assoc c).trans ?_
  rw [add_comm a, add_comm (a - c)]
  exact add_tsub_le_assoc

/-- See `add_tsub_add_eq_tsub_left` for the equality. -/
theorem add_tsub_add_le_tsub_left : a + b - (a + c) ≤ b - c := by
  rw [tsub_le_iff_left, add_assoc]
  exact add_le_add_left le_add_tsub _

/-- See `add_tsub_add_eq_tsub_right` for the equality. -/
theorem add_tsub_add_le_tsub_right : a + c - (b + c) ≤ a - b := by
  rw [tsub_le_iff_left, add_right_comm]
  exact add_le_add_right le_add_tsub c

end Cov

/-! #### Lemmas that assume that an element is `AddLECancellable` -/


namespace AddLECancellable

protected theorem le_add_tsub_swap (hb : AddLECancellable b) : a ≤ b + a - b :=
  hb le_add_tsub

protected theorem le_add_tsub (hb : AddLECancellable b) : a ≤ a + b - b := by
  rw [add_comm]
  exact hb.le_add_tsub_swap

protected theorem le_tsub_of_add_le_left (ha : AddLECancellable a) (h : a + b ≤ c) : b ≤ c - a :=
  ha <| h.trans le_add_tsub

protected theorem le_tsub_of_add_le_right (hb : AddLECancellable b) (h : a + b ≤ c) : a ≤ c - b :=
  hb.le_tsub_of_add_le_left <| by rwa [add_comm]

end AddLECancellable

/-! ### Lemmas where addition is order-reflecting -/


section Contra

variable [AddLeftReflectLE α]

theorem le_add_tsub_swap : a ≤ b + a - b :=
  Contravariant.AddLECancellable.le_add_tsub_swap

theorem le_add_tsub' : a ≤ a + b - b :=
  Contravariant.AddLECancellable.le_add_tsub

theorem le_tsub_of_add_le_left (h : a + b ≤ c) : b ≤ c - a :=
  Contravariant.AddLECancellable.le_tsub_of_add_le_left h

theorem le_tsub_of_add_le_right (h : a + b ≤ c) : a ≤ c - b :=
  Contravariant.AddLECancellable.le_tsub_of_add_le_right h

end Contra

end AddCommSemigroup

variable [AddCommMonoid α] [Sub α] [OrderedSub α] {a b : α}

theorem tsub_nonpos : a - b ≤ 0 ↔ a ≤ b := by rw [tsub_le_iff_left, add_zero]

alias ⟨_, tsub_nonpos_of_le⟩ := tsub_nonpos

end Preorder

/-! ### Partial order -/


variable [PartialOrder α] [AddCommSemigroup α] [Sub α] [OrderedSub α] {a b c d : α}

theorem tsub_tsub (b a c : α) : b - a - c = b - (a + c) := by
  apply le_antisymm
  · rw [tsub_le_iff_left, tsub_le_iff_left, ← add_assoc, ← tsub_le_iff_left]
  · rw [tsub_le_iff_left, add_assoc, ← tsub_le_iff_left, ← tsub_le_iff_left]

theorem tsub_add_eq_tsub_tsub (a b c : α) : a - (b + c) = a - b - c :=
  (tsub_tsub _ _ _).symm

theorem tsub_add_eq_tsub_tsub_swap (a b c : α) : a - (b + c) = a - c - b := by
  rw [add_comm]
  apply tsub_add_eq_tsub_tsub

theorem tsub_right_comm : a - b - c = a - c - b := by
  rw [← tsub_add_eq_tsub_tsub, tsub_add_eq_tsub_tsub_swap]

/-! ### Lemmas that assume that an element is `AddLECancellable`. -/


namespace AddLECancellable

/-- See `AddLECancellable.tsub_eq_of_eq_add'` for a version assuming that `a = c + b` itself is
cancellable rather than `b`. -/
protected theorem tsub_eq_of_eq_add (hb : AddLECancellable b) (h : a = c + b) : a - b = c :=
  le_antisymm (tsub_le_iff_right.mpr h.le) <| by
    rw [h]
    exact hb.le_add_tsub

/-- Weaker version of `AddLECancellable.tsub_eq_of_eq_add` assuming that `a = c + b` itself is
cancellable rather than `b`. -/
protected lemma tsub_eq_of_eq_add' [AddLeftMono α] (ha : AddLECancellable a)
    (h : a = c + b) : a - b = c := (h ▸ ha).of_add_right.tsub_eq_of_eq_add h

/-- See `AddLECancellable.eq_tsub_of_add_eq'` for a version assuming that `b = a + c` itself is
cancellable rather than `c`. -/
protected theorem eq_tsub_of_add_eq (hc : AddLECancellable c) (h : a + c = b) : a = b - c :=
  (hc.tsub_eq_of_eq_add h.symm).symm

/-- Weaker version of `AddLECancellable.eq_tsub_of_add_eq` assuming that `b = a + c` itself is
cancellable rather than `c`. -/
protected lemma eq_tsub_of_add_eq' [AddLeftMono α] (hb : AddLECancellable b)
    (h : a + c = b) : a = b - c := (hb.tsub_eq_of_eq_add' h.symm).symm

/-- See `AddLECancellable.tsub_eq_of_eq_add_rev'` for a version assuming that `a = b + c` itself is
cancellable rather than `b`. -/
protected theorem tsub_eq_of_eq_add_rev (hb : AddLECancellable b) (h : a = b + c) : a - b = c :=
  hb.tsub_eq_of_eq_add <| by rw [add_comm, h]

/-- Weaker version of `AddLECancellable.tsub_eq_of_eq_add_rev` assuming that `a = b + c` itself is
cancellable rather than `b`. -/
protected lemma tsub_eq_of_eq_add_rev' [AddLeftMono α]
    (ha : AddLECancellable a) (h : a = b + c) : a - b = c :=
  ha.tsub_eq_of_eq_add' <| by rw [add_comm, h]

@[simp]
protected theorem add_tsub_cancel_right (hb : AddLECancellable b) : a + b - b = a :=
  hb.tsub_eq_of_eq_add <| by rw [add_comm]

@[simp]
protected theorem add_tsub_cancel_left (ha : AddLECancellable a) : a + b - a = b :=
  ha.tsub_eq_of_eq_add <| add_comm a b

protected theorem lt_add_of_tsub_lt_left (hb : AddLECancellable b) (h : a - b < c) : a < b + c := by
  rw [lt_iff_le_and_ne, ← tsub_le_iff_left]
  refine ⟨h.le, ?_⟩
  rintro rfl
  simp [hb] at h

protected theorem lt_add_of_tsub_lt_right (hc : AddLECancellable c) (h : a - c < b) :
    a < b + c := by
  rw [lt_iff_le_and_ne, ← tsub_le_iff_right]
  refine ⟨h.le, ?_⟩
  rintro rfl
  simp [hc] at h

protected theorem lt_tsub_of_add_lt_right (hc : AddLECancellable c) (h : a + c < b) : a < b - c :=
  (hc.le_tsub_of_add_le_right h.le).lt_of_ne <| by
    rintro rfl
    exact h.not_ge le_tsub_add

protected theorem lt_tsub_of_add_lt_left (ha : AddLECancellable a) (h : a + c < b) : c < b - a :=
  ha.lt_tsub_of_add_lt_right <| by rwa [add_comm]

end AddLECancellable

/-! #### Lemmas where addition is order-reflecting. -/


section Contra

variable [AddLeftReflectLE α]

theorem tsub_eq_of_eq_add (h : a = c + b) : a - b = c :=
  Contravariant.AddLECancellable.tsub_eq_of_eq_add h

theorem eq_tsub_of_add_eq (h : a + c = b) : a = b - c :=
  Contravariant.AddLECancellable.eq_tsub_of_add_eq h

theorem tsub_eq_of_eq_add_rev (h : a = b + c) : a - b = c :=
  Contravariant.AddLECancellable.tsub_eq_of_eq_add_rev h

@[simp]
theorem add_tsub_cancel_right (a b : α) : a + b - b = a :=
  Contravariant.AddLECancellable.add_tsub_cancel_right

@[simp]
theorem add_tsub_cancel_left (a b : α) : a + b - a = b :=
  Contravariant.AddLECancellable.add_tsub_cancel_left

/-- A more general version of the reverse direction of `sub_eq_sub_iff_add_eq_add` -/
theorem tsub_eq_tsub_of_add_eq_add (h : a + d = c + b) : a - b = c - d := by
  calc a - b = a + d - d - b := by rw [add_tsub_cancel_right]
           _ = c + b - b - d := by rw [h, tsub_right_comm]
           _ = c - d := by rw [add_tsub_cancel_right]

theorem lt_add_of_tsub_lt_left (h : a - b < c) : a < b + c :=
  Contravariant.AddLECancellable.lt_add_of_tsub_lt_left h

theorem lt_add_of_tsub_lt_right (h : a - c < b) : a < b + c :=
  Contravariant.AddLECancellable.lt_add_of_tsub_lt_right h

/-- This lemma (and some of its corollaries) also holds for `ENNReal`, but this proof doesn't work
for it. Maybe we should add this lemma as field to `OrderedSub`? -/
theorem lt_tsub_of_add_lt_left : a + c < b → c < b - a :=
  Contravariant.AddLECancellable.lt_tsub_of_add_lt_left

theorem lt_tsub_of_add_lt_right : a + c < b → a < b - c :=
  Contravariant.AddLECancellable.lt_tsub_of_add_lt_right

end Contra

section Both

variable [AddLeftMono α] [AddLeftReflectLE α]

theorem add_tsub_add_eq_tsub_right (a c b : α) : a + c - (b + c) = a - b := by
  refine add_tsub_add_le_tsub_right.antisymm (tsub_le_iff_right.2 <| ?_)
  apply le_of_add_le_add_right
  rw [add_assoc]
  exact le_tsub_add

theorem add_tsub_add_eq_tsub_left (a b c : α) : a + b - (a + c) = b - c := by
  rw [add_comm a b, add_comm a c, add_tsub_add_eq_tsub_right]

end Both

end OrderedAddCommSemigroup

/-! ### Lemmas in a linearly ordered monoid. -/


section LinearOrder

variable {a b c : α} [LinearOrder α] [AddCommSemigroup α] [Sub α] [OrderedSub α]

/-- See `lt_of_tsub_lt_tsub_right_of_le` for a weaker statement in a partial order. -/
theorem lt_of_tsub_lt_tsub_right (h : a - c < b - c) : a < b :=
  lt_imp_lt_of_le_imp_le (fun h => tsub_le_tsub_right h c) h

/-- See `lt_tsub_iff_right_of_le` for a weaker statement in a partial order. -/
theorem lt_tsub_iff_right : a < b - c ↔ a + c < b :=
  lt_iff_lt_of_le_iff_le tsub_le_iff_right

/-- See `lt_tsub_iff_left_of_le` for a weaker statement in a partial order. -/
theorem lt_tsub_iff_left : a < b - c ↔ c + a < b :=
  lt_iff_lt_of_le_iff_le tsub_le_iff_left

theorem lt_tsub_comm : a < b - c ↔ c < b - a :=
  lt_tsub_iff_left.trans lt_tsub_iff_right.symm

section Cov

variable [AddLeftMono α]

/-- See `lt_of_tsub_lt_tsub_left_of_le` for a weaker statement in a partial order. -/
theorem lt_of_tsub_lt_tsub_left (h : a - b < a - c) : c < b :=
  lt_imp_lt_of_le_imp_le (fun h => tsub_le_tsub_left h a) h

end Cov

end LinearOrder

section OrderedAddCommMonoid

variable [PartialOrder α] [AddCommMonoid α] [Sub α] [OrderedSub α]

@[simp]
theorem tsub_zero (a : α) : a - 0 = a :=
  AddLECancellable.tsub_eq_of_eq_add addLECancellable_zero (add_zero _).symm

end OrderedAddCommMonoid
