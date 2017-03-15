{-# OPTIONS_GHC -fno-warn-name-shadowing #-}
{-# LANGUAGE ViewPatterns #-}
-----------------------------------------------------------------------------
-- |
-- Module     : Algebra.Graph.Test.Graph
-- Copyright  : (c) Andrey Mokhov 2016-2017
-- License    : MIT (see the file LICENSE)
-- Maintainer : andrey.mokhov@gmail.com
-- Stability  : experimental
--
-- Testsuite for 'Graph' and polymorphic functions defined in "Algebra.Graph".
--
-----------------------------------------------------------------------------
module Algebra.Graph.Test.Graph (
    -- * Testsuite
    testGraph
  ) where

import Algebra.Graph
import Algebra.Graph.Test
import Data.Set (Set)
import Data.IntSet (IntSet)
import Prelude hiding ((==))

import Algebra.Graph.Data as Data hiding (foldg, hasEdge, removeEdge)

import qualified Prelude     as P
import qualified Data.Set    as Set
import qualified Data.IntSet as IntSet

type F  = Fold Int
type G  = Data.Graph Int
type II = Int -> Int
type IB = Int -> Bool
type IG = Int -> G

testGraph :: IO ()
testGraph = do
    putStrLn "\n============ Graph ============"
    test "Axioms of graphs"     $ (axioms   :: GraphTestsuite G)
    test "\nTheorems of graphs" $ (theorems :: GraphTestsuite G)

    let (==) :: G -> G -> Bool
        (==) = (P.==)
    putStrLn "\n============ vertices ============"

    test "vertices []  == empty   " $
          vertices []  == empty
    test "vertices [x] == vertex x" $ \x ->
          vertices [x] == vertex x

    putStrLn "\n============ overlays ============"

    test "overlays []    == empty      " $
          overlays []    == empty
    test "overlays [x]   == x          " $ \x ->
          overlays [x]   == x
    test "overlays [x,y] == overlay x y" $ \x y ->
          overlays [x,y] == overlay x y

    putStrLn "\n============ connects ============"

    test "connects []    == empty      " $
          connects []    == empty
    test "connects [x]   == x          " $ \x ->
          connects [x]   == x
    test "connects [x,y] == connect x y" $ \x y ->
          connects [x,y] == connect x y

    putStrLn "\n============ edge ============"

    test "edge x y == connect (vertex x) (vertex y)" $ \x y ->
          edge x y == connect (vertex x) (vertex y)

    putStrLn "\n============ edges ============"

    test "edges []      == empty   " $
          edges []      == empty

    test "edges [(x,y)] == edge x y" $ \x y ->
          edges [(x,y)] == edge x y

    putStrLn "\n============ graph ============"

    test "graph []  []      == empty   " $
          graph []  []      == empty

    test "graph [x] []      == vertex x" $ \x ->
          graph [x] []      == vertex x

    test "graph []  [(x,y)] == edge x y" $ \x y ->
          graph []  [(x,y)] == edge x y

    putStrLn "\n============ path ============"

    test "path []    == empty   " $
          path []    == empty

    test "path [x]   == vertex x" $ \x ->
          path [x]   == vertex x

    test "path [x,y] == edge x y" $ \x y ->
          path [x,y] == edge x y

    putStrLn "\n============ circuit ============"

    test "circuit []    == empty               " $
          circuit []    == empty

    test "circuit [x]   == edge x x            " $ \x ->
          circuit [x]   == edge x x

    test "circuit [x,y] == edges [(x,y), (y,x)]" $ \x y ->
          circuit [x,y] == edges [(x,y), (y,x)]

    putStrLn "\n============ clique ============"

    test "clique []      == empty                      " $
          clique []      == empty

    test "clique [x]     == vertex x                   " $ \x ->
          clique [x]     == vertex x

    test "clique [x,y]   == edge x y                   " $ \x y ->
          clique [x,y]   == edge x y

    test "clique [x,y,z] == edges [(x,y), (x,z), (y,z)]" $ \x y z ->
          clique [x,y,z] == edges [(x,y), (x,z), (y,z)]

    putStrLn "\n============ biclique ============"

    test "biclique []      []      == empty                                     " $
          biclique []      []      == empty

    test "biclique [x]     []      == vertex x                                  " $ \x ->
          biclique [x]     []      == vertex x

    test "biclique []      [y]     == vertex y                                  " $ \y ->
          biclique []      [y]     == vertex y

    test "biclique [x1,x2] [y1,y2] == edges [(x1,y1), (x1,y2), (x2,y1), (x2,y2)]" $ \x1 x2 y1 y2 ->
          biclique [x1,x2] [y1,y2] == edges [(x1,y1), (x1,y2), (x2,y1), (x2,y2)]

    putStrLn "\n============ star ============"

    test "star x []    == vertex x            " $ \x ->
          star x []    == vertex x

    test "star x [y]   == edge x y            " $ \x y ->
          star x [y]   == edge x y

    test "star x [y,z] == edges [(x,y), (x,z)]" $ \x y z ->
          star x [y,z] == edges [(x,y), (x,z)]

    putStrLn "\n============ transpose ============"

    test "transpose empty         == empty   " $
          transpose empty         == empty

    test "transpose (vertex x)    == vertex x" $ \x ->
          transpose (vertex x)    == vertex x

    test "transpose (edge x y)    == edge y x" $ \x y ->
          transpose (edge x y)    == edge y x

    test "transpose (transpose x) == x       " $ \x ->
          transpose (transpose x) == gmap id x

    putStrLn "\n============ simplify ============"

    test "simplify x                        == x                                                 " $ \x ->
          simplify x                        == gmap id x

    test "1 + 1 :: Graph Int                == Overlay (Vertex 1) (Vertex 1)                     " $
         (1 + 1)                            == Overlay (Vertex 1) (Vertex 1)

    test "simplify (1 + 1) :: Graph Int     == Vertex 1                                          " $
          simplify (1 + 1)                  == Vertex 1

    test "1 * 1 * 1 :: Graph Int            == Connect (Connect (Vertex 1) (Vertex 1)) (Vertex 1)" $
         (1 * 1 * 1)                        == Connect (Connect (Vertex 1) (Vertex 1)) (Vertex 1)

    test "simplify (1 * 1 * 1) :: Graph Int == Connect (Vertex 1) (Vertex 1)                     " $
          simplify (1 * 1 * 1)              == Connect (Vertex 1) (Vertex 1)

    putStrLn "\n============ gmap ============"

    test "gmap f empty      == empty           " $ \(apply -> f :: II) ->
          gmap f empty      == empty

    test "gmap f (vertex x) == vertex (f x)    " $ \(apply -> f :: II) x ->
          gmap f (vertex x) == vertex (f x)

    test "gmap f (edge x y) == edge (f x) (f y)" $ \(apply -> f :: II) x y ->
          gmap f (edge x y) == edge (f x) (f y)

    test "gmap id           == id              " $ \x ->
          gmap id (fromGraph x) == x

    test "gmap f . gmap g   == gmap (f . g)    " $ \(apply -> f :: II) (apply -> g :: II) x ->
         (gmap f . gmap g) x== gmap (f . g) x

    putStrLn "\n============ replaceVertex ============"

    test "replaceVertex x x            == id                    " $ \x y ->
          replaceVertex x x y          == gmap id y

    test "replaceVertex x y (vertex x) == vertex y              " $ \x y ->
          replaceVertex x y (vertex x) == vertex y

    test "replaceVertex x y            == mergeVertices (== x) y" $ \x y z ->
          replaceVertex x y z          == mergeVertices (P.== x) y (gmap id z)

    putStrLn "\n============ mergeVertices ============"

    test "mergeVertices (const False) x    == id               " $ \x y ->
          mergeVertices (const False) x y  == gmap id y

    test "mergeVertices (== x) y           == replaceVertex x y" $ \x y z ->
          mergeVertices (P.== x) y z       == replaceVertex x y z

    test "mergeVertices even 1 (0 * 2)     == 1 * 1            " $
          mergeVertices even 1 (0 * 2)     ==(1 * 1)

    test "mergeVertices odd  1 (3 + 4 * 5) == 4 * 1            " $
          mergeVertices odd  1 (3 + 4 * 5) ==(4 * 1)

    putStrLn "\n============ bind ============"

    test "bind empty f         == empty                      " $ \(apply -> f :: IG) ->
          bind empty f         == empty

    test "bind (vertex x) f    == f x                        " $ \(apply -> f :: IG) x ->
          bind (vertex x) f    == f x

    test "bind (edge x y) f    == connect (f x) (f y)        " $ \(apply -> f :: IG) x y ->
          bind (edge x y) f    == connect (f x) (f y)

    test "bind (vertices xs) f == overlays (map f xs)        " $ mapSize (min 10) $ \xs (apply -> f :: IG) ->
          bind (vertices xs) f == overlays (map f xs)

    test "bind x (const empty) == empty                      " $ \(x :: F) ->
          bind x (const empty) == empty

    test "bind x vertex        == x                          " $ \(x :: F) ->
          bind x vertex        == gmap id x

    test "bind (bind x f) g    == bind x (\\y -> bind (f y) g)" $ mapSize (min 10) $ \x (apply -> f :: IG) (apply -> g :: IG) ->
          bind (fromGraph $ bind x f) g == bind x (\y -> bind (fromGraph $ f y) g)

    putStrLn "\n============ removeVertex ============"

    test "removeVertex x (vertex x)       == empty         " $ \x ->
          removeVertex x (vertex x)       == empty

    test "removeVertex x . removeVertex x == removeVertex x" $ \x y ->
         (removeVertex x . removeVertex x)y==removeVertex x y

    putStrLn "\n============ splitVertex ============"

    test "splitVertex x []                   == removeVertex x   " $ \x y ->
         (splitVertex x []) y                == removeVertex x y

    test "splitVertex x [x]                  == id               " $ \x y ->
         (splitVertex x [x]) y               == gmap id y

    test "splitVertex x [y]                  == replaceVertex x y" $ \x y z ->
         (splitVertex x [y]) z               == replaceVertex x y z

    test "splitVertex 1 [0, 1] $ 1 * (2 + 3) == (0 + 1) * (2 + 3)" $
         (splitVertex 1 [0, 1] $ 1 * (2 + 3))==((0 + 1) * (2 + 3))

    putStrLn "\n============ removeEdge ============"

    test "removeEdge x y (edge x y)       == vertices [x, y]" $ \x y ->
          removeEdge x y (edge x y)       == vertices [x, y]

    test "removeEdge x y . removeEdge x y == removeEdge x y " $ \x y z ->
         (removeEdge x y . removeEdge x y)z==removeEdge x y z

    test "removeEdge x y . removeVertex x == removeVertex x " $ \x y z ->
         (removeEdge x y . removeVertex x)z==removeVertex x z

    test "removeEdge 1 1 (1 * 1 * 2 * 2)  == 1 * 2 * 2      " $
          removeEdge 1 1 (1 * 1 * 2 * 2)  ==(1 * 2 * 2)

    test "removeEdge 1 2 (1 * 1 * 2 * 2)  == 1 * 1 + 2 * 2  " $
          removeEdge 1 2 (1 * 1 * 2 * 2)  ==(1 * 1 + 2 * 2)

    putStrLn "\n============ induce ============"

    test "induce (const True)  x      == x                        " $ \x ->
          induce (const True)  x      == gmap id x

    test "induce (const False) x      == empty                    " $ \x ->
          induce (const False) x      == empty

    test "induce (/= x)               == removeVertex x           " $ \x y ->
          induce (/= x) y             == removeVertex x y

    test "induce p . induce q         == induce (\\x -> p x && q x)" $ \(apply -> p :: IB) (apply -> q :: IB) y ->
         (induce p . induce q) y      == induce (\x -> p x && q x) y

    let (==) :: Eq a => a -> a -> Bool
        (==) = (P.==)
    test "isSubgraphOf (induce p x) x == True                     " $ \(apply -> p :: IB) (x :: G) ->
          isSubgraphOf (induce p $ fromGraph x) x == True

    putStrLn "\n============ foldg ============"

    test "foldg []   return        (++) (++) == toList " $ \(x :: F) ->
          foldg []   return        (++) (++)x== toList x

    test "foldg 0    (const 1)     (+)  (+)  == length " $ \(x :: F) ->
          foldg 0    (const 1)     (+)  (+)x == length x

    test "foldg True (const False) (&&) (&&) == isEmpty" $ \(x :: F) ->
          foldg True (const False) (&&) (&&)x== isEmpty x

    let (==) :: Bool -> Bool -> Bool
        (==) = (P.==)
    putStrLn "\n============ isSubgraphOf ============"

    test "isSubgraphOf empty         x             == True " $ \(x :: G) ->
          isSubgraphOf empty         x             == True

    test "isSubgraphOf (vertex x)    empty         == False" $ \x ->
          isSubgraphOf (vertex x)    (empty :: G)  == False

    test "isSubgraphOf x             (overlay x y) == True " $ \(x :: G) y ->
          isSubgraphOf x             (overlay x y) == True

    test "isSubgraphOf (overlay x y) (connect x y) == True " $ \(x :: G) y ->
          isSubgraphOf (overlay x y) (connect x y) == True

    test "isSubgraphOf (path xs)     (circuit xs)  == True " $ \xs ->
          isSubgraphOf (path xs :: G)(circuit xs)  == True

    putStrLn "\n============ isEmpty ============"

    test "isEmpty empty                       == True " $
          isEmpty empty                       == True

    test "isEmpty (vertex x)                  == False" $ \(x :: Int) ->
          isEmpty (vertex x)                  == False

    test "isEmpty (removeVertex x $ vertex x) == True " $ \(x :: Int) ->
          isEmpty (removeVertex x $ vertex x) == True

    test "isEmpty (removeEdge x y $ edge x y) == False" $ \(x :: Int) y ->
          isEmpty (removeEdge x y $ edge x y) == False

    putStrLn "\n============ hasVertex ============"

    test "hasVertex x empty            == False      " $ \(x :: Int) ->
          hasVertex x empty            == False

    test "hasVertex x (vertex x)       == True       " $ \(x :: Int) ->
          hasVertex x (vertex x)       == True

    test "hasVertex x . removeVertex x == const False" $ \(x :: Int) y ->
          hasVertex x (removeVertex x y)==const False y

    putStrLn "\n============ hasEdge ============"

    test "hasEdge x y empty            == False      " $ \(x :: Int) y ->
          hasEdge x y empty            == False

    test "hasEdge x y (vertex z)       == False      " $ \(x :: Int) y z ->
          hasEdge x y (vertex z)       == False

    test "hasEdge x y (edge x y)       == True       " $ \(x :: Int) y ->
          hasEdge x y (edge x y)       == True

    test "hasEdge x y . removeEdge x y == const False" $ \(x :: Int) y z ->
          hasEdge x y (removeEdge x y z)==const False z

    let (==) :: Set Int -> Set Int -> Bool
        (==) = (P.==)
    putStrLn "\n============ toSet ============"

    test "toSet empty         == Set.empty      " $
          toSet empty         == (Set.empty :: Set Int)

    test "toSet (vertex x)    == Set.singleton x" $ \(x :: Int) ->
          toSet (vertex x)    == Set.singleton x

    test "toSet (vertices xs) == Set.fromList xs" $ \(xs :: [Int]) ->
          toSet (vertices xs) == Set.fromList xs

    test "toSet (clique xs)   == Set.fromList xs" $ \(xs :: [Int]) ->
          toSet (clique xs)   == Set.fromList xs

    let (==) :: IntSet -> IntSet -> Bool
        (==) = (P.==)
    putStrLn "\n============ toIntSet ============"

    test "toIntSet empty         == IntSet.empty      " $
          toIntSet empty         == IntSet.empty

    test "toIntSet (vertex x)    == IntSet.singleton x" $ \x ->
          toIntSet (vertex x)    == IntSet.singleton x

    test "toIntSet (vertices xs) == IntSet.fromList xs" $ \xs ->
          toIntSet (vertices xs) == IntSet.fromList xs

    test "toIntSet (clique xs)   == IntSet.fromList xs" $ \xs ->
          toIntSet (clique xs)   == IntSet.fromList xs

    let (==) :: Data.Graph (Int, Char) -> Data.Graph (Int, Char) -> Bool
        (==) = (P.==)
    putStrLn "\n============ mesh ============"

    test "mesh xs     []   == empty                  " $ \xs ->
          mesh xs     []   == empty

    test "mesh []     ys   == empty                  " $ \ys ->
          mesh []     ys   == empty

    test "mesh [x]    [y]  == vertex (x, y)          " $ \x y ->
          mesh [x]    [y]  == vertex (x, y)

    test "mesh xs     ys   == box (path xs) (path ys)" $ \xs ys ->
          mesh xs     ys   == box (path xs) (path ys)

    test ("mesh [1..3] \"ab\" == <correct result>      ") $
         mesh [1..3] "ab"  == edges [ ((1,'a'),(1,'b')), ((1,'a'),(2,'a')), ((1,'b'),(2,'b')), ((2,'a'),(2,'b'))
                                    , ((2,'a'),(3,'a')), ((2,'b'),(3,'b')), ((3,'a'),(3,'b')) ]

    putStrLn "\n============ torus ============"

    test "torus xs     []   == empty                        " $ \xs ->
          torus xs     []   == empty

    test "torus []     ys   == empty                        " $ \ys ->
          torus []     ys   == empty

    test "torus [x]    [y]  == edge (x, y) (x, y)           " $ \x y ->
          torus [x]    [y]  == edge (x, y) (x, y)

    test "torus xs     ys   == box (circuit xs) (circuit ys)" $ \xs ys ->
          torus xs     ys   == box (circuit xs) (circuit ys)

    test ("torus [1..2] \"ab\" == <correct result>           ") $
         torus [1..2] "ab"  == edges [ ((1,'a'),(1,'b')), ((1,'a'),(2,'a')), ((1,'b'),(1,'a')), ((1,'b'),(2,'b'))
                                     , ((2,'a'),(1,'a')), ((2,'a'),(2,'b')), ((2,'b'),(1,'b')), ((2,'b'),(2,'a')) ]

    let (==) :: Data.Graph [Int] -> Data.Graph [Int] -> Bool
        (==) = (P.==)
    putStrLn "\n============ deBruijn ============"
    test "deBruijn k []    == empty                                               " $ \k ->
          deBruijn k []    == empty

    test "deBruijn 1 [0,1] == edges [ ([0],[0]), ([0],[1]), ([1],[0]), ([1],[1]) ]" $
          deBruijn 1 [0,1] == edges [ ([0],[0]), ([0],[1]), ([1],[0]), ([1],[1]) ]

    let (==) :: Data.Graph String -> Data.Graph String -> Bool
        (==) = (P.==)
    test "deBruijn 2 \"0\"   == edge \"00\" \"00\"                                      " $
          deBruijn 2 "0"   == edge "00" "00"

    test ("deBruijn 2 \"01\"  == <correct result>                                   ") $
          deBruijn 2 "01"  == edges [ ("00","00"), ("00","01"), ("01","10"), ("01","11")
                                    , ("10","00"), ("10","01"), ("11","10"), ("11","11") ]

    let (==) :: Data.Graph (Int, Int) -> Data.Graph (Int, Int) -> Bool
        (==) = (P.==)
        unit = gmap $ \(a, ())     -> a
        comm = gmap $ \(a, b)      -> (b, a)
    putStrLn "\n============ box ============"
    test "box x y             ~~ box y x                    " $ mapSize (min 10) $ \x y ->
          comm (box x y)      == box y x

    test "box x (overlay y z) == overlay (box x y) (box x z)" $ mapSize (min 10) $ \x y z ->
          box x (overlay y z) == overlay (box x y) (box x z)

    test "box x (vertex ())   ~~ x                          " $ mapSize (min 10) $ \x ->
     unit(box x (vertex ()))  == gmap id x

    test "box x empty         ~~ empty                      " $ mapSize (min 10) $ \x ->
     unit(box x empty)        == empty

    let (==) :: Data.Graph ((Int, Int), Int) -> Data.Graph ((Int, Int), Int) -> Bool
        (==)  = (P.==)
        assoc = gmap $ \(a, (b, c)) -> ((a, b), c)
    test "box x (box y z)     ~~ box (box x y) z            " $ mapSize (min 10) $ \x y z ->
      assoc (box x (box y z)) == box (box x y) z