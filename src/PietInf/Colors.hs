module PietInf.Colors where

import           Graphics.Gloss.Data.Color
import           PietInf.World
import           System.Random


pBlack  = makeColorI  28   23   21  255
pBlue   = makeColorI  95   75  185  255
pYellow = makeColorI 253  227    1  255
pWhite  = makeColorI 245  254  252  255
pRed    = makeColorI 232   71   58  255

colorsOf :: Int -> World -> [Color]
colorsOf n world =
    let
        gen = getRandGen world
        -- A random element will be picked from this list so you might add an
        -- object multiple times to change adjust probabilities.
        pColors = [
                pBlue, pBlue, pBlue,
                pYellow, pYellow, pYellow,
                pRed, pRed, pRed,
                pWhite, pWhite, pWhite, pWhite, pWhite, pWhite,
                pBlack
            ]
    in
        [pColors !! i | i <- randomRs (0, length pColors - 1) gen]
