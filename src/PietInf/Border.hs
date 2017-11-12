module PietInf.Border where

import           System.Random

import           PietInf.World

type Border = [Bool]

-- Borders
--   horizontal: fst top, snd bot(tom)
--   vertical  : fst left, snd right
data Borders = Borders {
    horizontal :: (Border,Border),
    vertical   :: (Border,Border)
} deriving Show

-- TODO
--   It works but it can definitely be improved:
--     - Choose two borders (vertical and/or horizontal) and set them randomly,
--       and adjust the remaining two to fit the criteria?
--     - Make it more *elegant*, it's ugly as it currently is.
bordersOf :: World -> Borders
bordersOf world =
    let
        gen = getRandGen world
        top = randTop gen
        bot = randBot gen
    in
        Borders {
            horizontal = (top, bot),
            vertical = (minimumLeft top bot, minimumRight top bot)
        }
    where
        randTop :: StdGen -> Border
        randTop gen = map (== 1) $ take 3 $ rand6BD gen

        randBot :: StdGen -> Border
        randBot gen = map (== 1) $ drop 3 $ rand6BD gen

        -- rand6BD: random 6 Binary Digits. Haskell errs without this function
        -- because of type ambiguity...
        rand6BD :: StdGen -> [Int]
        rand6BD gen = take 6 (randomRs (0, 1) gen)

        minimumLeft :: Border -> Border -> Border
        minimumLeft top bot =
            (
                if (top !! 0 && not (top !! 1)) || (top !! 1 && not (top !! 0)) then
                    if bot !! 0 && bot !! 1 then
                        [True, True, False]
                    else
                        [True, True, True]
                else
                    [False, False, False]
            ) `mergeBorders` (
                if (bot !! 0 && not (bot !! 1)) || (bot !! 1 && not (bot !! 0)) then
                    if top !! 0 && top !! 1 then
                        [False, True, True]
                    else
                        [True, True, True]
                else
                    [False, False, False]
            )

        minimumRight :: Border -> Border -> Border
        minimumRight top bot =
            (
                if (top !! 1 && not (top !! 2)) || (top !! 2 && not (top !! 1)) then
                    if bot !! 1 && bot !! 2 then
                        [True, True, False]
                    else
                        [True, True, True]
                else
                    [False, False, False]
            ) `mergeBorders` (
                if (bot !! 1 && not (bot !! 2)) || (bot !! 2 && not (bot !! 1)) then
                    if top !! 1 && top !! 2 then
                        [False, True, True]
                    else
                        [True, True, True]
                else
                    [False, False, False]
            )

        mergeBorders :: Border -> Border -> Border
        mergeBorders b1 b2
            | length b1 == length b2 && length b1 == 3 = zipWith (||) b1 b2
            | otherwise = error "borders must be of equal length 3"
