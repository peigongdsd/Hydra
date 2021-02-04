module Main where

import Interface.Server

main :: IO ()
main = warp 3000 app
