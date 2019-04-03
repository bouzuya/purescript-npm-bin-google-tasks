module Command.Task.Command.Get
  ( command
  ) where

import Prelude

import Command.Task.Command.Get.Options as Options
import Command.Task.TaskResource (TaskResource)
import Command.Task.TaskResource as TaskResource
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Either as Either
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class as Class
import Effect.Class.Console as Console
import Effect.Exception as Exception
import Foreign (Foreign)
import Foreign.Object (Object)
import Node.Encoding as Encoding
import Node.FS.Sync as FS
import Node.Path as Path
import Simple.JSON as SimpleJSON

foreign import data Client :: Type
foreign import getTaskImpl :: Foreign -> Client -> Effect (Promise Foreign)
foreign import newClientImpl :: String -> String -> Effect Client

type Response a =
  { config :: {} -- FIXME
  , data :: a
  , headers :: Object String
  , status :: Int
  , statusText :: String
  }

type TaskParams =
  { task :: String
  , tasklist :: String
  }

command :: Array String -> Effect Unit
command args = do
  { options } <-
    Either.either Exception.throw pure (Options.parse args)
  if options.help
    then Console.log Options.help
    else Aff.launchAff_ do
      client <- liftEffect (newClient ".") -- FIXME
      response <-
        getTask
          { task: options.taskId
          , tasklist: options.taskListId
          }
          client
      liftEffect
        (Console.log (TaskResource.format options.format response.data))

getTask :: TaskParams -> Client -> Aff (Response TaskResource)
getTask options client = do
  response <- Promise.toAffE (getTaskImpl (SimpleJSON.write options) client)
  Class.liftEffect
    (Either.either (Exception.throw <<< show) pure (SimpleJSON.read response))

newClient :: String -> Effect Client
newClient dir = do
  credentials <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "credentials.json"])
  token <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "token.json"])
  newClientImpl credentials token
