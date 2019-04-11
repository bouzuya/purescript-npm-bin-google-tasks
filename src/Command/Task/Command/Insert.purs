module Command.Task.Command.Insert
  ( command
  ) where

import Prelude

import Command.Task.Client (TaskInsertParams)
import Command.Task.Client as Client
import Command.Task.Command.Insert.Options (Options)
import Command.Task.Command.Insert.Options as Options
import Command.Task.TaskResource (TaskResourceParams)
import Command.Task.TaskResource as TaskResource
import Data.Array as Array
import Data.Either as Either
import Effect (Effect)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Effect.Exception as Exception
import Simple.JSON as SimpleJSON

buildParams :: Options -> TaskResourceParams -> TaskInsertParams
buildParams options resource =
  { parent: options.parent
  , previous: options.previous
  , resource
  , tasklist: options.taskListId
  }

command :: Array String -> Effect Unit
command args = do
  { arguments, options } <-
    Either.either Exception.throw pure (Options.parse args)
  resource <-
    Either.either
      Exception.throw
      pure
      do
        jsonText <- Either.note "resource is required" (Array.head arguments)
        Either.either
          (Either.Left <<< show)
          Either.Right
          (SimpleJSON.readJSON jsonText)
  if options.help
    then Console.log Options.help
    else Aff.launchAff_ do
      client <- liftEffect (Client.newClient ".") -- FIXME
      response <- Client.insertTask (buildParams options resource) client
      liftEffect
        (Console.log (TaskResource.format options.format response.data))
