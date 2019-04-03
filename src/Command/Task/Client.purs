module Command.Task.Client
  ( Client
  , newClient
  ) where

import Prelude

import Effect (Effect)
import Node.Encoding as Encoding
import Node.FS.Sync as FS
import Node.Path as Path

foreign import data Client :: Type
foreign import newClientImpl :: String -> String -> Effect Client

newClient :: String -> Effect Client
newClient dir = do
  credentials <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "credentials.json"])
  token <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "token.json"])
  newClientImpl credentials token
