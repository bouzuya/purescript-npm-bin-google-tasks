module Command.Task.Options
  ( Options
  , help
  , parse
  ) where

import Bouzuya.CommandLineOption as CommandLineOption
import Data.Either (Either)
import Data.Maybe (Maybe(..))
import Data.String as String

type Options =
  { help :: Boolean
  }

help :: String
help =
  String.joinWith
    "\n"
    [ "Usage: google-tasks task [options] <command>"
    , ""
    , "Commands:"
    , ""
    , "  delete    delete a task"
    , "  get       get a task"
    , "  help      display help"
    , "  insert    insert a task"
    , "  list      list tasks"
    , "  update    update a task"
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
