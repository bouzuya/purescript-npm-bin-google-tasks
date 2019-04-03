module Command.Task.Response
  ( Response
  ) where

import Foreign.Object (Object)

type Response a =
  { config :: {} -- FIXME
  , data :: a
  , headers :: Object String
  , status :: Int
  , statusText :: String
  }

