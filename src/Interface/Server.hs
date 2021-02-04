{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module Interface.Server ( app ) where

import Yesod
import Yesod.EmbeddedStatic
    ( embedStaticContent, mkEmbeddedStatic, embedDir, EmbeddedStatic )

mkEmbeddedStatic False "nodeModules" [embedDir "./src/Interface/node_modules/xterm"]

data ServerApp = ServerApp { getStatic :: EmbeddedStatic }

mkYesod "ServerApp" [parseRoutes|
/ HomeR GET
/static StaticR EmbeddedStatic getStatic
|]

instance Yesod ServerApp where
    addStaticContent = embedStaticContent getStatic StaticR Right

getHomeR :: Handler Html 
getHomeR = defaultLayout $ 
    toWidgetHead [hamlet|
    <p>Hello!!
    <a href=@css_xterm_css> what?
    |]

app :: ServerApp
app = ServerApp nodeModules
