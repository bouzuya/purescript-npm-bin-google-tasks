module Command.Task.Command.List
  ( command
  ) where

import Prelude

import Command.Task.Command.List.Options as Options
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Either as Either
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect as Effect
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Effect.Exception as Exception
import Foreign (Foreign)
import Foreign.Object (Object)
import Node.Encoding as Encoding
import Node.FS.Sync as FS
import Node.Path as Path
import Simple.JSON (E)
import Simple.JSON as SimpleJSON

foreign import data Client :: Type
foreign import listTasksImpl ::
  forall r. { | r } -> Client -> Effect (Promise Foreign)
foreign import newClientImpl :: String -> String -> Effect Client

type Response a =
  { config :: {} -- FIXME
  , data :: a
  , headers :: Object String
  , status :: Int
  , statusText :: String
  }

type TaskListResponse =
  { etag :: String
  , items :: Array TaskResource
  , kind :: String -- "tasks#tasks"
  , nextPageToken :: Maybe String
  }

-- TODO
type TaskResource =
  { kind :: String -- "tasks#task"
  , id :: String
  , etag :: String
  , title :: String
  -- TODO
  }

command :: Array String -> Effect Unit
command args = do
  { options } <-
    Either.either Exception.throw pure (Options.parse args)
  if options.help
    then Console.log Options.help
    else Aff.launchAff_ do
      client <- liftEffect (newClient ".") -- FIXME
      responseEither <-
        listTasks
          { showCompleted: false
          , tasklist: options.taskListId
          }
          client
      response <-
        Either.either
          (liftEffect <<< Exception.throw <<< show)
          pure
          responseEither
      liftEffect
        (Effect.foreachE response.data.items \item -> do
          Console.log (item.title <> " " <> item.id))

listTasks :: forall r. { | r } -> Client -> Aff (E (Response TaskListResponse))
listTasks options client = do
  response <- Promise.toAffE (listTasksImpl options client)
  pure (SimpleJSON.read response)

newClient :: String -> Effect Client
newClient dir = do
  credentials <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "credentials.json"])
  token <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "token.json"])
  newClientImpl credentials token
