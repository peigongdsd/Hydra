{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module Interface.Server ( app, warp ) where

import Yesod
    ( warp,
      RenderRoute(renderRoute),
      Yesod(defaultLayout, addStaticContent),
      Html,
      hamlet,
      julius,
      mkYesod,
      parseRoutes,
      ToWidget(toWidget),
      ToWidgetBody(toWidgetBody),
      ToWidgetHead(toWidgetHead) )
import Yesod.EmbeddedStatic
    ( embedStaticContent, mkEmbeddedStatic, embedDir, EmbeddedStatic )

import Interface.CmdLineUI

mkEmbeddedStatic False "nodeModules" [embedDir "./src/Interface/node_modules/xterm"]

data ServerApp = ServerApp { getStatic :: EmbeddedStatic }

mkYesod "ServerApp" [parseRoutes|
/ HomeR GET
/static StaticR EmbeddedStatic getStatic
|]

instance Yesod ServerApp where
    addStaticContent = embedStaticContent getStatic StaticR Right

getHomeR :: Handler Html 
getHomeR = defaultLayout $ do
    toWidgetHead [hamlet|
        <link rel="stylesheet" href=@{StaticR css_xterm_css} />
        <script src="@{StaticR lib_xterm_js}">
    |]
    toWidgetBody [hamlet|
        <div id="terminal">
    |]
    toWidget [julius|
        var term=new Terminal();
        term.open(document.getElementById('terminal'));
        term.write('Hello from \x1B[1;3;31mxterm.js\x1B[0m $ ')
    |]

app :: ServerApp
app = ServerApp nodeModules
