(*
    Example proof script for testing Coq Proof General.
 
    $Id$
*)    

(****************************************************************************)
(*                 The Calculus of Inductive Constructions                  *)
(*                                                                          *)
(*                                Projet Coq                                *)
(*                                                                          *)
(*                     INRIA                        ENS-CNRS                *)
(*              Rocquencourt                        Lyon                    *)
(*                                                                          *)
(*                                 Coq V6.1                                 *)
(*                               Oct 1st 1996                               *)
(*                                                                          *)
(****************************************************************************)
(*                                  List.v                                  *)
(****************************************************************************)

Require Le.

(* Some programs and results about lists *)

Parameter A:Set.

Inductive list : Set := nil : list | cons : A -> list -> list.

(*
Fixpoint app [l:list] : list -> list 
      := [m:list]Case l of
                (* nil *) m 
          (* cons a l1 *) [a:A][l1:list](cons a (app l1 m)) end.

*)

Fixpoint app [l:list] : list -> list 
      := [m:list]<list>Cases l of
                           nil =>  m 
                       | (cons a l1) => (cons a (app l1 m)) 
                   end.


Lemma app_nil_end : (l:list)(l=(app l nil)).
Proof. 
	Intro l ; Elim l ; Simpl ; Auto.
        Induction 1; Auto.
Qed.
Hint app_nil_end.

Lemma app_ass : (l,m,n : list)(app (app l m) n)=(app l (app m n)).
Proof. 
	Intros l m n ; Elim l ; Simpl ; Auto.
	Induction 1; Auto.
Qed.
Hint app_ass.

Lemma ass_app : (l,m,n : list)(app l (app m n))=(app (app l m) n).
Proof. 
	Auto.
Qed.
Hint ass_app.

(*
Definition tail := [l:list]Case l of
                 (* nil *) nil 
            (* cons a m *) [a:A][m:list]m end : list->list.
*)

Definition tail := 
    [l:list] <list>Cases l of  (cons _ m) => m | _ => nil end : list->list.
                   

Lemma nil_cons : (a:A)(m:list)~(nil=(cons a m)).
Intros;Discriminate.
Qed.

(****************************************)
(* Length of lists                      *)
(****************************************)
(*
Fixpoint length [l:list] : nat 
   := Case l of (* nil *) O
                (* cons a m *) [a:A][m:list](S (length m)) end.
*)

Fixpoint length [l:list] : nat 
   := <nat>Cases l of (cons _ m) => (S (length m)) | _ => O end.

(******************************)
(* Length order of lists      *)
(******************************)

Section length_order.
Definition lel := [l,m:list](le (length l) (length m)).

Variables a,b:A.
Variables l,m,n:list.

Lemma lel_refl : (lel l l).
Proof. 
	Unfold lel ; Auto.
Qed.

Lemma lel_trans : (lel l m)->(lel m n)->(lel l n).
Proof. 
	Unfold lel ; Intros.
        Apply le_trans with (length m) ; Auto.
Qed.

Lemma lel_cons_cons : (lel l m)->(lel (cons a l) (cons b m)).
Proof. 
	Unfold lel ; Simpl ; Auto.
Qed.

Lemma lel_cons : (lel l m)->(lel l (cons b m)).
Proof. 
	Unfold lel ; Simpl ; Auto.
Qed.

Lemma lel_tail : (lel (cons a l) (cons b m)) -> (lel l m).
Proof. 
	Unfold lel ; Simpl ; Auto.
Qed.

Lemma lel_nil : (l':list)(lel l' nil)->(nil=l').
Proof. 
	Intro l' ; Elim l' ; Auto.
	Intros a' y H H0.
	(*  <list>nil=(cons a' y)
	    ============================
	      H0 : (lel (cons a' y) nil)
	      H : (lel y nil)->(<list>nil=y)
	      y : list
	      a' : A
	      l' : list *)
	Absurd (le (S (length y)) O); Auto.
Qed.
End length_order.

Hint lel_refl lel_cons_cons lel_cons lel_nil lel_nil nil_cons.

Fixpoint In  [a:A;l:list] : Prop :=
      (Case l of (* nil *) False 
                 (* cons b m *) [b:A][m:list](b=a)\/(In a m) end).

Lemma in_eq : (a:A)(l:list)(In a (cons a l)).
Proof. 
	Simpl ; Auto.
Qed.
Hint in_eq.

Lemma in_cons : (a,b:A)(l:list)(In b l)->(In b (cons a l)).
Proof. 
	Simpl ; Auto.
Qed.
Hint in_cons.

Lemma in_app_or : (l,m:list)(a:A)(In a (app l m))->((In a l)\/(In a m)).
Proof. 
	Intros l m a.
	Elim l ; Simpl ; Auto.
	Intros a0 y H H0.
	(*  ((<A>a0=a)\/(In a y))\/(In a m)
	    ============================
	      H0 : (<A>a0=a)\/(In a (app y m))
	      H : (In a (app y m))->((In a y)\/(In a m))
	      y : list
	      a0 : A
	      a : A
	      m : list
	      l : list *)
	Elim H0 ; Auto.
	Intro H1.
	(*  ((<A>a0=a)\/(In a y))\/(In a m)
	    ============================
	      H1 : (In a (app y m)) *)
	Elim (H H1) ; Auto.
Qed.
Immediate in_app_or.

Lemma in_or_app : (l,m:list)(a:A)((In a l)\/(In a m))->(In a (app l m)).
Proof. 
	Intros l m a.
	Elim l ; Simpl ; Intro H.
	(* 1 (In a m)
	    ============================
	      H : False\/(In a m)
	      a : A
	      m : list
	      l : list *)
	Elim H ; Auto ; Intro H0.
	(*  (In a m)
	    ============================
	      H0 : False *)
	Elim H0. (* subProof completed *)
	Intros y H0 H1.
	(*  2 (<A>H=a)\/(In a (app y m))
	    ============================
	      H1 : ((<A>H=a)\/(In a y))\/(In a m)
	      H0 : ((In a y)\/(In a m))->(In a (app y m))
	      y : list *)
	Elim H1 ; Auto 4.
	Intro H2.
	(*  (<A>H=a)\/(In a (app y m))
	    ============================
	      H2 : (<A>H=a)\/(In a y) *)
	Elim H2 ; Auto.
Qed.
Hint in_or_app.

Definition incl := [l,m:list](a:A)(In a l)->(In a m).

Hint Unfold incl.

Lemma incl_refl : (l:list)(incl l l).
Proof. 
	Auto.
Qed.
Hint incl_refl.

Lemma incl_tl : (a:A)(l,m:list)(incl l m)->(incl l (cons a m)).
Proof. 
	Auto.
Qed.
Immediate incl_tl.

Lemma incl_tran : (l,m,n:list)(incl l m)->(incl m n)->(incl l n).
Proof. 
	Auto.
Qed.

Lemma incl_appl : (l,m,n:list)(incl l n)->(incl l (app n m)).
Proof. 
	Auto.
Qed.
Immediate incl_appl.

Lemma incl_appr : (l,m,n:list)(incl l n)->(incl l (app m n)).
Proof. 
	Auto.
Qed.
Immediate incl_appr.

Lemma incl_cons : (a:A)(l,m:list)(In a m)->(incl l m)->(incl (cons a l) m).
Proof. 
	Unfold incl ; Simpl ; Intros a l m H H0 a0 H1.
	(*  (In a0 m)
	    ============================
	      H1 : (<A>a=a0)\/(In a0 l)
	      a0 : A
	      H0 : (a:A)(In a l)->(In a m)
	      H : (In a m)
	      m : list
	      l : list
	      a : A *)
	Elim H1.
	(*  1 (<A>a=a0)->(In a0 m) *)
	Elim H1 ; Auto ; Intro H2.
	(*  (<A>a=a0)->(In a0 m)
	    ============================
	      H2 : <A>a=a0 *)
	Elim H2 ; Auto. (* solves subgoal *)
	(*  2 (In a0 l)->(In a0 m) *)
	Auto.
Qed.
Hint incl_cons.

Lemma incl_app : (l,m,n:list)(incl l n)->(incl m n)->(incl (app l m) n).
Proof. 
	Unfold incl ; Simpl ; Intros l m n H H0 a H1.
	(*  (In a n)
	    ============================
	      H1 : (In a (app l m))
	      a : A
	      H0 : (a:A)(In a m)->(In a n)
	      H : (a:A)(In a l)->(In a n)
	      n : list
	      m : list
	      l : list *)
	Elim (in_app_or l m a) ; Auto.
Qed.
Hint incl_app.


(* Id: List.v,v 1.4 1996/10/07 07:50:36 ccornes Exp  *)
