module Coq where

import Language.Haskell.Liquid.ProofCombinators

-- | <http://flint.cs.yale.edu/cs430/sectionNotes/section1/CoqTutorial.pdf> page 2
{-@ hilbert_axiom_S :: p:Bool -> q:Bool -> r:Bool -> { (p => q => r) => (p => q) => p => r } @-}
hilbert_axiom_S :: Bool -> Bool -> Bool -> Proof
hilbert_axiom_S _ _ _ = () *** QED

{-@ hilbert_axiom_S' :: p:Bool -> {q:Bool | p => q} -> {r:Bool | p => q => r} -> { p => r } @-}
hilbert_axiom_S' :: Bool -> Bool -> Bool -> Proof
hilbert_axiom_S' _ _ _ = () *** QED


-- | <http://flint.cs.yale.edu/cs430/sectionNotes/section1/CoqTutorial.pdf> page 4
{-@ distr_and_or :: p:Bool -> q:Bool -> r:Bool -> { (p && q) || (p && r) => p && (q || r) } @-}
distr_and_or :: Bool -> Bool -> Bool -> Proof
distr_and_or _ _ _ = () *** QED

{-@ distr_and_or' :: p:Bool -> {q:Bool | p && q} -> {r:Bool | p && r} -> { p && (q || r) } @-}
distr_and_or' :: Bool -> Bool -> Bool -> Proof
distr_and_or' _ _ _ = () *** QED


data Nat = O | S Nat
