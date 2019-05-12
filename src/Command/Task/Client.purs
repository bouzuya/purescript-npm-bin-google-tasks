module Command.Task.Client
  ( Client
  , TaskDeleteParams
  , TaskGetParams
  , TaskInsertParams
  , TaskListParams
  , TaskListResponse
  , TaskUpdateParams
  , deleteTask
  , getTask
  , insertTask
  , listAllTasks
  , listTasks
  , newClient
  , updateTask
  ) where

import Prelude

import Command.Task.Response (Response)
import Command.Task.TaskResource (TaskResource, TaskResourceParams)
import Control.Monad.Rec.Class as MonadRec
import Control.Promise (Promise)
import Control.Promise as Promise
import Data.Either as Either
import Data.Maybe (Maybe)
import Data.Maybe as Maybe
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class as Class
import Effect.Exception as Exception
import Foreign (Foreign)
import Node.Encoding as Encoding
import Node.FS.Sync as FS
import Node.Path as Path
import Record as Record
import Simple.JSON (class ReadForeign, class WriteForeign)
import Simple.JSON as SimpleJSON

foreign import data Client :: Type
foreign import executeCommandImpl ::
  String -> Foreign -> Client -> Effect (Promise Foreign)
foreign import newClientImpl :: String -> String -> Effect Client

type TaskDeleteParams =
  { task :: String
  , tasklist :: String
  }

type TaskGetParams =
  { task :: String
  , tasklist :: String
  }

type TaskInsertParams =
  { parent :: Maybe String
  , previous :: Maybe String
  , resource :: TaskResourceParams
  , tasklist :: String
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

type TaskUpdateParams =
  { task :: String
  , resource :: TaskResourceParams
  , tasklist :: String
  }

executeCommand ::
  forall a b. ReadForeign b => WriteForeign a => String -> a -> Client -> Aff b
executeCommand command options client = do
  response <-
    Promise.toAffE
      (executeCommandImpl command (SimpleJSON.write options) client)
  Class.liftEffect
    (Either.either (Exception.throw <<< show) pure (SimpleJSON.read response))

deleteTask :: TaskDeleteParams -> Client -> Aff (Response (Maybe {}))
deleteTask = executeCommand "delete"

getTask :: TaskGetParams -> Client -> Aff (Response TaskResource)
getTask = executeCommand "get"

insertTask :: TaskInsertParams -> Client -> Aff (Response TaskResource)
insertTask = executeCommand "insert"

listAllTasks :: TaskListParams -> Client -> Aff (Array TaskResource)
listAllTasks options client =
  MonadRec.tailRecM go { pageToken: Maybe.Nothing, tasks: [] }
  where
    go { pageToken, tasks } = do
      { data: { items, nextPageToken } } <-
        listTasks (Record.merge { pageToken } options) client
      let tasks' = tasks <> items
      pure
        (case nextPageToken of
          Maybe.Nothing ->
            MonadRec.Done tasks'
          Maybe.Just _ ->
            MonadRec.Loop { pageToken: nextPageToken, tasks: tasks' })

listTasks :: TaskListParams -> Client -> Aff (Response TaskListResponse)
listTasks = executeCommand "list"

updateTask :: TaskUpdateParams -> Client -> Aff (Response TaskResource)
updateTask = executeCommand "update"

newClient :: String -> Effect Client
newClient dir = do
  credentials <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "credentials.json"])
  token <-
    FS.readTextFile Encoding.UTF8 (Path.concat [dir, "token.json"])
  newClientImpl credentials token
