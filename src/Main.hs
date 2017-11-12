module Main where

import           System.Environment
import           System.Random

import           Graphics.Gloss

import           PietInf.Colors
import           PietInf.React
import           PietInf.Render
import           PietInf.World

defaultScreenSideLength = 1080
defaultMaxRenderDepth = 8

main = do
    seed <- getStdRandom (randomR (0, 1000000))
    args <- getArgs
    let
        world = mkWorld seed
        in
            play FullScreen black 0 world (render $ parseOpt args) react $ const . const world

parseOpt :: [String] -> (Int,Int)
parseOpt o
    | null o        = (defaultScreenSideLength, defaultMaxRenderDepth)
    | length o == 1 = (read (head o) :: Int, defaultMaxRenderDepth)
    | otherwise     = (read (head o) :: Int, read(head $ tail o) :: Int)
