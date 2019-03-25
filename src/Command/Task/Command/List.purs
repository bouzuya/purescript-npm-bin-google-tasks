module Command.Task.Command.List
  ( command
  ) where

import Prelude

import Command.Task.Command.List.Options as Options
import Control.Monad.Rec.Class as MonadRec
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Either as Either
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect as Effect
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
import Record as Record
import Simple.JSON as SimpleJSON

foreign import data Client :: Type
foreign import listTasksImpl :: Foreign -> Client -> Effect (Promise Foreign)
foreign import newClientImpl :: String -> String -> Effect Client

type Response a =
  { config :: {} -- FIXME
  , data :: a
  , headers :: Object String
  , status :: Int
  , statusText :: String
  }

type TaskListParams =
  { completedMax :: Maybe String
  , completedMin :: Maybe String
  , dueMax :: Maybe String
  , dueMin :: Maybe String
  , maxResults :: Maybe Int
  , pageToken :: Maybe String
  , showCompleted :: Maybe Boolean
  , showDeleted :: Maybe Boolean
  , showHidden :: Maybe Boolean
  , tasklist :: String
  , updatedMin :: Maybe String
  }

type TaskListResponse =
  { etag :: String
  , items :: Array TaskResource
  , kind :: String -- "tasks#tasks"
  , nextPageToken :: Maybe String
  }

type TaskResource =
  { completed :: Maybe String -- datetime,
  , deleted :: Maybe Boolean
  , due :: Maybe String -- datetime,
  , etag :: String
  , hidden :: Maybe Boolean
  , id :: String
  , kind :: String -- "tasks#task"
  , links ::
      Maybe
        (Array
          { type :: String
          , description :: String
          , link :: String
          })
  , notes :: Maybe String
  , parent :: Maybe String
  , position :: String
  , selfLink :: String
  , status :: String
  , title :: String
  , updated :: String -- datetime,
  }

command :: Array String -> Effect Unit
command args = do
  { options } <-
    Either.either Exception.throw pure (Options.parse args)
  if options.help
    then Console.log Options.help
    else Aff.launchAff_ do
      client <- liftEffect (newClient ".") -- FIXME
      tasks <-
        listAllTasks
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
          client
      liftEffect
        (Effect.foreachE tasks \task -> do
          Console.log (task.title <> " " <> task.id))

listAllTasks :: TaskListParams -> Client -> Aff (Array TaskResource)
listAllTasks options client =
  MonadRec.tailRecM go { pageToken: Nothing, tasks: [] }
  where
    go { pageToken, tasks } = do
      { data: { items, nextPageToken } } <-
        listTasks (Record.merge { pageToken } options) client
      let tasks' = tasks <> items
      pure
        (case nextPageToken of
          Nothing ->
            MonadRec.Done tasks'
          Just _ ->
            MonadRec.Loop { pageToken: nextPageToken, tasks: tasks' })

listTasks :: TaskListParams -> Client -> Aff (Response TaskListResponse)
listTasks options client = do
  response <- Promise.toAffE (listTasksImpl (SimpleJSON.write options) client)
  Class.liftEffect
    (Either.either (Exception.throw <<< show) pure (SimpleJSON.read response))

newClient :: String -> Effect Client
newClient dir = do
  credentials <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "credentials.json"])
  token <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "token.json"])
  newClientImpl credentials token
