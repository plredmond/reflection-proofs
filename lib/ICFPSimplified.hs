-- | This is a condensed and simplified version of the proof included in our
-- ICFP submission which was translated from Agda:
-- <https://gist.github.com/gshen42/19721e5086664b43ab58c3ede0855414#file-cbcast-agda>
{-# OPTIONS_GHC "-Wno-incomplete-patterns" #-}
module ICFPSimplified where

{-@ LIQUID "--exact-data" @-}
{-@ LIQUID "--ple-local" @-}

import Language.Haskell.Liquid.ProofCombinators


-- * Agda things

{-@ type Fin V = {v:Nat | v < V} @-}

{-@ type Vec a V = {v:[a] | len v == V} @-}

{-@ reflect index @-}
{-@ index :: xs:[a] -> {i:Nat | i < len xs } -> a @-}
index :: [a] -> Int -> a
index (x:xs) i
    | i == 0    = x
    | otherwise = index xs (i-1)


-- * CBCAST background

{-@ measure procCount :: Nat @-}

{-@ type PID = Fin {procCount} @-}

{-@ type VectorClock = Vec Nat {procCount} @-}

{-@ reflect bang @-}
{-@ bang :: VectorClock -> PID -> Nat @-}
bang :: [Int] -> Int -> Int
bang vc k = index vc k

{-@ data Message r = Message { mSender :: PID, mSent :: VectorClock, mRaw :: r } @-}
data Message r = Message { mSender :: Int, mSent :: [Int], mRaw :: r }

{-@ reflect deliverableK @-}
{-@ deliverableK :: Message r -> VectorClock -> PID -> Bool @-}
deliverableK :: Message r -> [Int] -> Int -> Bool
deliverableK msg procVc k
    | k == mSender msg  = mSent msg `bang` k == (procVc `bang` k) + 1
    | otherwise         = mSent msg `bang` k <=  procVc `bang` k

{-@ reflect causallyBeforeK @-}
{-@ causallyBeforeK :: Message r -> Message r -> PID -> Bool @-}
causallyBeforeK :: Message r -> Message r -> Int -> Bool
causallyBeforeK m1 m2 k
    =   mSent m1 `bang` k <= mSent m2 `bang` k
    &&  mSent m1          /= mSent m2


-- * Safety proof

{-@ type DeliverableProp M P = k:PID -> { _:Proof | deliverableK M P k } @-}

{-@ type CausallyBeforeProp M1 M2 = k:PID -> { _:Proof | causallyBeforeK M1 M2 k } @-}

{-@
assume processOrderAxiom
    ::  m1 : Message r
    ->  m2 : Message r
    ->  { _:Proof | mSender m1 == mSender m2 }
    ->  { _:Proof | bang (mSent m1) (mSender m1) != bang (mSent m2) (mSender m2) }
@-}
processOrderAxiom :: Message r -> Message r -> Proof -> Proof
processOrderAxiom Message{} Message{} () = ()

{-@ ple safety @-}
{-@
safety
    ::  procVc : VectorClock
    ->  m1 : Message r
    ->  m2 : Message r
    ->  DeliverableProp {m1} {procVc}
    ->  CausallyBeforeProp {m1} {m2}
    ->  DeliverableProp {m2} {procVc}
    ->  { _:Proof | false }
@-}
safety
    :: [Int]
    -> Message r
    -> Message r
    -> (Int -> Proof)
    -> (Int -> Proof)
    -> (Int -> Proof)
    -> Proof
safety _procVc m1 m2 m1_d_p m1_before_m2 m2_d_p
    | mSender m1 == mSender m2
        =   ()
            ? m1_d_p (mSender m1)
            ? m2_d_p (mSender m2)
            ? processOrderAxiom m1 m2 ()
            *** Admit
    | otherwise
        =   ()
            ? m1_before_m2 (mSender m1)
            ? m1_d_p (mSender m1)
            ? m2_d_p (mSender m1)
            *** Admit
