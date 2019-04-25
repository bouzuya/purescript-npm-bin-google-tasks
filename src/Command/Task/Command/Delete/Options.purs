module Command.Task.Command.Delete.Options
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
  , taskId :: String
  , taskListId :: String
  }

help :: String
help =
  Array.intercalate
    "\n"
    [ "Usage: google-tasks task delete [options]"
    , ""
    , "Options:"
    , ""
    , "  -h,--help           display help"
    , "  --task-id <ID>      Task id"
    , "  --task-list-id <ID> TaskList id"
    , ""
    ]

parse ::
  Array String
  -> Either String { arguments :: Array String, options ::  Options }
parse =
  CommandLineOption.parse
    { help:
        CommandLineOption.booleanOption "help" (Just 'h') "display help"
    , taskId:
        CommandLineOption.stringOption
          "task-id" Nothing "<ID>" "Task id" ""
    , taskListId:
        CommandLineOption.stringOption
          "task-list-id" Nothing "<ID>" "TaskList id" ""
    }
