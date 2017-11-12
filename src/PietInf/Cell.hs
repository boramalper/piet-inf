module PietInf.Cell where

import           Data.List

import           PietInf.Border
import           PietInf.World


type CellNo = Int

-- cellSets
--   Group merged cells in sets.
--
--   Returns a list of "list of cell numbers (Int) that constitute a cell".
--   For instance:
--     ╔═══╤═══╤═══╗
--     ║ 7 │ 8 │ 9 ║  [[1],[2],[3],[4],[5],[6],[7],[8],[9]]
--     ╟───┼───┼───╢
--     ║ 4 │ 5 │ 6 ║
--     ╟───┼───┼───╢
--     ║ 1 │ 2 │ 3 ║
--     ╚═══╧═══╧═══╝
--
--     ╔═══════╤═══╗
--     ║ 7   8 │ 9 ║  [[1],[3,2],[8,7,5,4],[9,6]]
--     ║  ANY  │   ║
--     ║ 4   5 │ 6 ║
--     ╟───┬───┴───╢
--     ║ 1 │ 2   3 ║
--     ╚═══╧═══════╝
cellSetsOf :: World -> [[CellNo]]
cellSetsOf world =
    let
        borders = bordersOf world
    in
        mCS' [[1]] 2 borders
    where
        mCS' :: [[Int]] -> Int -> Borders -> [[Int]]
        mCS' sets curCell borders
            | curCell <= 9 =
                if mergedWithLeft curCell then
                    mCS' (addInto sets curCell (curCell - 1)) (curCell + 1) borders
                else if mergedWithBottom curCell then
                    mCS' (addInto sets curCell (curCell - 3)) (curCell + 1) borders
                else
                    mCS' ([curCell] : sets) (curCell + 1) borders
            | otherwise = sets
            where
                -- addInto
                --   Add the guest into ALL* lists that contains the host in the
                --   list of lists.
                --
                --   *: For our purposes, there will be only one such list, as
                --      lists represent the sets of cells in our 3x3 canvas.
                addInto :: Eq a => [[a]] -> a -> a -> [[a]]
                addInto sets guest host =
                    [ if host `elem` l then guest : l else l
                    | l <- sets
                    ]

                mergedWithLeft :: CellNo -> Bool
                mergedWithLeft cell
                    | cell `elem` [1, 4, 7] = False
                    | otherwise =
                        not $ ([undefined, fst, snd] !! colNo cell $ vertical borders) !! rowNo cell

                mergedWithBottom :: CellNo -> Bool
                mergedWithBottom cell
                    | cell `elem` [1, 2, 3] = False
                    | otherwise =
                        not $ ([fst, snd] !! rowNo cell $ horizontal borders) !! colNo cell

rowNo :: CellNo -> Int
rowNo cell = 2 - ((cell - 1) `div` 3)


colNo :: CellNo -> Int
colNo cell = ((cell `mod` 3) + 2) `mod` 3


data MergedCell = MergedCell {
    nos    :: [CellNo],
    x      :: Int,
    y      :: Int,
    width  :: Int,
    height :: Int
} deriving Show

xF mc = fromIntegral $ x mc
yF mc = fromIntegral $ y mc
widthF mc  = fromIntegral $ width mc
heightF mc = fromIntegral $ height mc

mergedCellsOf :: World -> [MergedCell]
mergedCellsOf world =
    let
        borders = bordersOf world
    in
        [ MergedCell { nos = cs
                     , x = colNo (head cs)
                     , y = rowNo (last cs)
                     , width = width cs
                     , height = height cs
                     }
        | cs <- map sort $ cellSetsOf world
        ]
    where
        width :: [CellNo] -> Int
        width (c0:c1:c2:_) = 1 + (if c2 - c1 == 1 then 1 else 0) + (if c1 - c0 == 1 then 1 else 0)
        width [c0,c1]      = 1 + if c1 - c0 == 1 then 1 else 0
        width [_]          = 1

        height :: [CellNo] -> Int
        height cs = length cs `div` width cs

subworldsOf :: World -> [MergedCell]
subworldsOf world =
    [ mc | mc <- mergedCellsOf world, width mc == height mc ]

coatablesOf :: World -> [MergedCell]
coatablesOf world =
    [ mc | mc <- mergedCellsOf world, width mc /= height mc ]

-- pathNo
--   Gives the NEXT path numero to the cell in the world. If the cell is square
--   then the subworld inside the cell will have the path
--     pathNo world cell : path world
pathNo :: World -> CellNo -> Int
pathNo world cell =
    last $ nos $ findMergedCell world cell

findMergedCell :: World -> CellNo -> MergedCell
findMergedCell world cell =
    head [ mc | mc <- mergedCellsOf world, cell `elem` nos mc]
