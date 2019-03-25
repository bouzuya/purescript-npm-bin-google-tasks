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
  { completedMax :: Maybe String
  , completedMin :: Maybe String
  , dueMax :: Maybe String
  , dueMin :: Maybe String
  , format :: Maybe String
  , help :: Boolean
  , showCompleted :: Boolean
  , showDeleted :: Boolean
  , showHidden :: Boolean
  , taskListId :: String
  , updatedMin :: Maybe String
  }

help :: String
help =
  Array.intercalate
    "\n"
    [ "Usage: google-tasks task list [options]"
    , ""
    , "Options:"
    , ""
    , "  --completed-max <DATETIME> completed max"
    , "  --completed-min <DATETIME> completed min"
    , "  --due-max <DATETIME>       due max"
    , "  --due-max <DATETIME>       due min"
    , "  --format <FORMAT>          format"
    , "  -h,--help                  display help"
    , "  --show-completed           show completed"
    , "  --show-deleted             show deleted"
    , "  --show-hidden              show hidden"
    , "  --task-list-id <ID>        TaskList id"
    , "  --updated-min <DATETIME>   updated min"
    , ""
    ]

parse ::
  Array String
  -> Either String { arguments :: Array String, options ::  Options }
parse =
  CommandLineOption.parse
    { completedMax:
        CommandLineOption.maybeStringOption
          "completed-max" Nothing "<DATETIME>" "completed max" Nothing
    , completedMin:
        CommandLineOption.maybeStringOption
          "completed-min" Nothing "<DATETIME>" "completed min" Nothing
    , dueMax:
        CommandLineOption.maybeStringOption
          "due-max" Nothing "<DATETIME>" "due max" Nothing
    , dueMin:
        CommandLineOption.maybeStringOption
          "due-min" Nothing "<DATETIME>" "due min" Nothing
    , format:
        CommandLineOption.maybeStringOption
          "format" Nothing "<FORMAT>" "format" Nothing
    , help:
        CommandLineOption.booleanOption "help" (Just 'h') "display help"
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
    , updatedMin:
        CommandLineOption.maybeStringOption
          "updated-min" Nothing "<DATETIME>" "updated min" Nothing
    }
