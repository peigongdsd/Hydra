{-# LANGUAGE OverloadedStrings #-}
module Subscribe.Fetch(
    ProxyConfig(..),
    getSubsLinks,
    splitSubsLinks,
    readSubsLink,
    genConfigJson
) where

import Global ( InternalError(Error) )

import Subscribe.Vars ( defConfig, subsURL, ProxyConfig(..) )
import Subscribe.Persistent
    ( Persistent(..) )
import Control.Exception ( throw )

import Data.IORef ( IORef )
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

lineBreak :: String 
lineBreak = "(\r)?\n"

-- Just split by Lines!! No check!!
splitSubsLinks :: B.ByteString -> [B.ByteString] 
splitSubsLinks "" = []
splitSubsLinks s = if B.null scheme then next else scheme : next where
    (scheme, break, nextScheme) = (s =~ lineBreak) :: (B.ByteString, B.ByteString, B.ByteString)
    next = splitSubsLinks nextScheme

{-
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
-}

-- s in a scheme of something like "trojan://[a-zA-Z]*@domain:port#comment"
-- here we have checks for url
readSubsLink :: B.ByteString -> ProxyConfig -> ProxyConfig 
readSubsLink s c = if check then c {name = comment, remoteAddr = addr, remotePort = port, password = pass} else
        throw . Error $ "Error in subscribe link!!" where
    (pre0, urlScheme, urlContent) = (s =~ ("trojan://" :: String)) :: (B.ByteString, B.ByteString, B.ByteString)
    (pass, at, s') = (urlContent =~ ("@" :: String)) :: (B.ByteString, B.ByteString, B.ByteString)
    (addr, colon, s'') = (s' =~ (":" :: String)) :: (B.ByteString, B.ByteString, B.ByteString)
    (port, hash, comment) = (s'' =~ ("#" :: String)) :: (B.ByteString, B.ByteString, B.ByteString)
    check = not $ B.null urlScheme || B.null at || B.null colon || B.null hash

genConfigJson :: ProxyConfig -> B.ByteString
genConfigJson = undefined

{-
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
-}

