{-# OPTIONS_GHC "-Wno-incomplete-patterns" #-}
module Report where
import Language.Haskell.Liquid.ProofCombinators

{-@
type NatUnbound = {n:Integer | 0 <= n}
@-}

{-@
safeDiv :: a -> {denom:a | denom /= 0} -> a
@-}
safeDiv :: Integral a => a -> a -> a
safeDiv = div

{-@
consBigger :: a -> before:[a] -> {after:[a] | len before + 1 == len after}
@-}
consBigger :: a -> [a] -> [a]
consBigger = (:)

{-@ measure myLen @-}
{-@ myLen :: [a] -> Nat @-}
myLen :: [a] -> Int
myLen [] = 0
myLen (_:xs) = 1 + myLen xs

{-@ safeZip :: xs:[a] -> {ys:[b] | myLen xs == myLen ys} -> {zs:[(a, b)] | myLen xs == myLen zs && myLen ys == myLen zs} @-}
safeZip :: [a] -> [b] -> [(a, b)]
safeZip [] [] = []
safeZip (x:xs) (y:ys) = (x, y) : safeZip xs ys

{-@ LIQUID "--exact-data" @-}

{-@ reflect allLess @-}
{-@ allLess :: xs:[a] -> {ys:[a] | len xs <= len ys} -> Bool @-}
allLess :: Ord a => [a] -> [a] -> Bool
allLess [] _ = True
allLess (x:xs) (y:ys) = x < y && allLess xs ys

{-@ LIQUID "--ple-local" @-}
{-@ ple subElems @-}

{-@ subElems :: xs:[Nat] -> {ys:[Nat] | len xs == len ys && allLess ys xs} -> [Nat] @-}
subElems :: [Int] -> [Int] -> [Int]
subElems [] [] = []
subElems (x:xs) (y:ys) = (x - y) : subElems xs ys

{-@ safeHead :: {xs:[a] | xs /= []} -> a @-}
safeHead :: [a] -> a
safeHead (x:_) = x

{-@ sillyAdd :: Nat -> b:Nat -> Nat / [b] @-}
sillyAdd :: Int -> Int -> Int
sillyAdd a b
    | 0 < b = sillyAdd (a + 1) (b - 1)
    | otherwise = a

{-@ LIQUID "--no-adt" @-}
data Tree a = Node (Tree a) a (Tree a) | StrangeBranch (Tree a) (Tree a) | Leaf

mirror :: Tree a -> Tree a
mirror (Node left el right) = Node (mirror left) el (mirror right)
mirror (StrangeBranch left right) = StrangeBranch (mirror left) (mirror right)
mirror Leaf = Leaf

-- treeSize :: Tree a -> Int
-- treeSize (Node left _ right) = 1 + treeSize left + treeSize right
-- treeSize (StrangeBranch ts) = sum (map treeSize ts)
-- treeSize Leaf = 0

{-@
data Arena = Arena
    { width :: Nat
    , height :: Nat
    , playerPosition :: ({x:Nat | x < width}, {y:Nat | y < height})
    }
@-}
data Arena = Arena
    { width :: Int
    , height :: Int
    , playerPosition :: (Int, Int)
    }

{-@ onePlusOneIsTwo :: { _:Proof | 1 + 1 == 2 } @-}
onePlusOneIsTwo :: Proof
onePlusOneIsTwo
    =   1 + (1::Int)
    === 2
    *** QED
