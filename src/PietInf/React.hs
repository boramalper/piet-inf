module PietInf.React where

import           Data.Char

import           Graphics.Gloss.Interface.IO.Game

import           PietInf.Cell
import           PietInf.World


react :: Event -> World -> World
react (EventKey (Char '0') Up _ (_,_)) world = zoomOut world
react (EventKey (Char ch) Up _ (_,_)) world
    | '0' <= ch && ch <= '9' =
        let
            cellNo = digitToInt ch
            cell = findMergedCell world cellNo
        in
            if width cell == height cell then
                zoomIn world $ pathNo world cellNo
            else
                world
    | otherwise = world
react _ world = world
