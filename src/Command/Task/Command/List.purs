module Command.Task.Command.List
  ( command
  ) where

import Prelude

import Command.Task.Client (Client)
import Command.Task.Client as Client
import Command.Task.Command.List.Options as Options
import Command.Task.Response (Response)
import Command.Task.TaskResource (TaskResource)
import Command.Task.TaskResource as TaskResource
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
import Record as Record
import Simple.JSON as SimpleJSON

foreign import listTasksImpl :: Foreign -> Client -> Effect (Promise Foreign)

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

command :: Array String -> Effect Unit
command args = do
  { options } <-
    Either.either Exception.throw pure (Options.parse args)
  if options.help
    then Console.log Options.help
    else Aff.launchAff_ do
      client <- liftEffect (Client.newClient ".") -- FIXME
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
        (Effect.foreachE
          tasks
          (Console.log <<< (TaskResource.format options.format)))

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
