module Options
  ( Options
  , parse
  ) where

import Bouzuya.CommandLineOption as CommandLineOption
import Data.Either (Either)
import Data.Maybe (Maybe(..))

type Options =
  { help :: Boolean
  }

parse ::
  Array String
  -> Either String { arguments :: Array String, options ::  Options }
parse =
  CommandLineOption.parseWithOptions
    { greedyArguments: true }
    { help: CommandLineOption.booleanOption "help" (Just 'h') "display help" }
