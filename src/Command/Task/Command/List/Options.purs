module Command.Task.Command.List.Options
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
  , showCompleted :: Boolean
  , showDeleted :: Boolean
  , showHidden :: Boolean
  , taskListId :: String
  }

help :: String
help =
  Array.intercalate
    "\n"
    [ "Usage: google-tasks task list [options]"
    , ""
    , "Options:"
    , ""
    , "  -h,--help           display help"
    , "  --show-completed    show completed"
    , "  --show-deleted      show deleted"
    , "  --show-hidden       show hidden"
    , "  --task-list-id <ID> TaskList id"
    , ""
    ]

parse ::
  Array String
  -> Either String { arguments :: Array String, options ::  Options }
parse =
  CommandLineOption.parse
    { help: CommandLineOption.booleanOption "help" (Just 'h') "display help"
    , showCompleted:
        CommandLineOption.booleanOption
          "show-completed" Nothing "show completed"
    , showDeleted:
        CommandLineOption.booleanOption
          "show-deleted" Nothing "show deleted"
    , showHidden:
        CommandLineOption.booleanOption
          "show-hidden" Nothing "show hidden"
    , taskListId:
        CommandLineOption.stringOption
          "task-list-id" Nothing "<ID>" "TaskList id" ""
    }
