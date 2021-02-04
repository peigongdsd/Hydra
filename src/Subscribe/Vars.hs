{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}

module Subscribe.Vars(
    ProxyConfig(..),
    defaultProxyConfig,
    subsURL,
    defConfig
) where

import GHC.Generics
import qualified Data.ByteString as B 
import qualified Data.ByteString.Lazy as BZ
import Text.RawString.QQ ( r )

data ProxyConfig = ProxyConfig {
    name :: B.ByteString,
    remoteAddr :: B.ByteString,
    remotePort :: B.ByteString,
    password :: B.ByteString,
    localPort :: Int,
    localAddr :: B.ByteString,
    logLevel :: Int
} deriving ( Show ) 

defaultProxyConfig :: ProxyConfig
defaultProxyConfig = undefined

subsURL :: String 
subsURL = "https://s.trojanflare.com/subscription/shadowrocket/73f4af2f-a14f-413c-9382-5b0bb3cde889"

defConfig :: String 
defConfig = [r|{
    "run_type": "client",
    "local_addr": "127.0.0.1",
    "local_port": 1080,
    "remote_addr": "__REMOTE_ADDR__",
    "remote_port": __REMOTE_PORT__,
    "password": [
        "__PASSWORD__"
    ],
    "log_level": 1,https://prod.liveshare.vsengsaas.visualstudio.com/join?AD034C4A1629BD3D3F57BAB02C4E42087A01
    "ssl": {
        "verify": true,
        "verify_hostname": true,
        "cert": "",
        "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:AES128-SHA:AES256-SHA:DES-CBC3-SHA",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "sni": "",
        "alpn": [
            "h2",
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": false,
        "curves": ""
    },
    "tcp": {
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": false,
        "fast_open_qlen": 20
    }
}|]
