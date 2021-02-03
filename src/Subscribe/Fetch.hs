{-# LANGUAGE OverloadedStrings #-}
module Subscribe.Fetch(
    getSubsLinks,
    splitSubsLinks,
    readSubsLink,
    genConfigJson
) where

import Global ( InternalError(Error) )

import Subscribe.Vars ( defConfig, subsURL )
import Subscribe.Persistent
    ( ProxyConfig(..), defaultProxyConfig )
import Control.Exception ( throw )

import Network.HTTP.Conduit ( simpleHttp )
import qualified Data.ByteString as B 
import qualified Data.ByteString.Lazy as BZ
import qualified Data.ByteString.Base64 as Base64

import Data.Functor ( (<&>) )
import Data.Either ( fromRight )
import Data.String ( fromString )

import Text.Regex.TDFA ( (=~) )

type BSMatch = (B.ByteString, B.ByteString, B.ByteString)

getSubsLinks :: IO B.ByteString 
getSubsLinks = (simpleHttp :: String -> IO BZ.ByteString) subsURL <&>
    (fromRight (throw $ Error "Error decoding subscribe string!") . Base64.decode . BZ.toStrict)

splitSubsLinks :: B.ByteString -> [B.ByteString]
splitSubsLinks "" = []
splitSubsLinks "\r\n" = []
splitSubsLinks s = if pre =~ ("^(\r\n)?$" :: String) then match : splitSubsLinks next else
    throw $ Error "Invalid decoded subscribe string!" where
    (pre, match, next) = (s =~ ("trojan://.*?(?=\r\n)" :: String)) :: BSMatch

readSubsLink :: B.ByteString -> ProxyConfig
readSubsLink s 
    | pre0 /= "trojan://" = err
    | pre1 /= "@" = err
    | pre2 /= ":" = err
    | otherwise = defaultProxyConfig { name = name, 
        remoteAddr = addr, 
        remotePort = port,
        password = pass } 
        where
            (pre0, pass, next0) = (s =~ ("(?<=^trojan://).*?(?=@)" :: String)) :: BSMatch
            (pre1, addr, next1) = (next0 =~ ("(?<=^@).*?(?=:)" :: String)) :: BSMatch
            (pre2, port, next2) = (next1 =~ ("(?<=^:)[0-9]*?(?=#)" :: String)) :: BSMatch
            (pre3, name, _) = (next2 =~ ("(?<=^#).*$" :: String)) :: BSMatch
            err = throw $ Error "Invalid trojan config url!"

bsDefConfig :: B.ByteString
bsDefConfig = fromString defConfig :: B.ByteString
next0 :: B.ByteString
preAddr :: B.ByteString
(preAddr, _, next0) = (bsDefConfig =~ ("__REMOTE_ADDR__" :: String)) :: BSMatch
prePort :: B.ByteString
next1 :: B.ByteString
(prePort, _, next1) = (next0 =~ ("__REMOTE_PORT__" :: String)) :: BSMatch
prePass :: B.ByteString
next2 :: B.ByteString
(prePass, _, next2) = (next1 =~ ("__PASSWORD__" :: String)) :: BSMatch

genConfigJson :: ProxyConfig -> B.ByteString 
genConfigJson (ProxyConfig _ addr port pass) = foldr B.append B.empty  
    [preAddr, addr, prePort, port, prePass, pass, next2]



