module PietInf.Render where

import           Debug.Trace
import           System.Random

import           Graphics.Gloss.Data.Color
import           Graphics.Gloss.Data.Picture

import           PietInf.Border
import           PietInf.Cell
import           PietInf.Colors
import           PietInf.World

-- 1/30 = Piet's Ratio of a cell to border:
--   3 cells (x30), 2 borders (x1) = 3x30 + 2x1 = 92
csl2ssl = 30 / 92
bt2ssl  =  1 / 92

render :: (Int,Int) -> World -> Picture
render opts =
    let
        screenSideLength = fst opts
        maxRenderDepth = snd opts
    in
        render' screenSideLength maxRenderDepth
    where
        render' :: Int -> Int -> World -> Picture
        render' screenSideLength remaining world
            | remaining <= 0 = Pictures []
            | otherwise =
                let
                    borders = bordersOf world
                    cellSideLength = csl2ssl * fromIntegral screenSideLength -- 30 * screenSideLength / 92
                    borderThickness = bt2ssl * fromIntegral screenSideLength -- screenSideLength / 92
                in
                    Pictures $
                    renderBorders screenSideLength borders
                    :
                    renderCoatings screenSideLength world borders
                    :
                    map (\mc ->
                          move screenSideLength
                               (xF mc * (cellSideLength + borderThickness))
                               (yF mc * (cellSideLength + borderThickness))
                               (widthF mc  * cellSideLength + (widthF mc - 1) * borderThickness)
                               (heightF mc * cellSideLength + (heightF mc - 1) * borderThickness)
                        $ scale ((widthF mc * cellSideLength + (widthF mc - 1) * borderThickness) / (3 * cellSideLength + 2 * borderThickness))
                                ((heightF mc * cellSideLength + (heightF mc - 1) * borderThickness) / (3 * cellSideLength + 2 * borderThickness))
                        $ render' screenSideLength (remaining - 1) (zoomIn world $ pathNo world $ head $ nos mc)
                    ) (subworldsOf world)

id' :: Show a => a -> a
id' a
    | trace (show a) True = a

renderCoatings :: Int -> World -> Borders -> Picture
renderCoatings screenSideLength world borders =
    let
        borderThickness = bt2ssl * fromIntegral screenSideLength
        cellSideLength = csl2ssl * fromIntegral screenSideLength
        cells = coatablesOf world
    in
        Pictures $ map (\(mc,color) ->
            drawSolidRectangle screenSideLength
                               color
                               (fromIntegral (x mc) * (cellSideLength + borderThickness))
                               (fromIntegral (y mc) * (cellSideLength + borderThickness))
                               ((fromIntegral (width mc) * cellSideLength) + fromIntegral (width mc - 1) * borderThickness)
                               ((fromIntegral (height mc) * cellSideLength) + fromIntegral (height mc - 1) * borderThickness)
        ) $ zip cells $ length cells `colorsOf` world

-- TODO
--   This feels longer than it should be, try making it shorter without
--   harming the clarity.
renderBorders :: Int -> Borders -> Picture
renderBorders screenSideLength borders =
    let
        Pictures horizontalPictures = renderHorizontal $ horizontal borders
        Pictures verticalPictures   = renderVertical $ vertical borders
    in
        Pictures $ horizontalPictures ++ verticalPictures
    where
        renderHorizontal :: (Border, Border) -> Picture
        renderHorizontal (top, bot) =
            let
                borderThickness = bt2ssl  * fromIntegral screenSideLength
                cellSideLength  = csl2ssl * fromIntegral screenSideLength
                Pictures topP = rH cellSideLength top
                Pictures botP = rH (2 * cellSideLength + borderThickness) bot
            in
                Pictures (topP ++ botP)
            where
                rH :: Float -> Border -> Picture
                rH y border =
                    let
                        borderThickness = bt2ssl  * fromIntegral screenSideLength
                        cellSideLength  = csl2ssl * fromIntegral screenSideLength
                    in
                        Pictures [
                            drawSolidRectangle screenSideLength
                                               pBlack
                                               (leftOffset * (cellSideLength + borderThickness) - if leftOffset /= 0 then borderThickness else 0)
                                               y
                                               (cellSideLength + if leftOffset /= 0 then borderThickness else 0 + if leftOffset /= 2 then borderThickness else 0)
                                               borderThickness
                        |
                            (exists, leftOffset) <- zip border [0, 1..],
                            exists
                        ]

        renderVertical :: (Border, Border) -> Picture
        renderVertical (left, right) =
            let
                borderThickness = bt2ssl  * fromIntegral screenSideLength
                cellSideLength  = csl2ssl * fromIntegral screenSideLength
                Pictures leftP = rV cellSideLength left
                Pictures rightP = rV (2 * cellSideLength + borderThickness) right
            in
                Pictures $ leftP ++ rightP
            where
                rV :: Float -> Border -> Picture
                rV x border =
                    let
                        borderThickness = bt2ssl  * fromIntegral screenSideLength
                        cellSideLength  = csl2ssl * fromIntegral screenSideLength
                    in
                        Pictures [
                            drawSolidRectangle screenSideLength
                                               pBlack
                                               x
                                               (topOffset * (cellSideLength + borderThickness) - if topOffset /= 0 then borderThickness else 0)
                                               borderThickness
                                               (cellSideLength + if topOffset /= 0 then borderThickness else 0 + if topOffset /= 2 then borderThickness else 0)
                        |
                            (exists, topOffset) <- zip border [0, 1..],
                            exists
                        ]

-- move
--   Translate the picture so that THE TOP-LEFT CORNER OF THE PICTURE ends up at
--   (x, y).
--
--   For REFERENCE, the top-left corner of the screen is considered (0, 0) and
--   all coordinates are non-negative (i.e. coordinates increase left to right
--   and top to bottom).
move :: Int -> Float -> Float -> Float -> Float -> Picture -> Picture
move screenSideLength x y width height =
    Translate (-(fromIntegral screenSideLength / 2) + x + width / 2)
              ((fromIntegral screenSideLength / 2) - y - height / 2)

drawSolidRectangle :: Int -> Color -> Float -> Float -> Float -> Float -> Picture
drawSolidRectangle screenSideLength color x y width height =
      move screenSideLength x y width height
    $ Color color
    $ rectangleSolid width height
