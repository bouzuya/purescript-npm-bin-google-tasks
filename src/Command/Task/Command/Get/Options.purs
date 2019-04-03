module Command.Task.Command.Get.Options
  ( Options
  , help
  , parse
  ) where

import Bouzuya.CommandLineOption as CommandLineOption
import Data.Array as Array
import Data.Either (Either)
import Data.Maybe (Maybe(..))

type Options =
  { format :: Maybe String
  , help :: Boolean
  , taskId :: String
  , taskListId :: String
  }

help :: String
help =
  Array.intercalate
    "\n"
    [ "Usage: google-tasks task get [options]"
    , ""
    , "Options:"
    , ""
    , "  --format <FORMAT>   format"
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
    { format:
        CommandLineOption.maybeStringOption
          "format" Nothing "<FORMAT>" "format" Nothing
    , help:
        CommandLineOption.booleanOption "help" (Just 'h') "display help"
    , taskId:
        CommandLineOption.stringOption
          "task-id" Nothing "<ID>" "Task id" ""
    , taskListId:
        CommandLineOption.stringOption
          "task-list-id" Nothing "<ID>" "TaskList id" ""
    }
