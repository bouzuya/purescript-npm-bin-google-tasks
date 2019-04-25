module Command.Task.Command.Delete
  ( command
  ) where

import Prelude

import Command.Task.Client (TaskDeleteParams)
import Command.Task.Client as Client
import Command.Task.Command.Get.Options (Options)
import Command.Task.Command.Get.Options as Options
import Data.Either as Either
import Effect (Effect)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Effect.Exception as Exception

buildParams :: Options -> TaskDeleteParams
buildParams options =
  { task: options.taskId
  , tasklist: options.taskListId
  }

command :: Array String -> Effect Unit
command args = do
  { options } <-
    Either.either Exception.throw pure (Options.parse args)
  if options.help
    then Console.log Options.help
    else Aff.launchAff_ do
      client <- liftEffect (Client.newClient ".") -- FIXME
      _ <- Client.deleteTask (buildParams options) client
      liftEffect (Console.log "deleted")
