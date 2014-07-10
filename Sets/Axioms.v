Require Export Lib.

Parameter set : Type.

Parameter In : set → set → Prop.

Notation "x ∈ X" := (In x X) (at level 69).
Notation "x ∉ X" := (not (In x X)) (at level 69).

Definition Subq (X Y : set) : Prop := ∀ x : set, x ∈ X → x ∈ Y.

Notation "X ⊆ Y" := (Subq X Y) (at level 69).

Lemma Subq_refl : ∀ (A : set), A ⊆ A.
Proof. compute. auto. Qed.

Hint Resolve Subq_refl.

Lemma Subq_trans : ∀ (A B C : set), A ⊆ B → B ⊆ C → A ⊆ C.
Proof. compute. auto. Qed.

Hint Resolve Subq_trans.

(* Axiom 1 (Extensionality). Two sets X and Y are equal if they contain the
   same elements. *)

Axiom extensionality : ∀ X Y : set, X ⊆ Y → Y ⊆ X → X = Y.

Hint Resolve extensionality.

Lemma extensionality_E : ∀ X Y : set, X = Y -> X ⊆ Y ∧ Y ⊆ X.
Proof.
  intros. split; compute; intros.
    rewrite <- H. assumption.
    rewrite H. assumption.
Qed.

Hint Resolve extensionality.

Ltac extension := apply extensionality; unfold Subq; intros.

(* Axiom 2 (∈-induction). The membership relation on sets satisfies the
   induction principle. *)

Axiom In_ind : ∀ P : set → Prop,
  (∀ X : set, (∀ x, x ∈ X → P x) → P X) →
  (∀ X : set, P X).

(* Axiom 3 (The empty set). There ∃ a set which does not contain any
   elements.  We call this set the empty set and denote it by ∅. *)

Parameter Empty : set.

Notation "∅" := (Empty).

Axiom Empty_E : ∀ x : set, x ∉ ∅.

Hint Resolve Empty_E.

Definition inh_set (S : set) := ∃ w, w ∈ S.

(* Axiom 4 (Pairing). For all sets y and z there ∃ a set containing
   exactly y and z as elements. We call this set the unordered pair of y and z
   and denote it by {y,z}. *)

Parameter UPair : set → set → set.

Axiom UPair_I1 : ∀ y z : set, y ∈ (UPair y z).
Axiom UPair_I2 : ∀ y z : set, z ∈ (UPair y z).
Axiom UPair_E : ∀ x y z : set, x ∈ (UPair y z) → x = y ∨ x = z.

Hint Resolve UPair_I1.
Hint Resolve UPair_I2.
Hint Resolve UPair_E.

Notation "{ a , b }" := (UPair a b) (at level 69).

(* The axiomatic pairing of sets a and b is agnostic with respect to their
   ordering. *)

Theorem pair_agnostic : ∀ a b, {a, b} = {b, a}.
Proof.
  intros.
  pose extensionality.
  specialize (e (UPair a b) (UPair b a)).
  apply e; compute; intros;
    apply UPair_E in H; inversion H; rewrite H0; auto.
Qed.

Hint Resolve pair_agnostic.

Ltac pair_e H := apply UPair_E in H; try (inv H); try auto.
Ltac pair_1 := apply UPair_I1; try auto.
Ltac pair_2 := apply UPair_I2; try auto.

(* Axiom 5 (Union). Given a collection of sets X, there ∃ a set whose
   elements are exactly those which are a member of at least one of the sets
   in the collection X.  We call this set the union over X and denote it by
   ∪. *)

Parameter Union : set → set.

Axiom Union_I : ∀ X x Y : set, x ∈ Y → Y ∈ X → x ∈ (Union X).
Axiom Union_E : ∀ X x : set, x ∈ (Union X) → ∃ Y : set, x ∈ Y ∧ Y ∈ X.

Hint Resolve Union_I.
Hint Resolve Union_E.

Definition BinUnion (A B : set) : set := Union (UPair A B).

Lemma BinUnion_I1 : ∀ A B a: set, a ∈ A → a ∈ BinUnion A B.
Proof.
  intros. compute.
  apply Union_I with (Y := A). assumption.
  pair_1.
Qed.

Hint Resolve BinUnion_I1.

Lemma BinUnion_I2 : ∀ A B b: set, b ∈ B → b ∈ BinUnion A B.
Proof.
  intros. compute.
  apply Union_I with (Y := B). assumption.
  pair_2.
Qed.

Hint Resolve BinUnion_I2.

Lemma BinUnion_E : ∀ A B x, x ∈ BinUnion A B → x ∈ A ∨ x ∈ B.
Proof.
  intros. compute in H.
  apply Union_E in H. destruct H. inv H.
  pair_e H1.
Qed.

Hint Resolve BinUnion_E.

Notation "X ∪ Y" := (BinUnion X Y) (at level 69).

Ltac union_e H := apply BinUnion_E in H; destruct H; try (inv H); try auto.
Ltac union_1 := apply BinUnion_I1; try auto.
Ltac union_2 := apply BinUnion_I2; try auto.

(* Axiom 6 (Powerset). Given a set X, there ∃ a set which contains as its
   elements exactly those sets which are the subsets of X. We call this set the
   powerset of X and denote it by 𝒫(X). *)

Parameter Power : set → set.

Axiom Power_I : ∀ X Y : set, Y ⊆ X → Y ∈ (Power X).
Axiom Power_E : ∀ X Y : set, Y ∈ (Power X) → Y ⊆ X.

Hint Resolve Power_I.
Hint Resolve Power_E.

(* Axiom 7 (Replacement). Given a unary set former F and a set X, there ∃
   a set which contains exactly those elements obtained by applying F to each
   element in X. We denote this construction with {F x | x ∈ X}. *)

Parameter Repl : (set → set) → set → set.

Axiom Repl_I : ∀ (X : set) (F : set → set) (x : set),
  x ∈ X → (F x) ∈ (Repl F X).
Axiom Repl_E : ∀ (X : set) (F : set → set) (y : set),
  y ∈ (Repl F X) → ∃ x : set, x ∈ X ∧ y = F x.

Hint Resolve Repl_I.
Hint Resolve Repl_E.
