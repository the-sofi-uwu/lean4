/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Jeremy Avigad

Prime numbers.
-/
import data.nat logic.identities
open bool

namespace nat
open decidable

definition prime [reducible] (p : nat) := p ≥ 2 ∧ ∀ m, m ∣ p → m = 1 ∨ m = p

definition prime_ext (p : nat) := p ≥ 2 ∧ ∀ m, m ≤ p → m ∣ p → m = 1 ∨ m = p
local attribute prime_ext [reducible]

lemma prime_ext_iff_prime (p : nat) : prime_ext p ↔ prime p :=
iff.intro
  begin
    intro h, cases h with h₁ h₂, constructor, assumption,
    intro m d, exact h₂ m (le_of_dvd (lt_of_succ_le (le_of_succ_le h₁)) d) d
  end
  begin
    intro h, cases h with h₁ h₂, constructor, assumption,
    intro m l d, exact h₂ m d
  end

definition decidable_prime [instance] (p : nat) : decidable (prime p) :=
decidable_of_decidable_of_iff _ (prime_ext_iff_prime p)

lemma ge_two_of_prime {p : nat} : prime p → p ≥ 2 :=
suppose prime p, obtain h₁ h₂, from this,
h₁

theorem gt_one_of_prime {p : ℕ} (primep : prime p) : p > 1 :=
lt_of_succ_le (ge_two_of_prime primep)

theorem pos_of_prime {p : ℕ} (primep : prime p) : p > 0 :=
lt.trans zero_lt_one (gt_one_of_prime primep)

lemma not_prime_zero : ¬ prime 0 :=
λ h, absurd (ge_two_of_prime h) dec_trivial

lemma not_prime_one : ¬ prime 1 :=
λ h, absurd (ge_two_of_prime h) dec_trivial

lemma prime_two : prime 2 :=
dec_trivial

lemma prime_three : prime 3 :=
dec_trivial

lemma pred_prime_pos {p : nat} : prime p → pred p > 0 :=
suppose prime p,
have p ≥ 2,      from ge_two_of_prime this,
show pred p > 0, from lt_of_succ_le (pred_le_pred this)

lemma succ_pred_prime {p : nat} : prime p → succ (pred p) = p :=
assume h, succ_pred_of_pos (pos_of_prime h)

lemma eq_one_or_eq_self_of_prime_of_dvd {p m : nat} : prime p → m ∣ p → m = 1 ∨ m = p :=
assume h d, obtain h₁ h₂, from h, h₂ m d

lemma gt_one_of_pos_of_prime_dvd {i p : nat} : prime p → 0 < i → i mod p = 0 → 1 < i :=
assume ipp pos h,
have h₁ : p ≥ 2, from ge_two_of_prime ipp,
have p ∣ i,       from dvd_of_mod_eq_zero h,
have p ≤ i,      from le_of_dvd pos this,
lt_of_succ_le (le.trans h₁ this)

definition sub_dvd_of_not_prime {n : nat} : n ≥ 2 → ¬ prime n → {m | m ∣ n ∧ m ≠ 1 ∧ m ≠ n} :=
assume h₁ h₂,
have ¬ prime_ext n, from iff.mpr (not_iff_not_of_iff !prime_ext_iff_prime) h₂,
have ¬ n ≥ 2 ∨ ¬ (∀ m, m ≤ n → m ∣ n → m = 1 ∨ m = n), from iff.mp !not_and_iff_not_or_not this,
have ¬ (∀ m, m ≤ n → m ∣ n → m = 1 ∨ m = n), from or_resolve_right this (not_not_intro h₁),
have ¬ (∀ m, m < succ n → m ∣ n → m = 1 ∨ m = n), from
  assume h, absurd (λ m hl hd, h m (lt_succ_of_le hl) hd) this,
have {m | m < succ n ∧ ¬(m ∣ n → m = 1 ∨ m = n)}, from bsub_not_of_not_ball this,
obtain m hlt (h₃ : ¬(m ∣ n → m = 1 ∨ m = n)), from this,
obtain (h₄ : m ∣ n) (h₅ : ¬ (m = 1 ∨ m = n)), from iff.mp !not_implies_iff_and_not h₃,
have ¬ m = 1 ∧ ¬ m = n,  from iff.mp !not_or_iff_not_and_not h₅,
subtype.tag m (and.intro h₄ this)

theorem ex_dvd_of_not_prime {n : nat} : n ≥ 2 → ¬ prime n → ∃ m, m ∣ n ∧ m ≠ 1 ∧ m ≠ n :=
assume h₁ h₂, ex_of_sub (sub_dvd_of_not_prime h₁ h₂)

definition sub_dvd_of_not_prime2 {n : nat} : n ≥ 2 → ¬ prime n → {m | m ∣ n ∧ m ≥ 2 ∧ m < n} :=
assume h₁ h₂,
have n_ne_0 : n ≠ 0, from assume h, begin subst n, exact absurd h₁ dec_trivial end,
obtain m m_dvd_n m_ne_1 m_ne_n, from sub_dvd_of_not_prime h₁ h₂,
assert m_ne_0 : m ≠ 0, from assume h, begin subst m, exact absurd (eq_zero_of_zero_dvd m_dvd_n) n_ne_0 end,
begin
  existsi m, split, assumption,
  split,
    {cases m with m, exact absurd rfl m_ne_0, cases m with m, exact absurd rfl m_ne_1, exact succ_le_succ (succ_le_succ (zero_le _))},
    {have m_le_n : m ≤ n, from le_of_dvd (pos_of_ne_zero n_ne_0) m_dvd_n,
     exact lt_of_le_and_ne m_le_n m_ne_n}
end

theorem ex_dvd_of_not_prime2 {n : nat} : n ≥ 2 → ¬ prime n → ∃ m, m ∣ n ∧ m ≥ 2 ∧ m < n :=
assume h₁ h₂, ex_of_sub (sub_dvd_of_not_prime2 h₁ h₂)

definition sub_prime_and_dvd {n : nat} : n ≥ 2 → {p | prime p ∧ p ∣ n} :=
nat.strong_rec_on n
  (take n,
   assume ih : ∀ m, m < n → m ≥ 2 → {p | prime p ∧ p ∣ m},
   assume n_ge_2 : n ≥ 2,
   by_cases
    (λ h : prime n, subtype.tag n (and.intro h (dvd.refl n)))
    (λ h : ¬ prime n,
      obtain m m_dvd_n m_ge_2 m_lt_n, from sub_dvd_of_not_prime2 n_ge_2 h,
      obtain p (hp : prime p) (p_dvd_m : p ∣ m), from ih m m_lt_n m_ge_2,
      have p_dvd_n : p ∣ n, from dvd.trans p_dvd_m m_dvd_n,
      subtype.tag p (and.intro hp p_dvd_n)))

lemma ex_prime_and_dvd {n : nat} : n ≥ 2 → ∃ p, prime p ∧ p ∣ n :=
assume h, ex_of_sub (sub_prime_and_dvd h)

open eq.ops

definition infinite_primes (n : nat) : {p | p ≥ n ∧ prime p} :=
let m := fact (n + 1) in
have m ≥ 1,     from le_of_lt_succ (succ_lt_succ (fact_pos _)),
have m + 1 ≥ 2, from succ_le_succ this,
obtain p (prime_p : prime p) (p_dvd_m1 : p ∣ m + 1), from sub_prime_and_dvd this,
have p_ge_2 : p ≥ 2, from ge_two_of_prime prime_p,
have p_gt_0 : p > 0, from lt_of_succ_lt (lt_of_succ_le p_ge_2),
have p ≥ n, from by_contradiction
  (suppose ¬ p ≥ n,
    have p < n,     from lt_of_not_ge this,
    have p ≤ n + 1, from le_of_lt (lt.step this),
    have p ∣ m,      from dvd_fact p_gt_0 this,
    have p ∣ 1,      from dvd_of_dvd_add_right (!add.comm ▸ p_dvd_m1) this,
    have p ≤ 1,     from le_of_dvd zero_lt_one this,
    absurd (le.trans p_ge_2 this) dec_trivial),
subtype.tag p (and.intro this prime_p)

lemma ex_infinite_primes (n : nat) : ∃ p, p ≥ n ∧ prime p :=
ex_of_sub (infinite_primes n)

lemma odd_of_prime {p : nat} : prime p → p > 2 → odd p :=
λ pp p_gt_2, by_contradiction (λ hn,
  have even_p : even p, from even_of_not_odd hn,
  obtain k (hk : p = 2*k), from exists_of_even even_p,
  assert two_div_p : 2 ∣ p, by rewrite [hk]; apply dvd_mul_right,
  or.elim (eq_one_or_eq_self_of_prime_of_dvd pp two_div_p)
    (λ h : 2 = 1, absurd h dec_trivial)
    (λ h : 2 = p, by subst h; exact absurd p_gt_2 !lt.irrefl))

theorem dvd_of_prime_of_not_coprime {p n : ℕ} (primep : prime p) (nc : ¬ coprime p n) : p ∣ n :=
have H : gcd p n = 1 ∨ gcd p n = p, from eq_one_or_eq_self_of_prime_of_dvd primep !gcd_dvd_left,
or_resolve_right H nc ▸ !gcd_dvd_right

theorem coprime_of_prime_of_not_dvd {p n : ℕ} (primep : prime p) (npdvdn : ¬ p ∣ n) :
  coprime p n :=
by_contradiction (suppose ¬ coprime p n, npdvdn (dvd_of_prime_of_not_coprime primep this))

theorem not_dvd_of_prime_of_coprime {p n : ℕ} (primep : prime p) (cop : coprime p n) : ¬ p ∣ n :=
suppose p ∣ n,
have p ∣ gcd p n,  from dvd_gcd !dvd.refl this,
have p ≤ gcd p n, from le_of_dvd (!gcd_pos_of_pos_left (pos_of_prime primep)) this,
have 2 ≤ 1,       from le.trans (ge_two_of_prime primep) (cop ▸ this),
show false,       from !not_succ_le_self this

theorem not_coprime_of_prime_dvd {p n : ℕ} (primep : prime p) (pdvdn : p ∣ n) : ¬ coprime p n :=
assume cop, not_dvd_of_prime_of_coprime primep cop pdvdn

theorem dvd_of_prime_of_dvd_mul_left {p m n : ℕ} (primep : prime p)
    (Hmn : p ∣ m * n) (Hm : ¬ p ∣ m) :
  p ∣ n :=
have coprime p m, from coprime_of_prime_of_not_dvd primep Hm,
show p ∣ n, from dvd_of_coprime_of_dvd_mul_left this Hmn

theorem dvd_of_prime_of_dvd_mul_right {p m n : ℕ} (primep : prime p)
    (Hmn : p ∣ m * n) (Hn : ¬ p ∣ n) :
  p ∣ m :=
dvd_of_prime_of_dvd_mul_left primep (!mul.comm ▸ Hmn) Hn

theorem not_dvd_mul_of_prime {p m n : ℕ} (primep : prime p) (Hm : ¬ p ∣ m) (Hn : ¬ p ∣ n) :
  ¬ p ∣ m * n :=
assume Hmn, Hm (dvd_of_prime_of_dvd_mul_right primep Hmn Hn)

lemma dvd_or_dvd_of_prime_of_dvd_mul {p m n : nat} : prime p → p ∣ m * n → p ∣ m ∨ p ∣ n :=
λ h₁ h₂, by_cases
  (suppose p ∣ m, or.inl this)
  (suppose ¬ p ∣ m, or.inr (dvd_of_prime_of_dvd_mul_left h₁ h₂ this))

lemma dvd_of_prime_of_dvd_pow {p m : nat} : ∀ {n}, prime p → p ∣ m^n → p ∣ m
| 0 hp hd :=
  assert p = 1, from eq_one_of_dvd_one hd,
  have   1 ≥ 2, by rewrite -this; apply ge_two_of_prime hp,
  absurd this dec_trivial
| (succ n) hp hd :=
  have p ∣ (m^n)*m, by rewrite [pow_succ at hd]; exact hd,
  or.elim (dvd_or_dvd_of_prime_of_dvd_mul hp this)
    (λ h : p ∣ m^n, dvd_of_prime_of_dvd_pow hp h)
    (λ h : p ∣ m, h)

lemma coprime_pow_of_prime_of_not_dvd {p m a : nat} : prime p → ¬ p ∣ a → coprime a (p^m) :=
λ h₁ h₂, coprime_pow_right m (coprime_swap (coprime_of_prime_of_not_dvd h₁ h₂))

lemma coprime_primes {p q : nat} : prime p → prime q → p ≠ q → coprime p q :=
λ hp hq hn,
  assert gcd p q ∣ p, from !gcd_dvd_left,
  or.elim (eq_one_or_eq_self_of_prime_of_dvd hp this)
    (λ h : gcd p q = 1, h)
    (λ h : gcd p q = p,
      assert gcd p q ∣ q, from !gcd_dvd_right,
      have   p ∣ q, by rewrite -h; exact this,
      or.elim (eq_one_or_eq_self_of_prime_of_dvd hq this)
        (λ h₁ : p = 1, by subst p; exact absurd hp not_prime_one)
        (λ he : p = q, by contradiction))

lemma coprime_pow_primes {p q : nat} (n m : nat) : prime p → prime q → p ≠ q → coprime (p^n) (q^m) :=
λ hp hq hn, coprime_pow_right m (coprime_pow_left n (coprime_primes hp hq hn))

lemma coprime_or_dvd_of_prime {p} (Pp : prime p) (i : nat) : coprime p i ∨ p ∣ i :=
by_cases
 (λ h : p ∣ i, or.inr h)
 (λ h : ¬ p ∣ i, or.inl (coprime_of_prime_of_not_dvd Pp h))

lemma eq_one_or_dvd_of_dvd_prime_pow {p : nat} : ∀ {m i : nat}, prime p → i ∣ (p^m) → i = 1 ∨ p ∣ i
| 0        := take i, assume Pp, begin rewrite [pow_zero], intro Pdvd, apply or.inl (eq_one_of_dvd_one Pdvd) end
| (succ m) := take i, assume Pp, or.elim (coprime_or_dvd_of_prime Pp i)
  (λ Pcp, begin
    rewrite [pow_succ], intro Pdvd,
    apply eq_one_or_dvd_of_dvd_prime_pow Pp,
    apply dvd_of_coprime_of_dvd_mul_right,
      apply coprime_swap Pcp, exact Pdvd
  end)
  (λ Pdvd, assume P, or.inr Pdvd)
end nat
