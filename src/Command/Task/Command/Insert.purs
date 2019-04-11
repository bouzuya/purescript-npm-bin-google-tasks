module Command.Task.Command.Insert
  ( command
  ) where

import Prelude

import Command.Task.Client (Client)
import Command.Task.Client as Client
import Command.Task.Command.Insert.Options (Options)
import Command.Task.Command.Insert.Options as Options
import Command.Task.Response (Response)
import Command.Task.TaskResource (TaskResource, TaskResourceParams)
import Command.Task.TaskResource as TaskResource
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Array as Array
import Data.Either as Either
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class as Class
import Effect.Class.Console as Console
import Effect.Exception as Exception
import Foreign (Foreign)
import Simple.JSON as SimpleJSON

foreign import insertTaskImpl :: Foreign -> Client -> Effect (Promise Foreign)

type TaskInsertParams =
  { parent :: Maybe String
  , previous :: Maybe String
  , resource :: TaskResourceParams
  , tasklist :: String
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
      response <- insertTask (buildParams options resource) client
      liftEffect
        (Console.log (TaskResource.format options.format response.data))

insertTask :: TaskInsertParams -> Client -> Aff (Response TaskResource)
insertTask options client = do
  response <- Promise.toAffE (insertTaskImpl (SimpleJSON.write options) client)
  Class.liftEffect
    (Either.either (Exception.throw <<< show) pure (SimpleJSON.read response))

buildParams :: Options -> TaskResourceParams -> TaskInsertParams
buildParams options resource =
  { parent: options.parent
  , previous: options.previous
  , resource
  , tasklist: options.taskListId
  }
