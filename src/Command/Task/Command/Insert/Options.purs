module Command.Task.Command.Insert.Options
  ( Options
  , help
  , parse
  ) where

import Bouzuya.CommandLineOption as CommandLineOption
import Data.Either (Either)
import Data.Maybe (Maybe(..))
import Data.String as String

type Options =
  { format :: Maybe String
  , help :: Boolean
  , parent :: Maybe String
  , previous :: Maybe String
  , taskListId :: String
  }

help :: String
help =
  String.joinWith
    "\n"
    [ "Usage: google-tasks task insert [options] <RESOURCE>"
    , ""
    , "Options:"
    , ""
    , "  --format <FORMAT>   format"
    , "  -h,--help           display help"
    , "  --parent <ID>       parent task id"
    , "  --previous <ID>     previous task id"
    , "  --task-list-id <ID> TaskList id"
    , ""
    ]

parse ::
  Array String
  -> Either String { arguments :: Array String, options ::  Options }
parse =
  CommandLineOption.parse
    { format:
        CommandLineOption.maybeStringOption
          "format" Nothing "<FORMAT>" "format" Nothing
    , help:
        CommandLineOption.booleanOption "help" (Just 'h') "display help"
    , parent:
        CommandLineOption.maybeStringOption
          "parent" Nothing "<ID>" "parent task id" Nothing
    , previous:
        CommandLineOption.maybeStringOption
          "previous" Nothing "<ID>" "previous task id" Nothing
    , taskListId:
        CommandLineOption.stringOption
          "task-list-id" Nothing "<ID>" "TaskList id" ""
    }
