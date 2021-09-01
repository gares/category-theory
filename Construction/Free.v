Set Warnings "-notation-overridden".
Set Warnings "-deprecated-hint-without-locality".

Require Import Category.Lib.
Require Import Category.Lib.TList.
Require Export Category.Theory.Functor.
Require Export Category.Instance.Cat.

Generalizable All Variables.
Set Primitive Projections.
Set Universe Polymorphism.

Section Free.

Context {C : Category}.

(* Wikipedia: "In mathematics, the free category or path category generated by
   a directed graph or quiver is the category that results from freely
   concatenating arrows together, whenever the target of one arrow is the
   source of the next."
   
   "More precisely, the objects of the category are the vertices of the
   quiver, and the morphisms are paths between objects. Here, a path is
   defined as a finite sequence " *)

Definition composition {x y : C} : tlist hom x y -> x ~{C}~> y.
Proof.
  intros.
  induction X.
    exact id.
  exact (compose IHX b).
Defined.

Definition composition_tnil {x : C} : composition tnil ≈ id[x].
Proof. now cat. Qed.

Definition composition_tapp {x y z : C} (g : tlist hom y z) (f : tlist hom x y) :
  composition (f +++ g) ≈ composition g ∘ composition f.
Proof.
  induction f; simpl.
    rewrite tlist_app_tnil_l.
    now cat.
  rewrite <- tlist_app_comm_cons.
  simpl.
  rewrite IHf.
  now cat.
Qed.

Program Definition Free : Category := {|
  obj     := C;
  hom     := tlist hom;
  homset  := fun _ _ =>
    {| equiv := fun f g => composition f ≈ composition g |};
  id      := fun _ => tnil;
  compose := fun _ _ _ f g => g +++ f
|}.
Next Obligation. now equivalence. Qed.
Next Obligation. now rewrite !composition_tapp, X, X0. Qed.
Next Obligation. now rewrite tlist_app_tnil_r. Qed.
Next Obligation. now rewrite tlist_app_tnil_l. Qed.
Next Obligation. now rewrite tlist_app_assoc. Qed.
Next Obligation. now rewrite tlist_app_assoc. Qed.

End Free.

Program Definition FreeFunctor : Free ⟶ Cat := {|
  fobj := fun x => x;
  fmap := fun _ _ f => composition f;
  fmap_id := fun _ => composition_tnil;
  fmap_comp := fun _ _ _ => composition_tapp
|}.
