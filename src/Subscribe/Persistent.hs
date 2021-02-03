{-# LANGUAGE OverloadedStrings #-}
module Subscribe.Persistent(
    ProxyConfig(ProxyConfig, name, remoteAddr, remotePort, password),
    Persistent (Persistent, current, fallback),
    PerConf, defaultProxyConfig,
    update, rollback, get,
) where

import Data.IORef ( IORef )
import qualified Data.ByteString as B 
import Control.Exception ( throw )
import Global ( InternalError(Error) )

data ProxyConfig = ProxyConfig {
    name :: B.ByteString,
    remoteAddr :: B.ByteString,
    remotePort :: B.ByteString,
    password :: B.ByteString 
} deriving (Show) 

data Persistent a = Persistent {
    current :: Maybe a,
    fallback :: Maybe a
}

update :: a -> Persistent a -> Persistent a
update x (Persistent c _) = Persistent (Just x) c

rollback :: Persistent a -> Persistent a
rollback (Persistent _ x@(Just _)) = Persistent x Nothing
rollback (Persistent _ Nothing) = throw . Error $ "No previous profiles found to do fallback!!"

get :: Persistent a -> a
get (Persistent (Just x) _) = x
get (Persistent Nothing _) = throw . Error $ "No profiles to get, try refresh!!"

type PerConf = IORef (Persistent [ProxyConfig])
defaultProxyConfig :: ProxyConfig
defaultProxyConfig = ProxyConfig "DefaultName" "DefaultAddr" "DefaultPort" "DefaultPassword" 

