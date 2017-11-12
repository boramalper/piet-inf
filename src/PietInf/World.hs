module PietInf.World where

import           Data.Bits
import           System.Random


data World = World {
    seed :: Int,
    path :: [Int]
} deriving Show

mkWorld :: Int -> World
mkWorld seed = World {
    seed = seed,
    path = []  -- REVERSE! Current path is always `head path`
}

zoomIn :: World -> Int -> World
zoomIn world cell
    | 1 <= cell && cell <= 9 = World {
        seed = seed world,
        path = cell : path world
    }
    | otherwise = error "cell is not in range [1, 9]"

zoomOut :: World -> World
zoomOut world
    | not $ null $ path world =
         World {
            seed = seed world,
            path = tail $ path world
        }
    | otherwise = world

getRandGen :: World -> StdGen
getRandGen world = mkStdGen $ foldr (\a b -> (a `xor` b) `shiftL` 4) (seed world) (path world)
