{-# OPTIONS_GHC "-Wno-incomplete-patterns" #-}
{-# OPTIONS_GHC "-Wno-unused-matches" #-}
-- | Examples from the Dafny chapters we read as a class:
-- http://www.doc.ic.ac.uk/~scd/Dafny_Material/Lectures.pdf
module Dafny where

import Prelude hiding (head, tail, odd, even)
import Language.Haskell.Liquid.ProofCombinators

-- * Fibonacci function

-- ** 1.1

-- | Dafny book: <provides definition>
--
fib1 :: Int -> Int
fib1 n = if n <= 1
        then n
        else fib1 (n-1) + fib1 (n-2)

-- ** 3.1

-- | Dafny book: "This is not a correct definition, however, as fib(-1) does
-- not equal 1. The function should be undefined for n < 0."
--
-- LiquidHaskell: Fix the definition by constraining the input. The type alias
-- "Nat" stands for `n::Int` with the refinement `n > 0` which can be expressed
-- `{n:Int | n > 0}`.
--
{-@ fib1' :: Nat -> Int @-}
fib1' :: Int -> Int
fib1' n = if n <= 1
        then n
        else fib1' (n-1) + fib1' (n-2)

-- | Dafny book: "This function is no longer defined for n < 0, it will loop
-- instead."
--
-- LiquidHaskell: The definition cannot be proved to be terminating, and is
-- rejected. We disable the termination checker for illustration with "lazy".
--
{-@ lazy fib2 @-}
fib2 :: Int -> Int
fib2 n = if n == 0 || n == 1
        then 1
        else fib2 (n-1) + fib2 (n-2)

-- | Dafny book: "In Dafny, we can add pre-conditions to a function using
-- "requires"."
--
-- LiquidHaskell: Use the type alias "Nat" as the precondition. Now LH can
-- prove termination and accepts the definition.
--
{-@ fib2' :: Nat -> Int @-}
fib2' :: Int -> Int
fib2' n = if n == 0 || n == 1
        then 1
        else fib2' (n-1) + fib2' (n-2)


-- * Power function

-- ** 1.2

-- | Dafny book: <provides definition>
--
-- LiquidHaskell: Cannot prove termination. We disable the termination checker
-- again for illustration.
--
{-@ lazy power @-}
power :: Int -> Int -> Int
power x n = if n <= 0
            then 1
            else
                let r = power x (n-1) in
                    x * r

-- | LiquidHaskell: Help LH prove termination by telling LH which argument is
-- getting smaller.
--
{-@ power' :: Int -> n:Int -> Int / [n] @-}
power' :: Int -> Int -> Int
power' x n = if n <= 0
            then 1
            else
                let r = power' x (n-1) in
                    x * r


-- * List destructors

-- ** 3.2

-- | Dafny book: "These are not total functions, as they are undefined (will
-- crash) when given an empty list as input."
--
{-@ fail head @-}
head :: [a] -> a
head (x:xs) = x
{-@ fail tail @-}
tail :: [a] -> [a]
tail (x:xs) = xs

-- | LiquidHaskell: We can require that the functions are never called on empty
-- lists. There are at least two built-in ways to specify a non-empty list:
--
-- {xs:[a] | xs /= []}      "It's not the nil constructor."
--
-- {xs:[a] | 0 < len xs}    Zero is less than the "len" of the list ("len" is a
--                          built-in measure).
--
{-@ head' :: {xs:[a] | xs /= []} -> a @-}
-- {-@ head' :: {xs:[a] | 0 < len xs} -> a @-}
head' :: [a] -> a
head' (x:xs) = x
{-@ tail' :: {xs:[a] | xs /= []} -> [a] @-}
-- {-@ tail' :: {xs:[a] | 0 < len xs} -> [a] @-}
tail' :: [a] -> [a]
tail' (x:xs) = xs

-- * 4.1

-- | Dafny book: <provides definition>
--
data Natr = Zero | Succ Natr
    deriving Eq

-- | Dafny book: <provides definition>
--
odd :: Natr -> Bool
odd Zero = False
odd (Succ Zero) = True
odd (Succ z) = odd z

-- | Dafny book: <provides definition>
--
even :: Natr -> Bool
even Zero = True
even (Succ Zero) = False
even (Succ z) = even z

-- | Dafny book: "One simple property we would like to be able to prove is,
-- for-all x:N. x + 0 = x. That is to say:
--
--      for-all x:Natr. add(x, Zero) = x"
--
add :: Natr -> Natr -> Natr
add x y = case x of
    Zero -> y
    Succ x' -> Succ (add x' y)

-- * 4.2

-- | Dafny book: <explains about ghost methods>
--
-- LiquidHaskell: Any code that a theorem discusess must be lifted into LH
-- specifications (a measure, inlined, or reflected).
--
{-@ reflect add @-}
{-@ LIQUID "--exact-data-cons" @-} -- To lift Natr

-- ** 4.2.a

-- | Dafny book: "Notice that Dafny can verify prop_add_Zero automatically,
-- even though the hand-proof requires induction!"
--
-- LiquidHaskell: To prove a property, define a function which states the
-- property in the postcondition.
--
--  * Express cases by matching the constructors.
--  * Express the inductive assumption holds by calling the proof function.
--  * Enable PLE to help with automatically undfolding reflected definitions.
--  * Use the ProofCombinators import to access definitions that make reading
--    the proof nicer (they don't really change the functionality though).
--
{-@ LIQUID "--ple-local" @-}
{-@ ple prop_add_Zero @-}
{-@ prop_add_Zero :: x:Natr -> { _:Proof | add x Zero == x } @-}
prop_add_Zero :: Natr -> Proof
prop_add_Zero Zero = ()
prop_add_Zero (Succ x) = prop_add_Zero x

{-@ ple prop_add_Succ @-}
{-@ prop_add_Succ :: x:Natr -> y:Natr -> { _:Proof | Succ (add x y) == add x (Succ y) } @-}
prop_add_Succ :: Natr -> Natr -> Proof
prop_add_Succ  Zero    _ = ()
prop_add_Succ (Succ x) y = prop_add_Succ x y

{-@ prop_add_Succ1a :: x:Natr -> y:Natr -> { _:Proof | Succ (add x y) == add x (Succ y) } @-}
prop_add_Succ1a :: Natr -> Natr -> Proof
prop_add_Succ1a Zero y
    =             Succ (add Zero y)     -- Run 'add' forwards
    ===           Succ  y               -- Run 'add' backwards (first case)
    === add Zero (Succ  y          )
    *** QED
prop_add_Succ1a (Succ x) y
    =   Succ (add (Succ x) y)   -- Run 'add' forwards
    === Succ (Succ (add x y))   ? prop_add_Succ1a x y
    === Succ (add x (Succ y))   -- Run 'add' backwards
    === add (Succ x) (Succ y)
    *** QED

{-@ prop_add_Succ1b :: x:Natr -> y:Natr -> { _:Proof | Succ (add x y) == add x (Succ y) } @-}
prop_add_Succ1b :: Natr -> Natr -> Proof
prop_add_Succ1b Zero y
    =   Succ (add Zero y) == add Zero (Succ y)  -- Run 'add' forwards (left & right)
    === Succ (         y) ==          (Succ y)
    *** QED
prop_add_Succ1b (Succ x) y
    =   Succ (add (Succ x) y) == add (Succ x) (Succ y)  -- Run 'add' forwards (left & right)
    === Succ (Succ (add x y)) == Succ (add x (Succ y))  ? prop_add_Succ1b x y -- (left)
    === Succ (add x (Succ y)) == Succ (add x (Succ y))
    *** QED

{-@ prop_add_Succ2 :: x:Natr -> y:Natr -> { _:Proof | Succ (add x y) == add x (Succ y) } @-}
prop_add_Succ2 :: Natr -> Natr -> Proof
prop_add_Succ2 Zero Zero
    =             Succ (add Zero Zero)  -- Run 'add' forwards
    ===           Succ (         Zero)  -- Run 'add' backwards (first case)
    === add Zero (Succ (Zero         ))
    *** QED
prop_add_Succ2 (Succ x) Zero
    =   Succ (add (Succ x) Zero)    -- Run 'add' forwards
    === Succ (Succ (add x Zero))    ? prop_add_Succ2 x Zero
    === Succ (add x (Succ Zero))    -- Run 'add' backwards
    === add (Succ x) (Succ Zero)
    *** QED
prop_add_Succ2 Zero (Succ y)
    =             Succ (add Zero (Succ y))  -- Run 'add' forwards
    ===           Succ (          Succ y )  -- Run 'add' backwards (first case)
    === add Zero (Succ (          Succ y ))
    *** QED
prop_add_Succ2 (Succ x) (Succ y)
    =   Succ (add (Succ x) (Succ y))    -- Run 'add' forwards
    === Succ (Succ (add x (Succ y)))    ? prop_add_Succ2 x (Succ y)
    === Succ (add x (Succ (Succ y)))    -- Run 'add' backwards
    === add (Succ x) (Succ (Succ y))
    *** QED
