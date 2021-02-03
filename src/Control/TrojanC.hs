module Control.TrojanC () where

import Global
import Control.Vars ( trojanPath, configPath )
import System.Process
    ( createProcess, proc, terminateProcess, ProcessHandle )

startTrojan :: IO ProcessHandle 
startTrojan = (\(_, _, _, h) -> h) <$> createProcess (proc trojanPath ["-c", configPath])

stopTrojan :: ProcessHandle -> IO ()
stopTrojan = terminateProcess





