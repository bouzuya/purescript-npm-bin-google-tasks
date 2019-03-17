module Options
  ( Options
  , help
  , parse
  ) where

import Bouzuya.CommandLineOption as CommandLineOption
import Data.Array as Array
import Data.Either (Either)
import Data.Maybe (Maybe(..))

type Options =
  { help :: Boolean
  }

help :: String
help =
  Array.intercalate
    "\n"
    [ "Usage: google-tasks [options] <command>"
    , ""
    , "Commands:"
    , ""
    , "  help display help"
    , ""
    , "Options:"
    , ""
    , "  -h,--help display help"
    , ""
    ]

parse ::
  Array String
  -> Either String { arguments :: Array String, options ::  Options }
parse =
  CommandLineOption.parseWithOptions
    { greedyArguments: true }
    { help: CommandLineOption.booleanOption "help" (Just 'h') "display help" }
