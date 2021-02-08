-- | Examples from "Functional Pearl: Theorem Proving for All"
-- <https://arxiv.org/pdf/1806.03541.pdf>
module TPFA where

{-@ LIQUID "--ple-local" @-}

import Language.Haskell.Liquid.ProofCombinators
import Prelude hiding (length, (++), reverse)

length :: [a] -> Int
length [] = 0
length (_:xs) = 1 + length xs
{-@ length :: [a] -> {v:Int | 0 <= v } @-}
{-@ measure length @-}

-- | Was called `++` in the paper, but that caused a parse error in the
-- specification of distributivityP.
{-@ append :: xs:[a] -> ys:[a] -> {zs:[a] | length zs == length xs + length ys} @-}
append :: [a] -> [a] -> [a]
append [] ys = ys
append (x:xs) ys = x : (xs `append` ys)

{-@ reverse :: is:[a] -> {os:[a] | length is == length os} @-}
reverse :: [a] -> [a]
reverse [] = []
reverse (x:xs) = reverse xs `append` [x]
{-@ reflect reverse @-}
{-@ LIQUID "--exact-data" @-}
{-@ reflect append @-}

-- * Example 1

-- | Simplest example of a proof in LH in the paper.
{-@ singletonP :: x:a -> {reverse [x] == [x]} @-}
singletonP :: a -> Proof
singletonP x
    =   reverse [x]
    === reverse [] `append` [x]
    ===         [] `append` [x]
    ===                     [x]
    *** QED

-- * Example 2

-- | Demonstrates how to use another proof as evidence.
{-@ singleton1P :: { reverse [1] == [1] } @-}
singleton1P :: Proof
singleton1P
    =   reverse [1::Int]
        ? singletonP (1::Int)
    === [1]
    *** QED

-- * Example 3

-- | Proof by structural induction. Base case is base case. Inductive case is
-- expressed via recursion.
{-@ involutionP :: xs:[a] -> {reverse (reverse xs) == xs} @-}
involutionP :: [a] -> Proof
involutionP []
    =   reverse (reverse [])
    === reverse  []
    === []
    *** QED
involutionP (x:xs)
    =   reverse (reverse (x:xs))
    === reverse (reverse xs `append` [x])
        ? distributivityP (reverse xs) [x]
    === reverse [x] `append` reverse (reverse xs)
        ? involutionP xs
    === reverse [x] `append` xs
        ? singletonP x
    === [x] `append` xs
    === x : ([] `append` xs)
    === x : xs
    *** QED

-- ** Lemmas for Example 3

{-@ distributivityP :: xs:[a] -> ys:[a] -> {reverse (append xs ys) == append (reverse ys) (reverse xs)} @-}
distributivityP :: [a] -> [a] -> Proof
distributivityP [] ys
    =   reverse ([] `append` ys)
    === reverse ys
        ? rightIdP (reverse ys) -- Q for Niki: I had just `ys` here. How could I learn my mistake from the LH error?
    === reverse ys `append` []
    === reverse ys `append` reverse []
    *** QED
distributivityP (x:xs) ys
    =   reverse ((x:xs) `append` ys)
    === reverse (x : (xs `append` ys))
    === reverse (xs `append` ys) `append` [x]
        ? distributivityP xs ys
    === (reverse ys `append` reverse xs) `append` [x]
        ? assocP (reverse ys) (reverse xs) [x]
    === reverse ys `append` (reverse xs `append` [x])
    === reverse ys `append` reverse (x:xs)
    *** QED

{-@ rightIdP :: xs:[a] -> { append xs [] == xs } @-}
rightIdP :: [a] -> Proof
rightIdP []
    =   append [] []
    === []
    *** QED
rightIdP (x:xs)
    =   append (x:xs) []
    === x : (xs `append` [])
        ? rightIdP xs
    === x : xs
    *** QED

{-@ assocP :: xs:[a] -> ys:[a] -> zs:[a] -> {append xs (append ys zs) == append (append xs ys) zs} @-}
assocP :: [a] -> [a] -> [a] -> Proof
assocP [] _ _ = ()
assocP (_:xs) ys zs = assocP xs ys zs
{-@ ple assocP @-}
