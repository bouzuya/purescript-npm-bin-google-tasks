module Command.Task.Command.List
  ( command
  ) where

import Prelude

import Command.Task.Client (TaskListParams)
import Command.Task.Client as Client
import Command.Task.Command.List.Options (Options)
import Command.Task.Command.List.Options as Options
import Command.Task.TaskResource as TaskResource
import Data.Either as Either
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect as Effect
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Effect.Exception as Exception

buildParams :: Options -> TaskListParams
buildParams options =
  { completedMax: options.completedMax
  , completedMin: options.completedMin
  , dueMax: options.dueMax
  , dueMin: options.dueMin
  , maxResults: Just 100
  , pageToken: Nothing
  , showCompleted: Just options.showCompleted
  , showDeleted: Just options.showDeleted
  , showHidden: Just options.showHidden
  , tasklist: options.taskListId
  , updatedMin: options.updatedMin
  }

command :: Array String -> Effect Unit
command args = do
  { options } <-
    Either.either Exception.throw pure (Options.parse args)
  if options.help
    then Console.log Options.help
    else Aff.launchAff_ do
      client <- liftEffect (Client.newClient ".") -- FIXME
      tasks <- Client.listAllTasks (buildParams options) client
      liftEffect
        (Effect.foreachE
          tasks
          (Console.log <<< (TaskResource.format options.format)))
